import 'package:flutter/material.dart';
import 'package:guideme/core/services/firebase_auth_service.dart';
import 'package:guideme/widgets/auth_text_field.dart';
import 'package:guideme/widgets/custom_appbar.dart';
import 'package:guideme/widgets/custom_button.dart';
import 'package:guideme/widgets/custom_snackbar.dart';
import 'package:guideme/widgets/custom_title.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuthService _auth = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(title: ''),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TitlePage(title: 'Reset Password', subtitle: 'Enter your email to reset your password'),
            SizedBox(height: 40),
            AuthTextField(
              label: 'Email',
              controller: _emailController,
              obscureText: false,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 40),
            LargeButton(
              label: 'Reset Password',
              onPressed: () {
                final email = _emailController.text.trim();
                if (email.isNotEmpty) {
                  _auth.sendPasswordResetEmail(email, context);
                } else {
                  DangerFloatingSnackBar.show(
                    context: context,
                    message: 'Please enter your email',
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
