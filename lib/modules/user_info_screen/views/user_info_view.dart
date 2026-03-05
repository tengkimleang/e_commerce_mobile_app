import 'package:e_commerce_mobile_app/modules/bottom_navigation/views/supermarket_bottom_navigation.dart';
import 'package:e_commerce_mobile_app/modules/order_history_screen/views/order_history_view.dart';
import 'package:e_commerce_mobile_app/modules/promotion_screen/views/promotion_view.dart';
import 'package:e_commerce_mobile_app/modules/qr_code_screen/views/qr_code_view.dart';
import 'package:e_commerce_mobile_app/modules/term_condition_screen/views/term_condition_view.dart';
import 'package:flutter/material.dart';

class UserInfoView extends StatelessWidget {
  const UserInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _HeaderCard(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle(title: 'Personal Information'),
                          const SizedBox(height: 18),
                          const _InfoRow(
                            label: 'Your Name:',
                            value: 'Jame Taki',
                            trailingIcon: Icons.edit,
                            trailingColor: accent,
                          ),
                          const Divider(height: 28, color: Color(0xFFD7D1D6)),
                          const _InfoRow(
                            label: 'Date of Birth:',
                            value: 'Not Added',
                            trailingIcon: Icons.edit,
                            trailingColor: accent,
                          ),
                          const Divider(height: 28, color: Color(0xFFD7D1D6)),
                          const _InfoRow(
                            label: 'Address',
                            value: '',
                            trailingIcon: Icons.chevron_right,
                            trailingColor: accent,
                          ),
                          const Divider(height: 28, color: Color(0xFFD7D1D6)),
                          const _InfoRow(
                            label: 'Language',
                            value: 'English',
                            trailingIcon: Icons.translate,
                            trailingColor: accent,
                          ),
                          const SizedBox(height: 12),
                          const Divider(thickness: 8, color: Color(0xFFEDEAF1)),
                          const SizedBox(height: 20),
                          const _SectionTitle(title: 'Account Information'),
                          const SizedBox(height: 18),
                          const Text(
                            'Phone number:',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFFB0AAB3),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '(+855) 96 909 098',
                            style: TextStyle(
                              fontSize: 20,
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
                            onTap: () {},
                          ),
                          const Divider(height: 30, color: Color(0xFFD7D1D6)),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Login with Face ID:',
                                  style: TextStyle(
                                    fontSize: 18,
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
                                    fontSize: 18,
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
                                  style: TextStyle(fontSize: 18, color: accent),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 30, color: Color(0xFFD7D1D6)),
                          const Text(
                            'Account Deletion',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFFB0AAB3),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Delete Account!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D1B22),
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
                              onPressed: () {},
                              child: const Text(
                                'Logout',
                                style: TextStyle(fontSize: 20),
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
      bottomNavigationBar: SupermarketBottomNavigation(
        selectedIndex: 4,
        onTap: (index) => _onBottomNavTap(context, index),
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
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.favorite_border, color: accent, size: 30),
              SizedBox(width: 22),
              Icon(Icons.notifications_none, color: accent, size: 30),
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
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFFEAA4C3),
                    ),
                  ),
                  const Positioned(
                    right: -2,
                    bottom: 4,
                    child: CircleAvatar(
                      radius: 19,
                      backgroundColor: accent,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Jame Taki',
              style: TextStyle(
                fontSize: 24,
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
                fontSize: 18,
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
                  fontSize: 18,
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
        fontSize: 20,
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
  });

  final String label;
  final String value;
  final IconData trailingIcon;
  final Color trailingColor;

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
                style: const TextStyle(fontSize: 18, color: Color(0xFFB0AAB3)),
              ),
              if (value.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF34313A),
                  ),
                ),
              ],
            ],
          ),
        ),
        Icon(trailingIcon, color: trailingColor, size: 30),
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
                style: const TextStyle(fontSize: 18, color: Color(0xFFB0AAB3)),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 36,
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
            style: const TextStyle(fontSize: 18, color: Color(0xFFEC407A)),
          ),
        ),
      ],
    );
  }
}
