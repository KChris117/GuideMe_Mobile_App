import 'dart:io';
import 'package:flutter/material.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/main.dart';
import 'package:guideme/models/gallery_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/widgets/custom_snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GalleryController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // Fungsi untuk mengambil data gallery dari Firestore
  Stream<List<GalleryModel>> getGalleries() {
    return _firestore.collection('galleries').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return GalleryModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<Map<String, String>>> getGalleryNames(String category, String subcategory) {
    var collectionName = category + 's';

    return _firestore.collection(collectionName).where('category', isEqualTo: category).where('subcategory', isEqualTo: subcategory).snapshots().map((snapshot) {
      // Mengembalikan daftar nama dan recommendationId dalam bentuk Map
      return snapshot.docs.map((doc) {
        print('Document ID view: ${doc.id}'); // Debugging
        return {
          'name': doc['name'] as String,
          'recommendationId': doc.id, // Menyimpan doc.id sebagai recommendationId
        };
      }).toList();
    });
  }

  Stream<List<String>> getNamesByCategory(String category) {
    String collectionName;

    switch (category) {
      case 'event':
        collectionName = 'events';
        break;
      case 'destination':
        collectionName = 'destinations';
        break;
      case 'restaurants':
        collectionName = 'restaurants';
        break;
      // Tambahkan kategori lain sesuai kebutuhan
      default:
        collectionName = 'defaultCollection'; // Jika kategori tidak cocok
    }

    return _firestore
        .collection(collectionName) // Ganti dengan 'events' jika diperlukan
        .where('category', isEqualTo: category) // Filter berdasarkan kategori
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc['name'] as String; // Ambil field 'name'
      }).toList();
    });
  }

  // Menambahkan gallery baru ke Firestore
  Future<void> addGallery(GalleryModel gallery) async {
    var docRef = await _firestore.collection('galleries').add(gallery.toMap());
    gallery.galleryId = docRef.id;
    await docRef.update({'galleryId': docRef.id});
  }

  // Mengupdate gallery yang sudah ada
  // Future<void> updateGallery(GalleryModel gallery) async {
  //   await _firestore.collection('galleries').doc(gallery.galleryId).update(gallery.toMap());
  // }

  Future<void> updateGallery(GalleryModel gallery) async {
    try {
      // Ambil data gallery sebelumnya dari Firestore
      final gallerySnapshot = await _firestore.collection('galleries').doc(gallery.galleryId).get();

      if (gallerySnapshot.exists) {
        // Ambil URL gambar sebelumnya
        String previousImageUrl = gallerySnapshot.data()?['imageUrl'] ?? '';

        // Cek URL gambar sebelumnya
        print('Previous Image URL: $previousImageUrl');

        // Jika ada URL gambar sebelumnya, hapus dari Supabase Storage
        if (previousImageUrl.isNotEmpty && previousImageUrl != gallery.imageUrl) {
          // Ambil path gambar dari URL sebelumnya
          final previousImagePath = previousImageUrl.split('/').last;

          // Cek path gambar sebelumnya
          print('Previous Image Path: $previousImagePath');

          // Hapus gambar lama dari Supabase Storage
          final storageResponse = await Supabase.instance.client.storage
              .from('images') // Nama bucket di Supabase
              .remove(['uploads/$previousImagePath']); // Pastikan path dan folder sesuai

          // Periksa apakah penghapusan berhasil
          if (storageResponse.isEmpty) {
            print('No previous files were deleted, check the file path.');
          } else {
            print('Previous image successfully deleted from Supabase.');
          }
        }
      } else {
        throw Exception('Gallery not found.');
      }

      await _firestore.collection('galleries').doc(gallery.galleryId).update(gallery.toMap());
      print('Gallery successfully updated.');

      var collectionName = gallery.category + 's';
      var changedName = gallery.name;

      print(collectionName);

      // Periksa dan perbarui `destinations` jika `mainImage` bernilai `true`
      if (gallery.mainImage == true) {
        var collection = await _firestore.collection(collectionName).where('name', isEqualTo: changedName).get();

        print('Jumlah dokumen yang ditemukan: ${collection.docs.length}');

        if (collection.docs.isNotEmpty) {
          for (var doc in collection.docs) {
            await _firestore.collection(collectionName).doc(doc.id).update({
              'imageUrl': gallery.imageUrl,
              'updatedAt': Timestamp.now(),
            });
          }
          print('Destinations successfully updated.');
        } else {
          print('No matching destinations found.');
        }
      } else {
        print('tidak menemukan destinations');
      }

      print('Gallery successfully updated in Firestore.');
    } catch (error) {
      print('Error while updating gallery: $error');
      rethrow;
    }
  }

  // Menghapus gallery berdasarkan galleryId
  // Future<void> deleteGallery(String galleryId) async {
  //   await _firestore.collection('galleries').doc(galleryId).delete();
  // }

  Future<void> deleteGallery(BuildContext context, String galleryId) async {
    try {
      // Ambil data gallery dari Firebase terlebih dahulu
      final gallerySnapshot = await _firestore.collection('galleries').doc(galleryId).get();

      if (gallerySnapshot.exists) {
        // Cek apakah nilai mainImage adalah true
        bool mainImage = gallerySnapshot.data()?['mainImage'] ?? false;
        var imageCategory = gallerySnapshot.data()?['category'] ?? 'Default Category';

        if (mainImage) {
          // Tampilkan pesan peringatan menggunakan SnackBar
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(" Sorry, you can't remove ${imageCategory} images through the gallery."),
              backgroundColor: Colors.red,
            ),
          );
          return; // Hentikan proses jika mainImage adalah true
        }

        if (mainImage) {
          print('Main Image tidak dapat dihapus melalui gallery management');
          return; // Hentikan proses jika mainImage adalah true
        }

        // Ambil URL gambar yang tersimpan pada gallery
        String imageUrl = gallerySnapshot.data()?['imageUrl'] ?? '';

        // Cek URL gambar yang diambil
        print('Image URL: $imageUrl');

        // Jika ada URL gambar, hapus gambar dari Supabase Storage
        if (imageUrl.isNotEmpty) {
          // Ambil path gambar dari URL
          final imagePath = imageUrl.split('/').last;

          // Cek path gambar
          print('Image Path: $imagePath');

          // Coba hapus gambar dari Supabase Storage
          final storageResponse = await Supabase.instance.client.storage
              .from('images') // Nama bucket di Supabase
              .remove(['uploads/$imagePath']); // Pastikan path dan folder sesuai

          // Periksa apakah penghapusan berhasil
          if (storageResponse.isEmpty) {
            print('No files were deleted, check the file path.');
          } else {
            print('Image successfully deleted from Supabase.');
          }
        }

        // Setelah gambar dihapus, hapus data gallery dari Firebase
        await _firestore.collection('galleries').doc(galleryId).delete();
        // print('Gallery document deleted from Firebase.');
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(
              "Gallery successfully deleted.",
              style: AppTextStyles.mediumWhiteBold,
            ),
            backgroundColor: AppColors.redColor,
          ),
        );
      } else {
        DangerSnackBar.show(context, 'Gallery not found.');
        throw Exception('Gallery not found');
      }
    } catch (error) {
      DangerSnackBar.show(context, 'Error while deleting gallery: $error');
      print('Error while deleting gallery: $error');
      rethrow;
    }
  }

  // Mengambil gambar dari galeri dan mengembalikan path gambar
  Future<String?> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return pickedFile?.path;
  }

  // Menyimpan gambar secara lokal
  Future<String> saveImageLocally(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final localFile = File('${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await image.copy(localFile.path);
    return localFile.path;
  }
}

