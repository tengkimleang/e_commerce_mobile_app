// lib/modules/term_condition_screen/views/term_condition_view.dart
import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Terms of Conditions',
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
              child: const Text('© 2024 Chip Mong Retails. All rights reserved.', style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white)),
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
          const Text(
            'Privacy Policy',
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
    final intro =
        "At CHIP MONG RETAIL APP, we are committed to protecting Customers' privacy and ensuring Customers' personal information is handled in a safe and responsible manner. This Privacy Policy outlines how we collect, use, disclose, and protect your information when you use our mobile application (the “App”) and any services provided through the App (collectively, the “Service”).";

    const sectionTitle1 = '1. Personal Data Protection Principles';
    const sectionBodyIntro =
        'We are conducting the following efforts to ensure the basic policy of personal data protection:';

    const bulletItems = [
      'All executives and employees shall adhere to applicable laws, regulations, and internal policies regarding personal data protection.',
      'We will regularly review and update our personal data protection policies and practices to ensure they remain effective and compliant with relevant laws and regulations.',
      'We will provide regular training and awareness programs to our employees to ensure they understand their responsibilities regarding personal data protection and are equipped to handle personal data securely.',
    ];

    const sectionTitle2 = '2. How We Handle Your Personal Information';
    const sectionBody2 =
        'We will clarify the purpose of collecting and using personal information, and we will not use it for any other purposes without your consent. We will take appropriate measures to protect your personal information from unauthorized access, disclosure, alteration, or destruction. We will not share your personal information with third parties without your consent, except as required by law or as necessary to provide our services.';
    const sectionTitle3 = '3. How We Use Your Information';
    const sectionBody3 =
        'We may use the infomation we collect for various purposes, including to:';
        
    const bulletItems2 = ['Provide, operate, and maintain our App and services',
      'Improve, personalize, and expand our App and services',
      'Understand and analyze how you use our App and services',
      'Develop new products, services, features, and functionality',
      'Communicate with you, either directly or through one of our partners, including for customer service, to provide you with updates and other information relating to the App, and for marketing and promotional purposes',
      'Process your transactions and manage your orders',
      'Send you text messages and push notifications',
      'Find and prevent fraud',
      'Comply with legal obligations'
    ];
    const sectionBody4 = 'CHIP MONG RETAIL APP will not sell, rent, or lease your personal information to third parties. We may share your personal information with third-party service providers who perform services on our behalf, such as payment processing, data analysis, email delivery, hosting services, customer service, and marketing assistance. These third-party service providers are contractually obligated to protect your personal information and only use it for the purposes for which we disclose it to them. We may also disclose your personal information if required to do so by law or in response to valid requests by public authorities (e.g., a court or a government agency).';
    
    const sectionTitle4 = '4. Your Choices';
  const sectionBody5 = [
    'You may opt-out of receiving promotional communications from us by following the unsubscribe instructions in any marketing email we send you',
    'You have the right to access, correct, or delete your personal information',
    'You may disable cookies through your browser settings',
  ];
  const sectionTitle5 = '5. Sharing Your Information';
  const sectionBody6 = 'We may share your personal information in the following circumstances:';
    const bulletItems3 = [
      'All executives and employees shall adhere to applicable laws, regulations, and internal policies regarding personal data protection.',
      'We will regularly review and update our personal data protection policies and practices to ensure they remain effective and compliant with relevant laws and regulations.',
      'We will provide regular training and awareness programs to our employees to ensure they understand their responsibilities regarding personal data protection and are equipped to handle personal data securely.',
    ];
    const sectionTitle6 = '6. Data Security';
    const sectionBody7 = 'We take reasonable measures to protect your personal information from unauthorized access, disclosure, alteration, and destruction. However, no method of transmission over the Internet or method of electronic storage is 100% secure. Therefore, we cannot guarantee its absolute security.';
    const sectionTitle7 = '7. Changes to This Privacy Policy';
    const sectionBody8 = 'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page. You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.';
    const sectionTitle8 = '8. Contact Us';
    const sectionBody9 = 'If you have any questions about this Privacy Policy, please contact us at:';
    const sectionBody10 = 'Phone: (855) 90 877 811';

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
          style: const TextStyle(
            color: Color(0xFFEC407A),
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          sectionBodyIntro,
          style: const TextStyle(
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
          style: const TextStyle(
            color: Color(0xFFEC407A),
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
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
          style: const TextStyle(
            color: Color(0xFFEC407A),
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
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
        const Text(
          sectionBody4,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          sectionTitle4,
          style: const TextStyle(
            color: Color(0xFFEC407A),
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        ...sectionBody5.map(
          (item) => _BulletItem(text: item, leftPadding: 0),
          
        ),
        const SizedBox(height: 28),
        Text(
          sectionTitle5,
          style: const TextStyle(
            color: Color(0xFFEC407A),
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          sectionBody6,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        ...bulletItems3.map(
          (item) => _BulletItem(text: item),
        ),
        const SizedBox(height: 28),
        const Text(
          sectionTitle6,
          style: const TextStyle(
            color: Color(0xFFEC407A),     
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          sectionBody7,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          sectionTitle7,
          style: const TextStyle(
            color: Color(0xFFEC407A),
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          sectionBody8,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          sectionTitle8,
          style: const TextStyle(
            color: Color(0xFFEC407A),
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          sectionBody9,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
       
        const Text(
          sectionBody10,
          style: TextStyle(
            color: Color(0xFFEC407A),
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
