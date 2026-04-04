import 'dart:async';

import 'package:flutter/material.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';

import 'package:e_commerce_mobile_app/modules/bottom_navigation/views/supermarket_bottom_navigation.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/views/order_history_view.dart';
import 'package:e_commerce_mobile_app/modules/promotion_screen/views/promotion_view.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/repositories/user_info_repository.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/views/user_info_view.dart';
import '../models/mall_membership_qr_model.dart';
import '../repositories/mall_membership_qr_repository.dart';

class QrCodeView extends StatefulWidget {
  final bool showBottomNavigation;
  final bool? isGuest;

  const QrCodeView({super.key, this.showBottomNavigation = true, this.isGuest});

  @override
  State<QrCodeView> createState() => _QrCodeViewState();
}

class _QrCodeViewState extends State<QrCodeView> {
  late final UserInfoRepository _userInfoRepository;
  late Future<_SupermarketQrProfile> _profileFuture;

  bool get _guestMode => widget.isGuest ?? UserSession.isGuest;

  @override
  void initState() {
    super.initState();
    _userInfoRepository = UserInfoRepository();
    _profileFuture = _loadProfile();
  }

  Future<_SupermarketQrProfile> _loadProfile() async {
    if (_guestMode) return const _SupermarketQrProfile.guest();

    final sessionName = UserSession.displayName.trim();
    final sessionPhone = UserSession.phoneNumber.trim();
    var resolvedName = sessionName;
    var resolvedPhone = sessionPhone;
    var resolvedPoints = 0;

    try {
      final profile = await _userInfoRepository.loadUserInfo();
      final profileName = profile.username.trim();
      final profilePhone = profile.phoneNumber.trim();
      if (profileName.isNotEmpty) {
        resolvedName = profileName;
      }
      if (profilePhone.isNotEmpty) {
        resolvedPhone = profilePhone;
      }
      resolvedPoints = profile.points;
    } catch (_) {
      // Keep session fallback values.
    }

    if (resolvedName.isEmpty) {
      resolvedName = resolvedPhone.isEmpty ? 'User' : resolvedPhone;
    }

    return _SupermarketQrProfile(
      username: resolvedName,
      phone: resolvedPhone,
      points: resolvedPoints,
      isGuest: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: FutureBuilder<_SupermarketQrProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          final profile = snapshot.data ?? _SupermarketQrProfile.fromSession();
          final username = profile.isGuest ? '' : profile.username;
          final phone = profile.isGuest ? '' : profile.phone;
          final points = profile.points.toString();
          final usernameLabel = profile.isGuest
              ? '--------------------'
              : username;
          final phoneLabel = profile.isGuest ? '--------------------' : phone;

          final qrData = Uri.encodeComponent(
            'user:$username;phone:$phone;points:$points',
          );
          final qrUrl =
              'https://api.qrserver.com/v1/create-qr-code/?size=500x500&data=$qrData';

          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(26),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.09),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: SizedBox(
                    height: 86,
                    child: Center(
                      child: Text(
                        'QR Code',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 21,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
                  child: Column(
                    children: [
                      Image.network(
                        qrUrl,
                        width: 300,
                        height: 300,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 300,
                          height: 300,
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child: const Icon(Icons.qr_code_2, size: 64),
                        ),
                      ),
                      const SizedBox(height: 34),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEDED),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        child: Column(
                          children: [
                            _InfoRow(label: 'Username:', value: usernameLabel),
                            const SizedBox(height: 10),
                            const _DashedDivider(),
                            const SizedBox(height: 10),
                            _InfoRow(label: 'Phone number:', value: phoneLabel),
                            const SizedBox(height: 10),
                            const _DashedDivider(),
                            const SizedBox(height: 10),
                            _InfoRow(
                              label: 'Supermarket Point:',
                              value: points,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: widget.showBottomNavigation
          ? SupermarketBottomNavigation(
              selectedIndex: 2,
              onTap: (index) => _onBottomNavTap(context, index),
            )
          : null,
    );
  }

  void _onBottomNavTap(BuildContext context, int index) {
    if (index == 2) return;

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

    if (index == 3) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OrderHistoryView()),
      );
      return;
    }

    if (index == 4) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const UserInfoView()),
      );
    }
  }
}

