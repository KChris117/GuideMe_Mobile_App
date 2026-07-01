import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:guideme/core/services/auth_provider.dart';
import 'package:guideme/core/services/firebase_options.dart'; // File auto-generated oleh Firebase
import 'package:guideme/views/admin/dashboard_screen.dart';
import 'package:guideme/views/user/home_screen.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // supabase
  await Supabase.initialize(
    url: 'https://fxvyrivprwjrmebgywmc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ4dnlyaXZwcndqcm1lYmd5d21jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI4ODM2MzUsImV4cCI6MjA5ODQ1OTYzNX0.WIF3fS7iYGDwLQhuaGMznkH1zgDepsxxqVQ9PiNmqtY',
  );
  // checkClosingTimes();

  // Memuat data gambar (misalnya gambar dari Supabase Storage)
  // await loadImagesFromSupabase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initialize(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

// Future<void> checkClosingTimes() async {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Cek koleksi 'destinations'
//   QuerySnapshot destinationsSnapshot = await _firestore.collection('destinations').get();
//   for (var doc in destinationsSnapshot.docs) {
//     DateTime closingTime = (doc['closingTime'] as Timestamp).toDate();
//     // Jika closingTime sudah lewat
//     if (closingTime.isBefore(DateTime.now())) {
//       await _firestore.collection('destinations').doc(doc.id).update({
//         'status': 'close', // Ubah status menjadi 'close'
//       });
//     }
//   }

//   // Cek koleksi 'events'
//   QuerySnapshot eventsSnapshot = await _firestore.collection('events').get();
//   for (var doc in eventsSnapshot.docs) {
//     DateTime closingTime = (doc['closingTime'] as Timestamp).toDate();
//     // Jika closingTime sudah lewat
//     if (closingTime.isBefore(DateTime.now())) {
//       await _firestore.collection('events').doc(doc.id).update({
//         'status': 'close', // Ubah status menjadi 'close'
//       });
//     }
// }
// }

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Mulai pengecekan berkala
    _startPeriodicCheck();
    // Mulai mendengarkan perubahan pada koleksi
    _listenToChanges();
  }

  void _startPeriodicCheck() {
    // Panggil checkClosingTimes setiap 5 menit
    _timer = Timer.periodic(Duration(minutes: 5), (timer) {
      checkClosingTimes();
    });
  }

  void _listenToChanges() {
    // Mendengarkan perubahan pada koleksi 'destinations'
    _firestore.collection('destinations').snapshots().listen((snapshot) {
      for (var doc in snapshot.docs) {
        DateTime closingTime = (doc['closingTime'] as Timestamp).toDate();
        if (closingTime.isBefore(DateTime.now())) {
          _firestore.collection('destinations').doc(doc.id).update({
            'status': 'close',
          });
        }
      }
    });

    // Mendengarkan perubahan pada koleksi 'events'
    _firestore.collection('events').snapshots().listen((snapshot) {
      for (var doc in snapshot.docs) {
        DateTime closingTime = (doc['closingTime'] as Timestamp).toDate();
        if (closingTime.isBefore(DateTime.now())) {
          _firestore.collection('events').doc(doc.id).update({
            'status': 'close',
          });
        }
      }
    });
  }

  Future<void> checkClosingTimes() async {
    // Cek koleksi 'destinations'
    QuerySnapshot destinationsSnapshot = await _firestore.collection('destinations').get();
    for (var doc in destinationsSnapshot.docs) {
      DateTime closingTime = (doc['closingTime'] as Timestamp).toDate();
      if (closingTime.isBefore(DateTime.now())) {
        await _firestore.collection('destinations').doc(doc.id).update({
          'status': 'close',
        });
      }
    }

    // Cek koleksi 'events'
    QuerySnapshot eventsSnapshot = await _firestore.collection('events').get();
    for (var doc in eventsSnapshot.docs) {
      DateTime closingTime = (doc['closingTime'] as Timestamp).toDate();
      if (closingTime.isBefore(DateTime.now())) {
        await _firestore.collection('events').doc(doc.id).update({
          'status': 'close',
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hentikan timer saat widget dibuang
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug di aplikasi
      title: AppStrings.appTitle,
      theme: ThemeData(
        // Tentukan warna utama dan latar belakang aplikasi
        primaryColor: Colors.white, // Menentukan warna utama aplikasi.
        scaffoldBackgroundColor: AppColors.backgroundColor, // Mengatur warna latar belakang aplikasi
        useMaterial3: true, // Menggunakan Material Design 3
        colorScheme: ColorScheme.light(
          primary: AppColors.primaryColor, // Warna utama
          secondary: AppColors.secondaryColor, // Warna aksen
        ),

        // Menentukan font utama untuk aplikasi
        fontFamily: 'Inter', // Menetapkan Inter sebagai font default

        // Tentukan tema teks untuk berbagai ukuran dan jenis teks
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.normal, fontSize: 12),
          bodyMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.normal, fontSize: 10),
          titleLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16),
          titleMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 14),
          headlineMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 18),

          // Anda dapat menyesuaikan lebih lanjut sesuai kebutuhan aplikasi
        ),

        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primaryColor, // Warna kursor global
          selectionColor: AppColors.primaryColor.withOpacity(0.5), // Warna seleksi teks
          selectionHandleColor: AppColors.primaryColor, // Warna pegangan seleksi
        ),

        inputDecorationTheme: InputDecorationTheme(
          // Warna untuk label, hint, dan teks
          labelStyle: TextStyle(color: AppColors.primaryColor),
          hintStyle: TextStyle(color: AppColors.secondaryColor),
          helperStyle: TextStyle(color: AppColors.primaryColor),
          errorStyle: TextStyle(color: AppColors.redColor),

          // Warna untuk border
          // enabledBorder: OutlineInputBorder(
          //   borderSide: BorderSide(color: AppColors.primaryColor),
          //   borderRadius: BorderRadius.circular(8.0),
          // ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.redColor),
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.redColor, width: 2.0),
            borderRadius: BorderRadius.circular(8.0),
          ),

          // Warna latar belakang
          filled: true,
          fillColor: AppColors.backgroundColor,

          // Ikon di dalam TextField
          prefixIconColor: AppColors.primaryColor,
          suffixIconColor: AppColors.primaryColor,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryColor, // Warna teks default untuk TextButton
            backgroundColor: AppColors.backgroundColor, // Warna latar belakang default untuk TextButton
          ),
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: AppColors.secondaryColor, // Mengubah warna CircularProgressIndicator global
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true; // Untuk kontrol loading

  @override
  void initState() {
    super.initState();
    // Timer untuk menampilkan tombol setelah 3 detik
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _checkLogin(); // Panggil _checkLogin setelah loading selesai
        // _isLoading = false; // Hentikan loading setelah 3 detik
      });
    });
  }

  Future<void> _checkLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.fetchCurrentUser(); // Ambil data pengguna
    if (authProvider.uid != null) {
      // Cek role pengguna dan navigasikan
      if (authProvider.role == 'user') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else if (authProvider.role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } else {
      // Jika belum login, kembali ke halaman utama
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Latar belakang hitam
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: 1.5,
              duration: Duration(seconds: 2),
              curve: Curves.easeInOut,
              child: Image.asset(
                'assets/icons/launcher_icon.png',
                width: 120,
                height: 120,
              ),
            ),
            SizedBox(height: 20),
            if (_isLoading) CircularProgressIndicator(color: Colors.white), // Menampilkan CircularProgressIndicator hanya saat loading
            // if (_isLoading) SizedBox(
            //   width: 120,
            //   child: LinearProgressIndicator(
            //   color: Colors.white,
            //   minHeight: 4.0,
            //   backgroundColor: Colors.grey[300],
            //   ),
            // ), // Menampilkan LinearProgressIndicator hanya saat loading
          ],
        ),
      ),
    );
  }
}


