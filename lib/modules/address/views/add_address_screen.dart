import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/maps/address_search_view.dart';
import '../../../core/theme/app_theme.dart';
import '../blocs/address_bloc.dart';
import '../blocs/address_event.dart';
import '../models/delivery_address.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({
    super.key,
    this.existingAddress,
    this.startWithCurrentLocation = false,
  });

  final DeliveryAddress? existingAddress;
  final bool startWithCurrentLocation;

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  static const _fallbackCenter = LatLng(11.5564, 104.9282); // Phnom Penh
  static const _defaultZoom = 17.0;
  static const _minZoom = 4.0;
  static const _maxZoom = 19.5;

  final TextEditingController _searchCtrl = TextEditingController();
  GoogleMapController? _mapController;
  LatLng? _selectedCenter;
  String _resolvedAddress = '';
  bool _isLocating = false;
  bool _isResolvingAddress = false;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  AddressLabel _label = AddressLabel.other;
  bool _isDefault = true;

  LatLng get _mapCenter => _selectedCenter ?? _fallbackCenter;
  bool get _hasLocation => _selectedCenter != null;
  bool get _canSave =>
      _hasLocation &&
      _nameCtrl.text.trim().isNotEmpty &&
      _phoneCtrl.text.trim().isNotEmpty &&
      _resolvedAddress.isNotEmpty;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingAddress;
    if (existing != null) {
      _nameCtrl.text = existing.nameAddress;
      _phoneCtrl.text = existing.phoneNumber;
      _label = existing.label;
      _isDefault = existing.isDefault;
      _selectedCenter = LatLng(existing.latitude, existing.longitude);
      _resolvedAddress = existing.address;
    } else if (widget.startWithCurrentLocation) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _useCurrentLocation(),
      );
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ── location ──────────────────────────────────────────────────────────────

  Future<void> _useCurrentLocation() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);

    LatLng? center;
    String? warning;

    try {
      final pos = await _determinePosition();
      center = LatLng(pos.latitude, pos.longitude);
    } catch (e) {
      warning = _friendlyError(e);
      debugPrint('Could not get current location: $e');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }

    if (!mounted) return;

    if (center != null) {
      setState(() => _selectedCenter = center);
      await _moveCamera(center);
      await _resolveAddress(center);
    } else {
      await _moveCamera(_selectedCenter ?? _fallbackCenter);
    }

    if (warning != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$warning Tap the map to select your address.')),
      );
    }
  }

  Future<Position> _determinePosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) throw _LocationException('Location service is disabled.');

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied)
      throw _LocationException('Location permission denied.');
    if (perm == LocationPermission.deniedForever) {
      throw _LocationException('Location permission permanently denied.');
    }
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
    } on TimeoutException {
      final lastKnown = await _lastKnownPosition();
      if (lastKnown != null) return lastKnown;
      throw _LocationException(
        'Location timed out. Please make sure GPS is on.',
      );
    } catch (_) {
      final lastKnown = await _lastKnownPosition();
      if (lastKnown != null) return lastKnown;
      rethrow;
    }
  }

  Future<Position?> _lastKnownPosition() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position == null) return null;

      final timestamp = position.timestamp;
      final age = DateTime.now().difference(timestamp).abs();
      if (age > const Duration(minutes: 10)) return null;

      return position;
    } catch (_) {
      return null;
    }
  }

  String _friendlyError(Object e) {
    if (e is _LocationException) return e.message;
    return 'Unable to detect location.';
  }

  // ── map helpers ───────────────────────────────────────────────────────────

  void _onMapCreated(GoogleMapController ctrl) {
    _mapController = ctrl;
    if (_selectedCenter != null) {
      _moveCamera(_selectedCenter!);
    }
  }

  Future<void> _moveCamera(LatLng pos, {double zoom = _defaultZoom}) async {
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: pos, zoom: zoom)),
    );
  }

  Future<void> _onMapTapped(LatLng pos) async {
    setState(() => _selectedCenter = pos);
    await _resolveAddress(pos);
  }

  Future<void> _onMarkerDragEnd(LatLng pos) async {
    setState(() => _selectedCenter = pos);
    await _resolveAddress(pos);
  }

  Future<void> _zoomMap(double delta) async {
    final ctrl = _mapController;
    if (ctrl == null) return;
    final current = await ctrl.getZoomLevel();
    final next = (current + delta).clamp(_minZoom, _maxZoom).toDouble();
    await ctrl.animateCamera(CameraUpdate.zoomTo(next));
  }

  Future<void> _openAddressSearch() async {
    final selection = await Navigator.of(context).push<AddressSearchSelection>(
      MaterialPageRoute(
        builder: (_) => AddressSearchView(
          initialQuery: _searchCtrl.text,
          origin: _mapCenter,
        ),
      ),
    );

    if (selection == null || !mounted) return;

    final resolved = selection.address.trim();
    setState(() {
      _searchCtrl.text = selection.searchText;
      _selectedCenter = selection.location;
      _resolvedAddress = resolved.isEmpty
          ? _latLngFallback(selection.location)
          : resolved;
    });
    await _moveCamera(selection.location);
    if (resolved.isEmpty) {
      await _resolveAddress(selection.location);
    }
  }

  Future<void> _resolveAddress(LatLng pos) async {
    if (!mounted) return;
    setState(() => _isResolvingAddress = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      final place = placemarks.isEmpty ? null : placemarks.first;
      if (!mounted) return;
      setState(() => _resolvedAddress = _formatPlacemark(place, pos));
    } catch (_) {
      if (!mounted) return;
      setState(() => _resolvedAddress = _latLngFallback(pos));
    } finally {
      if (mounted) setState(() => _isResolvingAddress = false);
    }
  }

  String _formatPlacemark(Placemark? place, LatLng pos) {
    if (place == null) return _latLngFallback(pos);
    final parts = [
      place.street ?? '',
      place.subLocality ?? '',
      place.locality ?? '',
      place.administrativeArea ?? '',
      place.country ?? '',
    ];
    final unique = <String>[];
    for (final p in parts) {
      final t = p.trim();
      if (t.isNotEmpty && !unique.contains(t)) unique.add(t);
    }
    return unique.isEmpty ? _latLngFallback(pos) : unique.join(', ');
  }

  String _latLngFallback(LatLng pos) =>
      'Lat ${pos.latitude.toStringAsFixed(6)}, Lng ${pos.longitude.toStringAsFixed(6)}';

  // ── save ──────────────────────────────────────────────────────────────────

  void _save() {
    if (!_canSave) return;
    final center = _selectedCenter!;
    final existing = widget.existingAddress;
    final address = DeliveryAddress(
      id: existing?.id ?? const Uuid().v4(),
      nameAddress: _nameCtrl.text.trim(),
      address: _resolvedAddress,
      phoneNumber: _phoneCtrl.text.trim(),
      label: _label,
      isDefault: _isDefault,
      latitude: center.latitude,
      longitude: center.longitude,
    );
    final bloc = context.read<AddressBloc>();
    if (existing != null) {
      bloc.add(UpdateAddress(address));
    } else {
      bloc.add(AddAddress(address));
    }
    Navigator.of(context).pop();
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingAddress != null;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 22,
            color: Colors.black87,
          ),
        ),
        title: Text(
          isEditing ? 'Edit address' : 'Add address',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1D1B24),
          ),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildSaveBar(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // ── Map (always visible) ──────────────────────────────────────────
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.42,
          child: Stack(
            children: [
              Positioned.fill(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _mapCenter,
                    zoom: _defaultZoom,
                  ),
                  minMaxZoomPreference: const MinMaxZoomPreference(
                    _minZoom,
                    _maxZoom,
                  ),
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  tiltGesturesEnabled: false,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  onMapCreated: _onMapCreated,
                  onTap: _onMapTapped,
                  markers: _hasLocation
                      ? {
                          Marker(
                            markerId: const MarkerId('delivery-pin'),
                            position: _selectedCenter!,
                            draggable: true,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRose,
                            ),
                            onDragEnd: _onMarkerDragEnd,
                          ),
                        }
                      : {},
                ),
              ),
              // Search bar overlay
              Positioned(
                left: 14,
                right: 14,
                top: 12,
                child: Material(
                  color: Colors.transparent,
                  child: TextField(
                    controller: _searchCtrl,
                    readOnly: true,
                    showCursor: false,
                    textInputAction: TextInputAction.search,
                    onTap: _openAddressSearch,
                    decoration: InputDecoration(
                      hintText: 'Search here',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: IconButton(
                        onPressed: _openAddressSearch,
                        icon: const Icon(Icons.arrow_forward_rounded),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                ),
              ),
              // Zoom + location controls
              Positioned(
                right: 16,
                bottom: 16,
                child: Column(
                  children: [
                    _MapControlButton(
                      icon: Icons.add_rounded,
                      onTap: () => _zoomMap(1),
                    ),
                    const SizedBox(height: 10),
                    _MapControlButton(
                      icon: Icons.remove_rounded,
                      onTap: () => _zoomMap(-1),
                    ),
                    const SizedBox(height: 10),
                    _MapControlButton(
                      icon: Icons.my_location_rounded,
                      onTap: _isLocating ? null : _useCurrentLocation,
                      loading: _isLocating,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Scrollable form ───────────────────────────────────────────────
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resolved address display
                  const Text(
                    'Address',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D1B24),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.place_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isResolvingAddress
                              ? 'Detecting address...'
                              : (_resolvedAddress.isEmpty
                                    ? 'Tap the map to select your location'
                                    : _resolvedAddress),
                          style: TextStyle(
                            color:
                                (!_isResolvingAddress &&
                                    _resolvedAddress.isEmpty)
                                ? const Color(0xFFB0AFBA)
                                : const Color(0xFF34313B),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _FormLabel(label: 'Name address', required: true),
                  const SizedBox(height: 8),
                  _FormTextField(
                    controller: _nameCtrl,
                    hintText: 'Please type your address name',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  _FormLabel(label: 'Phone number', required: true),
                  const SizedBox(height: 8),
                  _FormTextField(
                    controller: _phoneCtrl,
                    hintText: 'Enter phone number',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[\d\s\+\-\(\)]'),
                      ),
                    ],
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Label',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D1B24),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LabelSelector(
                    selected: _label,
                    onChanged: (l) => setState(() => _label = l),
                  ),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () => setState(() => _isDefault = !_isDefault),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: _isDefault
                                ? AppColors.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _isDefault
                                  ? AppColors.primary
                                  : const Color(0xFFCCCCCC),
                              width: 1.5,
                            ),
                          ),
                          child: _isDefault
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Default Delivery Address',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveBar() {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 68,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _canSave ? _save : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: const Color(0xFFE2E2E7),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
          ),
          child: const Text(
            'Save',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

// ── Private widgets ────────────────────────────────────────────────────────

class _FormLabel extends StatelessWidget {
  const _FormLabel({required this.label, this.required = false});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1D1B24),
        ),
        children: required
            ? const [
                TextSpan(
                  text: '*',
                  style: TextStyle(color: AppColors.primary),
                ),
              ]
            : [],
      ),
    );
  }
}

class _FormTextField extends StatelessWidget {
  const _FormTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 15, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFB0AFBA), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _LabelSelector extends StatelessWidget {
  const _LabelSelector({required this.selected, required this.onChanged});

  final AddressLabel selected;
  final ValueChanged<AddressLabel> onChanged;

  static const _labels = [
    (AddressLabel.work, Icons.work_outline_rounded, 'Work'),
    (AddressLabel.home, Icons.home_outlined, 'Home'),
    (AddressLabel.school, Icons.school_outlined, 'School'),
    (AddressLabel.other, Icons.bookmark_border_rounded, 'Other'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _labels.map((entry) {
        final (label, icon, text) = entry;
        final isSelected = selected == label;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFFE5E5EA),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? AppColors.primary : Colors.black54,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.primary : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.icon,
    required this.onTap,
    this.loading = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(icon, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _LocationException implements Exception {
  const _LocationException(this.message);
  final String message;
}
