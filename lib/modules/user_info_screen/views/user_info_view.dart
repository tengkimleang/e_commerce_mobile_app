import 'dart:io';

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
import 'package:e_commerce_mobile_app/modules/login_screen/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/blocs/user_info_bloc.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/blocs/user_info_event.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/blocs/user_info_state.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/models/user_info_model.dart';

class UserInfoView extends StatelessWidget {
  final bool showBottomNavigation;

  const UserInfoView({super.key, this.showBottomNavigation = true});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);

    return BlocProvider(
      create: (_) => UserInfoBloc(),
      child: BlocBuilder<UserInfoBloc, UserInfoState>(
        builder: (context, state) {
          final userInfo = state is UserInfoUpdated
              ? state.userInfo
              : state is UserInfoInitial
                  ? state.userInfo
                  : UserInfoModel.initial();

          final String username = userInfo.username;
          final DateTime? dateOfBirth = userInfo.dateOfBirth;
          final String languageCode = userInfo.languageCode;
          final File? profileImageFile = userInfo.profileImagePath != null
              ? File(userInfo.profileImagePath!)
              : null;

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
                            profileImageFile: profileImageFile,
                            onTapCamera: () => _pickProfileImage(context),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SectionTitle(title: 'Personal Information'),
                                const SizedBox(height: 18),
                                _InfoRow(
                                  label: 'Your Name:',
                                  value: username,
                                  trailingIcon: Icons.edit,
                                  trailingColor: accent,
                                  onTrailingTap: () => _openEditUsername(context, username),
                                ),
                                const Divider(height: 28, color: Color(0xFFD7D1D6)),
                                _InfoRow(
                                  label: 'Date of Birth:',
                                  value: dateOfBirthLabel(),
                                  trailingIcon: Icons.edit,
                                  trailingColor: accent,
                                  onTrailingTap: () => _openEditDateOfBirth(context, dateOfBirth),
                                ),
                                const Divider(height: 28, color: Color(0xFFD7D1D6)),
                                _InfoRow(
                                  label: 'Address',
                                  value: '',
                                  trailingIcon: Icons.chevron_right,
                                  trailingColor: accent,
                                  onTrailingTap: () => _openReceivingAddress(context),
                                ),
                                const Divider(height: 28, color: Color(0xFFD7D1D6)),
                                _InfoRow(
                                  label: 'Language',
                                  value: languageLabel(),
                                  trailingIcon: Icons.g_translate,
                                  trailingColor: accent,
                                  onTrailingTap: () => _openEditLanguage(context, languageCode),
                                ),
                                const SizedBox(height: 12),
                                const Divider(thickness: 8, color: Color(0xFFEDEAF1)),
                                const SizedBox(height: 20),
                                const _SectionTitle(title: 'Account Information'),
                                const SizedBox(height: 18),
                                const Text(
                                  'Phone Number:',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFFB0AAB3),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '(+855) 96 909 098',
                                  style: TextStyle(
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
                                    color: const Color(0xFFDFF5E7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF0D9A58),
                                        size: 18,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Verified',
                                        style: TextStyle(
                                          color: Color(0xFF0D9A58),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const Divider(thickness: 8, color: Color(0xFFEDEAF1)),
                                const SizedBox(height: 20),
                                const _SectionTitle(title: 'Account Security'),
                                const SizedBox(height: 18),
                                _SecurityRow(
                                  title: 'Change PIN:',
                                  value: '****',
                                  trailingText: 'Change',
                                  onTap: () => _openChangePin(context),
                                ),
                                const Divider(height: 30, color: Color(0xFFD7D1D6)),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Login with Face ID:',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Color(0xFFB0AAB3),
                                        ),
                                      ),
                                    ),
                                    Switch(
                                      value: true,
                                      activeThumbColor: accent,
                                      activeTrackColor: const Color(0xFFF9DCEA),
                                      inactiveTrackColor: const Color(0xFFF9DCEA),
                                      onChanged: (_) {},
                                    ),
                                  ],
                                ),
                                const Divider(height: 30, color: Color(0xFFD7D1D6)),
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
                                            builder: (_) => const TermsOfUseView(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'See More',
                                        style: TextStyle(fontSize: 15, color: accent),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 30, color: Color(0xFFD7D1D6)),
                                const Text(
                                  'Account Deletion',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFFB0AAB3),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () => _showDeleteAccountDialog(context),
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
                                    onPressed: () => _showLogoutBottomSheet(context),
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
            bottomNavigationBar: showBottomNavigation
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

  Future<void> _openEditUsername(BuildContext context, String current) async {
    final updatedName = await showEditUsernameBottomSheet(
      context,
      initialUsername: current,
    );

    if (updatedName == null) return;
    final trimmed = updatedName.trim();
    if (trimmed.isEmpty || trimmed == current) return;

    context.read<UserInfoBloc>().add(UpdateUsername(trimmed));
  }

  Future<void> _openEditDateOfBirth(BuildContext context, DateTime? current) async {
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
    context.read<UserInfoBloc>().add(UpdateDateOfBirth(newDate));
  }

  Future<void> _openEditLanguage(BuildContext context, String currentCode) async {
    final selectedCode = await showLanguageBottomSheet(
      context,
      selectedLanguageCode: currentCode,
    );

    if (selectedCode == null || selectedCode == currentCode) return;
    context.read<UserInfoBloc>().add(UpdateLanguage(selectedCode));
  }

  Future<void> _openReceivingAddress(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ReceivingAddressView()));
  }

  Future<void> _openChangePin(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ChangePinOldPinView()));
  }

  Future<void> _pickProfileImage(BuildContext context) async {
    final source = await showProfileImageSourceBottomSheet(context);
    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (picked == null) return;
    context.read<UserInfoBloc>().add(UpdateProfileImage(picked.path));
  }

  void _showDeleteAccountDialog(BuildContext context) {
    const accent = Color(0xFFEC407A);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1D1B22),
                ),
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
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF1D1B22),
              ),
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
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginView()),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Yes',
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

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.username,
    required this.profileImageFile,
    required this.onTapCamera,
  });

  final String username;
  final File? profileImageFile;
  final VoidCallback onTapCamera;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);

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
                    child: profileImageFile != null
                        ? ClipOval(
                            child: Image.file(
                              profileImageFile!,
                              fit: BoxFit.cover,
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
              style:  TextStyle(
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
              const Text(
                '0',
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
