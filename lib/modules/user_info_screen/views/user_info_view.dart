import 'dart:async';
import 'dart:io';

import 'package:e_commerce_mobile_app/core/widgets/app_skeleton.dart';
import 'package:e_commerce_mobile_app/modules/bottom_navigation/views/supermarket_bottom_navigation.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/views/favorite_view.dart';
import 'package:e_commerce_mobile_app/modules/location_screen/views/receiving_address_view.dart';
import 'package:e_commerce_mobile_app/modules/notification_screen/views/notification_view.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/views/order_history_view.dart';
import 'package:e_commerce_mobile_app/modules/promotion_screen/views/promotion_view.dart';
import 'package:e_commerce_mobile_app/modules/qr_code_screen/views/qr_code_view.dart';
import 'package:e_commerce_mobile_app/modules/term_condition_screen/views/term_condition_view.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/views/edit_date_of_birth_view.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/views/edit_language_view.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/views/edit_username_view.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/views/change_pin_old_pin_view.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/views/profile_image_source_bottom_sheet.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/services/profile_image_pick_recovery.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/views/telegram_link_view.dart';
import 'package:e_commerce_mobile_app/modules/login_screen/views/login_view.dart';
import 'package:e_commerce_mobile_app/core/services/auth_service.dart';
import 'package:e_commerce_mobile_app/core/services/biometric/biometric_auth_service.dart';
import 'package:e_commerce_mobile_app/core/services/biometric/biometric_login_coordinator.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/blocs/user_info_bloc.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/blocs/user_info_event.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/blocs/user_info_state.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/models/user_info_model.dart';

class UserInfoView extends StatefulWidget {
  final bool showBottomNavigation;

  const UserInfoView({super.key, this.showBottomNavigation = true});

  @override
  State<UserInfoView> createState() => _UserInfoViewState();
}

class _UserInfoViewState extends State<UserInfoView> {
  static const _profileSkeletonMinDuration = Duration(milliseconds: 650);
  static final AuthService _authService = AuthService();

  late final UserInfoBloc _bloc;
  final ImagePicker _imagePicker = ImagePicker();
  late final DateTime _profileSkeletonStartedAt;
  bool _showProfileSkeleton = true;