//   Future<void> _checkLogin() async {
//     // Mengecek status login
//     bool isLoggedIn = await _auth.isLoggedIn();
//     if (isLoggedIn) {
//       // Mendapatkan informasi pengguna saat ini
//       var currentUser = await _auth.getCurrentUser();
//       if (currentUser != null) {
//         // Arahkan berdasarkan role pengguna
//         String role = currentUser['role']!;
//         if (role == 'user') {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => HomeScreen()), // Halaman Home untuk pengguna
//           );
//         } else if (role == 'admin') {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => DashboardScreen()), // Halaman Dashboard untuk admin
//           );
//         } else {
//           // Jika role tidak dikenal, kembali ke LoginScreen
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => HomeScreen()),
//           );
//         }
//       } else {
//         // Jika data pengguna tidak ditemukan, kembali ke HomeScreen
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => HomeScreen()),
//         );
//       }
//     } else {
//       // Jika belum login, navigasi ke LoginScreen
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => HomeScreen()),
//       );
//     }
//   }


// Future<void> loadImagesFromSupabase() async {
//   final storage = Supabase.instance.client.storage.from('images');

//   try {
//     // Mendapatkan daftar file dalam folder 'uploads'
//     final response = await storage.list(path: 'uploads');

//     // Periksa apakah response berisi file atau error
//     if (response is List<FileObject>) {
//       // Menampilkan daftar file yang ditemukan
//       for (var file in response) {
//         print('File ditemukan: ${file.name}');

//         // Mengunduh gambar dari setiap file
//         final fileData = await storage.download('uploads/${file.name}');
//         await processImage(fileData);
//       }
//     } else {
//       // Jika response bukan List<FileObject>, periksa error-nya
//       // print('Terjadi kesalahan: ${response.error?.message}');
//     }
//   } catch (e) {
//     print('Terjadi kesalahan saat mengambil gambar: $e');
//   }
// }

// Future<void> processImage(Uint8List imageBytes) async {
//   // Proses gambar, misalnya disimpan dalam cache atau ditampilkan
//   print('Memproses gambar..');
// }