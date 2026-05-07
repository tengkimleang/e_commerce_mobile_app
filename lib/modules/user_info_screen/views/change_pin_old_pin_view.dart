import 'dart:async';

import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePinOldPinView extends StatefulWidget {
  const ChangePinOldPinView({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  State<ChangePinOldPinView> createState() => _ChangePinOldPinViewState();
}

class _ChangePinOldPinViewState extends State<ChangePinOldPinView> {
  static const _lockUntilPrefKey = 'pin_lock_until_utc';
  String get _phoneLockKey => '${_lockUntilPrefKey}_${widget.phoneNumber}';

  final AuthService _authService = AuthService();

  late final List<TextEditingController> _oldControllers;
  late final List<FocusNode> _oldFocusNodes;
  late final List<TextEditingController> _newControllers;
  late final List<FocusNode> _newFocusNodes;

  bool _isSubmitting = false;
  bool _isPinLocked = false;
  int _lockSecondsRemaining = 0;
  Timer? _lockTimer;
  bool _lockCheckComplete = false;

  @override
  void initState() {
    super.initState();
    _oldControllers = List.generate(4, (_) => TextEditingController());
    _oldFocusNodes = List.generate(4, (_) => FocusNode());
    _newControllers = List.generate(4, (_) => TextEditingController());
    _newFocusNodes = List.generate(4, (_) => FocusNode());
    _checkPersistedLock();
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    for (final c in _oldControllers) {
      c.dispose();
    }
    for (final f in _oldFocusNodes) {
      f.dispose();
    }
    for (final c in _newControllers) {
      c.dispose();
    }
    for (final f in _newFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _checkPersistedLock() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_phoneLockKey);
    if (stored == null) {
      if (mounted) setState(() => _lockCheckComplete = true);
      return;
    }
    final lockUntil = DateTime.tryParse(stored)?.toUtc();
    if (lockUntil == null) {
      await prefs.remove(_phoneLockKey);
      if (mounted) setState(() => _lockCheckComplete = true);
      return;
    }
    final remaining = lockUntil.difference(DateTime.now().toUtc()).inSeconds;
    if (remaining > 0) {
      _startLockCountdown(remaining);
    } else {
      await prefs.remove(_phoneLockKey);
    }
    if (mounted) setState(() => _lockCheckComplete = true);
  }

  Future<void> _clearPersistedLock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_phoneLockKey);
  }

  String _formatCountdown(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _startLockCountdown(int seconds) {
    _lockTimer?.cancel();
    if (seconds <= 0) return;
    setState(() {
      _isPinLocked = true;
      _lockSecondsRemaining = seconds;
    });
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_lockSecondsRemaining <= 1) {
        timer.cancel();
        _clearPersistedLock();
        for (final c in _oldControllers) {
          c.clear();
        }
        for (final c in _newControllers) {
          c.clear();
        }
        if (_oldFocusNodes.isNotEmpty) {
          _oldFocusNodes.first.requestFocus();
        }
        setState(() {
          _isPinLocked = false;
          _lockSecondsRemaining = 0;
        });
        return;
      }
      setState(() => _lockSecondsRemaining -= 1);
    });
  }

  int _computeLockSecondsFromResponse(Map<String, dynamic> response) {
    final raw = response['lockUntilUtc'];
    if (raw == null) return 0;
    final lockUntil = DateTime.tryParse(raw.toString().trim())?.toUtc();
    if (lockUntil == null) return 0;
    final diff = lockUntil.difference(DateTime.now().toUtc()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  bool get _isOldComplete =>
      _oldControllers.every((c) => c.text.length == 1);
  bool get _isNewComplete =>
      _newControllers.every((c) => c.text.length == 1);
  bool get _isFormComplete => _isOldComplete && _isNewComplete;

  String get _oldPin => _oldControllers.map((c) => c.text).join();
  String get _newPin => _newControllers.map((c) => c.text).join();

  void _onOldDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < _oldFocusNodes.length - 1) {
        _oldFocusNodes[index + 1].requestFocus();
      } else {
        _newFocusNodes[0].requestFocus();
      }
    } else if (index > 0) {
      _oldFocusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _onNewDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < _newFocusNodes.length - 1) {
        _newFocusNodes[index + 1].requestFocus();
      } else {
        _newFocusNodes[index].unfocus();
      }
    } else if (index > 0) {
      _newFocusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_isFormComplete || _isSubmitting || _isPinLocked) return;
    setState(() => _isSubmitting = true);

    try {
      final result = await _authService.changePin(
        phoneNumber: widget.phoneNumber,
        oldPinCode: _oldPin,
        newPinCode: _newPin,
      );

      if (!mounted) return;

      final errorCode = (result['errorCode'] as String? ?? '').trim().toUpperCase();
      final errorMsg = (result['errorMsg'] as String? ?? '').trim();
      final success = result['success'] == true && errorCode.isEmpty;

      if (success) {
        setState(() => _isSubmitting = false);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN changed successfully'),
            backgroundColor: Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() => _isSubmitting = false);

      switch (errorCode) {
        case 'PIN_INCORRECT':
          final remaining = result['remainingAttempts'];
          final attemptsMsg = remaining != null
              ? '\n$remaining attempt${remaining == 1 ? '' : 's'} remaining before lockout.'
              : '';
          _showErrorDialog(
            title: 'Incorrect PIN',
            message: 'The old PIN you entered is incorrect.$attemptsMsg',
            icon: Icons.lock_outline_rounded,
            iconColor: Colors.orangeAccent,
          );
          _clearOldPin();
        case 'PIN_LOCKED':
          final prefs = await SharedPreferences.getInstance();
          final existingStored = prefs.getString(_phoneLockKey);
          final existingLockUntil = existingStored != null
              ? DateTime.tryParse(existingStored)?.toUtc()
              : null;
          final now = DateTime.now().toUtc();
          int remaining;
          if (existingLockUntil != null && existingLockUntil.isAfter(now)) {
            remaining = existingLockUntil.difference(now).inSeconds;
          } else {
            remaining = _computeLockSecondsFromResponse(result);
            final rawLockUntil = result['lockUntilUtc']?.toString().trim() ?? '';
            if (rawLockUntil.isNotEmpty) {
              await prefs.setString(_phoneLockKey, rawLockUntil);
            } else {
              final synthetic = now
                  .add(Duration(seconds: remaining > 0 ? remaining : 15 * 60))
                  .toIso8601String();
              await prefs.setString(_phoneLockKey, synthetic);
            }
            if (remaining <= 0) remaining = 15 * 60;
          }
          if (!mounted) return;
          _startLockCountdown(remaining);
        case 'PIN_REUSED':
          _showErrorDialog(
            title: 'Same PIN',
            message: 'Your new PIN cannot be the same as your current PIN.',
            icon: Icons.repeat_rounded,
            iconColor: const Color(0xFFEC407A),
          );
          _clearNewPin();
        case 'PIN_NOT_SET':
          _showErrorDialog(
            title: 'No PIN Set',
            message: 'No PIN is set on this account.',
            icon: Icons.info_outline_rounded,
            iconColor: Colors.blueAccent,
          );
        default:
          _showErrorDialog(
            title: 'Change PIN Failed',
            message: errorMsg.isNotEmpty
                ? errorMsg
                : 'Unable to change PIN right now. Please try again.',
            icon: Icons.error_outline_rounded,
            iconColor: Colors.redAccent,
          );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final isNetwork = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout;
      _showErrorDialog(
        title: isNetwork ? 'No Connection' : 'Server Error',
        message: isNetwork
            ? 'No internet connection. Please check your network and try again.'
            : 'Unable to change PIN right now. Please try again.',
        icon: isNetwork ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
        iconColor: isNetwork ? Colors.orangeAccent : Colors.redAccent,
      );
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showErrorDialog(
        title: 'No Connection',
        message: 'Request timed out. Please check your connection and try again.',
        icon: Icons.wifi_off_rounded,
        iconColor: Colors.orangeAccent,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showErrorDialog(
        title: 'Change PIN Failed',
        message: e.toString().replaceFirst('Exception: ', ''),
        icon: Icons.error_outline_rounded,
        iconColor: Colors.redAccent,
      );
    }
  }

  void _clearOldPin() {
    for (final c in _oldControllers) {
      c.clear();
    }
    setState(() {});
    _oldFocusNodes[0].requestFocus();
  }

  void _clearNewPin() {
    for (final c in _newControllers) {
      c.clear();
    }
    setState(() {});
    _newFocusNodes[0].requestFocus();
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
              style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
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
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinRow({
    required List<TextEditingController> controllers,
    required List<FocusNode> focusNodes,
    required void Function(int, String) onChanged,
    required bool autofocusFirst,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        controllers.length,
        (index) => Padding(
          padding: EdgeInsets.only(right: index == controllers.length - 1 ? 0 : 12),
          child: SizedBox(
            width: 64,
            child: _PinDigitField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              textInputAction: (index == controllers.length - 1 && controllers == _newControllers)
                  ? TextInputAction.done
                  : TextInputAction.next,
              autofocus: autofocusFirst && index == 0,
              enabled: !_isPinLocked,
              onChanged: (value) => onChanged(index, value),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.chevron_left, size: 34, color: Color(0xFF7A7A7A)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(26, 0, 26, 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Image.asset(
                      'assets/images/woman.png',
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Set new PIN',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D1B22),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Make sure you remember',
                      style: TextStyle(fontSize: 16, color: Color(0xFF4A4A4A)),
                    ),
                    const SizedBox(height: 32),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Old PIN',
                        style: TextStyle(fontSize: 16, color: Color(0xFFEC407A)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildPinRow(
                      controllers: _oldControllers,
                      focusNodes: _oldFocusNodes,
                      onChanged: _onOldDigitChanged,
                      autofocusFirst: true,
                    ),
                    const SizedBox(height: 28),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'New PIN',
                        style: TextStyle(fontSize: 16, color: Color(0xFFEC407A)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildPinRow(
                      controllers: _newControllers,
                      focusNodes: _newFocusNodes,
                      onChanged: _onNewDigitChanged,
                      autofocusFirst: false,
                    ),
                    if (_isPinLocked) ...
                      [
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEC407A).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFEC407A).withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lock_clock_rounded,
                                color: Color(0xFFEC407A),
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'PIN Temporarily Locked',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFEC407A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Too many incorrect attempts.\nTry again in ${_formatCountdown(_lockSecondsRemaining)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: (_isFormComplete && !_isSubmitting && !_isPinLocked && _lockCheckComplete) ? _submit : null,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) return const Color(0xFFA6A6A8);
                return const Color(0xFFEC407A);
              }),
              foregroundColor: WidgetStateProperty.all(Colors.white),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              elevation: WidgetStateProperty.all(0),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text('SUBMIT', style: TextStyle(fontSize: 15, letterSpacing: 1.2)),
          ),
        ),
      ),
    );
  }
}

class _PinDigitField extends StatelessWidget {
  const _PinDigitField({
    required this.controller,
    required this.focusNode,
    required this.textInputAction,
    required this.autofocus,
    required this.enabled,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final bool autofocus;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFFF0F0F2) : Colors.grey[200],
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        enabled: enabled,
        keyboardType: TextInputType.number,
        textInputAction: textInputAction,
        textAlign: TextAlign.center,
        obscureText: false,
        enableSuggestions: false,
        autocorrect: false,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1D1B22),
        ),
        maxLength: 1,
        buildCounter:
            (_, {required currentLength, required isFocused, maxLength}) =>
                null,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
