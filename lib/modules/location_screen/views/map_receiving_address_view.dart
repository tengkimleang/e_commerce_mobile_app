import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  const MapReceivingAddressView({super.key, this.initialAddress = ''});

  final String initialAddress;

  @override
  State<MapReceivingAddressView> createState() =>
      _MapReceivingAddressViewState();
}

class _MapReceivingAddressViewState extends State<MapReceivingAddressView> {
  static const _accent = Color(0xFFEC0C6E);
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
  bool _isSearching = false;
  String? _locationError;

  bool get _hasLocation => _selectedCenter != null;

  @override
  void initState() {
    super.initState();
    _resolvedAddress = widget.initialAddress.trim();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    if (_isLocating) return;
    setState(() {
      _isLocating = true;
      _locationError = null;
    });

    LatLng center = _fallbackCenter;
    String? locationWarning;

    try {
      final position = await _determinePosition();
      center = LatLng(position.latitude, position.longitude);
    } catch (error) {
      locationWarning = _mapLocationError(error);
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }

    if (!mounted) return;

    setState(() {
      _selectedCenter = center;
      _locationError = locationWarning;
    });
    await _moveCamera(center);
    await _resolveAddress(center);

    if (locationWarning != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not get current location. Move the map pin to your address.',
          ),
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

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  String _mapLocationError(Object error) {
    if (error is _LocationException) return error.message;
    return 'Unable to detect your location right now. Please try again.';
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
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

  Future<void> _setSelectedCenter(
    LatLng center, {
    bool animateCamera = false,
  }) async {
    setState(() => _selectedCenter = center);
    if (animateCamera) {
      await _moveCamera(center);
    }
    await _resolveAddress(center);
  }

  Future<void> _onMapTapped(LatLng center) async {
    if (!_hasLocation) return;
    await _setSelectedCenter(center);
  }

  Future<void> _onMarkerDragEnd(LatLng center) async {
    await _setSelectedCenter(center);
  }

  Future<void> _zoomMap(double delta) async {
    final controller = _mapController;
    if (controller == null) return;
    final currentZoom = await controller.getZoomLevel();
    final nextZoom = (currentZoom + delta).clamp(_minZoom, _maxZoom).toDouble();
    await controller.animateCamera(CameraUpdate.zoomTo(nextZoom));
  }

  Future<void> _searchAddress() async {
    if (_isSearching) return;
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);
    try {
      final locations = await locationFromAddress(query);
      if (locations.isEmpty) {
        throw const _LocationException('Address was not found.');
      }
      final result = locations.first;
      final target = LatLng(result.latitude, result.longitude);

      if (!mounted) return;
      await _setSelectedCenter(target, animateCamera: true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address not found. Try more specific keywords.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
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
      if (mounted) {
        setState(() => _isResolvingAddress = false);
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
        ),
        title: Text(
          _hasLocation ? 'Add address' : 'Receiving address',
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1D1B24),
          ),
        ),
      ),
      body: _hasLocation ? _buildMapBody() : _buildEmptyState(),
      bottomNavigationBar: _hasLocation
          ? _buildMapBottomBar()
          : _buildUseCurrentLocationButton(),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            color: const Color(0xFFF0F0F3),
            alignment: Alignment.center,
            child: _locationError == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _locationError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF8E8B96),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildUseCurrentLocationButton() {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 84,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLocating ? null : _useCurrentLocation,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            disabledBackgroundColor: _accent.withValues(alpha: 0.6),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
          ),
          child: _isLocating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Use Current Location',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }

  Widget _buildMapBody() {
    final center = _selectedCenter!;
    return Stack(
      children: [
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: center,
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
            markers: {
              Marker(
                markerId: const MarkerId('delivery-pin'),
                position: center,
                draggable: true,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRose,
                ),
                onDragEnd: _onMarkerDragEnd,
              ),
            },
          ),
        ),
        Positioned(
          left: 14,
          right: 14,
          top: 12,
          child: Material(
            color: Colors.transparent,
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchAddress(),
              decoration: InputDecoration(
                hintText: 'Search here',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        onPressed: _searchAddress,
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
        Positioned(
          right: 16,
          bottom: 260,
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

  Widget _buildMapBottomBar() {
    final canSave = _resolvedAddress.trim().isNotEmpty;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Address',
                style: TextStyle(
                  fontSize: 18,
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
                    child: Icon(Icons.place_rounded, color: _accent, size: 22),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isResolvingAddress
                          ? 'Detecting address...'
                          : (_resolvedAddress.trim().isEmpty
                                ? 'Move map to detect address'
                                : _resolvedAddress),
                      style: const TextStyle(
                        color: Color(0xFF34313B),
                        fontSize: 16,
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
                    backgroundColor: _accent,
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
                : Icon(icon, color: const Color(0xFFEC0C6E)),
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
