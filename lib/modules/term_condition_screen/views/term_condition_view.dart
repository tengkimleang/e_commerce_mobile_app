// lib/modules/term_condition_screen/views/term_condition_view.dart
import 'package:flutter/material.dart';
import 'package:e_commerce_mobile_app/l10n/generated/app_localizations.dart';

enum TermConditionType { termsOfUse, privacyPolicy }

class TermsOfUseView extends StatelessWidget {
  const TermsOfUseView({super.key});

  @override
  Widget build(BuildContext context) {
    return const TermConditionView(type: TermConditionType.termsOfUse);
  }
}

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const TermConditionView(type: TermConditionType.privacyPolicy);
  }
}

class TermConditionView extends StatelessWidget {
  const TermConditionView({super.key, required this.type});

  final TermConditionType type;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.termsOfConditionsTitle,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 25,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Banner(type: type),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: _PolicyContent(type: type),
            ),
            Container(
              alignment: Alignment.center,
              color: Colors.grey[700],
              padding: const EdgeInsets.all(16.0),
              child: Text(
                AppLocalizations.of(context)!.copyrightNotice,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.type});

  final TermConditionType type;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      color: primary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        children: [
          Container(
            width: 94,
            height: 94,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Image.asset(
                'assets/images/Chipmong_Logo.png',
                fit: BoxFit.contain,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            AppLocalizations.of(context)!.privacyPolicyTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyContent extends StatelessWidget {
  const _PolicyContent({required this.type});

  final TermConditionType type;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context)!;
    final intro = l10n.privacyPolicyIntro;

    final sectionTitle1 = l10n.privacyPolicySection1Title;
    final sectionBodyIntro = l10n.privacyPolicySection1Intro;

    final bulletItems = [
      l10n.privacyPolicySection1Bullet1,
      l10n.privacyPolicySection1Bullet2,
      l10n.privacyPolicySection1Bullet3,
    ];

    final sectionTitle2 = l10n.privacyPolicySection2Title;
    final sectionBody2 = l10n.privacyPolicySection2Body;
    final sectionTitle3 = l10n.privacyPolicySection3Title;
    final sectionBody3 = l10n.privacyPolicySection3Intro;

    final bulletItems2 = [
      l10n.privacyPolicySection3Bullet1,
      l10n.privacyPolicySection3Bullet2,
      l10n.privacyPolicySection3Bullet3,
      l10n.privacyPolicySection3Bullet4,
      l10n.privacyPolicySection3Bullet5,
      l10n.privacyPolicySection3Bullet6,
      l10n.privacyPolicySection3Bullet7,
      l10n.privacyPolicySection3Bullet8,
      l10n.privacyPolicySection3Bullet9,
    ];
    final sectionBody4 = l10n.privacyPolicySection3Body;

    final sectionTitle4 = l10n.privacyPolicySection4Title;
    final sectionBody5 = [
      l10n.privacyPolicySection4Bullet1,
      l10n.privacyPolicySection4Bullet2,
      l10n.privacyPolicySection4Bullet3,
    ];
    final sectionTitle5 = l10n.privacyPolicySection5Title;
    final sectionBody6 = l10n.privacyPolicySection5Intro;
    final bulletItems3 = [
      l10n.privacyPolicySection5Bullet1,
      l10n.privacyPolicySection5Bullet2,
      l10n.privacyPolicySection5Bullet3,
    ];
    final sectionTitle6 = l10n.privacyPolicySection6Title;
    final sectionBody7 = l10n.privacyPolicySection6Body;
    final sectionTitle7 = l10n.privacyPolicySection7Title;
    final sectionBody8 = l10n.privacyPolicySection7Body;
    final sectionTitle8 = l10n.privacyPolicySection8Title;
    final sectionBody9 = l10n.privacyPolicySection8Intro;
    final sectionBody10 = l10n.privacyPolicyPhone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          intro,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          sectionTitle1,
          style: TextStyle(
            color: primary,
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          sectionBodyIntro,
          style: TextStyle(
            color: Color.fromARGB(221, 86, 84, 84),
            fontSize: 20,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        ...bulletItems.map((item) => _BulletItem(text: item)),
        const SizedBox(height: 28),
        Text(
          sectionTitle2,
          style: TextStyle(
            color: primary,
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          sectionBody2,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          sectionTitle3,
          style: TextStyle(
            color: primary,
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          sectionBody3,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        ...bulletItems2.map((item) => _BulletItem(text: item)),
        const SizedBox(height: 28),
        Text(
          sectionBody4,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          sectionTitle4,
          style: TextStyle(
            color: primary,
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        ...sectionBody5.map((item) => _BulletItem(text: item, leftPadding: 0)),
        const SizedBox(height: 28),
        Text(
          sectionTitle5,
          style: TextStyle(
            color: primary,
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          sectionBody6,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        ...bulletItems3.map((item) => _BulletItem(text: item)),
        const SizedBox(height: 28),
        Text(
          sectionTitle6,
          style: TextStyle(
            color: primary,
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          sectionBody7,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          sectionTitle7,
          style: TextStyle(
            color: primary,
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          sectionBody8,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          sectionTitle8,
          style: TextStyle(
            color: primary,
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          sectionBody9,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),

        Text(
          sectionBody10,
          style: TextStyle(
            color: primary,
            fontSize: 20,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.text, this.leftPadding = 14});

  final String text;
  final double leftPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: leftPadding, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              '•',
              style: TextStyle(
                fontSize: 20,
                height: 1,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 20,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
