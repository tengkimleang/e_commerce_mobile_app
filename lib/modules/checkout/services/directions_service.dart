import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsService {
  // Dedicated Dio with no baseUrl/auth headers — only for Google APIs.
  DirectionsService([Dio? dio])
      : _dio = dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));

  final Dio _dio;

  // API key is injected at build time via --dart-define=MAPS_API_KEY=...
  // Never commit the real key to source control.
  static const _apiKey = String.fromEnvironment('MAPS_API_KEY');
  // Routes API (new) — replaces the legacy Directions API.
  static const _routesUrl =
      'https://routes.googleapis.com/directions/v2:computeRoutes';

  /// Returns a list of [LatLng] points representing the driving route between
  /// [origin] and [destination]. Returns an empty list on failure.
  Future<List<LatLng>> getRoutePoints(LatLng origin, LatLng dest) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _routesUrl,
        options: Options(
          headers: {
            'X-Goog-Api-Key': _apiKey,
            // Only request the encoded polyline to minimise response size.
            'X-Goog-FieldMask': 'routes.polyline.encodedPolyline',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'origin': {
            'location': {
              'latLng': {
                'latitude': origin.latitude,
                'longitude': origin.longitude,
              },
            },
          },
          'destination': {
            'location': {
              'latLng': {
                'latitude': dest.latitude,
                'longitude': dest.longitude,
              },
            },
          },
          'travelMode': 'DRIVE',
        },
      );

      final data = response.data;
      if (data == null) {
        debugPrint('[DirectionsService] null response data');
        return [];
      }

      final routes = data['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) {
        debugPrint('[DirectionsService] no routes returned: $data');
        return [];
      }

      final encodedPoints =
          ((routes[0] as Map<String, dynamic>)['polyline']
                  as Map<String, dynamic>?)?['encodedPolyline'] as String?;
      if (encodedPoints == null || encodedPoints.isEmpty) return [];

      final decoded = PolylinePoints().decodePolyline(encodedPoints);
      return decoded
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList(growable: false);
    } on DioException catch (e) {
      debugPrint('[DirectionsService] DioException: ${e.type} — ${e.message}');
      debugPrint('[DirectionsService] Response: ${e.response?.statusCode} ${e.response?.data}');
      return [];
    } catch (e) {
      debugPrint('[DirectionsService] Unexpected error: $e');
      return [];
    }
  }
}
