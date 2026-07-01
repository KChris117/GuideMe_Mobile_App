import 'package:flutter/material.dart';

// konstanta
import 'package:guideme/core/constants/constants.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final bool obscureText;
  final TextEditingController controller; // Menambahkan controller
  final String? Function(String?)? validator; // Menambahkan validator
  final TextInputType? keyboardType; // Menambahkan keyboardType opsional

  const AuthTextField({
    super.key,
    required this.label,
    this.hintText,
    this.obscureText = false,
    required this.controller, // Controller ditambahkan di konstruktor
    this.validator, // Validator ditambahkan di konstruktor
    this.keyboardType, // keyboardType opsional
  });

  @override
  _AuthTextFieldState createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _isObscureText;

  @override
  void initState() {
    super.initState();
    _isObscureText = widget.obscureText;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscureText = !_isObscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.bodyBlackBold,
        ),
        TextFormField(
          controller: widget.controller, // Menambahkan controller
          obscureText: _isObscureText,
          keyboardType: widget.keyboardType ?? TextInputType.text, // keyboardType default
          style: AppTextStyles.bodyBlack,
          decoration: InputDecoration(
            // labelText: widget.label,
            labelStyle: AppTextStyles.headingBlack,
            floatingLabelBehavior: FloatingLabelBehavior.always, // Label selalu mengambang
            contentPadding: EdgeInsets.only(
              left: 8,
              top: _isObscureText ? 10 : 10, // Padding atas hanya jika true
              bottom: _isObscureText ? 10 : 16, // Padding bawah hanya jika true
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey), // Border default
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                width: 2,
                color: AppColors.primaryColor, // Border berubah warna saat fokus
              ),
            ),
            // Menambahkan icon hanya ketika obscureText true
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _isObscureText ? AppIcons.eyeOpen : AppIcons.eyeClose,
                      color: AppColors.primaryColor, // Warna ikon
                    ),
                    onPressed: _togglePasswordVisibility, // Toggle password visibility
                  )
                : null, // Tidak menampilkan ikon jika obscureText false
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Field cannot be empty';
            }
            if (widget.validator != null) {
              return widget.validator!(value);
            }
            return null;
          }, // Menambahkan validator wajib
        ),
      ],
    );
  }
}
