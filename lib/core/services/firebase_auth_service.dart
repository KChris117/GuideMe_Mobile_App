import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/core/utils/validators.dart';
import 'package:guideme/views/admin/dashboard_screen.dart';
import 'package:guideme/views/auth/login_screen.dart';
import 'package:guideme/views/user/home_screen.dart';
import 'package:guideme/widgets/custom_snackbar.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi untuk mengirim verifikasi email
  Future<void> sendEmailVerification(User? user) async {
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Fungsi untuk update role jika email terverifikasi
  Future<void> updateRoleIfVerified(User? user) async {
    if (user != null && user.emailVerified) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'role': 'user', // Menetapkan role user jika email sudah diverifikasi
      });
    }
  }

  Future<String?> registerUser(BuildContext context, String email, String password, String username) async {
    try {
      // Mendaftarkan pengguna di Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Kirim email verifikasi
        await sendEmailVerification(user);

        // Menyimpan data pengguna ke Firestore dengan role dan tanggal pembuatan akun
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'username': username,
          'role': null, // role default
          'profilePicture': 'https://errgdpvuqptgmkobutnt.supabase.co/storage/v1/object/public/images/profiles/profile.jpg?t=2024-12-18T09%3A14%3A25.142Z',
          'createdAt': Timestamp.now(),
        });

        // Logout pengguna setelah registrasi
        await _auth.signOut();

        // Arahkan pengguna ke halaman login dengan pesan untuk memverifikasi email
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        return 'Registration successful. Please verify your email before logging in.';
      }
    } catch (e) {
      print("Register failed: $e");
      return 'Error: $e';
    }
    return 'Registration failed';
  }

  // Fungsi login
  Future<void> loginUser(BuildContext context, String email, String password) async {
    try {
      // Login menggunakan FirebaseAuth
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Ambil role pengguna dari Firestore
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
        final userRole = userDoc.data()?['role'];

        if (userRole == 'admin') {
          PrimarySnackBar.show(
            context,
            'Success logged in as admin',
          );
          // Jika admin, abaikan verifikasi email dan langsung navigasi ke Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
          return;
        }

        // Jika bukan admin, periksa apakah email telah diverifikasi
        if (!firebaseUser.emailVerified) {
          DangerFloatingSnackBar.show(
            context: context,
            message: 'Please verify your email before logging in.',
          );

          // Kirim email verifikasi ulang
          await sendEmailVerification(firebaseUser);
          await FirebaseAuth.instance.signOut(); // Logout pengguna jika email belum diverifikasi
          return;
        }

        // Jika email terverifikasi, update role menjadi 'user'
        await updateRoleIfVerified(firebaseUser);

        // Tampilkan pesan sukses menggunakan SnackBar
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //       "Success logged in as user",
        //       style: AppTextStyles.mediumBold.copyWith(
        //         color: AppColors.backgroundColor, // Mengubah warna teks
        //       ),
        //     ),
        //     backgroundColor: AppColors.primaryColor, // Mengubah warna background menjadi merah
        //     behavior: SnackBarBehavior.floating, // Opsional: membuat SnackBar mengapung
        //     margin: EdgeInsets.all(16), // Menambahkan margin
        //   ),
        // );

        // Menampilkan FloatingSnackbar
        // FloatingSnackBar.show(
        //   context: context,
        //   message: 'Welcome to Home Screen!',
        // );

        // Memberikan delay agar snackbar tampil terlebih dahulu
        // await Future.delayed(Duration(seconds: 2));
        PrimarySnackBar.show(
          context,
          'Success logged in as user',
        );
        // Navigasi ke HomeScreen untuk pengguna biasa
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        // .        then((_) {
        //   // Menampilkan Snackbar setelah navigasi
        //   // ScaffoldMessenger.of(context).showSnackBar(
        //   //   SnackBar(
        //   //     content: Text('Welcome to Home Screen!'),
        //   //     duration: Duration(seconds: 2),
        //   //   ),
        //   // );
        //   Future.delayed(Duration(milliseconds: 100), () {
        //     FloatingSnackBar.show(
        //       context: context,
        //       message: 'Welcome to Home Screen!',
        //     );
        //   });
        // });
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException code: ${e.code}"); // Tambahkan log ini untuk melihat kode kesalahan

      // Tangkap kesalahan dan tampilkan pesan peringatan
      if (e.code == 'invalid-email') {
        // FloatingSnackBar.show(
        //   context: context,
        //   message: "The email address is badly formatted.",
        //   backgroundColor: Colors.red,
        //   textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        //   duration: Duration(seconds: 2),
        // );
        DangerFloatingSnackBar.show(
          context: context,
          message: 'The email address is badly formatted.',
        );
      } else if (e.code == 'user-not-found') {
        // FloatingSnackBar.show(
        //   context: context,
        //   message: "No user found for that email.",
        //   backgroundColor: Colors.red,
        //   textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        //   duration: Duration(seconds: 2),
        // );
        DangerFloatingSnackBar.show(
          context: context,
          message: 'No user found for that email.',
        );
      } else if (await isEmailNotInUse(email)) {
        // FloatingSnackBar.show(
        //   context: context,
        //   message: "No user found for that email.",
        //   backgroundColor: Colors.red,
        //   textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        //   duration: Duration(seconds: 2),
        // );
        DangerFloatingSnackBar.show(
          context: context,
          message: 'No user found for that email.',
        );
        // } else if (e.code == 'wrong-password') {
        //   // FloatingSnackBar.show(
        //   //   context: context,
        //   //   message: "Wrong password provided for that user.",
        //   //   backgroundColor: Colors.red,
        //   //   textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        //   //   duration: Duration(seconds: 2),
        //   // );
        //   DangerFloatingSnackBar.show(
        //     context: context,
        //     message: 'Wrong password provided for that user.',
        //   );
      } else {
        // FloatingSnackBar.show(
        //   context: context,
        //   message: "Please check your password \n\nError during login: ${e.message}",
        //   backgroundColor: Colors.red,
        //   textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        //   duration: Duration(seconds: 2),
        // );
        // DangerFloatingSnackBar.show(
        //   context: context,
        //   message: 'Please check your password \n\nError during login: ${e.message}',
        // );
        DangerFloatingSnackBar.show(
          context: context,
          message: 'Wrong password provided for that user.',
        );
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Login failed: $e")),
      // );
      DangerFloatingSnackBar.show(
        context: context,
        message: 'Login failed: $e',
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);

      // Menampilkan FloatingSnackbar
      SuccessFloatingSnackBar.show(
        context: context,
        message: 'Password reset email sent. Please check your email.',
      );

      // Memberikan delay agar snackbar tampil terlebih dahulu
      await Future.delayed(Duration(seconds: 4));

      // Beralih ke LoginScreen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error: ${e.toString()}')),
      // );
      DangerFloatingSnackBar.show(
        context: context,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  // Future<String?> registerUser(BuildContext context, String email, String password, String username) async {

  //   try {
  //     // Mendaftarkan pengguna di Firebase Authentication
  //     UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     User? user = userCredential.user;

  //     if (user != null) {
  //       // Kirim email verifikasi
  //       await sendEmailVerification(user);

  //       // Menyimpan data pengguna ke Firestore dengan role dan tanggal pembuatan akun
  //       await _firestore.collection('users').doc(user.uid).set({
  //         'uid': user.uid,
  //         'email': email,
  //         'username': username,
  //         'role': 'user', // role default
  //         'profilePicture': 'https://errgdpvuqptgmkobutnt.supabase.co/storage/v1/object/public/images/profiles/profile.jpg?t=2024-12-18T09%3A14%3A25.142Z',
  //         'createdAt': Timestamp.now(),
  //       });

  //       // Mengambil data pengguna dari Firestore dan mengonversinya menjadi UserModel
  //       DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
  //       if (userDoc.exists) {
  //         UserModel userModel = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);

  //         // Jika pendaftaran berhasil, arahkan pengguna ke halaman login
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (context) => LoginScreen()),
  //         );
  //         return 'Registration successful'; // Tambahkan pesan sukses
  //       }
  //     }
  //   } catch (e) {
  //     print("Register failed: $e");
  //     return 'Error: $e';
  //   }
  //   return 'Registration failed';
  // }

  // // Fungsi register
  // Future<UserModel?> registerUser(String email, String password, String username) async {
  //   try {
  //     // Mendaftarkan pengguna di Firebase Authentication
  //     UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     User? user = userCredential.user;

  //     if (user != null) {
  //       // Kirim email verifikasi
  //       await sendEmailVerification(user);

  //       // Menyimpan data pengguna ke Firestore dengan role dan tanggal pembuatan akun
  //       await _firestore.collection('users').doc(user.uid).set({
  //         'uid': user.uid,
  //         'email': email,
  //         'username': username,
  //         'role': 'user', // role default
  //         'profilePicture': 'https://errgdpvuqptgmkobutnt.supabase.co/storage/v1/object/public/images/profiles/profile.jpg?t=2024-12-18T09%3A14%3A25.142Z',
  //         // 'createdAt': Timestamp.now(), // Tanggal pembuatan akun
  //         'createdAt': Timestamp.now(),
  //       });

  //       // Mengambil data pengguna dari Firestore dan mengonversinya menjadi UserModel
  //       DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
  //       if (userDoc.exists) {
  //         return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
  //       }
  //     }
  //   } catch (e) {
  //     print("Register failed: $e");
  //   }
  //   return null;
  // }

  // Future<void> loginUser(BuildContext context, String email, String password) async {
  //   try {
  //     // Login menggunakan FirebaseAuth
  //     final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     final firebaseUser = userCredential.user;

  //     if (firebaseUser != null) {
  //       // Ambil role pengguna dari Firestore
  //       final userDoc = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
  //       final userRole = userDoc.data()?['role'];

  //       if (userRole == 'admin') {
  //         // Jika admin, abaikan verifikasi email dan langsung navigasi ke Dashboard
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (context) => DashboardScreen()),
  //         );
  //         return;
  //       }

  //       // Jika bukan admin, periksa apakah email telah diverifikasi
  //       if (!firebaseUser.emailVerified) {
  //         // ScaffoldMessenger.of(context).showSnackBar(
  //         //   SnackBar(content: Text("Please verify your email before logging in.")),
  //         // );

  //         FloatingSnackBar.show(
  //           context: context,
  //           message: "Please verify your email before logging in.",
  //           backgroundColor: Colors.red,
  //           textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  //           duration: Duration(seconds: 2),
  //         );

  //         //   // Kirim email verifikasi ulang
  //         //   await sendEmailVerification(firebaseUser);
  //         //   return;
  //         // }
  //         // Kirim email verifikasi ulang
  //         await sendEmailVerification(firebaseUser);
  //         await FirebaseAuth.instance.signOut(); // Logout pengguna jika email belum diverifikasi
  //         return;
  //       }

  //       // Jika email terverifikasi, update role menjadi 'user'
  //       await updateRoleIfVerified(firebaseUser);

  //       // Navigasi ke HomeScreen untuk pengguna biasa
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => HomeScreen()),
  //       );
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     print("FirebaseAuthException code: ${e.code}"); // Tambahkan log ini untuk melihat kode kesalahan

  //     // Tangkap kesalahan dan tampilkan pesan peringatan
  //     if (e.code == 'invalid-email') {
  //       FloatingSnackBar.show(
  //         context: context,
  //         message: "The email address is badly formatted.",
  //         backgroundColor: Colors.red,
  //         textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  //         duration: Duration(seconds: 2),
  //       );
  //     } else if (e.code == 'user-not-found') {
  //       FloatingSnackBar.show(
  //         context: context,
  //         message: "No user found for that email.",
  //         backgroundColor: Colors.red,
  //         textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  //         duration: Duration(seconds: 2),
  //       );
  //     } else if (e.code == 'wrong-password') {
  //       FloatingSnackBar.show(
  //         context: context,
  //         message: "Wrong password provided for that user.",
  //         backgroundColor: Colors.red,
  //         textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  //         duration: Duration(seconds: 2),
  //       );
  //     } else {
  //       FloatingSnackBar.show(
  //         context: context,
  //         message: "Error during login: ${e.message}",
  //         backgroundColor: Colors.red,
  //         textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  //         duration: Duration(seconds: 2),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Login failed: $e")),
  //     );
  //   }
  // }

  // Future<UserModel?> loginUser(String email, String password) async {
  //   try {
  //     UserCredential userCredential = await _auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );

  //     String uid = userCredential.user!.uid;

  //     DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
  //     if (userDoc.exists) {
  //       return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     // Tangkap kesalahan dan lempar ulang untuk ditangani di layar login
  //     throw e;
  //   } catch (e) {
  //     print("Error during login: $e");
  //   }
  //   return null;
  // }

  // Fungsi untuk mendapatkan pengguna yang sedang login
  Future<Map<String, String>?> getCurrentUser() async {
    // Mengambil user yang sedang login
    User? user = _auth.currentUser;

    if (user != null) {
      // Mengambil data pengguna berdasarkan UID
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        // Mengambil username dan role dari dokumen pengguna
        String username = userDoc['username'];
        String role = userDoc['role'];

        return {
          'username': username,
          'role': role,
        };
      } else {
        // Jika data pengguna tidak ada di Firestore
        return null;
      }
    } else {
      // Jika tidak ada pengguna yang login
      return null;
    }
  }
  // Future<User?> getCurrentUser() async {
  //   return _auth.currentUser; // Mengembalikan user jika sedang login
  // }

  // Mengecek status login pengguna
  Future<bool> isLoggedIn() async {
    var user = await getCurrentUser();
    return user != null;
  }

  // Fungsi untuk logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Logout failed: $e');
    }
  }
}
