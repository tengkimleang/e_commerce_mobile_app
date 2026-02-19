// This is the UI for the login screen
// It displays the form and responds to BLoC state changes

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_mobile_app/modules/login/controller/login_bloc.dart';
import 'package:e_commerce_mobile_app/modules/login/controller/login_event.dart';
import 'package:e_commerce_mobile_app/modules/login/controller/login_state.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: const _LoginContent(),
    );
  }
}

class _LoginContent extends StatefulWidget {
  const _LoginContent({Key? key}) : super(key: key);

  @override
  State<_LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<_LoginContent> {
  // Text controllers to manage input fields
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: const Text('Sign Up'),
      //   titleTextStyle: TextStyle(color:Colors.pinkAccent,fontSize: 15,fontWeight: FontWeight.bold),
      //   centerTitle: true,
      // ),
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          // Show snackbar for success/error messages
          if (state is LoginSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // TODO: Navigate to home screen after successful login
            // Navigator.of(context).pushReplacementNamed('/home');
          } else if (state is LoginError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'Sign Up',
                      style:TextStyle(color:Colors.pinkAccent,fontSize: 20,fontWeight: FontWeight.bold),

                      // style: Theme.of(context).textTheme.headlineLarge,
                    ),
                      // App Logo or Title
               Image.asset(
                          'assets/images/Chipmong_Logo.png', // Make sure this matches your file name
                          height: 120,       // Adjust size as you like
                          fit: BoxFit.contain,
                        ),
  
                    


                    // Phone Number Input Field
                  const SizedBox(height: 40),
                          Text(
                          'Phone number*',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,

                          ),
                        ),
                  TextField(
                    
                    controller: _phoneController,
                    keyboardType: TextInputType.phone, // Opens the number pad
                    decoration: InputDecoration(
                      // labelText: 'Enter phone number',
                      hintText: 'Enter phone number',
                      // prefixIcon: const Icon(Icons.phone),
                     // Optional: Add your country code here
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // Show error if phone number is invalid
                      errorText: state is LoginUpdated && state.isPhoneValid == false && _phoneController.text.isNotEmpty
                          ? 'Please enter a valid phone number'
                          : null,
                    ),
                    onChanged: (phone) {
                      context.read<LoginBloc>().add(PhoneChanged(phone));
                    },
                  ),
                    const SizedBox(height: 16),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: state is LoginLoading
                            ? null // Disable button while loading
                            : () {
                                context
                                    .read<LoginBloc>()
                                    .add(const LoginPressed());
                              },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: state is LoginLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Forgot Password Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        TextButton(
                          onPressed: () {
                            // TODO: Navigate to sign up screen
                            // Navigator.of(context).pushNamed('/signup');
                          },
                          child: const Text('Sign up'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to forgot password screen
                        // Navigator.of(context).pushNamed('/forgot-password');
                      },
                      child: const Text('Forgot password?'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}