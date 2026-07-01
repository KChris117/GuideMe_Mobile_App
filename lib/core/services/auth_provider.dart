import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _uid;
  String? _username;
  String? _email;
  String? _role;
  String? _profilePicture;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getter
  String? get uid => _uid;
  String? get username => _username;
  String? get email => _email;
  String? get role => _role;
  String? get profilePicture => _profilePicture;
  bool get isLoading => _isLoading;

  bool get isLoggedIn => _auth.currentUser != null;
  bool get isUser => _role == 'user';
  bool get isAdmin => _role == 'admin';

  // Inisialisasi saat aplikasi pertama kali dijalankan
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    if (isLoggedIn && _uid == null) {
      await _loadUserDataFromPreferences();
      if (_uid == null) {
        await fetchCurrentUser();
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  // Mendapatkan data pengguna
  Future<void> fetchCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          _uid = user.uid;
          _username = userDoc['username'];
          _email = userDoc['email'];
          _role = userDoc['role'];
          _profilePicture = userDoc['profilePicture'];
          await _saveUserDataToPreferences();
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  // Simpan data pengguna ke SharedPreferences
  Future<void> _saveUserDataToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', _uid ?? '');
    await prefs.setString('username', _username ?? '');
    await prefs.setString('email', _email ?? '');
    await prefs.setString('role', _role ?? '');
    await prefs.setString('profilePicture', _profilePicture ?? '');
  }

  // Muat data pengguna dari SharedPreferences
  Future<void> _loadUserDataFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _uid = prefs.getString('uid');
    _username = prefs.getString('username');
    _email = prefs.getString('email');
    _role = prefs.getString('role');
    _profilePicture = prefs.getString('profilePicture');
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _clearUserDataFromPreferences();
      _resetData();
    } catch (e) {
      print('Logout failed: $e');
    }
  }

  // Hapus data pengguna dari SharedPreferences
  Future<void> _clearUserDataFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('role');
    await prefs.remove('profilePicture');
  }

  void _resetData() {
    _uid = null;
    _username = null;
    _email = null;
    _role = null;
    _profilePicture = null;
    notifyListeners();
  }

  // Fungsi untuk mendapatkan URL gambar profil
  Future<String?> getProfilePicture() async {
    if (_profilePicture == null && _uid != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(_uid).get();
        if (userDoc.exists) {
          _profilePicture = userDoc['profilePicture'];
          await _saveUserDataToPreferences();
        }
      } catch (e) {
        print('Error fetching profile picture: $e');
      }
    }
    return _profilePicture;
  }
}
