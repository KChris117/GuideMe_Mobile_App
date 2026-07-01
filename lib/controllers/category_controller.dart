import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guideme/core/constants/colors.dart';
import 'package:guideme/core/constants/text_styles.dart';
import 'package:guideme/main.dart';
import 'package:guideme/models/category_model.dart';

class CategoryController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mengambil data kategori dari Firestore
  Stream<List<CategoryModel>> getCategoriesList() {
    return _firestore.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Mendapatkan kategori dari koleksi 'categories'
  Stream<List<String>> getCategories() {
    return _firestore.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc['name'] as String;
      }).toList();
    });
  }

  // Mendapatkan subkategori dari koleksi 'subcategories'
  Stream<List<String>> getSubcategories(String categoryName) {
    return _firestore.collection('categories').where('name', isEqualTo: categoryName).snapshots().map((snapshot) {
      // if (snapshot.docs.isNotEmpty) {
      return List<String>.from(snapshot.docs.first['subcategories']);
      // }
      // return [];
    });
  }

  // Menambahkan kategori baru
  Future<void> addCategory(String name, List<String> subcategories) async {
    try {
      DocumentReference docRef = await _firestore.collection('categories').add({
        'name': name,
        'subcategories': subcategories,
      });
      // Update dokumen untuk menyimpan categoryId
      await docRef.update({
        'categoryId': docRef.id, // Menyimpan ID dokumen sebagai categoryId
      });
    } catch (e) {
      throw Exception("Error adding category: $e");
    }
  }

  // Menambahkan atau mengupdate subkategori pada kategori
  Future<void> updateSubcategories(String categoryId, List<String> subcategories) async {
    try {
      await _firestore.collection('categories').doc(categoryId).update({
        'subcategories': subcategories,
      });
    } catch (e) {
      throw Exception("Error updating subcategories: $e");
    }
  }

  // Menghapus kategori
  Future<void> deleteCategory(BuildContext context, String categoryId) async {
    try {
      await _firestore.collection('categories').doc(categoryId).delete();
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        content: Text(
          "Category successfully deleted.",
          style: AppTextStyles.mediumWhiteBold,
        ),
        backgroundColor: AppColors.redColor,
        // behavior: SnackBarBehavior.floating,
      ));

      // DeleteSnackBar.show("Category successfully deleted.");
    } catch (e) {
      throw Exception("Error deleting category: $e");
    }
  }

// Menambahkan subkategori ke kategori
  Future<void> addSubcategory(String categoryId, String subcategoryName) async {
    try {
      // Ambil kategori terlebih dahulu menggunakan categoryId
      DocumentSnapshot doc = await _firestore.collection('categories').doc(categoryId).get();
      print(categoryId);

      // Ambil subkategori dan pastikan menjadi List<String>
      List<String> subcategories = List<String>.from((doc.data() as Map<String, dynamic>)['subcategories'] ?? []);

      // Tambahkan subkategori baru ke array
      subcategories.add(subcategoryName);

      // Perbarui subkategori dalam database
      await updateSubcategories(categoryId, subcategories);
    } catch (e) {
      throw Exception("Error adding subcategory: $e");
    }
  }

// Menghapus subkategori dari kategori
  Future<void> deleteSubcategory(String categoryId, String subcategoryName) async {
    try {
      // Ambil kategori terlebih dahulu
      DocumentSnapshot doc = await _firestore.collection('categories').doc(categoryId).get();

      // Ambil subkategori dan pastikan menjadi List<String>
      List<String> subcategories = List<String>.from((doc.data() as Map<String, dynamic>)['subcategories'] ?? []);

      // Hapus subkategori dari array
      subcategories.remove(subcategoryName);

      // Perbarui subkategori dalam database
      await updateSubcategories(categoryId, subcategories);
    } catch (e) {
      throw Exception("Error deleting subcategory: $e");
    }
  }
}










// class CategoryController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Mendapatkan semua kategori
//   Stream<List<CategoryModel>> getCategories() {
//     return _firestore.collection('categories').snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         return CategoryModel.fromMap(doc.data(), doc.id);
//       }).toList();
//     });
//   }

//   // Menambahkan kategori baru
//   Future<void> addCategory(String name) async {
//     try {
//       await _firestore.collection('categories').add({
//         'name': name,
//       });
//     } catch (e) {
//       throw Exception("Error adding category: $e");
//     }
//   }

//   Future<void> deleteCategory(String categoryId) async {
//     try {
//       await _firestore.collection('categories').doc(categoryId).delete();
//       print('Category deleted successfully');
//     } catch (e) {
//       print('Error deleting category: $e');
//     }
//   }
// }