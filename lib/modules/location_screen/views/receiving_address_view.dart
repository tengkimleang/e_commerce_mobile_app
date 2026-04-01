import 'package:flutter/material.dart';

class ReceivingAddressView extends StatefulWidget {
  const ReceivingAddressView({super.key, this.initialAddress = ''});

  final String initialAddress;

  @override
  State<ReceivingAddressView> createState() => _ReceivingAddressViewState();
}

class _ReceivingAddressViewState extends State<ReceivingAddressView> {
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.initialAddress);
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    final value = _addressController.text.trim();
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC0C6E);
    final canSave = _addressController.text.trim().isNotEmpty;

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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Address',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF8E8B96),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              onChanged: (_) => setState(() {}),
              minLines: 3,
              maxLines: 5,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Enter your address',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                _addressController.text = 'Current Location';
                _addressController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _addressController.text.length),
                );
                setState(() {});
              },
              icon: const Icon(Icons.my_location, color: accent),
              label: const Text(
                'Use Current Location',
                style: TextStyle(color: accent, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: canSave ? _saveAddress : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                disabledBackgroundColor: const Color(0xFFE2E2E7),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Save Address',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
