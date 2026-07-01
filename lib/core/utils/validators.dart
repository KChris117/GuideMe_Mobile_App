import 'package:cloud_firestore/cloud_firestore.dart';

// Fungsi untuk memeriksa apakah email sudah digunakan
Future<bool> isEmailInUse(String email) async {
  final querySnapshot = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();
  return querySnapshot.docs.isNotEmpty; // Mengembalikan true jika email sudah ada
}
Future<bool> isEmailNotInUse(String email) async {
  final querySnapshot = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();
  return querySnapshot.docs.isEmpty; // Mengembalikan true jika email sudah ada
}

// Fungsi untuk memeriksa apakah username sudah digunakan
Future<bool> isUsernameTaken(String username) async {
  final querySnapshot = await FirebaseFirestore.instance.collection('users').where('username', isEqualTo: username).get();
  return querySnapshot.docs.isNotEmpty; // Mengembalikan true jika username sudah ada
}

// Fungsi untuk validasi format email
bool isValidEmail(String email) {
  // Validasi format email menggunakan regex sederhana
  return email.contains('@') && email.contains('.');
}

// Fungsi untuk validasi username (misalnya minimal 4 karakter)
bool isValidUsername(String username) {
  return username.length >= 4;
}

// Fungsi untuk validasi password
bool isValidPassword(String password) {
  final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])[A-Za-z\d!@#$%^&*(),.?":{}|<>]{6,}$');
  return regex.hasMatch(password);
}