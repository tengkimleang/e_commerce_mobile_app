// lib/modules/login_screen/views/login_view.dart
import 'package:e_commerce_mobile_app/modules/term_condition_screen/views/term_condition_view.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/views/edit_language_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_mobile_app/core/services/auth_service.dart';
import 'package:e_commerce_mobile_app/modules/login_screen/blocs/login_bloc.dart';
import 'package:e_commerce_mobile_app/modules/login_screen/blocs/login_event.dart';
import 'package:e_commerce_mobile_app/modules/login_screen/blocs/login_state.dart';
import 'package:e_commerce_mobile_app/modules/slash_screen/views/index.dart';
import 'package:e_commerce_mobile_app/modules/signup_screen/views/signup_view.dart';
import 'package:e_commerce_mobile_app/modules/login_screen/views/otp_view.dart';
import 'package:e_commerce_mobile_app/modules/login_screen/views/pin_login_view.dart';
import 'package:flutter/services.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';

class _ReactivateOtpLaunch {
  const _ReactivateOtpLaunch({
    required this.phoneNumber,
    required this.channel,
    this.deliveryMessage,
  });

  final String phoneNumber;
  final String channel;
  final String? deliveryMessage;
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  static final AuthService _authService = AuthService();

  static void _showErrorDialog(BuildContext context, LoginError state) {
    IconData icon;
    Color iconColor;
    String title;

    switch (state.errorType) {
      case LoginErrorType.network:
        icon = Icons.wifi_off_rounded;
        iconColor = Colors.orangeAccent;
        title = 'No Connection';
      case LoginErrorType.server:
        icon = Icons.cloud_off_rounded;
        iconColor = Colors.redAccent;
        title = 'Server Error';
      case LoginErrorType.validation:
        icon = Icons.error_outline_rounded;
        iconColor = Theme.of(context).colorScheme.primary;
        title = 'Invalid Input';
      case LoginErrorType.unknown:
        icon = Icons.warning_amber_rounded;
        iconColor = Colors.red;
        title = 'Something Went Wrong';
    }

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
              state.message,
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
                foregroundColor: Theme.of(context).colorScheme.primary,
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

  static Future<void> _showNotRegisteredDialog(
    BuildContext context,
    LoginPhoneNotRegistered state,
  ) async {
    final shouldGoSignup = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final primary = Theme.of(dialogContext).colorScheme.primary;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  color: primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Account Not Found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                '${state.message}\nPlease sign up first.',
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
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: primary,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Go to Sign Up'),
            ),
          ],
        );
      },
    );

    if (!context.mounted || shouldGoSignup != true) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignupView(initialPhoneNumber: state.phoneNumber),
      ),
    );
  }

  static Future<void> _showDeletedPhoneSheet(
    BuildContext context,
    LoginPhoneDeleted state,
  ) async {
    final launch = await showModalBottomSheet<_ReactivateOtpLaunch>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final primary = Theme.of(sheetContext).colorScheme.primary;
        var isSubmitting = false;
        String errorText = '';

        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> requestActivationOtp() async {
              if (isSubmitting) return;
              setSheetState(() {
                isSubmitting = true;
                errorText = '';
              });

              try {
                final result = await _authService.requestReactivateOtp(
                  phoneNumber: state.phoneNumber,
                );
                final errorCode = (result['errorCode'] ?? '').toString().trim();
                final errorMsg = (result['errorMsg'] ?? '').toString().trim();
                final sent = result['sent'] == true;
                final success = result['success'] == true;
                final didSend = sent || success;

                if (errorCode.isNotEmpty || !didSend) {
                  setSheetState(() {
                    isSubmitting = false;
                    errorText = errorMsg.isEmpty
                        ? 'Unable to request activation OTP right now.'
                        : errorMsg;
                  });
                  return;
                }

                if (!sheetContext.mounted) return;
                Navigator.of(sheetContext).pop(
                  _ReactivateOtpLaunch(
                    phoneNumber: state.phoneNumber,
                    channel: result['channel'] as String? ?? 'sms',
                    deliveryMessage: result['deliveryMessage'] as String?,
                  ),
                );
              } catch (_) {
                if (!sheetContext.mounted) return;
                setSheetState(() {
                  isSubmitting = false;
                  errorText = 'Unable to request activation OTP right now.';
                });
              }
            }

            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  30,
                  24,
                  24 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      state.message.isEmpty
                          ? 'This phone number has been deleted'
                          : state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D1B22),
                      ),
                    ),
                    const SizedBox(height: 72),
                    const Text(
                      'To activate this phone number back, please click confirm activation and do the verification process again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF1D1B22),
                        height: 1.35,
                      ),
                    ),
                    if (errorText.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        errorText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                        ),
                      ),
                    ],
                    const SizedBox(height: 72),
                    SizedBox(
                      height: 58,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : requestActivationOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Confirm Activation',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (!context.mounted || launch == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpView(
          phoneNumber: launch.phoneNumber,
          flow: AuthFlow.reactivation,
          channel: launch.channel,
          deliveryMessage: launch.deliveryMessage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          debugPrint(
            '[LoginView] BlocListener received state: ${state.runtimeType}',
          );
          if (state is LoginPinRequired) {
            debugPrint(
              '[LoginView] Navigating to PinLoginView with phone: ${state.phoneNumber}',
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PinLoginView(phoneNumber: state.phoneNumber),
              ),
            );
          } else if (state is LoginPhoneNotRegistered) {
            _showNotRegisteredDialog(context, state);
          } else if (state is LoginPhoneDeleted) {
            _showDeletedPhoneSheet(context, state);
          } else if (state is LoginError) {
            _showErrorDialog(context, state);
          }
        },
        child: const _LoginContent(),
      ),
    );
  }
}

