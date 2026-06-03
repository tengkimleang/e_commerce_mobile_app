import 'dart:async';

import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:e_commerce_mobile_app/l10n/generated/app_localizations.dart';

class DeleteAccountPinView extends StatefulWidget {
  const DeleteAccountPinView({super.key});

  @override
  State<DeleteAccountPinView> createState() => _DeleteAccountPinViewState();
}

class _DeleteAccountPinViewState extends State<DeleteAccountPinView> {
  final AuthService _authService = AuthService();
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  bool _showPin = false;
  bool _isSubmitting = false;

  bool get _isComplete =>
      _controllers.every((controller) => controller.text.trim().isNotEmpty);
  String get _pinCode =>
      _controllers.map((controller) => controller.text).join();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (_) => TextEditingController());
    _focusNodes = List.generate(4, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < _focusNodes.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _clearPin() {
    for (final controller in _controllers) {
      controller.clear();
    }
    setState(() {});
    if (_focusNodes.isNotEmpty) {
      _focusNodes.first.requestFocus();
    }
  }

  String _formatLockMessage(Map<String, dynamic> result) {
    final rawLockUntil = (result['lockUntilUtc'] ?? '').toString().trim();
    final lockUntil = rawLockUntil.isEmpty
        ? null
        : DateTime.tryParse(rawLockUntil)?.toLocal();
    if (lockUntil == null) {
      return 'PIN is temporarily locked. Please try again later.';
    }
    final hour = lockUntil.hour.toString().padLeft(2, '0');
    final minute = lockUntil.minute.toString().padLeft(2, '0');
    return 'PIN is temporarily locked. Please try again after $hour:$minute.';
  }

  Future<void> _submit() async {
    if (!_isComplete || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final result = await _authService.deleteAccount(pinCode: _pinCode);
      if (!mounted) return;

      final errorCode = (result['errorCode'] ?? '').toString().trim();
      final errorMsg = (result['errorMsg'] ?? '').toString().trim();
      final success = result['success'] == true && errorCode.isEmpty;

      if (success) {
        setState(() => _isSubmitting = false);
        Navigator.of(context).pop(true);
        return;
      }

      setState(() => _isSubmitting = false);

      switch (errorCode.toUpperCase()) {
        case 'PIN_INCORRECT':
          final remaining = result['remainingAttempts'];
          final hasRemaining = remaining is int && remaining >= 0;
          final attemptsMessage = hasRemaining
              ? '\n$remaining attempt${remaining == 1 ? '' : 's'} remaining.'
              : '';
          _showErrorDialog(
            title: 'Incorrect PIN',
            message: 'The PIN you entered is incorrect.$attemptsMessage',
            icon: Icons.lock_outline_rounded,
            iconColor: Colors.orangeAccent,
          );
          _clearPin();
        case 'PIN_LOCKED':
          _showErrorDialog(
            title: 'PIN Temporarily Locked',
            message: _formatLockMessage(result),
            icon: Icons.lock_clock_outlined,
            iconColor: Colors.orangeAccent,
          );
          _clearPin();
        default:
          _showErrorDialog(
            title: 'Delete Account Failed',
            message: errorMsg.isEmpty
                ? 'Unable to delete account right now. Please try again.'
                : errorMsg,
            icon: Icons.error_outline_rounded,
            iconColor: Colors.redAccent,
          );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final isNetworkError =
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout;
      _showErrorDialog(
        title: isNetworkError ? 'No Connection' : 'Server Error',
        message: isNetworkError
            ? 'No internet connection. Please check your network and try again.'
            : 'Unable to delete account right now. Please try again.',
        icon: isNetworkError ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
        iconColor: isNetworkError ? Colors.orangeAccent : Colors.redAccent,
      );
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showErrorDialog(
        title: 'No Connection',
        message:
            'Request timed out. Please check your connection and try again.',
        icon: Icons.wifi_off_rounded,
        iconColor: Colors.orangeAccent,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showErrorDialog(
        title: 'Delete Account Failed',
        message: e.toString().replaceFirst('Exception: ', ''),
        icon: Icons.error_outline_rounded,
        iconColor: Colors.redAccent,
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
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
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
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinBox(int index) {
    return Container(
      margin: EdgeInsets.only(right: index == _controllers.length - 1 ? 0 : 12),
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          enabled: !_isSubmitting,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          obscureText: !_showPin,
          maxLength: 1,
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
          ),
          onChanged: (value) => _onChanged(index, value),
        ),
      ),
    );
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
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.pop(context),
                  icon: const Icon(Icons.chevron_left, size: 30),
                ),
              ),
              const SizedBox(height: 24),
              const Icon(
                Icons.delete_forever_outlined,
                size: 82,
                color: Color(0xFFEC407A),
              ),
              const SizedBox(height: 24),
              const Text(
                'Enter your PIN Code',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please enter your PIN Code to delete your account.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_controllers.length, _buildPinBox),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: _isSubmitting
                      ? null
                      : () => setState(() => _showPin = !_showPin),
                  child: Text(
                    _showPin ? 'Hide PIN' : 'Show PIN',
                    style: const TextStyle(
                      color: Color(0xFFEC407A),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
                child: SizedBox(
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : (_isComplete ? _submit : null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEC407A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'CONFIRM',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
