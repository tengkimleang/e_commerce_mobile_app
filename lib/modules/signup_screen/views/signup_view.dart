import 'dart:async' show TimeoutException;

import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/services/auth_service.dart';
import 'package:e_commerce_mobile_app/modules/login_screen/views/otp_view.dart';
import 'package:e_commerce_mobile_app/modules/term_condition_screen/views/term_condition_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final AuthService _authService = AuthService();

  bool _isPhoneValid = false;
  bool _showFullNameError = false;
  bool _isSubmitting = false;

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

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    final fullName = _fullNameController.text.trim();

    final isPhoneValid = _isValidPhone(phone);
    final isFullNameValid = fullName.isNotEmpty;

    if (!isPhoneValid || !isFullNameValid) {
      setState(() {
        _isPhoneValid = isPhoneValid;
        _showFullNameError = !isFullNameValid;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _showFullNameError = false;
    });

    try {
      await _authService.requestOtp(phone);

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpView(phoneNumber: phone),
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      String title;
      String message;
      IconData icon;
      Color iconColor;

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        title = 'No Connection';
        message =
            'No internet connection. Please check your network and try again.';
        icon = Icons.wifi_off_rounded;
        iconColor = Colors.orangeAccent;
      } else if (e.response != null) {
        title = 'Request Failed';
        message = e.response?.data?['errorMsg'] ??
            'Server error. Please try again later.';
        icon = Icons.cloud_off_rounded;
        iconColor = Colors.redAccent;
      } else {
        title = 'Something Went Wrong';
        message = 'Unable to reach the server. Please try again.';
        icon = Icons.warning_amber_rounded;
        iconColor = Colors.red;
      }

      _showErrorDialog(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
      );
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showErrorDialog(
        title: 'Request Timed Out',
        message: 'Please check your connection and try again.',
        icon: Icons.wifi_off_rounded,
        iconColor: Colors.orangeAccent,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showErrorDialog(
        title: 'Request Failed',
        message: e.toString().replaceFirst('Exception: ', ''),
        icon: Icons.error_outline_rounded,
        iconColor: const Color(0xFFEC407A),
      );
    }
  }

  void _showErrorDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
            ),
            const SizedBox(height: 20),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEC407A),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
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
              const Text('Phone number', style: TextStyle(fontSize: 15)),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) => setState(
                  () => _isPhoneValid = _isValidPhone(value.trim()),
                ),
                decoration: InputDecoration(
                  hintText: 'Enter phone number',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              const Text('Full name', style: TextStyle(fontSize: 15)),
              const SizedBox(height: 8),
              TextField(
                controller: _fullNameController,
                onChanged: (_) => setState(() {
                  _showFullNameError = false;
                }),
                decoration: InputDecoration(
                  hintText: 'Enter full name',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  errorText:
                      _showFullNameError ? 'Please enter your full name' : null,
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
                  final isButtonEnabled =
                      _isPhoneValid &&
                      _fullNameController.text.trim().isNotEmpty &&
                      !_isSubmitting;

                  return SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isButtonEnabled ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEC407A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.2,
                              ),
                            )
                          : const Text(
                              'NEXT',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
