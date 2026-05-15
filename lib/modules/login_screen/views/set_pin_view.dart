import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/services/auth_service.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/blocs/favorite_bloc.dart';
import 'package:e_commerce_mobile_app/modules/favorite_screen/blocs/favorite_event.dart';
import 'package:e_commerce_mobile_app/modules/slash_screen/views/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum PinSetupFlow { signup, forgotPin }

class SetPinView extends StatefulWidget {
  const SetPinView({
    super.key,
    required this.flow,
    required this.phoneNumber,
    this.fullName,
    this.resetToken,
  });

  final PinSetupFlow flow;
  final String phoneNumber;
  final String? fullName;
  final String? resetToken;

  @override
  State<SetPinView> createState() => _SetPinViewState();
}

class _ResolvedSessionData {
  const _ResolvedSessionData({
    required this.fullName,
    required this.phoneNumber,
    required this.token,
    required this.refreshToken,
    required this.accessTokenExpiresInSeconds,
    required this.refreshTokenExpiresInSeconds,
    required this.hasCredentialPayload,
  });

  final String fullName;
  final String phoneNumber;
  final String token;
  final String refreshToken;
  final int? accessTokenExpiresInSeconds;
  final int? refreshTokenExpiresInSeconds;
  final bool hasCredentialPayload;
}

class _SetPinViewState extends State<SetPinView> {
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

