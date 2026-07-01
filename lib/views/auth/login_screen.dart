import 'package:double_back_to_exit/double_back_to_exit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:guideme/views/auth/forgot_password_screen.dart';
import 'package:guideme/views/auth/register_screen.dart'; // Import RegisterScreen
import 'package:guideme/views/user/home_screen.dart';
import 'package:guideme/widgets/custom_snackbar.dart';
import 'package:guideme/widgets/widgets.dart';
import 'package:guideme/core/services/firebase_auth_service.dart'; // Import FirebaseAuthService
import 'package:guideme/core/constants/constants.dart'; // Import Constants

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService(); // Inisialisasi FirebaseAuthService
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn(); // Periksa status login saat halaman dimulai
  }

  Future<void> _checkIfLoggedIn() async {
    bool isLoggedIn = await _auth.isLoggedIn(); // Metode untuk memeriksa status login
    if (isLoggedIn) {
      // Jika sudah login, arahkan langsung ke HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  void _loginUser(BuildContext context) async {
    FocusScope.of(context).unfocus();
    // Cek apakah email kosong
    if (_emailController.text.isEmpty) {
      DangerFloatingSnackBar.show(
        context: context,
        message: 'Email cannot be empty',
      );
      return;
    }
    if (_passwordController.text.isEmpty) {
      DangerFloatingSnackBar.show(
        context: context,
        message: 'Password cannot be empty',
      );
      return;
    }

    try {
      // Panggil fungsi loginUser dari FirebaseAuthService
      await _auth.loginUser(
        context,
        _emailController.text,
        _passwordController.text,
      );
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("An unexpected error occurred. Please try again.")),
      // );
      DangerFloatingSnackBar.show(
        context: context,
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DoubleBackToExit(
      snackBarMessage: 'Press back again to exit',
      child: Scaffold(
        appBar: CloseAppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                TitlePage(
                  title: 'Login',
                  subtitle: 'Log in to start planning your trip.',
                  // borderColor: Colors.blue,
                ),
                SizedBox(height: 40),
                AuthTextField(
                  controller: _emailController,
                  label: 'Email',
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email cannot be empty';
                    }
                    // Regular expression for email validation
                    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
                    RegExp regex = RegExp(pattern);
                    if (!regex.hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                AuthTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: true,
                ),
                SizedBox(height: 40),
                LargeButton(
                  label: 'Login',
                  onPressed: () => _loginUser(context),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: "Don't have an account? ", style: AppTextStyles.smallBlack),
                          TextSpan(
                            text: "Register here",
                            style: AppTextStyles.smallBlackBold,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).push(
                                  SlideAnimation(
                                    page: RegisterScreen(),
                                    direction: AxisDirection.left,
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: AppTextStyles.smallBold.copyWith(color: AppColors.blueColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
