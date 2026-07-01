// import 'package:cloud_firestore/cloud_firestore.dart';

// class UserModel {
//   final String uid;
//   final String email;
//   final String username;
//   final String role;
//   final String profilePicture;
//   final Timestamp createdAt;

//   UserModel({
//     required this.uid,
//     required this.email,
//     required this.username,
//     required this.role,
//     required this.profilePicture,
//     required this.createdAt,
//   });

//   // Fungsi untuk mengonversi data dari Firestore ke UserModel
//   factory UserModel.fromMap(Map<String, dynamic> data) {
//     return UserModel(
//       uid: data['uid'] ?? '',
//       email: data['email'] ?? '',
//       username: data['username'] ?? '',
//       role: data['role'] ?? '',
//       profilePicture: data['profilePicture'] ?? 'https://errgdpvuqptgmkobutnt.supabase.co/storage/v1/object/public/images/profiles/profile.jpg?t=2024-12-18T09%3A14%3A25.142Z',
//       createdAt: data['createdAt'] is Timestamp
//           ? data['createdAt'] as Timestamp
//           : Timestamp.fromDate(DateTime.now()), // Default ke timestamp sekarang jika tidak ditemukan
//     );
//   }

//   // Fungsi untuk mengonversi UserModel menjadi Map untuk penyimpanan di Firestore
//   Map<String, dynamic> toMap() {
//     return {
//       'uid': uid,
//       'email': email,
//       'username': username,
//       'role': role,
//       'profilePicture': profilePicture,
//       'createdAt': createdAt,
//     };
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String role;
  final String profilePicture;
  final Timestamp createdAt;
  String? first_name;
  String? last_name;
  String? country;
  String? province;
  String? city;
  String? street;
  String? post_code;
  String? birth_date;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.role,
    required this.profilePicture,
    required this.createdAt,
    this.first_name,
    this.last_name,
    this.country,
    this.province,
    this.city,
    this.street,
    this.post_code,
    this.birth_date,
  });

  // Fungsi untuk mengonversi data dari Firestore ke UserModel
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      first_name: data['first_name'] ?? '',
      last_name: data['last_name'] ?? '',
      country: data['country'] ?? '',
      province: data['province'] ?? '',
      city: data['city'] ?? '',
      street: data['street'] ?? '',
      post_code: data['post_code'] ?? '',
      birth_date: data['birth_date'] ?? '',
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      role: data['role'] ?? '',
      profilePicture:
          data['profilePicture'] ?? 'https://errgdpvuqptgmkobutnt.supabase.co/storage/v1/object/public/images/profiles/profile.jpg?t=2024-12-18T09%3A14%3A25.142Z',
      createdAt:
          data['createdAt'] is Timestamp ? data['createdAt'] as Timestamp : Timestamp.fromDate(DateTime.now()), // Default ke timestamp sekarang jika tidak ditemukan
    );
  }

  // Fungsi untuk mengonversi UserModel menjadi Map untuk penyimpanan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'role': role,
      'profilePicture': profilePicture,
      'createdAt': createdAt,
      'first_name': first_name,
      'last_name': last_name,
      'country': country,
      'province': province,
      'city': city,
      'street': street,
      'post_code': post_code,
      'birth_date': birth_date,
    };
  }
}
