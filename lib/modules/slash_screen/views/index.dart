import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_mobile_app/core/localization/app_language.dart';
import 'package:e_commerce_mobile_app/core/localization/language_cubit.dart';
import 'package:e_commerce_mobile_app/l10n/generated/app_localizations.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/views/profile_image_source_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_commerce_mobile_app/core/common/auth_required_dialog.dart';
import 'package:e_commerce_mobile_app/core/services/auth_service.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/models/user_info_model.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/repositories/user_info_repository.dart';
import '../../chipmong_screen/views/chipmong_mall_screen.dart';
import '../../home_screen/view/supermarket_main_screen.dart';
import '../../user_info_screen/views/edit_language_view.dart';
import '../../login_screen/views/login_view.dart';

class IndexView extends StatefulWidget {
  const IndexView({super.key});

  @override
  State<IndexView> createState() => _IndexViewState();
}

class _IndexViewState extends State<IndexView> {
  final AuthService _authService = AuthService();
  final UserInfoRepository _userInfoRepository = UserInfoRepository();
  String? _profileImagePath;
  String _profileImageUrl = '';
  UserInfoModel? _userInfo;
  final GlobalKey _menuButtonKey = GlobalKey();
  bool get _isAuthenticated => UserSession.isAuthenticated;

  String get _displayName {
    final name = UserSession.displayName.trim();
    return name.isEmpty ? 'User' : name;
  }

  @override
  void initState() {
    super.initState();
    UserInfoRepository.userInfoChanges.addListener(_handleUserInfoChanged);
    _loadProfileImage();
  }

  @override
  void dispose() {
    UserInfoRepository.userInfoChanges.removeListener(_handleUserInfoChanged);
    super.dispose();
  }

  void _handleUserInfoChanged() {
    final userInfo = UserInfoRepository.userInfoChanges.value;
    if (!mounted || userInfo == null) return;

    setState(() {
      _userInfo = userInfo;
      _profileImagePath = userInfo.profileImagePath;
      _profileImageUrl = userInfo.profileImageUrl;
    });
  }

  Future<void> _loadProfileImage() async {
    if (!_isAuthenticated) return;

    final userInfo = await _userInfoRepository.loadUserInfo(
      fallbackLanguageCode: AppLanguage.currentLanguageCode,
    );
    if (!mounted) return;

    setState(() {
      _userInfo = userInfo;
      _profileImagePath = userInfo.profileImagePath;
      _profileImageUrl = userInfo.profileImageUrl;
    });
  }

  Future<void> _openLanguageSelector() async {
    final selectedCode = await showLanguageBottomSheet(
      context,
      selectedLanguageCode: context.read<LanguageCubit>().state.languageCode,
    );

    if (!mounted || selectedCode == null) {
      return;
    }

    await context.read<LanguageCubit>().changeLanguage(selectedCode);
  }

  List<PopupMenuEntry<_BurgerMenuAction>> _buildBurgerMenuItems() {
    final accent = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context);
    final languageCode = context.read<LanguageCubit>().state.languageCode;
    final options = <_BurgerMenuItemData>[
      if (_isAuthenticated)
        _BurgerMenuItemData(
          action: _BurgerMenuAction.setProfilePhoto,
          icon: Icons.camera_alt_outlined,
          label: l10n.setProfilePhoto,
        ),
      _BurgerMenuItemData(
        action: _BurgerMenuAction.language,
        icon: Icons.g_translate_outlined,
        label: AppLanguage.labelFor(languageCode),
      ),
      if (_isAuthenticated)
        _BurgerMenuItemData(
          action: _BurgerMenuAction.logout,
          icon: Icons.logout_rounded,
          label: l10n.logout,
        ),
    ];

