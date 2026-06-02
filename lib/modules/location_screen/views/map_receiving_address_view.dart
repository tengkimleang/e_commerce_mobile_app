import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/maps/address_search_view.dart';
import '../../../core/theme/app_theme.dart';

class MapReceivingAddressResult {
  const MapReceivingAddressResult({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String address;
  final double latitude;
  final double longitude;
}

class MapReceivingAddressView extends StatefulWidget {
  const MapReceivingAddressView({
    super.key,
    this.initialAddress = '',
    this.startWithCurrentLocation = true,
  });

  final String initialAddress;
  final bool startWithCurrentLocation;

  @override
  State<MapReceivingAddressView> createState() =>
      _MapReceivingAddressViewState();
}

class _MapReceivingAddressViewState extends State<MapReceivingAddressView> {
  static const _fallbackCenter = LatLng(11.5564, 104.9282); // Phnom Penh
  static const _defaultZoom = 17.0;
  static const _minZoom = 4.0;
  static const _maxZoom = 19.5;

  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng? _selectedCenter;
  String _resolvedAddress = '';
  bool _isLocating = false;
  bool _isResolvingAddress = false;

  LatLng get _mapCenter => _selectedCenter ?? _fallbackCenter;
  bool get _hasLocation => _selectedCenter != null;

  @override
  void initState() {
    super.initState();
    _resolvedAddress = widget.initialAddress.trim();
    if (widget.startWithCurrentLocation) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _useCurrentLocation(),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ── location ──────────────────────────────────────────────────────────────

  Future<void> _useCurrentLocation() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);

    LatLng? center;
    String? locationWarning;

    try {
      final position = await _determinePosition();
      center = LatLng(position.latitude, position.longitude);
    } catch (error) {
      locationWarning = _mapLocationError(error);
      debugPrint('Could not get current location: $error');
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

    if (locationWarning != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$locationWarning Tap the map to select your address.'),
        ),
      );
    }
  }

  Future<Position> _determinePosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw const _LocationException(
        'Location service is disabled. Please enable GPS and try again.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const _LocationException(
        'Location permission is denied. Please allow location access.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw const _LocationException(
        'Location permission is permanently denied. Please allow it from app settings.',
      );
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
      throw const _LocationException(
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

  String _mapLocationError(Object error) {
    if (error is _LocationException) return error.message;
    return 'Unable to detect your location right now. Please try again.';
  }

  // ── map helpers ───────────────────────────────────────────────────────────

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_selectedCenter != null) {
      _moveCamera(_selectedCenter!);
    }
  }

  Future<void> _moveCamera(LatLng center, {double zoom = _defaultZoom}) async {
    final controller = _mapController;
    if (controller == null) return;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: center, zoom: zoom),
      ),
    );
  }

  Future<void> _onMapTapped(LatLng center) async {
    setState(() => _selectedCenter = center);
    await _resolveAddress(center);
  }

  Future<void> _onMarkerDragEnd(LatLng center) async {
    setState(() => _selectedCenter = center);
    await _resolveAddress(center);
  }

  Future<void> _zoomMap(double delta) async {
    final controller = _mapController;
    if (controller == null) return;
    final currentZoom = await controller.getZoomLevel();
    final nextZoom = (currentZoom + delta).clamp(_minZoom, _maxZoom).toDouble();
    await controller.animateCamera(CameraUpdate.zoomTo(nextZoom));
  }

  Future<void> _openAddressSearch() async {
    final selection = await Navigator.of(context).push<AddressSearchSelection>(
      MaterialPageRoute(
        builder: (_) => AddressSearchView(
          initialQuery: _searchController.text,
          origin: _mapCenter,
        ),
      ),
    );

    if (selection == null || !mounted) return;

    final resolved = selection.address.trim();
    setState(() {
      _searchController.text = selection.searchText;
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

  Future<void> _resolveAddress(LatLng center) async {
    if (!mounted) return;
    setState(() => _isResolvingAddress = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        center.latitude,
        center.longitude,
      );
      final place = placemarks.isEmpty ? null : placemarks.first;
      final formatted = _formatPlacemark(place);
      if (!mounted) return;
      setState(() {
        _resolvedAddress = formatted.isEmpty
            ? _latLngFallback(center)
            : formatted;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _resolvedAddress = _latLngFallback(center));
    } finally {
      if (mounted) setState(() => _isResolvingAddress = false);
    }
  }

  String _latLngFallback(LatLng center) {
    return 'Lat ${center.latitude.toStringAsFixed(6)}, '
        'Lng ${center.longitude.toStringAsFixed(6)}';
  }

  String _formatPlacemark(Placemark? place) {
    if (place == null) return '';
    final parts = <String>[
      place.street ?? '',
      place.subLocality ?? '',
      place.locality ?? '',
      place.administrativeArea ?? '',
      place.country ?? '',
    ];
    final normalized = <String>[];
    for (final part in parts) {
      final text = part.trim();
      if (text.isEmpty || normalized.contains(text)) continue;
      normalized.add(text);
    }
    return normalized.join(', ');
  }

  void _saveAddress() {
    final value = _resolvedAddress.trim();
    final center = _selectedCenter;
    if (value.isEmpty || center == null) return;
    Navigator.of(context).pop(
      MapReceivingAddressResult(
        address: value,
        latitude: center.latitude,
        longitude: center.longitude,
      ),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
        ),
        title: const Text(
          'Add address',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1D1B24),
          ),
        ),
      ),
      body: _buildMapBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildMapBody() {
    final primary = Theme.of(context).colorScheme.primary;

    return Stack(
      children: [
        // Full-screen map
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
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
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
                        HSVColor.fromColor(primary).hue,
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
              controller: _searchController,
              style: AppTypography.input,
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
    );
  }

  Widget _buildBottomBar() {
    final primary = Theme.of(context).colorScheme.primary;
    final canSave = _hasLocation && _resolvedAddress.trim().isNotEmpty;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D1B24),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.place_rounded, color: primary, size: 22),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isResolvingAddress
                          ? 'Detecting address...'
                          : (_resolvedAddress.trim().isEmpty
                                ? 'Tap the map to select your location'
                                : _resolvedAddress),
                      style: TextStyle(
                        color:
                            (!_isResolvingAddress &&
                                _resolvedAddress.trim().isEmpty)
                            ? const Color(0xFFB0AFBA)
                            : const Color(0xFF34313B),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: canSave ? _saveAddress : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    disabledBackgroundColor: const Color(0xFFE2E2E7),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
    final primary = Theme.of(context).colorScheme.primary;

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
                : Icon(icon, color: primary),
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