  @override
  void initState() {
    super.initState();
    _profileSkeletonStartedAt = DateTime.now();
    _bloc = UserInfoBloc()..add(const LoadUserInfo());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recoverLostProfileImage();
    });
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);

    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<UserInfoBloc, UserInfoState>(
        listener: (context, state) {
          if (state is UserInfoUpdated && _showProfileSkeleton) {
            unawaited(_hideProfileSkeletonAfterMinimum());
          }
        },
        builder: (context, state) {
          if (_showProfileSkeleton) {
            return Scaffold(
              backgroundColor: const Color(0xFFF3F3F3),
              body: const SafeArea(child: _UserInfoPageSkeleton()),
              bottomNavigationBar: widget.showBottomNavigation
                  ? SupermarketBottomNavigation(
                      selectedIndex: 4,
                      onTap: (index) => _onBottomNavTap(context, index),
                    )
                  : null,
            );
          }

          final userInfo = state is UserInfoUpdated
              ? state.userInfo
              : state is UserInfoInitial
              ? state.userInfo
              : UserInfoModel.initial();

          final sessionFullName = UserSession.fullName.trim();
          final sessionPhone = UserSession.phoneNumber.trim();
          final String username = userInfo.username.trim().isNotEmpty
              ? userInfo.username.trim()
              : (sessionFullName.isNotEmpty
                    ? sessionFullName
                    : (sessionPhone.isNotEmpty ? sessionPhone : 'User'));
          final profilePhone = userInfo.phoneNumber.trim();
          final rawPhone = profilePhone.isNotEmpty
              ? profilePhone
              : sessionPhone;
          final String phoneDisplay = _formatPhoneNumber(rawPhone);
          final DateTime? dateOfBirth = userInfo.dateOfBirth;
          final String languageCode = userInfo.languageCode;
          final String address = userInfo.address.trim();
          final bool isVerified = userInfo.isVerified;
          final String profileImageUrl = userInfo.profileImageUrl.trim();
          final String profileImagePath =
              userInfo.profileImagePath?.trim() ?? '';

          String dateOfBirthLabel() {
            if (dateOfBirth == null) return 'Not Added';
            const monthNames = [
              'Jan',
              'Feb',
              'Mar',
              'Apr',
              'May',
              'Jun',
              'Jul',
              'Aug',
              'Sep',
              'Oct',
              'Nov',
              'Dec',
            ];
            final date = dateOfBirth;
            final day = date.day.toString().padLeft(2, '0');
            return '$day ${monthNames[date.month - 1]} ${date.year}';
          }

          String languageLabel() {
            if (languageCode == 'km') return 'Khmer';
            return 'English';
          }

          return Scaffold(
            backgroundColor: const Color(0xFFF3F3F3),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _HeaderCard(
                            username: username,
                            profileImagePath: profileImagePath,
                            profileImageUrl: profileImageUrl,
                            points: userInfo.points,
                            onTapCamera: () => _pickProfileImage(context),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SectionTitle(
                                  title: 'Personal Information',
                                ),
                                const SizedBox(height: 18),
                                _InfoRow(
                                  label: 'Your Name:',
                                  value: username,
                                  trailingIcon: Icons.edit,
                                  trailingColor: accent,
                                  onTrailingTap: () =>
                                      _openEditUsername(context, username),
                                ),
                                const Divider(
                                  height: 28,
                                  color: Color(0xFFD7D1D6),
                                ),
                                _InfoRow(
                                  label: 'Date of Birth:',
                                  value: dateOfBirthLabel(),
                                  trailingIcon: Icons.edit,
                                  trailingColor: accent,
                                  onTrailingTap: () => _openEditDateOfBirth(
                                    context,
                                    dateOfBirth,
                                  ),
                                ),
                                const Divider(
                                  height: 28,
                                  color: Color(0xFFD7D1D6),
                                ),
                                _InfoRow(
                                  label: 'Address',
                                  value: address.isEmpty
                                      ? 'Not Added'
                                      : address,
                                  trailingIcon: Icons.chevron_right,
                                  trailingColor: accent,
                                  onTrailingTap: () => _openReceivingAddress(
                                    context,
                                    currentAddress: address,
                                  ),
                                ),
                                const Divider(
                                  height: 28,
                                  color: Color(0xFFD7D1D6),
                                ),
                                _InfoRow(
                                  label: 'Language',
                                  value: languageLabel(),
                                  trailingIcon: Icons.g_translate,
                                  trailingColor: accent,
                                  onTrailingTap: () =>
                                      _openEditLanguage(context, languageCode),
                                ),
                                const SizedBox(height: 12),
                                const Divider(
                                  thickness: 8,
                                  color: Color(0xFFEDEAF1),
                                ),
                                const SizedBox(height: 20),
                                const _SectionTitle(
                                  title: 'Account Information',
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'Phone Number:',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFFB0AAB3),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  phoneDisplay,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF34313A),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isVerified
                                        ? const Color(0xFFDFF5E7)
                                        : const Color(0xFFE6E6E8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isVerified
                                            ? Icons.check_circle
                                            : Icons.info_outline,
                                        color: isVerified
                                            ? const Color(0xFF0D9A58)
                                            : const Color(0xFF7B7883),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isVerified ? 'Verified' : 'Unverified',
                                        style: TextStyle(
                                          color: isVerified
                                              ? const Color(0xFF0D9A58)
                                              : const Color(0xFF57545C),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const Divider(
                                  thickness: 8,
                                  color: Color(0xFFEDEAF1),
                                ),
                                const SizedBox(height: 20),
                                const _SectionTitle(title: 'Account Security'),
                                const SizedBox(height: 18),
                                _SecurityRow(
                                  title: 'Change PIN:',
                                  value: '****',
                                  trailingText: 'Change',
                                  onTap: () => _openChangePin(context),
                                ),
                                const Divider(
                                  height: 30,
                                  color: Color(0xFFD7D1D6),
                                ),
                                const _TelegramBackupTile(),
                                const Divider(
                                  height: 30,
                                  color: Color(0xFFD7D1D6),
                                ),
                                _BiometricLoginTile(phoneNumber: rawPhone),
                                const Divider(
                                  height: 30,
                                  color: Color(0xFFD7D1D6),
                                ),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Term of Condition',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Color(0xFFB0AAB3),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const TermsOfUseView(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'See More',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: accent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  height: 30,
                                  color: Color(0xFFD7D1D6),
                                ),
                                const Text(
                                  'Account Deletion',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFFB0AAB3),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () =>
                                      _showDeleteAccountDialog(context),
                                  child: const Text(
                                    'Delete Account!',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1D1B22),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'v1.8.3 | 1830',
                                    style: TextStyle(
                                      color: Color(0xFFCFA6BD),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE2E2E7),
                                      foregroundColor: const Color(0xFF1D1B22),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: () =>
                                        _showLogoutBottomSheet(context),
                                    child: const Text(
                                      'Logout',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: widget.showBottomNavigation
                ? SupermarketBottomNavigation(
                    selectedIndex: 4,
                    onTap: (index) => _onBottomNavTap(context, index),
                  )
                : null,
          );
        },
      ),
    );
  }

  Future<void> _hideProfileSkeletonAfterMinimum() async {
    final elapsed = DateTime.now().difference(_profileSkeletonStartedAt);
    final remaining = _profileSkeletonMinDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
    if (!mounted || !_showProfileSkeleton) return;
    setState(() => _showProfileSkeleton = false);
  }

  Future<void> _openEditUsername(BuildContext context, String current) async {
    final updatedName = await showEditUsernameBottomSheet(
      context,
      initialUsername: current,
    );

    if (updatedName == null) return;
    final trimmed = updatedName.trim();
    if (trimmed.isEmpty || trimmed == current) return;

    if (!context.mounted) return;
    _bloc.add(UpdateUsername(trimmed));
  }

  String _formatPhoneNumber(String rawPhone) {
    final trimmed = rawPhone.trim();
    if (trimmed.isEmpty) return 'Not Added';

    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return trimmed;

    if (digits.startsWith('0') && digits.length > 1) {
      return '(+855) ${digits.substring(1)}';
    }
    if (digits.startsWith('855') && digits.length > 3) {
      return '(+855) ${digits.substring(3)}';
    }
    return trimmed;
  }

  Future<void> _openEditDateOfBirth(
    BuildContext context,
    DateTime? current,
  ) async {
    final selectedDate = await showDateOfBirthPickerDialog(
      context,
      initialDate: current,
    );

    if (selectedDate == null) return;

    final newDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    if (!context.mounted) return;
    _bloc.add(UpdateDateOfBirth(newDate));
  }

  Future<void> _openEditLanguage(
    BuildContext context,
    String currentCode,
  ) async {
    final selectedCode = await showLanguageBottomSheet(
      context,
      selectedLanguageCode: currentCode,
    );

    if (selectedCode == null || selectedCode == currentCode) return;
    if (!context.mounted) return;
    _bloc.add(UpdateLanguage(selectedCode));
  }

  Future<void> _openReceivingAddress(
    BuildContext context, {
    required String currentAddress,
  }) async {
    final updatedAddress = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => ReceivingAddressView(initialAddress: currentAddress),
      ),
    );
    if (!context.mounted || updatedAddress == null) return;

    final trimmed = updatedAddress.trim();
    if (trimmed == currentAddress.trim()) return;
    _bloc.add(UpdateAddress(trimmed));
  }

  Future<void> _openChangePin(BuildContext context) async {
    final phone = UserSession.phoneNumber.trim();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangePinOldPinView(phoneNumber: phone),
      ),
    );
  }

  Future<void> _pickProfileImage(BuildContext context) async {
    final source = await showProfileImageSourceBottomSheet(context);
    if (source == null) return;

    await ProfileImagePickRecovery.markPending();
    XFile? picked;
    try {
      picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
    } catch (e) {
      await ProfileImagePickRecovery.clearPending();
      debugPrint('[UserInfoView] profile image picker failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open selected image.')),
        );
      }
      return;
    }

    await ProfileImagePickRecovery.clearPending();
    if (picked == null) return;
    if (!context.mounted) return;
    _bloc.add(UpdateProfileImage(picked.path));
  }

  Future<void> _recoverLostProfileImage() async {
    final hasPendingPick = await ProfileImagePickRecovery.hasPendingPick();
    if (!hasPendingPick) return;

    try {
      final response = await _imagePicker.retrieveLostData();
      if (response.isEmpty) return;

      final file =
          response.file ??
          ((response.files?.isNotEmpty ?? false)
              ? response.files!.first
              : null);
      if (response.exception != null) {
        debugPrint(
          '[UserInfoView] lost profile image picker data failed: ${response.exception}',
        );
      }
      if (!mounted || file == null) return;
      _bloc.add(UpdateProfileImage(file.path));
    } catch (e) {
      debugPrint('[UserInfoView] retrieveLostData failed: $e');
    } finally {
      await ProfileImagePickRecovery.clearPending();
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    const accent = Color(0xFFEC407A);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFFF5F8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delete Account!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D1B22),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This action cannot be undone.',
                style: TextStyle(fontSize: 15, color: Color(0xFF1D1B22)),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE2E2E7),
                          foregroundColor: const Color(0xFF1D1B22),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          // TODO: Handle account deletion
                        },
                        child: const Text(
                          'Confirm',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutBottomSheet(BuildContext context) {
    const accent = Color(0xFFEC407A);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Logout',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D1B22),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Really want to logout?',
              style: TextStyle(fontSize: 15, color: Color(0xFF1D1B22)),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE2E2E7),
                        foregroundColor: const Color(0xFF1D1B22),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        try {
                          await _authService.logout();
                        } catch (e) {
                          debugPrint('[UserInfoView] logout revoke failed: $e');
                        }
                        await UserSession.markGuest();
                        if (!context.mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginView()),
                          (route) => false,
                        );
                      },
                      child: const Text('Yes', style: TextStyle(fontSize: 15)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onBottomNavTap(BuildContext context, int index) {
    if (index == 4) return;

    if (index == 0) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    }

    if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PromotionView()),
      );
      return;
    }

    if (index == 2) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const QrCodeView()));
      return;
    }

    if (index == 3) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OrderHistoryView()),
      );
    }
  }
}

