import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getUserCount() async {
    try {
      // Mengambil snapshot dari koleksi 'tickets'
      QuerySnapshot snapshot = await _firestore.collection('users').get();

      // Mengembalikan jumlah dokumen
      return snapshot.docs.length;
    } catch (e) {
      print("Error getting user count: $e");
      return 0; // Mengembalikan 0 jika terjadi kesalahan
    }
  }

  Future<int> getDestinationCount() async {
    try {
      // Mengambil snapshot dari koleksi 'tickets'
      QuerySnapshot snapshot = await _firestore.collection('destinations').get();

      // Mengembalikan jumlah dokumen
      return snapshot.docs.length;
    } catch (e) {
      print("Error getting destination count: $e");
      return 0; // Mengembalikan 0 jika terjadi kesalahan
    }
  }

  Future<int> getEventCount() async {
    try {
      // Mengambil snapshot dari koleksi 'tickets'
      QuerySnapshot snapshot = await _firestore.collection('events').get();

      // Mengembalikan jumlah dokumen
      return snapshot.docs.length;
    } catch (e) {
      print("Error getting event count: $e");
      return 0; // Mengembalikan 0 jika terjadi kesalahan
    }
  }
  Future<int> getGalleryCount() async {
    try {
      // Mengambil snapshot dari koleksi 'tickets'
      QuerySnapshot snapshot = await _firestore.collection('galleries').get();

      // Mengembalikan jumlah dokumen
      return snapshot.docs.length;
    } catch (e) {
      print("Error getting gallery count: $e");
      return 0; // Mengembalikan 0 jika terjadi kesalahan
    }
  }

  Future<int> getTicketCount() async {
    try {
      // Mengambil snapshot dari koleksi 'tickets'
      QuerySnapshot snapshot = await _firestore.collection('tickets').get();

      // Mengembalikan jumlah dokumen
      return snapshot.docs.length;
    } catch (e) {
      print("Error getting ticket count: $e");
      return 0; // Mengembalikan 0 jika terjadi kesalahan
    }
  }

  Future<int> getReviewCount() async {
    try {
      // Mengambil snapshot dari koleksi 'tickets'
      QuerySnapshot snapshot = await _firestore.collection('reviews').get();

      // Mengembalikan jumlah dokumen
      return snapshot.docs.length;
    } catch (e) {
      print("Error getting review count: $e");
      return 0; // Mengembalikan 0 jika terjadi kesalahan
    }
  }
}
 // int _selectedIndex = 0;

  // int get selectedIndex => _selectedIndex;

  // // Fungsi untuk memperbarui indeks tab yang dipilih
  // void onItemTapped(int index) {
  //   _selectedIndex = index;
  // }

  // // Fungsi untuk mendapatkan halaman yang dipilih
  // Widget getSelectedPage() {
  //   switch (_selectedIndex) {
  //     case 0:
  //       return DashboardScreen(); // Halaman pengguna
  //     case 1:
  //       return EventManagementScreen(); // Halaman manajemen acara
  //     default:
  //       return UserManagementScreen();
  //   }
  // }