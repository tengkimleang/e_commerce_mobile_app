import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/localization/app_language.dart';
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
  static const _googlePlaceAutocompleteUrl =
      'https://places.googleapis.com/v1/places:autocomplete';
  static const _googlePlaceDetailsUrl =
      'https://places.googleapis.com/v1/places';

  String get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  Future<LatLng?> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return null;

    final nativeResult = await _searchNativeGeocoder(trimmed);
    if (nativeResult != null) return nativeResult;

    return _searchGoogleGeocoding(trimmed);
  }

  Future<List<AddressSearchSuggestion>> suggestions(
    String query, {
    LatLng? origin,
    String? sessionToken,
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return const [];

    final apiKey = _apiKey;
    if (apiKey.isEmpty) {
      debugPrint('[AddressGeocodingService] Missing GOOGLE_MAPS_API_KEY.');
      throw const AddressSearchException(
        'Address suggestions are unavailable right now.',
      );
    }

    try {
      final body = <String, dynamic>{
        'input': trimmed,
        'includedRegionCodes': ['kh'],
        'languageCode': AppLanguage.currentLanguageCode,
        'regionCode': 'KH',
      };
      if (sessionToken != null) {
        body['sessionToken'] = sessionToken;
      }
      if (origin != null) {
        final center = {
          'latitude': origin.latitude,
          'longitude': origin.longitude,
        };
        body.addAll({
          'origin': center,
          'locationBias': {
            'circle': {'center': center, 'radius': 50000.0},
          },
        });
      }

      final response = await _dio.post<Map<String, dynamic>>(
        _googlePlaceAutocompleteUrl,
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': apiKey,
            'X-Goog-FieldMask': [
              'suggestions.placePrediction.placeId',
              'suggestions.placePrediction.text.text',
              'suggestions.placePrediction.structuredFormat.mainText.text',
              'suggestions.placePrediction.structuredFormat.secondaryText.text',
              'suggestions.placePrediction.distanceMeters',
            ].join(','),
          },
        ),
      );

      final data = response.data;
      if (data == null) return const [];

      final suggestions = data['suggestions'] as List<dynamic>?;
      if (suggestions == null || suggestions.isEmpty) return const [];

      return suggestions
          .whereType<Map<String, dynamic>>()
          .map(AddressSearchSuggestion.fromPlacePrediction)
          .where((suggestion) => suggestion.description.isNotEmpty)
          .toList(growable: false);
    } on DioException catch (error) {
      debugPrint(
        '[AddressGeocodingService] Google place autocomplete DioException: '
        '${error.type} ${error.response?.statusCode} ${error.response?.data}',
      );
      throw const AddressSearchException(
        'Address suggestions are unavailable right now.',
      );
    } catch (error) {
      debugPrint(
        '[AddressGeocodingService] Google place autocomplete failed: $error',
      );
      throw const AddressSearchException(
        'Address suggestions are unavailable right now.',
      );
    }
  }

  Future<AddressSearchResult?> resolveSuggestion(
    AddressSearchSuggestion suggestion, {
    String? sessionToken,
  }) async {
    if (suggestion.placeId.isNotEmpty) {
      final details = await _placeDetails(
        suggestion.placeId,
        fallbackAddress: suggestion.description,
        sessionToken: sessionToken,
      );
      if (details != null) return details;
    }

    final location = await search(suggestion.description);
    if (location == null) return null;
    return AddressSearchResult(
      address: suggestion.description,
      location: location,
    );
  }

  Future<AddressSearchResult?> searchResult(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return null;

    List<AddressSearchSuggestion> suggestions;
    try {
      suggestions = await this.suggestions(trimmed);
    } on AddressSearchException {
      suggestions = const [];
    }
    if (suggestions.isNotEmpty) {
      return resolveSuggestion(suggestions.first);
    }

    final location = await search(trimmed);
    if (location == null) return null;
    return AddressSearchResult(address: trimmed, location: location);
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
    final apiKey = _apiKey;
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

  Future<AddressSearchResult?> _placeDetails(
    String placeId, {
    required String fallbackAddress,
    String? sessionToken,
  }) async {
    final apiKey = _apiKey;
    if (apiKey.isEmpty) {
      debugPrint('[AddressGeocodingService] Missing GOOGLE_MAPS_API_KEY.');
      return null;
    }

    try {
      final queryParameters = <String, dynamic>{'sessionToken': ?sessionToken};

      final response = await _dio.get<Map<String, dynamic>>(
        '$_googlePlaceDetailsUrl/${Uri.encodeComponent(placeId)}',
        queryParameters: queryParameters,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': apiKey,
            'X-Goog-FieldMask': 'id,displayName,formattedAddress,location',
          },
        ),
      );

      final data = response.data;
      if (data == null) return null;

      final location = data['location'] as Map<String, dynamic>?;
      final lat = (location?['latitude'] as num?)?.toDouble();
      final lng = (location?['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) return null;

      final formattedAddress = (data['formattedAddress'] ?? '')
          .toString()
          .trim();
      final displayName = data['displayName'] as Map<String, dynamic>?;
      final name = (displayName?['text'] ?? '').toString().trim();
      final address = formattedAddress.isNotEmpty
          ? formattedAddress
          : (name.isNotEmpty ? name : fallbackAddress);

      return AddressSearchResult(address: address, location: LatLng(lat, lng));
    } on DioException catch (error) {
      debugPrint(
        '[AddressGeocodingService] Google place details DioException: '
        '${error.type} ${error.response?.statusCode} ${error.response?.data}',
      );
      return null;
    } catch (error) {
      debugPrint(
        '[AddressGeocodingService] Google place details failed: $error',
      );
      return null;
    }
  }
}

class AddressSearchSuggestion {
  const AddressSearchSuggestion({
    required this.placeId,
    required this.description,
    required this.primaryText,
    required this.secondaryText,
    this.distanceMeters,
  });

  final String placeId;
  final String description;
  final String primaryText;
  final String secondaryText;
  final double? distanceMeters;

  factory AddressSearchSuggestion.fromPlacePrediction(
    Map<String, dynamic> json,
  ) {
    final prediction = json['placePrediction'] as Map<String, dynamic>?;
    final text = prediction?['text'] as Map<String, dynamic>?;
    final structured =
        prediction?['structuredFormat'] as Map<String, dynamic>? ?? const {};
    final mainText = structured['mainText'] as Map<String, dynamic>?;
    final secondary = structured['secondaryText'] as Map<String, dynamic>?;

    final description = (text?['text'] ?? '').toString().trim();
    final primaryText = (mainText?['text'] ?? '').toString().trim();
    final secondaryText = (secondary?['text'] ?? '').toString().trim();

    return AddressSearchSuggestion(
      placeId: (prediction?['placeId'] ?? '').toString(),
      description: description,
      primaryText: primaryText.isEmpty
          ? _firstDescriptionPart(description)
          : primaryText,
      secondaryText: secondaryText,
      distanceMeters: (prediction?['distanceMeters'] as num?)?.toDouble(),
    );
  }

  static String _firstDescriptionPart(String description) {
    final parts = description.split(',');
    return parts.isEmpty ? description : parts.first.trim();
  }
}

class AddressSearchResult {
  const AddressSearchResult({required this.address, required this.location});

  final String address;
  final LatLng location;
}

class AddressSearchException implements Exception {
  const AddressSearchException(this.message);

  final String message;
}