class _SupermarketQrProfile {
  const _SupermarketQrProfile({
    required this.username,
    required this.phone,
    required this.points,
    required this.isGuest,
  });

  const _SupermarketQrProfile.guest()
    : username = '',
      phone = '',
      points = 0,
      isGuest = true;

  final String username;
  final String phone;
  final int points;
  final bool isGuest;

  factory _SupermarketQrProfile.fromSession() {
    if (UserSession.isGuest) {
      return const _SupermarketQrProfile.guest();
    }

    final sessionName = UserSession.displayName.trim();
    final sessionPhone = UserSession.phoneNumber.trim();
    final name = sessionName.isEmpty
        ? (sessionPhone.isEmpty ? 'User' : sessionPhone)
        : sessionName;

    return _SupermarketQrProfile(
      username: name,
      phone: sessionPhone,
      points: 0,
      isGuest: false,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.black87, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashCount = (constraints.maxWidth / 10).floor();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            dashCount,
            (_) => Container(
              width: 6,
              height: 1.2,
              color: const Color(0xFFCACACA),
            ),
          ),
        );
      },
    );
  }
}

// ===========================================================================
// QrCodeBody — embeddable widget used by ChipmongMallScreen QR tab
// ===========================================================================

class QrCodeBody extends StatefulWidget {
  final MallMembershipQrRepository? repository;

  const QrCodeBody({super.key, this.repository});

  @override
  State<QrCodeBody> createState() => _QrCodeBodyState();
}

class _QrCodeBodyState extends State<QrCodeBody> {
  static const _autoRefreshInterval = Duration(seconds: 90);

