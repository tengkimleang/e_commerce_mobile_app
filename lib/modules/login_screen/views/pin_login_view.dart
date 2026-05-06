import 'dart:async';

import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/modules/login_screen/views/otp_view.dart';
import 'package:e_commerce_mobile_app/modules/slash_screen/views/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinLoginView extends StatefulWidget {
  const PinLoginView({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  State<PinLoginView> createState() => _PinLoginViewState();
}

class _PinLoginViewState extends State<PinLoginView> {
  static const _lockUntilPrefKey = 'pin_lock_until_utc';

  final AuthService _authService = AuthService();
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  bool _showPin = false;
  bool _isSubmitting = false;
  bool _isSendingForgotOtp = false;

  bool _isPinLocked = false;
  int _lockSecondsRemaining = 0;
  Timer? _lockTimer;
  // Guards _submit() from firing before the async startup lock check completes.
  bool _lockCheckComplete = false;

  bool get _isComplete =>
      _controllers.every((controller) => controller.text.trim().isNotEmpty);
  String get _pinCode =>
      _controllers.map((controller) => controller.text).join();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (_) => TextEditingController());
    _focusNodes = List.generate(4, (_) => FocusNode());
    _checkPersistedLock();
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
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

  /// On startup, check if a lock was previously stored and is still active.
  Future<void> _checkPersistedLock() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_lockUntilPrefKey);
    if (stored == null) {
      if (mounted) setState(() => _lockCheckComplete = true);
      return;
    }
    final lockUntil = DateTime.tryParse(stored)?.toUtc();
    if (lockUntil == null) {
      await prefs.remove(_lockUntilPrefKey);
      if (mounted) setState(() => _lockCheckComplete = true);
      return;
    }
    final remaining =
        lockUntil.difference(DateTime.now().toUtc()).inSeconds;
    if (remaining > 0) {
      _startLockCountdown(remaining);
    } else {
      await prefs.remove(_lockUntilPrefKey);
    }
    if (mounted) setState(() => _lockCheckComplete = true);
  }

  /// Removes the persisted lock (called when the countdown expires).
  Future<void> _clearPersistedLock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lockUntilPrefKey);
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
        for (final c in _controllers) {
          c.clear();
        }
        if (_focusNodes.isNotEmpty) {
          _focusNodes.first.requestFocus();
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

  /// Reads [lockUntilUtc] from the verify-pin response and returns
  /// how many seconds remain until the lock expires. Returns 0 if
  /// the field is absent or the timestamp has already passed.
  int _computeLockSecondsFromResponse(Map<String, dynamic> response) {
    final raw = response['lockUntilUtc'];
    if (raw == null) return 0;
    final lockUntil = DateTime.tryParse(raw.toString().trim())?.toUtc();
    if (lockUntil == null) return 0;
    final diff = lockUntil.difference(DateTime.now().toUtc()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  String _clean(dynamic value) => value?.toString().trim() ?? '';

  bool _isMissingEndpointResponse({
    required String errorCode,
    required String errorMsg,
  }) {
    final normalizedCode = errorCode.toUpperCase();
    if (normalizedCode == 'HTTP404' || normalizedCode == 'HTTP405') {
      return true;
    }
    final normalizedMsg = errorMsg.toLowerCase();
    return normalizedMsg.contains('not found') ||
        normalizedMsg.contains('no endpoint');
  }

  String _pickFirstNonEmpty(Iterable<dynamic> values) {
    for (final value in values) {
      final text = _clean(value);
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  int _pickFirstPositiveInt(Iterable<dynamic> values) {
    for (final value in values) {
      if (value is int && value > 0) return value;
      if (value is num && value > 0) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null && parsed > 0) return parsed;
      }
    }
    return 0;
  }

  Map<String, dynamic>? _toMap(dynamic source) {
    if (source is Map<String, dynamic>) return source;
    if (source is Map) {
      return source.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  Map<String, dynamic> _extractDataMap(Map<String, dynamic> payload) {
    final nested = _toMap(payload['data']);
    return nested ?? payload;
  }

  String _extractAccessToken(Map<String, dynamic> payload) {
    final data = _extractDataMap(payload);
    return _pickFirstNonEmpty([
      payload['accessToken'],
      payload['token'],
      payload['jwt'],
      payload['jwtToken'],
      data['accessToken'],
      data['token'],
      data['jwt'],
      data['jwtToken'],
    ]);
  }

  String _extractRefreshToken(Map<String, dynamic> payload) {
    final data = _extractDataMap(payload);
    return _pickFirstNonEmpty([payload['refreshToken'], data['refreshToken']]);
  }

  int _extractAccessTokenExpiresInSeconds(Map<String, dynamic> payload) {
    final data = _extractDataMap(payload);
    return _pickFirstPositiveInt([
      payload['accessTokenExpiresInSeconds'],
      payload['accessTokenExpiresInSecond'],
      payload['expiresInSeconds'],
      data['accessTokenExpiresInSeconds'],
      data['accessTokenExpiresInSecond'],
      data['expiresInSeconds'],
    ]);
  }

  int _extractRefreshTokenExpiresInSeconds(Map<String, dynamic> payload) {
    final data = _extractDataMap(payload);
    return _pickFirstPositiveInt([
      payload['refreshTokenExpiresInSeconds'],
      payload['refreshExpiresInSeconds'],
      data['refreshTokenExpiresInSeconds'],
      data['refreshExpiresInSeconds'],
    ]);
  }

  Future<void> _submit() async {
    if (!_isComplete || _isSubmitting || _isPinLocked || !_lockCheckComplete) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await _authService.verifyPin(
        phoneNumber: widget.phoneNumber,
        pinCode: _pinCode,
      );
      if (!mounted) return;

      final success = response['success'] == true;
      final errorCode = _clean(response['errorCode']).toUpperCase();
      final errorMsg = _clean(response['errorMsg']);

      if (!success || errorCode.isNotEmpty) {
        setState(() => _isSubmitting = false);
        if (_isMissingEndpointResponse(
          errorCode: errorCode,
          errorMsg: errorMsg,
        )) {
          await _showPinEndpointNotReadyDialog();
          return;
        }

        if (errorCode == 'PIN_NOT_SET') {
          await _showPinNotSetDialog(
            message: errorMsg.isEmpty
                ? 'PIN is not set yet. Please verify OTP and create a PIN first.'
                : errorMsg,
          );
          return;
        }

        if (errorCode == 'PIN_LOCKED') {
          // Never overwrite an existing valid stored lock — the backend may
          // return a fresh lockUntilUtc (now + 15 min) on every pre-check call,
          // which would reset the countdown on every app restart.
          final prefs = await SharedPreferences.getInstance();
          final existingStored = prefs.getString(_lockUntilPrefKey);
          final existingLockUntil =
              existingStored != null
                  ? DateTime.tryParse(existingStored)?.toUtc()
                  : null;
          final now = DateTime.now().toUtc();

          int remaining;
          if (existingLockUntil != null && existingLockUntil.isAfter(now)) {
            // Valid lock already on disk — honour the original expiry time.
            remaining = existingLockUntil.difference(now).inSeconds;
          } else {
            // No valid stored lock — use backend's lockUntilUtc and persist it.
            remaining = _computeLockSecondsFromResponse(response);
            final rawLockUntil =
                response['lockUntilUtc']?.toString().trim() ?? '';
            if (rawLockUntil.isNotEmpty) {
              await prefs.setString(_lockUntilPrefKey, rawLockUntil);
            } else {
              final synthetic = now
                  .add(Duration(seconds: remaining > 0 ? remaining : 15 * 60))
                  .toIso8601String();
              await prefs.setString(_lockUntilPrefKey, synthetic);
            }
            if (remaining <= 0) remaining = 15 * 60;
          }
          if (!mounted) return;
          _startLockCountdown(remaining);
          return;
        }

        _showErrorDialog(
          title: 'Login Failed',
          message: errorMsg.isEmpty ? 'Invalid phone or PIN code.' : errorMsg,
          icon: Icons.error_outline_rounded,
          iconColor: const Color(0xFFEC407A),
        );
        return;
      }

      final data = _extractDataMap(response);
      final resolvedName = _pickFirstNonEmpty([
        data['fullName'],
        data['name'],
        data['username'],
      ]);
      final resolvedPhone = _pickFirstNonEmpty([
        data['phoneNumber'],
        data['phone'],
        widget.phoneNumber,
      ]);
      final accessToken = _extractAccessToken(response);
      final refreshToken = _extractRefreshToken(response);
      final accessTokenExpiresInSeconds = _extractAccessTokenExpiresInSeconds(
        response,
      );
      final refreshTokenExpiresInSeconds = _extractRefreshTokenExpiresInSeconds(
        response,
      );

      await UserSession.markAuthenticated(
        fullName: resolvedName.isEmpty ? null : resolvedName,
        phoneNumber: resolvedPhone.isEmpty ? null : resolvedPhone,
        token: accessToken.isEmpty ? '' : accessToken,
        refreshToken: refreshToken,
        accessTokenExpiresInSeconds: accessTokenExpiresInSeconds > 0
            ? accessTokenExpiresInSeconds
            : null,
        refreshTokenExpiresInSeconds: refreshTokenExpiresInSeconds > 0
            ? refreshTokenExpiresInSeconds
            : null,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const IndexView()),
        (route) => false,
      );
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      final isNetworkError =
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout;

      _showErrorDialog(
        title: isNetworkError ? 'No Connection' : 'Login Failed',
        message: isNetworkError
            ? 'No internet connection. Please check your network and try again.'
            : _clean(e.response?.data?['errorMsg']).isEmpty
            ? 'Unable to verify your PIN right now.'
            : _clean(e.response?.data?['errorMsg']),
        icon: isNetworkError ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
        iconColor: isNetworkError ? Colors.orangeAccent : Colors.redAccent,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showErrorDialog(
        title: 'Login Failed',
        message: e.toString().replaceFirst('Exception: ', ''),
        icon: Icons.error_outline_rounded,
        iconColor: const Color(0xFFEC407A),
      );
    }
  }

  Future<void> _showPinNotSetDialog({required String message}) async {
    if (!mounted) return;
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('PIN Not Set'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC407A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Verify OTP'),
          ),
        ],
      ),
    );

    if (shouldContinue == true) {
      await _startForgotPinFlow();
    }
  }

  Future<void> _showPinEndpointNotReadyDialog() async {
    if (!mounted) return;
    final useOtpFallback = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('PIN Login Not Ready'),
        content: const Text(
          'PIN login endpoint is not available on backend yet. Use OTP login for now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC407A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Use OTP'),
          ),
        ],
      ),
    );

    if (useOtpFallback == true) {
      await _startLegacyOtpLogin();
    }
  }

  Future<void> _startLegacyOtpLogin() async {
    if (_isSendingForgotOtp || _isSubmitting) return;
    setState(() => _isSendingForgotOtp = true);
    try {
      final requestResult = await _authService.requestOtp(widget.phoneNumber);
      if (!mounted) return;
      final errorCode = _clean(requestResult['errorCode']);
      final errorMsg = _clean(requestResult['errorMsg']);
      final sent = requestResult['sent'] == true;
      if (errorCode.isNotEmpty || !sent) {
        setState(() => _isSendingForgotOtp = false);
        _showErrorDialog(
          title: 'Request Failed',
          message: errorMsg.isEmpty
              ? 'Unable to request OTP right now.'
              : errorMsg,
          icon: Icons.error_outline_rounded,
          iconColor: const Color(0xFFEC407A),
        );
        return;
      }
      setState(() => _isSendingForgotOtp = false);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpView(phoneNumber: widget.phoneNumber),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSendingForgotOtp = false);
      _showErrorDialog(
        title: 'Request Failed',
        message: 'Unable to request OTP right now.',
        icon: Icons.error_outline_rounded,
        iconColor: const Color(0xFFEC407A),
      );
    }
  }

  Future<void> _startForgotPinFlow() async {
    if (_isSendingForgotOtp || _isSubmitting) return;

    setState(() => _isSendingForgotOtp = true);

    try {
      final result = await _authService.requestForgotPinOtp(
        phoneNumber: widget.phoneNumber,
      );
      if (!mounted) return;

      final errorCode = _clean(result['errorCode']);
      final errorMsg = _clean(result['errorMsg']);
      final sent = result['sent'] == true;
      final success = result['success'] == true;
      final didSend = sent || success;

      if (errorCode.isNotEmpty || !didSend) {
        setState(() => _isSendingForgotOtp = false);
        _showErrorDialog(
          title: 'Request Failed',
          message: errorMsg.isEmpty
              ? 'Unable to send OTP for PIN reset.'
              : errorMsg,
          icon: Icons.error_outline_rounded,
          iconColor: const Color(0xFFEC407A),
        );
        return;
      }

      setState(() => _isSendingForgotOtp = false);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpView(
            phoneNumber: widget.phoneNumber,
            flow: AuthFlow.forgotPin,
          ),
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isSendingForgotOtp = false);
      final isNetworkError =
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout;
      _showErrorDialog(
        title: isNetworkError ? 'No Connection' : 'Request Failed',
        message: isNetworkError
            ? 'No internet connection. Please check your network and try again.'
            : 'Unable to request OTP right now.',
        icon: isNetworkError ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
        iconColor: isNetworkError ? Colors.orangeAccent : Colors.redAccent,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSendingForgotOtp = false);
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
              child: const Text('OK'),
            ),
          ),
        ],
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
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.chevron_left, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Icon(
                Icons.lock_outline_rounded,
                size: 82,
                color: Color(0xFFEC407A),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Enter your PIN Code',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Please enter the PIN Code to login for ${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _controllers.length,
                  (index) => Container(
                    margin: EdgeInsets.only(right: index == 3 ? 0 : 12),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _isPinLocked
                          ? Colors.grey[200]
                          : const Color(0xFFF5F7FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        obscureText: !_showPin,
                        maxLength: 1,
                        enabled: !_isPinLocked,
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) => _onChanged(index, value),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1,
                    child: child,
                  ),
                ),
                child: _isPinLocked
                    ? Padding(
                        key: const ValueKey('lock_banner'),
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
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
                      )
                    : const SizedBox.shrink(key: ValueKey('no_banner')),
              ),
              Center(
                child: GestureDetector(
                  onTap: _isPinLocked
                      ? null
                      : () => setState(() => _showPin = !_showPin),
                  child: Text(
                    'Show PIN',
                    style: TextStyle(
                      color: _isPinLocked
                          ? Colors.grey[400]
                          : const Color(0xFFEC407A),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: _isSendingForgotOtp || _isSubmitting
                      ? null
                      : _startForgotPinFlow,
                  child: Text(
                    _isSendingForgotOtp
                        ? 'Sending OTP...'
                        : 'Forgot the PIN code?',
                    style: TextStyle(
                      color: _isSendingForgotOtp
                          ? Colors.grey
                          : const Color(0xFFEC407A),
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
                    onPressed: _isSubmitting || _isPinLocked
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
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'SUBMIT',
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
