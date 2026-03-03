import 'package:flutter/material.dart';

enum TermConditionType { termsOfUse, privacyPolicy }

class TermConditionView extends StatelessWidget {
  const TermConditionView({super.key, required this.type});

  final TermConditionType type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Term of Condition',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 30,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Banner(type: type),
            Container(
              color: const Color(0xFFF2F2F4),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: _PolicyContent(type: type),
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
    return Container(
      color: const Color(0xFFEC407A),
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
            type == TermConditionType.privacyPolicy
                ? 'Privacy Policy'
                : 'Terms of Use',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
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
    final intro = type == TermConditionType.privacyPolicy
        ? "At CHIP MONG RETAIL APP, we are committed to protecting Customers' privacy and ensuring Customers' personal information is handled in a safe and responsible manner. This Privacy Policy outlines how we collect, use, disclose, and protect your information when you use our mobile application (the “App”) and any services provided through the App (collectively, the “Service”)."
        : "By using CHIP MONG RETAIL APP, you agree to these Terms of Use. These terms describe the conditions for accessing and using our app and services, including your rights and responsibilities when placing orders, using promotions, and interacting with content in the app.";
    final sectionTitle = type == TermConditionType.privacyPolicy
        ? '1. Personal Data Protection Principles'
        : '1. User Responsibilities';
    final sectionBody = type == TermConditionType.privacyPolicy
        ? 'We are conducting the following efforts to ensure the basic policy of personal data protection:'
        : 'You are responsible for providing accurate account information and for using the service in compliance with applicable laws and regulations.';

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
          sectionTitle,
          style: const TextStyle(
            color: Color(0xFFEC407A),
            fontSize: 30,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          sectionBody,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
