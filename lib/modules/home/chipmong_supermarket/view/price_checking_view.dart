import 'package:flutter/material.dart';

class PriceCheckingView extends StatelessWidget {
  const PriceCheckingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Price Checking'), backgroundColor: const Color(0xFFEC407A)),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Price checking functionality goes here.'),
        ),
      ),
    );
  }
}