class _BiometricLoginTile extends StatefulWidget {
  const _BiometricLoginTile({required this.phoneNumber});

  final String phoneNumber;

  @override
  State<_BiometricLoginTile> createState() => _BiometricLoginTileState();
}

class _BiometricLoginTileState extends State<_BiometricLoginTile> {
  final BiometricLoginCoordinator _coordinator =
      BiometricLoginCoordinator.instance;

  DeviceBiometricStatus? _deviceStatus;
  bool _isEnabled = false;
  bool _isLoading = true;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  @override
  void didUpdateWidget(covariant _BiometricLoginTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phoneNumber.trim() != widget.phoneNumber.trim()) {
      _loadState();
    }
  }

  Future<void> _loadState() async {
    setState(() => _isLoading = true);
    final status = await _coordinator.getDeviceStatus();
    final enabled = widget.phoneNumber.trim().isNotEmpty
        ? await _coordinator.isEnabledForPhone(widget.phoneNumber)
        : false;

    if (!mounted) return;
    setState(() {
      _deviceStatus = status;
      _isEnabled = enabled;
      _isLoading = false;
    });
  }

  Future<void> _onToggleChanged(bool nextValue) async {
    if (_isBusy || _isLoading) return;

    setState(() => _isBusy = true);
    if (nextValue) {
      final result = await _coordinator.enableBiometricLogin(
        phoneNumber: widget.phoneNumber,
      );
      if (mounted && result.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: result.isSuccess
                ? const Color(0xFF4CAF50)
                : const Color(0xFF5F5A63),
          ),
        );
      }
    } else {
      await _coordinator.disableBiometricLogin();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric login has been disabled.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    if (!mounted) return;
    await _loadState();
    if (!mounted) return;
    setState(() => _isBusy = false);
  }

  @override
  Widget build(BuildContext context) {
    final status = _deviceStatus;
    final label = status?.settingsLabel ?? 'Login with Biometric:';
    final canEnable =
        status?.isSupported == true && widget.phoneNumber.trim().isNotEmpty;
    final canDisable = _isEnabled;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, color: Color(0xFFB0AAB3)),
          ),
        ),
        if (_isBusy || _isLoading) const SkeletonBox(width: 18, height: 18),
        if (_isBusy || _isLoading) const SizedBox(width: 10),
        Switch(
          value: _isEnabled,
          activeThumbColor: const Color(0xFFEC407A),
          activeTrackColor: const Color(0xFFF9DCEA),
          inactiveTrackColor: const Color(0xFFF9DCEA),
          onChanged: (_isBusy || _isLoading || (!canEnable && !canDisable))
              ? null
              : _onToggleChanged,
        ),
      ],
    );
  }
}