    return [
      for (final option in options)
        PopupMenuItem<_BurgerMenuAction>(
          value: option.action,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Icon(option.icon, color: accent, size: 22),
              const SizedBox(width: 14),
              Text(
                option.label,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF2E2E2E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
    ];
  }

  Future<void> _openBurgerMenu() async {
    final buttonContext = _menuButtonKey.currentContext;
    if (buttonContext == null) return;

    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    final button = buttonContext.findRenderObject() as RenderBox?;
    if (overlay == null || button == null) return;

    final topLeft = button.localToGlobal(Offset.zero, ancestor: overlay);
    final buttonRect = Rect.fromLTWH(
      topLeft.dx,
      topLeft.dy,
      button.size.width,
      button.size.height,
    );

    const popupWidth = 260.0;
    final left = (buttonRect.right - popupWidth).clamp(
      16.0,
      overlay.size.width - popupWidth - 16,
    );
    final top = buttonRect.bottom + 10;
    final estimatedHeight = _isAuthenticated ? 190.0 : 78.0;
    final menuRect = Rect.fromLTWH(left, top, popupWidth, estimatedHeight);

    final action = await showMenu<_BurgerMenuAction>(
      context: context,
      color: Colors.white,
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      position: RelativeRect.fromRect(menuRect, Offset.zero & overlay.size),
      items: _buildBurgerMenuItems(),
    );

    if (!mounted || action == null) return;

    switch (action) {
      case _BurgerMenuAction.language:
        await _openLanguageSelector();
      case _BurgerMenuAction.setProfilePhoto:
        await _openProfilePhotoSelector();
      case _BurgerMenuAction.logout:
        await _showLogoutBottomSheet();
    }
  }

  Future<void> _openProfilePhotoSelector() async {
    final source = await showProfileImageSourceBottomSheet(context);
    if (!mounted || source == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (!mounted || pickedFile == null) return;

    setState(() => _profileImagePath = pickedFile.path);

    final current =
        (_userInfo ??
                await _userInfoRepository.loadUserInfo(
                  fallbackLanguageCode: AppLanguage.currentLanguageCode,
                ))
            .copyWith(profileImagePath: pickedFile.path);
    final updated = await _userInfoRepository.uploadProfileImage(
      current: current,
      localPath: pickedFile.path,
    );
    if (!mounted) return;

    setState(() {
      _userInfo = updated;
      _profileImagePath = updated.profileImagePath;
      _profileImageUrl = updated.profileImageUrl;
    });
  }

  Future<void> _showLogoutBottomSheet() async {
    final accent = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context);
    final shouldLogout = await showModalBottomSheet<bool>(
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
            Text(
              l10n.logout,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D1B22),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.reallyWantToLogout,
              style: const TextStyle(fontSize: 15, color: Color(0xFF1D1B22)),
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
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(fontSize: 15),
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
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(
                        l10n.yes,
                        style: const TextStyle(fontSize: 15),
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

    if (!mounted || shouldLogout != true) return;

    try {
      await _authService.logout();
    } catch (e) {
      debugPrint('[IndexView] logout revoke failed: $e');
    }
    await UserSession.markGuest();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = math.min(
      350.0,
      math.max(0.0, MediaQuery.sizeOf(context).width - 24),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 70,
            top: 64,
            bottom: 30,
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: _isAuthenticated
                ? _GreetingHeader(
                    displayName: _displayName,
                    profileImagePath: _profileImagePath,
                    profileImageUrl: _profileImageUrl,
                  )
                : InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginView()),
                      );
                    },
                    child: const Text(
                      'Login or Signup',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
          ),
        ),
        actions: [
          IconButton(
            key: _menuButtonKey,
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: _openBurgerMenu,
          ),
        ],
        toolbarHeight: 280,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(32)),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),

            // Card 1 — stuck to the RIGHT
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () async {
                  if (UserSession.isGuest) {
                    await showAuthRequiredDialog(
                      context,
                      title: 'User not found',
                      message:
                          'Chip Mong Mall is available after Login or Signup',
                    );
                    return;
                  }

                  if (!context.mounted) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChipmongMallScreen(),
                    ),
                  );
                },
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  topLeft: Radius.circular(18),
                ),
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(18),
                      topLeft: Radius.circular(18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                        ),

                        child: CachedNetworkImage(
                          imageUrl:
                              'https://www.chipmong.com/wp-content/uploads/2020/04/2.Chip-mong-Supermarket-.jpg',
                          fit: BoxFit.cover,
                          height: 100,
                          width: cardWidth,
                          placeholder: (context, url) =>
                              Container(height: 100, color: Colors.grey[200]),
                          errorWidget: (context, url, error) => Container(
                            height: 100,
                            width: cardWidth,
                            color: Colors.grey[200],
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Chip Mong Mall",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Shopping global brand",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
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

            const SizedBox(height: 60),

            // Card 2 — stuck to the LEFT
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SupermarketMainView(),
                    ),
                  );
                },
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(18),
                        ),
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://www.chipmong.com/wp-content/uploads/portfolio/retail/598-Mall/2.jpg',
                          fit: BoxFit.cover,
                          height: 100,
                          width: cardWidth,
                          placeholder: (context, url) =>
                              Container(height: 100, color: Colors.grey[200]),
                          errorWidget: (context, url, error) => Container(
                            height: 100,
                            width: cardWidth,
                            color: Colors.grey[200],
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Chip Mong Supermarket",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Explore our marketplace.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
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

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

enum _BurgerMenuAction { setProfilePhoto, language, logout }

class _BurgerMenuItemData {
  const _BurgerMenuItemData({
    required this.action,
    required this.icon,
    required this.label,
  });

  final _BurgerMenuAction action;
  final IconData icon;
  final String label;
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({
    required this.displayName,
    required this.profileImagePath,
    required this.profileImageUrl,
  });

  final String displayName;
  final String? profileImagePath;
  final String profileImageUrl;

  @override
  Widget build(BuildContext context) {
    final imagePath = profileImagePath?.trim() ?? '';
    final imageUrl = profileImageUrl.trim();
    final token = (UserSession.token ?? '').trim();
    final imageHeaders = token.isEmpty
        ? null
        : <String, String>{'Authorization': 'Bearer $token'};

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 86,
          height: 86,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFE8B6CE),
              shape: BoxShape.circle,
            ),
            child: _GreetingAvatarImage(
              imagePath: imagePath,
              imageUrl: imageUrl,
              imageHeaders: imageHeaders,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Hello,\n$displayName',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            height: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _GreetingAvatarImage extends StatelessWidget {
  const _GreetingAvatarImage({
    required this.imagePath,
    required this.imageUrl,
    required this.imageHeaders,
  });

  final String imagePath;
  final String imageUrl;
  final Map<String, String>? imageHeaders;

  @override
  Widget build(BuildContext context) {
    if (imagePath.isNotEmpty && File(imagePath).existsSync()) {
      return ClipOval(
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, error, stackTrace) => _fallbackIcon(),
        ),
      );
    }

    if (imageUrl.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          httpHeaders: imageHeaders,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (_, _) => Container(color: const Color(0xFFE8B6CE)),
          errorWidget: (_, _, _) => _fallbackIcon(),
        ),
      );
    }

    return _fallbackIcon();
  }

  Widget _fallbackIcon() {
    return const Icon(Icons.person, color: Colors.white, size: 42);
  }
}
