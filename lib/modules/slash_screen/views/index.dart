import 'package:flutter/material.dart';
import 'package:e_commerce_mobile_app/core/common/auth_required_dialog.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
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
  String _languageCode = 'en';
  bool get _isAuthenticated => UserSession.isAuthenticated;

  String get _displayName {
    final name = UserSession.displayName.trim();
    return name.isEmpty ? 'User' : name;
  }

  Future<void> _openLanguageSelector() async {
    final selectedCode = await showLanguageBottomSheet(
      context,
      selectedLanguageCode: _languageCode,
    );

    if (!mounted || selectedCode == null || selectedCode == _languageCode) {
      return;
    }

    setState(() => _languageCode = selectedCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFEC407A),
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
                ? _GreetingHeader(displayName: _displayName)
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
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: _openLanguageSelector,
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

                        child: Image.network(
                          'https://www.chipmong.com/wp-content/uploads/2020/04/2.Chip-mong-Supermarket-.jpg',
                          fit: BoxFit.cover,
                          height: 100,
                          width: 350,
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
                        child: Image.network(
                          'https://www.apacoutlookmag.com/media/chip-mong-retail-1-1597331139.profileImage.2x-1536x884.webp',
                          fit: BoxFit.cover,
                          height: 100,
                          width: 350,
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

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
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
            child: const Icon(Icons.person, color: Colors.white, size: 42),
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