class _UserInfoPageSkeleton extends StatelessWidget {
  const _UserInfoPageSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: SingleChildScrollView(
        key: const ValueKey('user-info-page-skeleton'),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SkeletonCircle(size: 30),
                      SizedBox(width: 18),
                      SkeletonCircle(size: 30),
                    ],
                  ),
                  SizedBox(height: 16),
                  SkeletonCircle(size: 108),
                  SizedBox(height: 18),
                  SkeletonBox(width: 150, height: 16, radius: 6),
                  SizedBox(height: 10),
                  SkeletonBox(width: 178, height: 15, radius: 6),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      SkeletonCircle(size: 42),
                      SizedBox(width: 10),
                      SkeletonBox(width: 70, height: 16, radius: 6),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 10),
                  SkeletonBox(width: 174, height: 18, radius: 6),
                  SizedBox(height: 18),
                  _SkeletonInfoRow(),
                  Divider(height: 28, color: Color(0xFFD7D1D6)),
                  _SkeletonInfoRow(),
                  Divider(height: 28, color: Color(0xFFD7D1D6)),
                  _SkeletonInfoRow(),
                  Divider(height: 28, color: Color(0xFFD7D1D6)),
                  _SkeletonInfoRow(),
                  SizedBox(height: 12),
                  Divider(thickness: 8, color: Color(0xFFEDEAF1)),
                  SizedBox(height: 20),
                  SkeletonBox(width: 168, height: 18, radius: 6),
                  SizedBox(height: 18),
                  _SkeletonInfoRow(showTrailing: false),
                  Divider(height: 30, color: Color(0xFFD7D1D6)),
                  SkeletonBox(width: 152, height: 18, radius: 6),
                  SizedBox(height: 18),
                  Divider(thickness: 8, color: Color(0xFFEDEAF1)),
                  SizedBox(height: 20),
                  SkeletonBox(width: 154, height: 18, radius: 6),
                  SizedBox(height: 18),
                  _SkeletonInfoRow(),
                  Divider(height: 30, color: Color(0xFFD7D1D6)),
                  _SkeletonInfoRow(),
                  Divider(height: 30, color: Color(0xFFD7D1D6)),
                  _SkeletonInfoRow(showTrailing: false),
                  SizedBox(height: 24),
                  SkeletonBox(height: 52, radius: 14),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonInfoRow extends StatelessWidget {
  const _SkeletonInfoRow({this.showTrailing = true});

  final bool showTrailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 122, height: 14, radius: 6),
              SizedBox(height: 8),
              SkeletonBox(width: 178, height: 15, radius: 6),
            ],
          ),
        ),
        if (showTrailing) const SkeletonCircle(size: 30),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.username,
    required this.profileImagePath,
    required this.profileImageUrl,
    required this.points,
    required this.onTapCamera,
  });

  final String username;
  final String profileImagePath;
  final String profileImageUrl;
  final int points;
  final VoidCallback onTapCamera;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);
    final token = (UserSession.token ?? '').trim();
    final imageHeaders = token.isEmpty
        ? null
        : <String, String>{'Authorization': 'Bearer $token'};

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FavoriteView()),
                  );
                },
                icon: const Icon(
                  Icons.favorite_border,
                  color: accent,
                  size: 30,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationView()),
                  );
                },
                icon: const Icon(
                  Icons.notifications_none,
                  color: accent,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7D6E5),
                      shape: BoxShape.circle,
                      border: Border.all(color: accent, width: 2),
                    ),
                    child:
                        profileImagePath.isNotEmpty &&
                            File(profileImagePath).existsSync()
                        ? ClipOval(
                            child: Image.file(
                              File(profileImagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (_, error, stackTrace) {
                                debugPrint(
                                  '[UserInfoView] local avatar load failed for $profileImagePath: $error',
                                );
                                return const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Color(0xFFEAA4C3),
                                );
                              },
                            ),
                          )
                        : profileImageUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              profileImageUrl,
                              headers: imageHeaders,
                              fit: BoxFit.cover,
                              errorBuilder: (_, error, stackTrace) {
                                debugPrint(
                                  '[UserInfoView] avatar load failed for $profileImageUrl: $error',
                                );
                                return const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Color(0xFFEAA4C3),
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFFEAA4C3),
                          ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: 4,
                    child: Material(
                      color: accent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onTapCamera,
                        child: const Padding(
                          padding: EdgeInsets.all(9),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              username,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D1B22),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Supermarket Point',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF9B9B9B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE3EE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.copyright, color: accent),
              ),
              const SizedBox(width: 10),
              Text(
                points.toString(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D1B22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1D1B22),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.trailingIcon,
    required this.trailingColor,
    this.onTrailingTap,
  });

  final String label;
  final String value;
  final IconData trailingIcon;
  final Color trailingColor;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 15, color: Color(0xFFB0AAB3)),
              ),
              if (value.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF34313A),
                  ),
                ),
              ],
            ],
          ),
        ),
        onTrailingTap != null
            ? IconButton(
                onPressed: onTrailingTap,
                icon: Icon(trailingIcon, color: trailingColor, size: 30),
                splashRadius: 18,
              )
            : Icon(trailingIcon, color: trailingColor, size: 30),
      ],
    );
  }
}