class _LoginContent extends StatefulWidget {
  const _LoginContent();

  @override
  State<_LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<_LoginContent> {
  late TextEditingController _phoneController;
  late TapGestureRecognizer _termsTapRecognizer;
  late TapGestureRecognizer _privacyTapRecognizer;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _termsTapRecognizer = TapGestureRecognizer()..onTap = _openTermsOfUsePage;
    _privacyTapRecognizer = TapGestureRecognizer()
      ..onTap = _openPrivacyPolicyPage;
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
    _termsTapRecognizer.dispose();
    _privacyTapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isShortScreen = MediaQuery.sizeOf(context).height < 700;
    final logoSize = isShortScreen ? 132.0 : 180.0;
    final formGap = isShortScreen ? 20.0 : 32.0;
    final actionGap = isShortScreen ? 18.0 : 48.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupView(),
                          ),
                        );
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () {
                        showLanguageBottomSheet(
                          context,
                          selectedLanguageCode: 'en',
                        ).then((selectedCode) {
                          if (selectedCode != null) {
                            // Handle language change if needed
                          }
                        });
                      },
                      icon: const Text("🇬🇧", style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
                Center(
                  child: Container(
                    width: logoSize,
                    height: logoSize,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: Image.asset(
                      'assets/images/Chipmong_Logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: formGap),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    children: [
                      const TextSpan(text: 'Phone number'),
                      TextSpan(
                        text: '*',
                        style: TextStyle(color: primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    return TextField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: "Enter phone number",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primary, width: 1.8),
                        ),
                        errorText:
                            (state is LoginUpdated &&
                                state.isPhoneValid == false &&
                                _phoneController.text.isNotEmpty)
                            ? "Please enter a valid phone number"
                            : null,
                        errorStyle: const TextStyle(fontSize: 12),
                      ),
                      onChanged: (value) {
                        context.read<LoginBloc>().add(PhoneChanged(value));
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(
                        text:
                            "By clicking Next button you are agreeing to the ",
                      ),
                      TextSpan(
                        text: "Terms of Use",
                        style: TextStyle(
                          color: primary,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: _termsTapRecognizer,
                      ),
                      const TextSpan(text: " and the "),
                      TextSpan(
                        text: "Privacy Policy",
                        style: TextStyle(
                          color: primary,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: _privacyTapRecognizer,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: actionGap),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      await UserSession.markGuest();
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IndexView(),
                        ),
                      );
                    },
                    child: Text(
                      "Continue as guest",
                      style: TextStyle(
                        color: primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    return SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: state is LoginLoading
                            ? null
                            : () {
                                context.read<LoginBloc>().add(
                                  const LoginPressed(),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: state is LoginLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    "@2026 CHIP MONG GROUP | v1.8.3",
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
