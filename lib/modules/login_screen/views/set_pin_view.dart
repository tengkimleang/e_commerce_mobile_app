import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/services/auth_service.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/modules/slash_screen/views/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PinSetupFlow { signup, forgotPin }

class SetPinView extends StatefulWidget {
  const SetPinView({
    super.key,
    required this.flow,
    required this.phoneNumber,
    this.fullName,
  });

  final PinSetupFlow flow;
  final String phoneNumber;
  final String? fullName;

  @override
  State<SetPinView> createState() => _SetPinViewState();
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
        _showErrorDialog(
          title: 'PIN Setup Failed',
          message: errorMsg.isEmpty
              ? 'Unable to set your PIN right now. Please try again.'
              : errorMsg,
          icon: Icons.error_outline_rounded,
          iconColor: const Color(0xFFEC407A),
        );
        return;
      }

      await UserSession.markAuthenticated(
        fullName: _clean(widget.fullName).isEmpty ? null : widget.fullName,
        phoneNumber: _clean(widget.phoneNumber).isEmpty
            ? null
            : widget.phoneNumber,
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