class _SecurityRow extends StatelessWidget {
  const _SecurityRow({
    required this.title,
    required this.value,
    required this.trailingText,
    required this.onTap,
  });

  final String title;
  final String value;
  final String trailingText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 15, color: Color(0xFFB0AAB3)),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D1B22),
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            trailingText,
            style: const TextStyle(fontSize: 15, color: Color(0xFFEC407A)),
          ),
        ),
      ],
    );
  }
}

/// Self-contained tile that loads the Telegram link status and lets the user
/// link or unlink their Telegram account as an OTP fallback channel.
class _TelegramBackupTile extends StatefulWidget {
  const _TelegramBackupTile();

  @override
  State<_TelegramBackupTile> createState() => _TelegramBackupTileState();
}

class _TelegramBackupTileState extends State<_TelegramBackupTile> {
  static const _accent = Color(0xFFEC407A);
  final AuthService _authService = AuthService();
  static final RegExp _pinPattern = RegExp(r'^\d{4}$');

  bool _isLoading = true;
  bool _isLinked = false;
  bool _isUnlinking = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final result = await _authService.checkTelegramLinkStatus();
      if (!mounted) return;
      final errorCode = (result['errorCode'] ?? '')
          .toString()
          .trim()
          .toUpperCase();
      final isAuthError =
          errorCode == 'AUTH401' ||
          errorCode == 'HTTP401' ||
          errorCode == 'UNAUTHORIZED';
      setState(() {
        _isLinked = !isAuthError && result['linked'] == true;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openLinkView() async {
    final linked = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const TelegramLinkView()));
    if (linked == true && mounted) {
      setState(() => _isLinked = true);
    }
  }

