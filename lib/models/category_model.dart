import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  String categoryId; // ID dokumen
  String name; // Nama kategori
  List<String> subcategories; // Daftar subkategori
  Timestamp? createdAt;

  CategoryModel({
    required this.categoryId,
    required this.name,
    required this.subcategories,
    this.createdAt,
  });

  // Konversi dari Map (Firestore) ke objek CategoryModel
  factory CategoryModel.fromMap(Map<String, dynamic> map, String categoryId) {
    return CategoryModel(
      categoryId: categoryId,
      name: map['name'] ?? '',
      subcategories: List<String>.from(map['subcategories'] ?? []), // Ambil array subkategori
      createdAt: map['createdAt'] is Timestamp ? map['createdAt'] as Timestamp : null, // Pastikan null jika bukan Timestamp
    );
  }

  // Konversi dari objek CategoryModel ke Map (untuk Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'subcategories': subcategories, // Menambahkan subkategori saat konversi ke Map
      'createdAt': createdAt,
    };
  }
}




// class CategoryModel {
//   String categoryId; // ID dokumen
//   String name; // Nama kategori

//   CategoryModel({required this.categoryId, required this.name});

//   // Konversi dari Map (Firestore) ke objek CategoryModel
//   factory CategoryModel.fromMap(Map<String, dynamic> map, String categoryId) {
//     return CategoryModel(
//       categoryId: categoryId,
//       name: map['name'] ?? '',
//     );
//   }

//   // Konversi dari objek CategoryModel ke Map (untuk Firestore)
//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//     };
//   }
// }
