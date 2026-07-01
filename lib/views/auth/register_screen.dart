import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guideme/widgets/custom_snackbar.dart';
import 'package:guideme/widgets/widgets.dart';
import 'package:guideme/core/services/firebase_auth_service.dart'; // Jika ada widget yang digunakan seperti AuthTextField
import 'package:guideme/core/utils/validators.dart'; // Import validators.dart

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Tambahkan GlobalKey

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  Future<String?> _registerUser(BuildContext context) async {
    // Cek apakah email kosong
    if (_emailController.text.isEmpty) {
      DangerFloatingSnackBar.show(
        context: context,
        message: 'Email cannot be empty',
      );
      return 'Email cannot be empty';
    }

    // Validasi format email
    if (!isValidEmail(_emailController.text)) {
      DangerFloatingSnackBar.show(
        context: context,
        message: 'Invalid email format',
      );
      return 'Invalid email format';
    }

    // Pengecekan apakah email sudah digunakan
    if (await isEmailInUse(_emailController.text)) {
      DangerFloatingSnackBar.show(
        context: context,
        message: 'Email is already in use',
      );
      return 'Email is already in use';
    }

    // Cek apakah username kosong
    if (_usernameController.text.isEmpty) {
      DangerFloatingSnackBar.show(
        context: context,
        message: 'Username cannot be empty',
      );
      return 'Username cannot be empty';
    }

    // Validasi panjang username
    if (!isValidUsername(_usernameController.text)) {
      DangerFloatingSnackBar.show(
        context: context,
        message: 'Username must be at least 4 characters',
      );
      return 'Username must be at least 4 characters';
    }

    // Pengecekan apakah username sudah digunakan
    if (await isUsernameTaken(_usernameController.text)) {
      DangerFloatingSnackBar.show(
        context: context,
        message: 'Username is already taken',
      );
      return 'Username is already taken';
    }

    // Cek apakah password kosong
    if (_passwordController.text.isEmpty) {
      DangerFloatingSnackBar.show(
        context: context,
        message: 'Password cannot be empty',
      );
      return 'Password cannot be empty';
    }

    // Validasi password jika diperlukan (contoh: minimal 6 karakter)
    if (_passwordController.text.length < 6) {
      DangerFloatingSnackBar.show(
        context: context,
        message: 'Password must be at least 6 characters',
      );
      return 'Password must be at least 6 characters';
    }

    // Validasi format password
    if (!isValidPassword(_passwordController.text)) {
      DangerFloatingSnackBar.show(
        context: context,
        message: 'Password must contain at least 1 lowercase letter, 1 uppercase letter, 1 number, and 1 special character',
      );
      return 'Password must contain at least 1 lowercase letter, 1 uppercase letter, 1 number, and 1 special character';
    }

    // Cek apakah confirm password kosong
    if (_confirmPasswordController.text.isEmpty) {
      DangerFloatingSnackBar.show(
        context: context,
        message: 'Please confirm your password',
      );
      return 'Please confirm your password';
    }

    // Cek apakah password dan confirm password sama
    if (_passwordController.text != _confirmPasswordController.text) {
      // FloatingSnackBar.show(
      //   context: context,
      //   message: "Passwords do not match",
      //   backgroundColor: Colors.red,
      //   textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      //   duration: Duration(seconds: 2),
      // );
      DangerFloatingSnackBar.show(
        context: context,
        message: 'Passwords do not match',
      );
      return 'Passwords do not match';
    }

    // Jika username dan email valid, lanjutkan registrasi
    String? validationMessage = await _auth.registerUser(
      context,
      _emailController.text,
      _passwordController.text,
      _usernameController.text,
    );

    // Jika ada pesan validasi, tampilkan Snackbar
    if (validationMessage != null) {
      // FloatingSnackBar.show(
      //   context: context,
      //   message: validationMessage,
      //   backgroundColor: Colors.green,
      //   textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      //   duration: Duration(seconds: 3),
      // );
      SuccessFloatingSnackBar.show(
        context: context,
        message: validationMessage,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CloseAppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                TitlePage(title: "Register", subtitle: "Create a new account."),
                SizedBox(height: 40),
                AuthTextField(
                  controller: _emailController,
                  label: 'Email',
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Field cannot be empty';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                AuthTextField(
                  controller: _usernameController,
                  label: 'Username',
                  obscureText: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Field cannot be empty';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                AuthTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Field cannot be empty';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                AuthTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Field cannot be empty';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),
                LargeButton(
                  label: 'Register',
                  onPressed: () => _registerUser(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
