import 'package:flutter/material.dart';

class LoyaltyView extends StatelessWidget {
  const LoyaltyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loyalty'), backgroundColor: const Color(0xFFEC407A)),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Loyalty form / details go here.'),
        ),
      ),
    );
  }
}
