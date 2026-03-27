import 'dart:async';

import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/services/auth_service.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:e_commerce_mobile_app/modules/slash_screen/views/index.dart';

enum AuthFlow { login, signup }

class OtpView extends StatefulWidget {
  final String phoneNumber;
  final String? fullName;
  final AuthFlow flow;

  const OtpView({
    super.key,
    required this.phoneNumber,
    this.fullName,
    this.flow = AuthFlow.login,
  });

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  static const int _signupResendCooldownSeconds = 5;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  final AuthService _authService = AuthService();

  bool _showPin = false;
  bool _isSubmitting = false;
  bool _isResending = false;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  bool get _isSignupFlow => widget.flow == AuthFlow.signup;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (_) => TextEditingController());
    _focusNodes = List.generate(4, (_) => FocusNode());
    if (_isSignupFlow) {
      _startResendCooldown();
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  bool get _isComplete =>
      _controllers.every((controller) => controller.text.trim().isNotEmpty);

  String get _otpCode => _controllers.map((c) => c.text).join();

  String _pickFirstNonEmpty(Iterable<dynamic> candidates) {
    for (final candidate in candidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }
    return '';
  }

  int _pickFirstPositiveInt(Iterable<dynamic> candidates) {
    for (final candidate in candidates) {
      if (candidate is int && candidate > 0) {
        return candidate;
      }
      if (candidate is num && candidate > 0) {
        return candidate.toInt();
      }
      if (candidate is String) {
        final parsed = int.tryParse(candidate.trim());
        if (parsed != null && parsed > 0) {
          return parsed;
        }
      }
    }
    return 0;
  }

  String _resolveLoginVerifyMessage({
    required String errorCode,
    required String errorMsg,
  }) {
    if (errorCode == 'USR404') {
      return 'This phone is not registered. Please sign up first.';
    }
    if (errorMsg.isNotEmpty) {
      return errorMsg;
    }
    return 'OTP verification failed.';
  }

  Map<String, dynamic>? _extractPrimaryUser(Map<String, dynamic> data) {
    Map<String, dynamic>? castToStringDynamicMap(dynamic source) {
      if (source is Map<String, dynamic>) return source;
      if (source is Map) {
        return source.map((key, value) => MapEntry(key.toString(), value));
      }
      return null;
    }

    List<dynamic> resolveUsersList(dynamic source) {
      if (source is List) return source;
      return const [];
    }

    final directUsers = resolveUsersList(data['users']);
    if (directUsers.isNotEmpty) {
      final user = castToStringDynamicMap(directUsers.first);
      if (user != null) return user;
    }

    final directUsersUpper = resolveUsersList(data['Users']);
    if (directUsersUpper.isNotEmpty) {
      final user = castToStringDynamicMap(directUsersUpper.first);
      if (user != null) return user;
    }

    final nested = castToStringDynamicMap(data['data']);
    if (nested == null) return null;

    final nestedUsers = resolveUsersList(nested['users']);
    if (nestedUsers.isNotEmpty) {
      final user = castToStringDynamicMap(nestedUsers.first);
      if (user != null) return user;
    }

    final nestedUsersUpper = resolveUsersList(nested['Users']);
    if (nestedUsersUpper.isNotEmpty) {
      final user = castToStringDynamicMap(nestedUsersUpper.first);
      if (user != null) return user;
    }

    return null;
  }

  String? _extractToken(Map<String, dynamic> data) {
    final nested = data['data'];
    final nestedMap = nested is Map<String, dynamic> ? nested : null;
    final token = _pickFirstNonEmpty([
      data['token'],
      data['accessToken'],
      data['jwt'],
      data['jwtToken'],
      nestedMap?['token'],
      nestedMap?['accessToken'],
      nestedMap?['jwt'],
      nestedMap?['jwtToken'],
    ]);
    return token.isEmpty ? null : token;
  }

  void _clearOtpInputs() {
    for (final c in _controllers) {
      c.clear();
    }
    if (_focusNodes.isNotEmpty) {
      _focusNodes.first.requestFocus();
    }
    setState(() {});
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();

    if (!_isSignupFlow) return;

    setState(() => _resendSeconds = _signupResendCooldownSeconds);

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
        return;
      }

      setState(() => _resendSeconds -= 1);
    });
  }

  Future<void> _onResendSignupOtp() async {
    if (!_isSignupFlow || _isResending || _resendSeconds > 0) return;

    final fullName = widget.fullName?.trim() ?? '';
    if (fullName.isEmpty) {
      _showErrorDialog(
        title: 'Request Failed',
        message: 'Full name is missing. Please go back and try signup again.',
        icon: Icons.error_outline_rounded,
        iconColor: const Color(0xFFEC407A),
      );
      return;
    }

    setState(() => _isResending = true);

    try {
      final requestResult = await _authService.requestSignupOtp(
        fullName: fullName,
        phoneNumber: widget.phoneNumber,
      );
      final errorCode = (requestResult['errorCode'] ?? '').toString().trim();
      final errorMsg = (requestResult['errorMsg'] ?? '').toString().trim();
      final sent = requestResult['sent'] == true;

      if (!mounted) return;

      if (errorCode.isNotEmpty || !sent) {
        setState(() => _isResending = false);
        _showErrorDialog(
          title: 'Request Failed',
          message: errorMsg.isEmpty ? 'Request OTP failed.' : errorMsg,
          icon: Icons.error_outline_rounded,
          iconColor: const Color(0xFFEC407A),
        );
        return;
      }

      setState(() => _isResending = false);
      _clearOtpInputs();
      _startResendCooldown();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('OTP has been sent again.')));
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isResending = false);

      final isNetworkError =
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout;

      _showErrorDialog(
        title: isNetworkError ? 'No Connection' : 'Request Failed',
        message: isNetworkError
            ? 'No internet connection. Please check your network and try again.'
            : (e.response?.data?['errorMsg'] ??
                  'Unable to request OTP right now.'),
        icon: isNetworkError ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
        iconColor: isNetworkError ? Colors.orangeAccent : Colors.redAccent,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isResending = false);
      _showErrorDialog(
        title: 'Request Failed',
        message: e.toString().replaceFirst('Exception: ', ''),
        icon: Icons.error_outline_rounded,
        iconColor: const Color(0xFFEC407A),
      );
    }
  }

  Future<void> _showSignupRecoveryDialog({
    required String errorCode,
    required String message,
  }) async {
    if (!mounted) return;

    final shouldResend = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Verification Failed'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC407A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Request New OTP'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (shouldResend == true) {
      if (_resendSeconds > 0) {
        _showErrorDialog(
          title: 'Please Wait',
          message:
              'Please wait $_resendSeconds second(s) before requesting OTP.',
          icon: Icons.timer_outlined,
          iconColor: Colors.orangeAccent,
        );
        return;
      }
      await _onResendSignupOtp();
      return;
    }

    if (errorCode == 'OTP002' || errorCode == 'OTP003') {
      Navigator.of(context).pop();
    }
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

  Future<void> _submit() async {
    if (!_isComplete) return;

    setState(() => _isSubmitting = true);

    try {
      final verifyData = _isSignupFlow
          ? await _authService.verifySignupOtp(
              phoneNumber: widget.phoneNumber,
              otpCode: _otpCode,
            )
          : await _authService.verifyOtp(
              phoneNumber: widget.phoneNumber,
              otpCode: _otpCode,
            );

      if (!mounted) return;

      final verifyErrorCode = (verifyData['errorCode'] ?? '').toString().trim();
      final verifyErrorMsg = (verifyData['errorMsg'] ?? '').toString().trim();
      final verifySuccess = verifyData['success'] == true;

      if (verifyErrorCode.isNotEmpty || !verifySuccess) {
        setState(() => _isSubmitting = false);

        if (_isSignupFlow &&
            (verifyErrorCode == 'OTP002' || verifyErrorCode == 'OTP003')) {
          await _showSignupRecoveryDialog(
            errorCode: verifyErrorCode,
            message: verifyErrorMsg.isEmpty
                ? 'OTP verification failed.'
                : verifyErrorMsg,
          );
          return;
        }

        _showErrorDialog(
          title: 'Verification Failed',
          message: _isSignupFlow
              ? (verifyErrorMsg.isEmpty
                    ? 'OTP verification failed.'
                    : verifyErrorMsg)
              : _resolveLoginVerifyMessage(
                  errorCode: verifyErrorCode,
                  errorMsg: verifyErrorMsg,
                ),
          icon: Icons.error_outline_rounded,
          iconColor: const Color(0xFFEC407A),
        );
        return;
      }

      var sessionData = verifyData;
      final verifyNested = verifyData['data'];
      final verifyNestedMap = verifyNested is Map<String, dynamic>
          ? verifyNested
          : null;
      final verifyPrimaryUser = _extractPrimaryUser(verifyData);
      final resolvedUserId = _pickFirstPositiveInt([
        verifyData['userId'],
        verifyNestedMap?['userId'],
        verifyPrimaryUser?['userId'],
        verifyPrimaryUser?['UserId'],
      ]);
      final hasNameInVerify = _pickFirstNonEmpty([
        verifyData['fullName'],
        verifyData['name'],
        verifyData['username'],
        verifyNestedMap?['fullName'],
        verifyNestedMap?['name'],
        verifyNestedMap?['username'],
        verifyPrimaryUser?['fullName'],
        verifyPrimaryUser?['name'],
        verifyPrimaryUser?['username'],
        verifyPrimaryUser?['FullName'],
        verifyPrimaryUser?['Name'],
        verifyPrimaryUser?['Username'],
      ]).isNotEmpty;
      final shouldFetchUser =
          resolvedUserId > 0 && (_isSignupFlow || !hasNameInVerify);

      if (shouldFetchUser) {
        try {
          final userResult = await _authService.getSignupUser(
            userId: resolvedUserId,
          );

          if (!mounted) return;

          final userErrorCode = (userResult['errorCode'] ?? '')
              .toString()
              .trim();
          final userSuccess = userResult['success'] == true;

          if (userErrorCode.isEmpty && userSuccess) {
            sessionData = userResult;
          } else {
            debugPrint(
              '[OtpView] getSignupUser failed (errorCode=$userErrorCode, success=$userSuccess), fallback to verify response',
            );
          }
        } on DioException catch (e) {
          // Do not block successful OTP verify if user profile fetch fails.
          final status = e.response?.statusCode;
          debugPrint(
            '[OtpView] getSignupUser DioException (status=$status, type=${e.type}), fallback to verify response',
          );
        } catch (e) {
          debugPrint(
            '[OtpView] getSignupUser unexpected error ($e), fallback to verify response',
          );
        }
      } else if (_isSignupFlow && resolvedUserId <= 0) {
        debugPrint(
          '[OtpView] verifySignupOtp returned no valid userId, skipping getSignupUser',
        );
      }

      final nested = sessionData['data'];
      final nestedMap = nested is Map<String, dynamic> ? nested : null;
      final sessionPrimaryUser = _extractPrimaryUser(sessionData);
      final resolvedFullName = _pickFirstNonEmpty([
        widget.fullName,
        sessionData['fullName'],
        sessionData['name'],
        sessionData['username'],
        nestedMap?['fullName'],
        nestedMap?['name'],
        nestedMap?['username'],
        sessionPrimaryUser?['fullName'],
        sessionPrimaryUser?['name'],
        sessionPrimaryUser?['username'],
        sessionPrimaryUser?['FullName'],
        sessionPrimaryUser?['Name'],
        sessionPrimaryUser?['Username'],
      ]);

      final resolvedPhone = _pickFirstNonEmpty([
        widget.phoneNumber,
        sessionData['phoneNumber'],
        sessionData['phone'],
        nestedMap?['phoneNumber'],
        nestedMap?['phone'],
        sessionPrimaryUser?['phoneNumber'],
        sessionPrimaryUser?['phone'],
        sessionPrimaryUser?['PhoneNumber'],
        sessionPrimaryUser?['Phone'],
      ]);

      setState(() => _isSubmitting = false);
      await UserSession.markAuthenticated(
        fullName: resolvedFullName.isEmpty ? null : resolvedFullName,
        phoneNumber: resolvedPhone.isEmpty ? null : resolvedPhone,
        token: _isSignupFlow ? null : _extractToken(sessionData),
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const IndexView()),
        (route) => false,
      );
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      String message;
      IconData icon;
      Color iconColor;
      String title;

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
        title = 'Verification Failed';
        message =
            e.response?.data?['errorMsg'] ??
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
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSubmitting = false);

      _showErrorDialog(
        title: 'Verification Failed',
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
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Enter OTP Code',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Please enter the 4-digit code sent to ${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _controllers.length,
                  (index) => Container(
                    margin: EdgeInsets.only(right: index == 3 ? 0 : 12),
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
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        onChanged: (v) => _onChanged(index, v),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => setState(() => _showPin = !_showPin),
                  child: Text(
                    _showPin ? 'Hide OTP' : 'Show OTP',
                    style: const TextStyle(color: Color(0xFFEC407A)),
                  ),
                ),
              ),
              if (_isSignupFlow) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed:
                        (_isSubmitting || _isResending || _resendSeconds > 0)
                        ? null
                        : _onResendSignupOtp,
                    child: Text(
                      _isResending
                          ? 'Sending...'
                          : _resendSeconds > 0
                          ? 'Resend OTP in ${_resendSeconds}s'
                          : 'Resend OTP',
                      style: TextStyle(
                        color:
                            (_isSubmitting ||
                                _isResending ||
                                _resendSeconds > 0)
                            ? Colors.grey
                            : const Color(0xFFEC407A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
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
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'VERIFY OTP',
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
