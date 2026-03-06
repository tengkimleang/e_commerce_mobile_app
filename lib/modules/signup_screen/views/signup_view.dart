import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce_mobile_app/modules/term_condition_screen/views/term_condition_view.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  
  bool _isPhoneValid = false;
  bool _isValidPhone(String phone) {
  final regex = RegExp(r'^0\d{8,9}$');
  return regex.hasMatch(phone);
}
  late TextEditingController _phoneController;
  late TextEditingController _fullNameController;
  late TapGestureRecognizer _termsTapRecognizer;
  late TapGestureRecognizer _privacyTapRecognizer;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _fullNameController = TextEditingController();
    _termsTapRecognizer = TapGestureRecognizer()..onTap = _openTermsOfUsePage;
    _privacyTapRecognizer = TapGestureRecognizer()..onTap = _openPrivacyPolicyPage;
  }

  void _openTermsOfUsePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsOfUseView()),
    );
  }

  void _openPrivacyPolicyPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyView()),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _fullNameController.dispose();
    _termsTapRecognizer.dispose();
    _privacyTapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: Image.network(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1OJzt6aExDeNZVojWp3jWz4CUcDC2Y4Nggg&s',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text('Phone number*', style: TextStyle(fontSize: 15)),
              const SizedBox(height: 8),
              TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              onChanged: (value) => setState(() => _isPhoneValid = _isValidPhone(value)),
              decoration: InputDecoration(
                hintText: 'Enter phone number',
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                errorText: (!_isPhoneValid && _phoneController.text.isNotEmpty)
                    ? 'Please enter a valid phone number'
                    : null,
              ),
            ),
              const SizedBox(height: 16),
              const Text('Full name*', style: TextStyle(fontSize: 15)),
              const SizedBox(height: 8),
             TextField(
              controller: _fullNameController,
              onChanged: (_) => setState((){}),
              decoration: InputDecoration(
                hintText: 'Full name',
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
              const SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
                  children: [
                    const TextSpan(text: 'By clicking Next button you are agreeing to the '),
                    TextSpan(
                      text: 'Terms of Use',
                      style: const TextStyle(color: Color(0xFFEC407A), decoration: TextDecoration.underline),
                      recognizer: _termsTapRecognizer,
                    ),
                    const TextSpan(text: ' and the '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: const TextStyle(color: Color(0xFFEC407A), decoration: TextDecoration.underline),
                      recognizer: _privacyTapRecognizer,
                    ),
                  ],
                ),
              ),
              const Spacer(),
Builder(
  builder: (context) {
    final isButtonEnabled = _isPhoneValid && _fullNameController.text.trim().isNotEmpty;
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isButtonEnabled
            ? () {
                // TODO: implement signup action / OTP flow
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEC407A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('NEXT', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  },
),
const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
