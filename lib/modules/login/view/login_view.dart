import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_mobile_app/modules/login/controller/login_bloc.dart';
import 'package:e_commerce_mobile_app/modules/login/controller/login_event.dart';
import 'package:e_commerce_mobile_app/modules/login/controller/login_state.dart';
import 'package:e_commerce_mobile_app/modules/home/view/home_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: const _LoginContent(),
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

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
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
              // Top bar (unchanged)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // TODO: go to sign up screen
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Color(0xFFEC407A),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text("🇬🇧", style: TextStyle(fontSize: 20)),
                ],
              ),

              // Logo (unchanged)
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Image.asset(
                        'assets/images/Chipmong_Logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Phone number* (your nice RichText version)
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(text: 'Phone number'),
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.pinkAccent),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // TextField with Bloc (unchanged)
              BlocBuilder<LoginBloc, LoginState>(
                builder: (context, state) {
                  return TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: "Enter phone number",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFEC407A), width: 1.8),
                      ),
                      errorText: (state is LoginUpdated &&
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

              // Terms (unchanged)
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
                  children: [
                    const TextSpan(text: "By clicking Next button you are agreeing to the "),
                    TextSpan(
                      text: "Terms of Use",
                      style: const TextStyle(color: Color(0xFFEC407A), decoration: TextDecoration.underline),
                    ),
                    const TextSpan(text: " and the "),
                    TextSpan(
                      text: "Privacy Policy",
                      style: const TextStyle(color: Color(0xFFEC407A), decoration: TextDecoration.underline),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 5),

              // 🔥 UPDATED: Continue as guest → now navigates!
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeView(),   // ← goes to home screen
                      ),
                    );
                  },
                  child: const Text(
                    "Continue as guest",
                    style: TextStyle(
                      color: Colors.pink,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Pink Login button (unchanged)
              BlocBuilder<LoginBloc, LoginState>(
                builder: (context, state) {
                  return SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state is LoginLoading
                          ? null
                          : () {
                              context.read<LoginBloc>().add(const LoginPressed());
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEC407A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: state is LoginLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              "Login",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Footer (unchanged)
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
    );
  }
}