  Future<void> _confirmUnlink() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Telegram Backup'),
        content: const Text(
          'OTP will only be sent via SMS after removing Telegram backup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: _accent),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final pinVerified = await _showPinVerificationDialog();
    if (pinVerified != true || !mounted) return;

    setState(() => _isUnlinking = true);
    try {
      await _authService.unlinkTelegram();
      if (!mounted) return;
      setState(() {
        _isLinked = false;
        _isUnlinking = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isUnlinking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove Telegram backup.')),
      );
    }
  }

  Future<bool> _showPinVerificationDialog() async {
    final verified = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _TelegramPinVerificationView(authService: _authService),
      ),
    );
    return verified == true;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppSkeleton(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SkeletonBox(width: 164, height: 15, radius: 6),
              Spacer(),
              SkeletonBox(width: 56, height: 18, radius: 6),
            ],
          ),
        ),
      );
    }

    if (_isLinked) {
      return Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF0D9A58), size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Telegram OTP Backup:',
              style: TextStyle(fontSize: 15, color: Color(0xFFB0AAB3)),
            ),
          ),
          _isUnlinking
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _accent,
                  ),
                )
              : TextButton(
                  onPressed: _confirmUnlink,
                  style: TextButton.styleFrom(foregroundColor: _accent),
                  child: const Text('Remove', style: TextStyle(fontSize: 15)),
                ),
        ],
      );
    }

    return Row(
      children: [
        const Expanded(
          child: Text(
            'Telegram OTP Backup:',
            style: TextStyle(fontSize: 15, color: Color(0xFFB0AAB3)),
          ),
        ),
        TextButton(
          onPressed: _openLinkView,
          style: TextButton.styleFrom(foregroundColor: _accent),
          child: const Text('Set Up', style: TextStyle(fontSize: 15)),
        ),
      ],
    );
  }
}

