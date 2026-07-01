import 'package:cloud_firestore/cloud_firestore.dart';

class UserController {

    // Fungsi untuk menghapus pengguna berdasarkan UID
  Future<void> deleteUser(String uid) async {
    try {
      // Menghapus data pengguna dari Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      print("User deleted successfully.");
    } catch (e) {
      print("Error deleting user: $e");
    }
  }






  // final FirebaseAuthService _auth = FirebaseAuthService();

  // Fungsi untuk login
  // Future<void> loginUser(BuildContext context, String email, String password) async {
  //   try {
  //     // Coba untuk login menggunakan FirebaseAuthService
  //     UserModel? user = await _auth.loginUser(email, password);
  //     if (user != null) {
  //       // Jika login berhasil, cek role pengguna
  //       if (user.role == 'admin') {
  //         // Tampilkan pesan sukses menggunakan SnackBar
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text("Success logged in as ${user.role}")),
  //         );

  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (context) => DashboardScreen()),
  //         );
  //       } else {
  //         // Tampilkan pesan sukses menggunakan SnackBar
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text("Success logged in as ${user.role}")),
  //         );

  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (context) => HomeScreen()),
  //         );
  //       }
  //     } else {
  //       // Jika login gagal, tampilkan pesan kesalahan
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Email atau Password salah")),
  //       );
  //     }
  //   } catch (e) {
  //     // Menangani kesalahan lainnya, misalnya kesalahan server atau koneksi
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Login gagal: $e")),
  //     );
  //   }
  // }

  // Mendapatkan role login pengguna
  // Future<bool> isLoggedIn() async {
  //   var user = await _auth.getCurrentUser();
  //   return user != null;
  // }

  // Future<bool> isAdmin() async {
  //   var user = await _auth.getCurrentUser();
  //   if (user != null) {
  //     // Asumsi Anda menyimpan data peran pengguna (role) di Firebase Firestore
  //     var userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  //     var role = userDoc.data()?['role']; // Ambil role dari dokumen pengguna
  //     return role == 'admin'; // Mengembalikan true jika role admin
  //   }
  //   return false;
  // }

// Fungsi untuk register pengguna
  // Fungsi untuk validasi email (contoh sederhana)
  // bool _isValidEmail(String email) {
  //   // Validasi format email menggunakan regex sederhana
  //   return email.contains('@') && email.contains('.');
  // }

  // // Fungsi untuk validasi username (misalnya minimal 4 karakter)
  // bool _isValidUsername(String username) {
  //   return username.length >= 4;
  // }

  // Future<String?> registerUser(BuildContext context, String email, String password, String username) async {
  //   // Validasi panjang username
  //   if (!_isValidUsername(username)) {
  //     return 'Username must be at least 4 characters';
  //   }

  //   // Validasi format email
  //   if (!_isValidEmail(email)) {
  //     return 'Invalid email format';
  //   }

  //   // Validasi password jika diperlukan (contoh: minimal 6 karakter)
  //   if (password.length < 6) {
  //     return 'Password must be at least 6 characters';
  //   }

  //   // Memanggil fungsi registerUser pada FirebaseAuthService untuk mendaftar pengguna
  //   try {
  //     UserModel? user = await _auth.registerUser(email, password, username);

  //     if (user != null) {
  //       // Jika pendaftaran berhasil, arahkan pengguna ke halaman login
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => LoginScreen()),
  //       );
  //       return 'Registration successful'; // Tambahkan pesan sukses
  //     } else {
  //       return 'Registration failed';
  //     }
  //   } catch (e) {
  //     return 'Error: $e';
  //   }
  // }

  // // Fungsi untuk memeriksa apakah email sudah digunakan
  // Future<bool> isEmailInUse(String email) async {
  //   final querySnapshot = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();

  //   return querySnapshot.docs.isNotEmpty; // Mengembalikan true jika email sudah ada
  // }

  // // Fungsi untuk memeriksa apakah username sudah digunakan
  // Future<bool> isUsernameTaken(String username) async {
  //   final querySnapshot = await FirebaseFirestore.instance.collection('users').where('username', isEqualTo: username).get();

  //   return querySnapshot.docs.isNotEmpty; // Mengembalikan true jika username sudah ada
  // }

  // Fungsi untuk logout
  // Future<void> logout() async {
  //   await _auth.logout();
  // }


}
