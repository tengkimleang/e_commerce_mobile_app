import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressGeocodingService {
  AddressGeocodingService._();

  static final AddressGeocodingService instance = AddressGeocodingService._();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static const _googleGeocodeUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';

  Future<LatLng?> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return null;

    final nativeResult = await _searchNativeGeocoder(trimmed);
    if (nativeResult != null) return nativeResult;

    return _searchGoogleGeocoding(trimmed);
  }

  Future<LatLng?> _searchNativeGeocoder(String query) async {
    try {
      final locations = await locationFromAddress(query);
      if (locations.isEmpty) return null;
      return LatLng(locations.first.latitude, locations.first.longitude);
    } catch (error) {
      debugPrint('[AddressGeocodingService] Native geocoder failed: $error');
      return null;
    }
  }

  Future<LatLng?> _searchGoogleGeocoding(String query) async {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      debugPrint('[AddressGeocodingService] Missing GOOGLE_MAPS_API_KEY.');
      return null;
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _googleGeocodeUrl,
        queryParameters: {'address': query, 'region': 'kh', 'key': apiKey},
      );

      final data = response.data;
      if (data == null) return null;

      final status = data['status'] as String?;
      if (status != 'OK') {
        debugPrint(
          '[AddressGeocodingService] Google geocoding failed: '
          '$status ${data['error_message'] ?? ''}',
        );
        return null;
      }

      final results = data['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) return null;

      final first = results.first as Map<String, dynamic>;
      final geometry = first['geometry'] as Map<String, dynamic>?;
      final location = geometry?['location'] as Map<String, dynamic>?;
      final lat = (location?['lat'] as num?)?.toDouble();
      final lng = (location?['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) return null;

      return LatLng(lat, lng);
    } on DioException catch (error) {
      debugPrint(
        '[AddressGeocodingService] Google geocoding DioException: '
        '${error.type} ${error.response?.statusCode} ${error.response?.data}',
      );
      return null;
    } catch (error) {
      debugPrint('[AddressGeocodingService] Google geocoding failed: $error');
      return null;
    }
  }
}