class _TelegramPinVerificationView extends StatefulWidget {
  final AuthService authService;

  const _TelegramPinVerificationView({required this.authService});

  @override
  State<_TelegramPinVerificationView> createState() =>
      _TelegramPinVerificationViewState();
}

class _TelegramPinVerificationViewState
    extends State<_TelegramPinVerificationView> {
  static const _accent = Color(0xFFEC407A);
  static const _fallbackLockSeconds = 15 * 60;

  final TextEditingController _pinController = TextEditingController();
  Timer? _lockTimer;

  bool _isSubmitting = false;
  bool _hidePin = true;
  bool _isPinLocked = false;
  int _lockSecondsRemaining = 0;
  String _errorText = '';

  @override
  void dispose() {
    _lockTimer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  String _extractRawLockUntil(Map<String, dynamic> response) {
    const keys = [
      'lockUntilUtc',
      'LockUntilUtc',
      'lock_until_utc',
      'lockedUntil',
      'lockedUntilUtc',
      'pinLockUntilUtc',
    ];

    for (final key in keys) {
      final value = response[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }

    final nested = response['data'];
    if (nested is Map) {
      for (final key in keys) {
        final value = nested[key]?.toString().trim() ?? '';
        if (value.isNotEmpty) return value;
      }
    }

    return '';
  }

  int _computeLockSeconds(Map<String, dynamic> response) {
    final rawLockUntil = _extractRawLockUntil(response);
    if (rawLockUntil.isEmpty) return 0;

    DateTime? lockUntil = DateTime.tryParse(rawLockUntil);
    if (lockUntil == null &&
        !rawLockUntil.endsWith('Z') &&
        !rawLockUntil.contains('+')) {
      lockUntil = DateTime.tryParse('${rawLockUntil}Z');
    }

    lockUntil = lockUntil?.toUtc();
    if (lockUntil == null) return 0;

    final diff = lockUntil.difference(DateTime.now().toUtc()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  String _formatCountdown(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  String _resolvePinErrorMessage(String rawMessage, {required bool locked}) {
    final fallback = locked
        ? 'PIN is temporarily locked. Please try again later.'
        : 'Incorrect PIN. Please try again.';
    final normalized = rawMessage.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return fallback;
    if (normalized.length <= 140) return normalized;
    return '${normalized.substring(0, 137)}...';
  }

  void _stopLockTimer() {
    _lockTimer?.cancel();
    _lockTimer = null;
  }

  void _startLockTimer(int seconds) {
    _stopLockTimer();
    setState(() {
      _lockSecondsRemaining = seconds > 0 ? seconds : _fallbackLockSeconds;
      _isPinLocked = true;
    });

    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_lockSecondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _lockSecondsRemaining = 0;
          _isPinLocked = false;
          _errorText = '';
        });
        return;
      }

      setState(() => _lockSecondsRemaining -= 1);
    });
  }

  void _close(bool verified) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(verified);
  }

  Future<void> _submitPin() async {
    final pinCode = _pinController.text.trim();
    if (!_TelegramBackupTileState._pinPattern.hasMatch(pinCode) ||
        _isSubmitting ||
        _isPinLocked) {
      return;
    }

    final phoneNumber = UserSession.phoneNumber.trim();
    if (phoneNumber.isEmpty) {
      setState(() {
        _errorText = 'Unable to verify PIN. Please login again.';
      });
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isSubmitting = true;
      _errorText = '';
    });

    try {
      final verifyResponse = await widget.authService.verifyPin(
        phoneNumber: phoneNumber,
        pinCode: pinCode,
      );
      if (!mounted) return;

      final success = verifyResponse['success'] == true;
      final errorCode = (verifyResponse['errorCode'] ?? '')
          .toString()
          .trim()
          .toUpperCase();
      final errorMsg = (verifyResponse['errorMsg'] ?? '').toString().trim();

      if (!success || errorCode.isNotEmpty) {
        final locked = errorCode == 'PIN_LOCKED';
        final rawLockSeconds = locked ? _computeLockSeconds(verifyResponse) : 0;
        final effectiveLockSeconds = locked
            ? (rawLockSeconds > 0 ? rawLockSeconds : _fallbackLockSeconds)
            : 0;

        if (locked) {
          _startLockTimer(effectiveLockSeconds);
        } else {
          _stopLockTimer();
        }

        setState(() {
          _isSubmitting = false;
          _isPinLocked = locked;
          _lockSecondsRemaining = effectiveLockSeconds;
          _errorText = _resolvePinErrorMessage(errorMsg, locked: locked);
        });
        return;
      }

      _stopLockTimer();
      _close(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorText = 'Unable to verify PIN right now. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinCode = _pinController.text.trim();
    final canSubmit =
        _TelegramBackupTileState._pinPattern.hasMatch(pinCode) &&
        !_isSubmitting &&
        !_isPinLocked;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F0F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF34313A),
        elevation: 0,
        leading: IconButton(
          onPressed: _isSubmitting ? null : () => _close(false),
          icon: const Icon(Icons.close),
        ),
        title: const Text(
          'Enter PIN',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Remove Telegram backup',
                  style: TextStyle(
                    color: Color(0xFF34313A),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your login PIN to remove Telegram OTP backup.',
                  style: TextStyle(
                    color: Color(0xFF756B73),
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _pinController,
                  autofocus: true,
                  enabled: !_isSubmitting && !_isPinLocked,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  obscureText: _hidePin,
                  maxLength: 4,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: InputDecoration(
                    counterText: '',
                    labelText: 'PIN',
                    hintText: '4 digits',
                    errorText: _errorText.isEmpty ? null : _errorText,
                    errorMaxLines: 2,
                    filled: true,
                    fillColor: const Color(0xFFFFF7FA),
                    suffixIcon: IconButton(
                      onPressed: _isPinLocked
                          ? null
                          : () => setState(() => _hidePin = !_hidePin),
                      icon: Icon(
                        _hidePin ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _accent, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE6CCD8)),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE6CCD8)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _accent),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _accent, width: 1.5),
                    ),
                  ),
                  onChanged: (_) {
                    setState(() {
                      if (_errorText.isNotEmpty) _errorText = '';
                    });
                  },
                  onSubmitted: (_) => _submitPin(),
                ),
                if (_isPinLocked) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Try again in ${_formatCountdown(_lockSecondsRemaining)}',
                    style: const TextStyle(
                      color: Color(0xFF756B73),
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: canSubmit ? _submitPin : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFF3D6E2),
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isPinLocked ? 'Locked' : 'Confirm'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _isSubmitting ? null : () => _close(false),
                    style: TextButton.styleFrom(foregroundColor: _accent),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