  late final MallMembershipQrRepository _repository;
  late final MallMembershipQrModel _fallback;
  late Future<MallMembershipQrModel> _membershipFuture;
  Timer? _autoRefreshTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? MallMembershipQrRepository();
    _fallback = _repository.buildLocalFallback();
    _membershipFuture = _repository.loadMembershipQr();
    _isRefreshing = true;
    _membershipFuture.whenComplete(() => _isRefreshing = false);
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(_autoRefreshInterval, (_) {
      _refreshMembershipData();
    });
  }

  void _refreshMembershipData() {
    if (!mounted || _isRefreshing) return;
    _isRefreshing = true;
    final nextFuture = _repository.loadMembershipQr();
    nextFuture.whenComplete(() => _isRefreshing = false);
    setState(() {
      _membershipFuture = nextFuture;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MallMembershipQrModel>(
      future: _membershipFuture,
      builder: (context, snapshot) {
        final data = snapshot.data ?? _fallback;
        final qrData = Uri.encodeComponent(data.qrPayload);
        final qrUrl =
            'https://api.qrserver.com/v1/create-qr-code/?size=500x500&data=$qrData';

        return Column(
          children: [
            _MallPointsBanner(points: data.points),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  children: [
                    if ((data.statusMessage ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _MallStatusNotice(message: data.statusMessage!),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Text(
                            'Auto refresh: 90s',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8E8E8E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed:
                                snapshot.connectionState ==
                                    ConnectionState.waiting
                                ? null
                                : _refreshMembershipData,
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFEC407A),
                              minimumSize: const Size(0, 34),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text(
                              'Refresh QR',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _MallQrFrame(qrUrl: qrUrl),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    const SizedBox(height: 32),
                    _MallMemberInfoCard(
                      name: data.username,
                      level: data.tierLevel,
                      id: data.membershipId,
                      type: data.membershipType,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Backend status notice
// ---------------------------------------------------------------------------
class _MallStatusNotice extends StatelessWidget {
  final String message;

  const _MallStatusNotice({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFC56B)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: Color(0xFFAF6A00),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFFAF6A00),
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pink points banner
// ---------------------------------------------------------------------------
class _MallPointsBanner extends StatelessWidget {
  final int points;

  const _MallPointsBanner({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF48FB1), Color(0xFFEC407A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available points',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontFamily: 'Battambang',
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$points',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.diamond_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 72,
            height: 56,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Icon(
                    Icons.monetization_on_rounded,
                    color: Colors.white.withValues(alpha: 0.35),
                    size: 52,
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 14,
                  child: Icon(
                    Icons.monetization_on_rounded,
                    color: Colors.white.withValues(alpha: 0.55),
                    size: 46,
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 26,
                  child: Icon(
                    Icons.monetization_on_rounded,
                    color: Colors.white.withValues(alpha: 0.75),
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animated QR frame with pink corner brackets
// ---------------------------------------------------------------------------
class _MallQrFrame extends StatefulWidget {
  final String qrUrl;

  const _MallQrFrame({required this.qrUrl});

  @override
  State<_MallQrFrame> createState() => _MallQrFrameState();
}

class _MallQrFrameState extends State<_MallQrFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scale = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bracketColor = Color(0xFFEC407A);
    const bracketSize = 44.0;
    const frameSize = 270.0;
    const qrSize = 200.0;

    return SizedBox(
      width: frameSize,
      height: frameSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            widget.qrUrl,
            width: qrSize,
            height: qrSize,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const SizedBox(
              width: qrSize,
              height: qrSize,
              child: Icon(Icons.qr_code_2, size: qrSize * 0.8),
            ),
          ),
          ScaleTransition(
            scale: _scale,
            child: Stack(
              children: [
                const SizedBox(width: frameSize, height: frameSize),
                const Positioned(
                  top: 0,
                  left: 0,
                  child: _MallCornerBracket(
                    isTop: true,
                    isLeft: true,
                    color: bracketColor,
                    size: bracketSize,
                  ),
                ),
                const Positioned(
                  top: 0,
                  right: 0,
                  child: _MallCornerBracket(
                    isTop: true,
                    isLeft: false,
                    color: bracketColor,
                    size: bracketSize,
                  ),
                ),
                const Positioned(
                  bottom: 0,
                  left: 0,
                  child: _MallCornerBracket(
                    isTop: false,
                    isLeft: true,
                    color: bracketColor,
                    size: bracketSize,
                  ),
                ),
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: _MallCornerBracket(
                    isTop: false,
                    isLeft: false,
                    color: bracketColor,
                    size: bracketSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MallCornerBracket extends StatelessWidget {
  final bool isTop;
  final bool isLeft;
  final Color color;
  final double size;

  const _MallCornerBracket({
    required this.isTop,
    required this.isLeft,
    required this.color,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MallCornerBracketPainter(
          isTop: isTop,
          isLeft: isLeft,
          color: color,
        ),
      ),
    );
  }
}

class _MallCornerBracketPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;
  final Color color;

  const _MallCornerBracketPainter({
    required this.isTop,
    required this.isLeft,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final x = isLeft ? 0.0 : size.width;
    final y = isTop ? 0.0 : size.height;
    final endX = isLeft ? size.width : 0.0;
    final endY = isTop ? size.height : 0.0;

    canvas.drawLine(Offset(x, y), Offset(endX, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, endY), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Member info card
// ---------------------------------------------------------------------------
class _MallMemberInfoCard extends StatelessWidget {
  final String name;
  final String level;
  final String id;
  final String type;

  const _MallMemberInfoCard({
    required this.name,
    required this.level,
    required this.id,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          _MallInfoRow(label: 'Username:', value: name),
          const _MallDashedDivider(),
          _MallInfoRow(label: 'Tier Level:', value: level),
          const _MallDashedDivider(),
          _MallInfoRow(label: 'Membership ID:', value: id),
          const _MallDashedDivider(),
          _MallInfoRow(label: 'Membership Type:', value: type),
        ],
      ),
    );
  }
}

class _MallInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _MallInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Battambang',
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _MallDashedDivider extends StatelessWidget {
  const _MallDashedDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dashCount = (constraints.maxWidth / 10).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              dashCount,
              (_) => Container(
                width: 6,
                height: 1.2,
                color: const Color(0xFFCACACA),
              ),
            ),
          );
        },
      ),
    );
  }
}
