import 'package:flutter/material.dart';

class ReceivingAddressView extends StatelessWidget {
  const ReceivingAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC0C6E);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
        ),
        title: const Text(
          'Receiving address',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1D1B24),
          ),
        ),
      ),
      body: const SizedBox.expand(),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 88,
          decoration: const BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
            ),
            child: const Text(
              'Use Current Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}
