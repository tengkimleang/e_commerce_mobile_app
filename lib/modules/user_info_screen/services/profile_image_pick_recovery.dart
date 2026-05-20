import 'package:shared_preferences/shared_preferences.dart';

class ProfileImagePickRecovery {
  ProfileImagePickRecovery._();

  static const _pendingProfileImagePickKey = 'pending_profile_image_pick';

  static Future<void> markPending() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pendingProfileImagePickKey, true);
  }

  static Future<void> clearPending() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingProfileImagePickKey);
  }

  static Future<bool> hasPendingPick() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pendingProfileImagePickKey) ?? false;
  }
}
