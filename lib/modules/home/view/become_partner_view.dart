import 'package:flutter/material.dart';

class BecomePartnerView extends StatelessWidget {
  const BecomePartnerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Become Partner'), backgroundColor: const Color(0xFFEC407A)),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Partner registration form / details go here.'),
        ),
      ),
    );
  }
}
