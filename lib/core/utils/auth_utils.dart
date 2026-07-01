import 'package:flutter/material.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/views/user/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:guideme/core/services/auth_provider.dart'; // Sesuaikan dengan path yang benar

// Fungsi untuk menangani logout
Future<void> handleLogout(BuildContext context) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  await authProvider.logout();

  // Menampilkan SnackBar setelah logout berhasil
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        "Logout successful",
        style: AppTextStyles.mediumBold.copyWith(
          color: AppColors.backgroundColor, // Mengubah warna teks
        ),
      ),
      backgroundColor: AppColors.redColor, // Mengubah warna background menjadi merah
      behavior: SnackBarBehavior.floating, // Opsional: membuat SnackBar mengapung
      margin: EdgeInsets.all(16), // Menambahkan margin
    ),
  );
  // Navigasi ke halaman login setelah logout
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => HomeScreen()),
    (Route<dynamic> route) => false, // Menghapus semua halaman sebelumnya
  );
}
