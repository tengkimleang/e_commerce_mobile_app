import 'package:e_commerce_mobile_app/core/constants/app_constants.dart';
import 'package:e_commerce_mobile_app/core/services/auth_service.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/models/user_info_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoRepository {
  UserInfoRepository({AuthService? authService})
    : _authService = authService ?? AuthService();

  final AuthService _authService;

  static const _cacheNameKey = 'user_info_cache_name';
  static const _cacheDobKey = 'user_info_cache_date_of_birth';
  static const _cacheAddressKey = 'user_info_cache_address';
  static const _cachePhoneKey = 'user_info_cache_phone';
  static const _cacheVerifiedKey = 'user_info_cache_verified';
  static const _cachePointsKey = 'user_info_cache_points';
  static const _cacheImagePathKey = 'user_info_cache_profile_image_path';
  static const _cacheImageUrlKey = 'user_info_cache_profile_image_url';
  static const _cacheLanguageKey = 'user_info_cache_language';
  static const _cacheOwnerKey = 'user_info_cache_owner';

  Future<UserInfoModel> loadUserInfo({
    String fallbackLanguageCode = 'en',
  }) async {
    final cached = await _loadCachedUserInfo(
      fallbackLanguageCode: fallbackLanguageCode,
    );

    try {
      final response = await _authService.getUserProfile();
      final errorCode = (response['errorCode'] ?? '').toString().trim();
      final success = response['success'] == true;
      if (errorCode.isNotEmpty || !success) {
        return cached;
      }

      final data = _extractDataMap(response);
      final hasName =
          data.containsKey('fullName') || data.containsKey('username');
      final hasPhone =
          data.containsKey('phoneNumber') || data.containsKey('phone');
      final hasAddress = data.containsKey('address');

      final remote =
          UserInfoModel.fromProfileJson(
            data,
            fallbackLanguageCode: cached.languageCode,
          ).copyWith(
            username: hasName && data['fullName'] != null
                ? (data['fullName'] ?? data['username']).toString().trim()
                : (hasName
                      ? (data['username'] ?? '').toString().trim()
                      : cached.username),
            phoneNumber: hasPhone && data['phoneNumber'] != null
                ? data['phoneNumber'].toString().trim()
                : (hasPhone
                      ? (data['phone'] ?? '').toString().trim()
                      : cached.phoneNumber),
            address: hasAddress
                ? (data['address'] ?? '').toString().trim()
                : cached.address,
            profileImagePath: cached.profileImagePath,
            profileImageUrl: _normalizePublicUrl(
              _firstNonEmpty([
                data['profileImageUrl'],
                response['profileImageUrl'],
              ]),
            ),
            clearProfileImagePath: _normalizePublicUrl(
              _firstNonEmpty([
                data['profileImageUrl'],
                response['profileImageUrl'],
              ]),
            ).isNotEmpty,
            languageCode: cached.languageCode,
          );

      await cacheUserInfo(remote);
      await _syncSession(remote);
      return remote;
    } catch (_) {
      return cached;
    }
  }

  Future<UserInfoModel> updateProfile({
    required UserInfoModel current,
    String? fullName,
    DateTime? dateOfBirth,
    String? address,
  }) async {
    final draft = current.copyWith(
      username: fullName,
      dateOfBirth: dateOfBirth,
      address: address,
    );

    await cacheUserInfo(draft);
    await _syncSession(draft);

    try {
      final response = await _authService.updateUserProfile(
        fullName: draft.username,
        dateOfBirth: _formatDateOnly(draft.dateOfBirth),
        address: draft.address,
      );
      final errorCode = (response['errorCode'] ?? '').toString().trim();
      final success = response['success'] == true;
      if (errorCode.isNotEmpty || !success) {
        return draft;
      }

      final data = _extractDataMap(response);
      final hasName =
          data.containsKey('fullName') || data.containsKey('username');
      final hasPhone =
          data.containsKey('phoneNumber') || data.containsKey('phone');
      final hasAddress = data.containsKey('address');

      final remote =
          UserInfoModel.fromProfileJson(
            data,
            fallbackLanguageCode: draft.languageCode,
          ).copyWith(
            username: hasName && data['fullName'] != null
                ? (data['fullName'] ?? data['username']).toString().trim()
                : (hasName
                      ? (data['username'] ?? '').toString().trim()
                      : draft.username),
            phoneNumber: hasPhone && data['phoneNumber'] != null
                ? data['phoneNumber'].toString().trim()
                : (hasPhone
                      ? (data['phone'] ?? '').toString().trim()
                      : draft.phoneNumber),
            address: hasAddress
                ? (data['address'] ?? '').toString().trim()
                : draft.address,
            profileImagePath: draft.profileImagePath,
            profileImageUrl: _normalizePublicUrl(
              _firstNonEmpty([
                data['profileImageUrl'],
                response['profileImageUrl'],
              ]),
            ),
            clearProfileImagePath: _normalizePublicUrl(
              _firstNonEmpty([
                data['profileImageUrl'],
                response['profileImageUrl'],
              ]),
            ).isNotEmpty,
            languageCode: draft.languageCode,
          );

      await cacheUserInfo(remote);
      await _syncSession(remote);
      return remote;
    } catch (_) {
      return draft;
    }
  }

  Future<UserInfoModel> uploadProfileImage({
    required UserInfoModel current,
    required String localPath,
  }) async {
    final draft = current.copyWith(profileImagePath: localPath);
    await cacheUserInfo(draft);

    try {
      final response = await _authService.uploadUserAvatar(filePath: localPath);
      final errorCode = (response['errorCode'] ?? '').toString().trim();
      final success = response['success'] == true;
      if (errorCode.isNotEmpty || !success) {
        debugPrint(
          '[UserInfoRepository] uploadProfileImage failed: errorCode=$errorCode, errorMsg=${response['errorMsg']}',
        );
        return draft;
      }

      final data = _extractDataMap(response);
      final profileImageUrl = _normalizePublicUrl(
        _firstNonEmpty([data['profileImageUrl'], response['profileImageUrl']]),
      );

      final remote = draft.copyWith(
        profileImageUrl: profileImageUrl,
        clearProfileImagePath: profileImageUrl.isNotEmpty,
      );
      await cacheUserInfo(remote);
      return remote;
    } catch (e) {
      debugPrint('[UserInfoRepository] uploadProfileImage exception: $e');
      return draft;
    }
  }

  Future<void> cacheUserInfo(UserInfoModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheNameKey, model.username.trim());
    await prefs.setString(_cacheAddressKey, model.address.trim());
    await prefs.setString(_cachePhoneKey, model.phoneNumber.trim());
    await prefs.setBool(_cacheVerifiedKey, model.isVerified);
    await prefs.setInt(_cachePointsKey, model.points);
    await prefs.setString(_cacheLanguageKey, model.languageCode.trim());

    final dateText = _formatDateOnly(model.dateOfBirth);
    if (dateText.isEmpty) {
      await prefs.remove(_cacheDobKey);
    } else {
      await prefs.setString(_cacheDobKey, dateText);
    }

    final imagePath = model.profileImagePath?.trim() ?? '';
    if (imagePath.isEmpty) {
      await prefs.remove(_cacheImagePathKey);
    } else {
      await prefs.setString(_cacheImagePathKey, imagePath);
    }

    final imageUrl = model.profileImageUrl.trim();
    if (imageUrl.isEmpty) {
      await prefs.remove(_cacheImageUrlKey);
    } else {
      await prefs.setString(_cacheImageUrlKey, imageUrl);
    }

    final owner = _activeSessionOwner(model: model);
    if (owner.isEmpty) {
      await prefs.remove(_cacheOwnerKey);
    } else {
      await prefs.setString(_cacheOwnerKey, owner);
    }
  }

  Future<UserInfoModel> _loadCachedUserInfo({
    required String fallbackLanguageCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionModel = _buildSessionModel(
      fallbackLanguageCode: fallbackLanguageCode,
    );
    final activeOwner = _activeSessionOwner();
    final cachedOwner = (prefs.getString(_cacheOwnerKey) ?? '').trim();

    final canUseCache =
        activeOwner.isNotEmpty &&
        cachedOwner.isNotEmpty &&
        cachedOwner == activeOwner;
    if (!canUseCache) {
      return sessionModel;
    }

    final name = (prefs.getString(_cacheNameKey) ?? '').trim();
    final dateText = (prefs.getString(_cacheDobKey) ?? '').trim();
    final address = (prefs.getString(_cacheAddressKey) ?? '').trim();
    final phone = (prefs.getString(_cachePhoneKey) ?? '').trim();
    final imagePath = (prefs.getString(_cacheImagePathKey) ?? '').trim();
    final imageUrl = (prefs.getString(_cacheImageUrlKey) ?? '').trim();
    final language = (prefs.getString(_cacheLanguageKey) ?? '').trim();
    final dateOfBirth = dateText.isEmpty ? null : DateTime.tryParse(dateText);
    final points = prefs.getInt(_cachePointsKey) ?? 0;
    final verified = prefs.getBool(_cacheVerifiedKey) ?? false;

    final hasCache =
        name.isNotEmpty ||
        address.isNotEmpty ||
        phone.isNotEmpty ||
        imagePath.isNotEmpty ||
        imageUrl.isNotEmpty ||
        dateOfBirth != null ||
        points != 0 ||
        verified;

    if (!hasCache) return sessionModel;

    return sessionModel.copyWith(
      username: name.isEmpty ? sessionModel.username : name,
      dateOfBirth: dateOfBirth,
      address: address,
      phoneNumber: phone.isEmpty ? sessionModel.phoneNumber : phone,
      profileImagePath: imagePath.isEmpty ? null : imagePath,
      profileImageUrl: _normalizePublicUrl(imageUrl),
      languageCode: language.isEmpty ? fallbackLanguageCode : language,
      points: points,
      isVerified: verified,
    );
  }

  UserInfoModel _buildSessionModel({required String fallbackLanguageCode}) {
    final fullName = UserSession.fullName.trim();
    final phone = UserSession.phoneNumber.trim();
    final username = fullName.isNotEmpty
        ? fullName
        : (phone.isNotEmpty ? phone : 'User');

    return UserInfoModel(
      username: username,
      languageCode: fallbackLanguageCode,
      phoneNumber: phone,
    );
  }

  Map<String, dynamic> _extractDataMap(Map<String, dynamic> payload) {
    final rawData = payload['data'];
    if (rawData is Map<String, dynamic>) return rawData;
    if (rawData is Map) {
      return rawData.map((key, value) => MapEntry(key.toString(), value));
    }
    return payload;
  }

  String _firstNonEmpty(Iterable<dynamic> values) {
    for (final value in values) {
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  String _normalizePublicUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';

    final baseUri = Uri.tryParse(ApiUrl.baseUrl);
    if (baseUri == null || !baseUri.hasScheme || baseUri.host.isEmpty) {
      return value;
    }

    final imageUri = Uri.tryParse(value);
    if (imageUri == null) {
      return baseUri.resolve(value).toString();
    }

    if (!imageUri.hasScheme) {
      return baseUri.resolveUri(imageUri).toString();
    }

    final host = imageUri.host.toLowerCase();
    if (host == 'localhost' || host == '127.0.0.1') {
      return imageUri
          .replace(
            scheme: baseUri.scheme,
            host: baseUri.host,
            port: baseUri.hasPort ? baseUri.port : null,
          )
          .toString();
    }

    return imageUri.toString();
  }

  String _formatDateOnly(DateTime? date) {
    if (date == null) return '';
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _activeSessionOwner({UserInfoModel? model}) {
    final modelPhone = model?.phoneNumber.trim() ?? '';
    if (modelPhone.isNotEmpty) return 'phone:$modelPhone';

    final sessionPhone = UserSession.phoneNumber.trim();
    if (sessionPhone.isNotEmpty) return 'phone:$sessionPhone';

    final modelName = model?.username.trim() ?? '';
    if (modelName.isNotEmpty) return 'name:$modelName';

    final sessionName = UserSession.fullName.trim();
    if (sessionName.isNotEmpty) return 'name:$sessionName';

    return '';
  }

  Future<void> _syncSession(UserInfoModel model) async {
    if (!UserSession.isAuthenticated) return;

    final fullName = model.username.trim();
    final phone = model.phoneNumber.trim();

    await UserSession.markAuthenticated(
      fullName: fullName.isEmpty ? null : fullName,
      phoneNumber: phone.isEmpty ? null : phone,
    );
  }
}