// import 'dart:io';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart' as path;

// class GalleryController {
//   final SupabaseClient _supabaseClient = Supabase.instance.client;
//   final ImagePicker _picker = ImagePicker();

//   // Fungsi untuk mengambil gambar dari galeri dan mengembalikan path gambar
//   Future<String?> pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     return pickedFile?.path;
//   }

//   // Fungsi untuk mengunggah gambar ke Supabase Storage
//   Future<String?> uploadImageToSupabase(File imageFile) async {
//     try {
//       final fileName = path.basename(imageFile.path);
//       final response = await _supabaseClient.storage
//           .from('images') // Ganti dengan nama bucket Anda
//           .upload(fileName, imageFile);

//       if (response.isEmpty) {
//         throw Exception("Upload failed");
//       }

//       // Dapatkan URL publik untuk gambar
//       final publicUrl = _supabaseClient.storage.from('images').getPublicUrl(fileName);
//       return publicUrl;
//     } catch (e) {
//       print('Upload failed: $e');
//       return null;
//     }
//   }

//   // Menambahkan gallery baru ke Supabase Database
//   Future<void> addGalleryToSupabase(GalleryModel gallery) async {
//     try {
//       await _supabaseClient.from('galleries').insert(gallery.toMap());
//     } catch (e) {
//       print('Failed to add gallery: $e');
//     }
//   }

//   // Mengupdate gallery yang sudah ada di Supabase Database
//   Future<void> updateGalleryInSupabase(GalleryModel gallery) async {
//     try {
//       await _supabaseClient
//           .from('galleries')
//           .update(gallery.toMap())
//           .eq('galleryId', gallery.galleryId);
//     } catch (e) {
//       print('Failed to update gallery: $e');
//     }
//   }

//   // Menghapus gallery dari Supabase Database dan Storage
//   Future<void> deleteGallery(String galleryId, String imageUrl) async {
//     try {
//       // Hapus data dari database
//       await _supabaseClient.from('galleries').delete().eq('galleryId', galleryId);

//       // Hapus gambar dari storage
//       final fileName = Uri.parse(imageUrl).pathSegments.last;
//       await _supabaseClient.storage.from('images').remove([fileName]);
//     } catch (e) {
//       print('Failed to delete gallery: $e');
//     }
//   }
// }
