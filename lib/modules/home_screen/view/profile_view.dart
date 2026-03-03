import 'package:e_commerce_mobile_app/modules/term_condition_screen/views/term_condition_view.dart';
import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

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
                    Container(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
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
                                  Positioned(
                                    right: -2,
                                    bottom: 4,
                                    child: Container(
                                      width: 38,
                                      height: 38,
                                      decoration: const BoxDecoration(
                                        color: accent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
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
                                fontSize: 44,
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
                                fontSize: 28,
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
                                  fontSize: 48,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1D1B22),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Account Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D1B22),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Phone number:',
                            style: TextStyle(fontSize: 18, color: Color(0xFF9B9B9B)),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '(+855) 96 326 7044',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF3B3B3B),
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
                                Icon(Icons.check_circle, color: Color(0xFF0D9A58), size: 18),
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
                          const SizedBox(height: 24),
                          const Divider(height: 1, color: Color(0xFFE6E2E8)),
                          const SizedBox(height: 24),
                          const Text(
                            'Account Security',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D1B22),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _SecurityRow(
                            title: 'Change PIN:',
                            value: '****',
                            trailingText: 'Change',
                            onTap: () {},
                          ),
                          const SizedBox(height: 18),
                          const Divider(height: 1, color: Color(0xFFD7D1D6)),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Login with Face ID:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF9B9B9B),
                                  ),
                                ),
                              ),
                              Switch(
                                value: true,
                                activeColor: accent,
                                onChanged: (_) {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const Divider(height: 1, color: Color(0xFFD7D1D6)),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Term of Condition',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF9B9B9B),
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
                          const SizedBox(height: 18),
                          const Divider(height: 1, color: Color(0xFFD7D1D6)),
                          const SizedBox(height: 18),
                          const Text(
                            'Account Deletion',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF9B9B9B),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Delete Account!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D1B22),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'v1.8.3 | 1830',
                              style: TextStyle(
                                color: Color(0xFFCFA6BD),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE8E8ED),
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
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _ProfileBottomNav(
              selectedIndex: 4,
              onHomeTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
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
                style: const TextStyle(fontSize: 18, color: Color(0xFF9B9B9B)),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
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

class _ProfileBottomNav extends StatelessWidget {
  const _ProfileBottomNav({
    required this.selectedIndex,
    required this.onHomeTap,
  });

  final int selectedIndex;
  final VoidCallback onHomeTap;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC407A);

    Widget navItem({required int index, required IconData icon, VoidCallback? onTap}) {
      final selected = index == selectedIndex;
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: selected ? const EdgeInsets.all(10) : const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: selected ? accent : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 30, color: selected ? Colors.white : accent),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navItem(index: 0, icon: Icons.home_outlined, onTap: onHomeTap),
            navItem(index: 1, icon: Icons.local_offer_outlined),
            navItem(index: 2, icon: Icons.qr_code_2),
            navItem(index: 3, icon: Icons.assignment_outlined),
            navItem(index: 4, icon: Icons.person),
          ],
        ),
      ),
    );
  }
}