  String _clean(dynamic value) => value?.toString().trim() ?? '';

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
      if (candidate is int && candidate > 0) return candidate;
      if (candidate is num && candidate > 0) return candidate.toInt();
      if (candidate is String) {
        final parsed = int.tryParse(candidate.trim());
        if (parsed != null && parsed > 0) return parsed;
      }
    }
    return 0;
  }

  Map<String, dynamic>? _toStringDynamicMap(dynamic source) {
    if (source is Map<String, dynamic>) return source;
    if (source is Map) {
      return source.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  Map<String, dynamic>? _extractPrimaryUser(Map<String, dynamic> data) {
    List<dynamic> resolveUsersList(dynamic source) {
      if (source is List) return source;
      return const [];
    }

    final directUsers = resolveUsersList(data['users']);
    if (directUsers.isNotEmpty) {
      final user = _toStringDynamicMap(directUsers.first);
      if (user != null) return user;
    }

    final directUsersUpper = resolveUsersList(data['Users']);
    if (directUsersUpper.isNotEmpty) {
      final user = _toStringDynamicMap(directUsersUpper.first);
      if (user != null) return user;
    }

    final nested = _toStringDynamicMap(data['data']);
    if (nested == null) return null;

    final nestedUsers = resolveUsersList(nested['users']);
    if (nestedUsers.isNotEmpty) {
      final user = _toStringDynamicMap(nestedUsers.first);
      if (user != null) return user;
    }

    final nestedUsersUpper = resolveUsersList(nested['Users']);
    if (nestedUsersUpper.isNotEmpty) {
      final user = _toStringDynamicMap(nestedUsersUpper.first);
      if (user != null) return user;
    }

    return null;
  }

  String _extractToken(Map<String, dynamic> data) {
    final nestedMap = _toStringDynamicMap(data['data']);
    return _pickFirstNonEmpty([
      data['token'],
      data['accessToken'],
      data['jwt'],
      data['jwtToken'],
      nestedMap?['token'],
      nestedMap?['accessToken'],
      nestedMap?['jwt'],
      nestedMap?['jwtToken'],
    ]);
  }

  String _extractRefreshToken(Map<String, dynamic> data) {
    final nestedMap = _toStringDynamicMap(data['data']);
    return _pickFirstNonEmpty([
      data['refreshToken'],
      data['RefreshToken'],
      nestedMap?['refreshToken'],
      nestedMap?['RefreshToken'],
    ]);
  }

  int? _extractAccessTokenExpiresInSeconds(Map<String, dynamic> data) {
    final nestedMap = _toStringDynamicMap(data['data']);
    final expiresIn = _pickFirstPositiveInt([
      data['accessTokenExpiresInSeconds'],
      data['AccessTokenExpiresInSeconds'],
      data['accessTokenExpiresInSecond'],
      data['AccessTokenExpiresInSecond'],
      data['expiresInSeconds'],
      data['ExpiresInSeconds'],
      nestedMap?['accessTokenExpiresInSeconds'],
      nestedMap?['AccessTokenExpiresInSeconds'],
      nestedMap?['accessTokenExpiresInSecond'],
      nestedMap?['AccessTokenExpiresInSecond'],
      nestedMap?['expiresInSeconds'],
      nestedMap?['ExpiresInSeconds'],
    ]);
    return expiresIn > 0 ? expiresIn : null;
  }

  int? _extractRefreshTokenExpiresInSeconds(Map<String, dynamic> data) {
    final nestedMap = _toStringDynamicMap(data['data']);
    final expiresIn = _pickFirstPositiveInt([
      data['refreshTokenExpiresInSeconds'],
      data['RefreshTokenExpiresInSeconds'],
      data['refreshExpiresInSeconds'],
      data['RefreshExpiresInSeconds'],
      nestedMap?['refreshTokenExpiresInSeconds'],
      nestedMap?['RefreshTokenExpiresInSeconds'],
      nestedMap?['refreshExpiresInSeconds'],
      nestedMap?['RefreshExpiresInSeconds'],
    ]);
    return expiresIn > 0 ? expiresIn : null;
  }

  Future<_ResolvedSessionData> _resolveSessionData(
    Map<String, dynamic> response, {
    String fallbackFullName = '',
    String fallbackPhoneNumber = '',
  }) async {
    final nestedMap = _toStringDynamicMap(response['data']);
    final primaryUser = _extractPrimaryUser(response);

    var resolvedFullName = _pickFirstNonEmpty([
      fallbackFullName,
      response['fullName'],
      response['name'],
      response['username'],
      response['full_name'],
      response['user_name'],
      nestedMap?['fullName'],
      nestedMap?['name'],
      nestedMap?['username'],
      nestedMap?['full_name'],
      nestedMap?['user_name'],
      primaryUser?['fullName'],
      primaryUser?['name'],
      primaryUser?['username'],
      primaryUser?['full_name'],
      primaryUser?['user_name'],
      primaryUser?['FullName'],
      primaryUser?['Name'],
      primaryUser?['Username'],
    ]);

    var resolvedPhoneNumber = _pickFirstNonEmpty([
      fallbackPhoneNumber,
      response['phoneNumber'],
      response['phone'],
      response['phone_number'],
      nestedMap?['phoneNumber'],
      nestedMap?['phone'],
      nestedMap?['phone_number'],
      primaryUser?['phoneNumber'],
      primaryUser?['phone'],
      primaryUser?['phone_number'],
      primaryUser?['PhoneNumber'],
      primaryUser?['Phone'],
    ]);

    final resolvedToken = _extractToken(response);
    final resolvedRefreshToken = _extractRefreshToken(response);
    final resolvedAccessTokenExpiresInSeconds =
        _extractAccessTokenExpiresInSeconds(response);
    final resolvedRefreshTokenExpiresInSeconds =
        _extractRefreshTokenExpiresInSeconds(response);
    final hasCredentialPayload =
        resolvedToken.isNotEmpty ||
        resolvedRefreshToken.isNotEmpty ||
        resolvedAccessTokenExpiresInSeconds != null ||
        resolvedRefreshTokenExpiresInSeconds != null;

    if (resolvedFullName.isEmpty && resolvedToken.isNotEmpty) {
      try {
        final profileResult = await _authService.getUserProfile(
          accessToken: resolvedToken,
        );
        final profileErrorCode = _clean(profileResult['errorCode']);
        final profileSuccess = profileResult['success'] == true;

        if (profileErrorCode.isEmpty && profileSuccess) {
          final profileMap =
              _toStringDynamicMap(profileResult['data']) ?? profileResult;
          final profileUser = _extractPrimaryUser(profileResult);

          final profileName = _pickFirstNonEmpty([
            profileMap['fullName'],
            profileMap['name'],
            profileMap['username'],
            profileMap['full_name'],
            profileMap['user_name'],
            profileUser?['fullName'],
            profileUser?['name'],
            profileUser?['username'],
            profileUser?['full_name'],
            profileUser?['user_name'],
          ]);
          final profilePhone = _pickFirstNonEmpty([
            profileMap['phoneNumber'],
            profileMap['phone'],
            profileMap['phone_number'],
            profileUser?['phoneNumber'],
            profileUser?['phone'],
            profileUser?['phone_number'],
          ]);

          if (profileName.isNotEmpty) {
            resolvedFullName = profileName;
          }
          if (profilePhone.isNotEmpty) {
            resolvedPhoneNumber = profilePhone;
          }
        }
      } catch (_) {
        // Keep the PIN setup flow successful even if profile hydration fails.
      }
    }

    return _ResolvedSessionData(
      fullName: resolvedFullName,
      phoneNumber: resolvedPhoneNumber,
      token: resolvedToken,
      refreshToken: resolvedRefreshToken,
      accessTokenExpiresInSeconds: resolvedAccessTokenExpiresInSeconds,
      refreshTokenExpiresInSeconds: resolvedRefreshTokenExpiresInSeconds,
      hasCredentialPayload: hasCredentialPayload,
    );
  }

  Future<_ResolvedSessionData> _ensureSessionAfterPinSetup(
    Map<String, dynamic> pinSetupResponse,
  ) async {
    final fallbackFullName = _clean(widget.fullName);
    final fallbackPhoneNumber = _clean(widget.phoneNumber);

    var resolved = await _resolveSessionData(
      pinSetupResponse,
      fallbackFullName: fallbackFullName,
      fallbackPhoneNumber: fallbackPhoneNumber,
    );

    final hasExistingAccessToken = (UserSession.token ?? '').trim().isNotEmpty;
    final shouldAutoLogin =
        !resolved.hasCredentialPayload &&
        !hasExistingAccessToken &&
        fallbackPhoneNumber.isNotEmpty;

    if (!shouldAutoLogin) {
      return resolved;
    }

    final loginResponse = await _authService.verifyPin(
      phoneNumber: fallbackPhoneNumber,
      pinCode: _pinCode,
    );
    final loginErrorCode = _clean(loginResponse['errorCode']);
    final loginSuccess = loginResponse['success'] == true;

    if (loginErrorCode.isNotEmpty || !loginSuccess) {
      throw Exception(
        'Your PIN was updated, but automatic sign-in failed. Please log in with your new PIN.',
      );
    }

    resolved = await _resolveSessionData(
      loginResponse,
      fallbackFullName: fallbackFullName,
      fallbackPhoneNumber: fallbackPhoneNumber,
    );

    return resolved;
  }

  bool _isMissingEndpointResponse(Map<String, dynamic> payload) {
    final code = _clean(payload['errorCode']).toUpperCase();
    if (code == 'HTTP404' || code == 'HTTP405') return true;
    final message = _clean(payload['errorMsg']).toLowerCase();
    return message.contains('not found') || message.contains('no endpoint');
  }

  Future<Map<String, dynamic>> _submitPinToBackend() async {
    if (widget.flow == PinSetupFlow.forgotPin) {
      final resetResponse = await _authService.resetPin(
        pinCode: _pinCode,
        confirmPinCode: _pinCode,
        phoneNumber: widget.phoneNumber,
        resetToken: widget.resetToken,
      );
      if (_isMissingEndpointResponse(resetResponse)) {
        return _authService.setPin(pinCode: _pinCode, confirmPinCode: _pinCode);
      }
      return resetResponse;
    }

    final setResponse = await _authService.setPin(
      pinCode: _pinCode,
      confirmPinCode: _pinCode,
    );
    if (_isMissingEndpointResponse(setResponse)) {
      return _authService.resetPin(
        pinCode: _pinCode,
        confirmPinCode: _pinCode,
        phoneNumber: widget.phoneNumber,
      );
    }
    return setResponse;
  }

  Future<void> _submit() async {
    if (!_isComplete || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final response = await _submitPinToBackend();
      if (!mounted) return;

      final success = response['success'] == true;
      final errorCode = _clean(response['errorCode']);
      final errorMsg = _clean(response['errorMsg']);
      final isAccepted = errorCode.isEmpty && success;

      if (!isAccepted) {
        setState(() => _isSubmitting = false);
        // Security: never expose the backend's specific error message in the
        // forgotPin flow. A message like "New PIN must be different from
        // current PIN" reveals that the entered PIN matches the current PIN,
        // allowing brute-force PIN discovery via the OTP reset path.
        final displayMessage = widget.flow == PinSetupFlow.forgotPin
            ? 'PIN reset failed. Please try again.'
            : (errorMsg.isEmpty
                  ? 'Unable to set your PIN right now. Please try again.'
                  : errorMsg);
        _showErrorDialog(
          title: 'PIN Setup Failed',
          message: displayMessage,
          icon: Icons.error_outline_rounded,
          iconColor: const Color(0xFFEC407A),
        );
        return;
      }

      final resolvedSession = await _ensureSessionAfterPinSetup(response);
      if (!mounted) return;

      await UserSession.markAuthenticated(
        fullName: resolvedSession.fullName.isEmpty
            ? (_clean(widget.fullName).isEmpty ? null : widget.fullName)
            : resolvedSession.fullName,
        phoneNumber: resolvedSession.phoneNumber.isEmpty
            ? null
            : resolvedSession.phoneNumber,
        token: resolvedSession.hasCredentialPayload
            ? resolvedSession.token
            : null,
        refreshToken: resolvedSession.hasCredentialPayload
            ? resolvedSession.refreshToken
            : null,
        accessTokenExpiresInSeconds: resolvedSession.hasCredentialPayload
            ? resolvedSession.accessTokenExpiresInSeconds
            : null,
        refreshTokenExpiresInSeconds: resolvedSession.hasCredentialPayload
            ? resolvedSession.refreshTokenExpiresInSeconds
            : null,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      context.read<FavoriteBloc>().add(const FavoriteMigrationRequested());
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
        title: isNetworkError ? 'No Connection' : 'PIN Setup Failed',
        message: isNetworkError
            ? 'No internet connection. Please check your network and try again.'
            : 'Unable to set PIN right now.',
        icon: isNetworkError ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
        iconColor: isNetworkError ? Colors.orangeAccent : Colors.redAccent,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showErrorDialog(
        title: 'PIN Setup Failed',
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
    final title = widget.flow == PinSetupFlow.signup
        ? 'Set new PIN'
        : 'Reset your PIN';
    final subtitle = widget.flow == PinSetupFlow.signup
        ? 'Make sure you remember'
        : 'Choose a new PIN for login';

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
                Icons.shield_outlined,
                size: 82,
                color: Color(0xFFEC407A),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  subtitle,
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
                        onChanged: (value) => _onChanged(index, value),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () => setState(() => _showPin = !_showPin),
                  child: const Text(
                    'Show PIN',
                    style: TextStyle(color: Color(0xFFEC407A), fontSize: 16),
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
