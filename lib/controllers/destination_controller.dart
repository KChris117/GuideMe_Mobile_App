import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/controllers/gallery_controller.dart';
import 'package:guideme/models/destination_model.dart';
import 'package:guideme/models/gallery_model.dart';
import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart'; // Untuk Timer

class DestinationController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GalleryController _galleryController = GalleryController();

  // Mendapatkan semua destination dari Firestore
  Stream<List<DestinationModel>> getDestinations() {
    return _firestore.collection('destinations').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return DestinationModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Menambahkan destination baru dan galeri ke Firestore
  Future<void> addDestination(DestinationModel destination, String imageUrl) async {
    // Mengecek apakah destination dengan nama yang sama sudah ada
    var existingDestination = await _firestore.collection('destinations').where('name', isEqualTo: destination.name).get();

    if (existingDestination.docs.isEmpty) {
      // Menambahkan destination ke koleksi Firestore
      var docRef = await _firestore.collection('destinations').add(destination.toMap());
      destination.destinationId = docRef.id;
      await docRef.update({'destinationId': docRef.id});

      // Menambahkan galeri terkait destination
      GalleryModel dataGallery = GalleryModel(
        galleryId: '',
        name: destination.name,
        category: destination.category,
        subcategory: destination.subcategory,
        description: destination.description,
        imageUrl: imageUrl,
        createdAt: Timestamp.now(),
        mainImage: true,
      );

      await _galleryController.addGallery(dataGallery);
    } else {
      throw Exception('Destination with the same name already exists.');
    }
  }

  // Mengupdate destination yang sudah ada
  // Future<void> updateDestination(DestinationModel destination) async {
  //   await _firestore.collection('destinations').doc(destination.destinationId).update(destination.toMap());
  // }

  // Mengupdate destination dan galeri terkait
  Future<void> updateDestination(DestinationModel destination, String finalImageUrl, {double? newRating}) async {
    try {
      // Ambil data destination sebelumnya dari Firestore
      final destinationSnapshot = await _firestore.collection('destinations').doc(destination.destinationId).get();

      if (destinationSnapshot.exists) {
        try {
          // Ambil URL gambar sebelumnya
          String previousImageUrl = destinationSnapshot.data()?['imageUrl'] ?? '';
          print('Previous Image URL: $previousImageUrl');

          // Jika ada URL gambar sebelumnya, hapus dari Supabase Storage
          if (previousImageUrl.isNotEmpty && previousImageUrl != destination.imageUrl) {
            // Ambil path gambar dari URL sebelumnya
            final previousImagePath = previousImageUrl.split('/').last;
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
        } catch (e) {
          print('Error deleting previous image from Supabase: $e');
        }
      } else {
        throw Exception('Image not found.');
      }

      try {
        // Update destination di Firestore
        await _firestore.collection('destinations').doc(destination.destinationId).update({
          ...destination.toMap(),
          if (newRating != null) 'rating': newRating,
        });

        // Jika rating baru tidak null, perbarui juga koleksi tickets
        if (newRating != null) {
          var ticketDocs = await _firestore.collection('tickets').where('name', isEqualTo: destination.name).get();

          for (var doc in ticketDocs.docs) {
            await _firestore.collection('tickets').doc(doc.id).update({
              'rating': newRating,
              'updatedAt': Timestamp.now(),
            });
          }
        }

        // await _firestore.collection('destinations').doc(destination.destinationId).update(destination.toMap());

        // Query semua galeri terkait destination
        var galleryDocs = await _firestore
            .collection('galleries')
            .where('name', isEqualTo: destination.name) // Kondisi pertama
            .where('mainImage', isEqualTo: true) // Kondisi kedua
            .get();

        // Perbarui setiap dokumen galeri yang ditemukan
        for (var doc in galleryDocs.docs) {
          await _firestore.collection('galleries').doc(doc.id).update({
            'name': destination.name,
            'category': destination.category,
            'subcategory': destination.subcategory,
            'description': destination.description,
            'imageUrl': finalImageUrl, // Jika gambar galeri juga diperbarui
            'updatedAt': Timestamp.now(), // Tambahkan timestamp pembaruan
          });
        }
      } catch (e) {
        print('Error updating destination or galleries: $e');
      }
    } catch (e) {
      print('Error in updateDestination function: $e');
    }
  }

  // Future<void> updateDestination(DestinationModel destination, String imageUrl) async {
  //    try {
  //     // Ambil data destination sebelumnya dari Firestore
  //     final destinationSnapshot = await _firestore.collection('galleries').doc(destination.destinationId).get();

  //     if (destinationSnapshot.exists) {
  //       // Ambil URL gambar sebelumnya
  //       String previousImageUrl = destinationSnapshot.data()?['imageUrl'] ?? '';

  //       // Cek URL gambar sebelumnya
  //       print('Previous Image URL: $previousImageUrl');

  //       // Jika ada URL gambar sebelumnya, hapus dari Supabase Storage
  //       if (previousImageUrl.isNotEmpty && previousImageUrl != destination.imageUrl) {
  //         // Ambil path gambar dari URL sebelumnya
  //         final previousImagePath = previousImageUrl.split('/').last;

  //         // Cek path gambar sebelumnya
  //         print('Previous Image Path: $previousImagePath');

  //         // Hapus gambar lama dari Supabase Storage
  //         final storageResponse = await Supabase.instance.client.storage
  //             .from('images') // Nama bucket di Supabase
  //             .remove(['uploads/$previousImagePath']); // Pastikan path dan folder sesuai

  //         // Periksa apakah penghapusan berhasil
  //         if (storageResponse.isEmpty) {
  //           print('No previous files were deleted, check the file path.');
  //         } else {
  //           print('Previous image successfully deleted from Supabase.');
  //         }
  //       }
  //     } else {
  //       throw Exception('Image not found.');
  //     }

  //   // Update destination di Firestore
  //   await _firestore.collection('destinations').doc(destination.destinationId).update(destination.toMap());

  //   // Query semua galeri terkait destination
  //   var galleryDocs = await _firestore.collection('galleries').where('createdAt', isEqualTo: destination.createdAt).get();

  //   // Perbarui setiap dokumen galeri yang ditemukan
  //   for (var doc in galleryDocs.docs) {
  //     await _firestore.collection('galleries').doc(doc.id).update({
  //       'name': destination.name,
  //       'category': destination.category,
  //       'subcategory': destination.subcategory,
  //       'description': destination.description,
  //       'imageUrl': imageUrl, // Jika gambar galeri juga diperbarui
  //       'updatedAt': Timestamp.now(), // Tambahkan timestamp pembaruan
  //     });
  //   }
  // }

  // Menghapus destination berdasarkan destinationId
  Future<void> deleteDestination(String destinationId, String name) async {
    await _firestore.collection('destinations').doc(destinationId).delete();

    // Menghapus dokumen pada koleksi tickets dengan recommendationId = destinationId
    QuerySnapshot ticketsSnapshot = await _firestore.collection('tickets').where('recommendationId', isEqualTo: destinationId).get();

    // Menghapus semua tiket yang memiliki recommendationId yang sama
    for (var ticket in ticketsSnapshot.docs) {
      await ticket.reference.delete();
    }

    // Menghapus dokumen pada koleksi tickets dengan name = name
    QuerySnapshot nameSnapshot = await _firestore.collection('tickets').where('name', isEqualTo: name).get();

    // Menghapus semua tiket yang memiliki name yang sama
    for (var ticket in nameSnapshot.docs) {
      await ticket.reference.delete();
    }

    // Menghapus dokumen pada koleksi galleries dengan recommendationId = destinationId
    QuerySnapshot gallerySnapshot = await _firestore.collection('galleries').where('recommendationId', isEqualTo: destinationId).get();

    // Menghapus semua gallery yang memiliki recommendationId yang sama
    for (var gallery in gallerySnapshot.docs) {
      await gallery.reference.delete();
    }

    // Menghapus dokumen pada koleksi galleries dengan name = name
    QuerySnapshot galleryNameSnapshot = await _firestore.collection('galleries').where('name', isEqualTo: name).get();

    // Menghapus semua gallery yang memiliki name yang sama
    for (var gallery in galleryNameSnapshot.docs) {
      await gallery.reference.delete();
    }
  }

  // Future<void> deleteDestination(String destinationId) async {
  //   await _firestore.collection('destinations').doc(destinationId).delete();
  // }

  // Fungsi untuk memeriksa apakah destination sudah melewati closingTime dan mengubah statusnya
  Future<void> checkAndCloseExpireddestinations() async {
    DateTime now = DateTime.now();

    // Mendapatkan semua destination dari Firestore
    var destinationsSnapshot = await _firestore.collection('destinations').get();

    for (var destinationDoc in destinationsSnapshot.docs) {
      DestinationModel destination = DestinationModel.fromMap(destinationDoc.data(), destinationDoc.id);

      // Periksa apakah closingTime sudah lewat
      if (destination.closingTime.toDate().isBefore(now)) {
        // Jika sudah lewat, update status destination ke 'close'
        await _firestore.collection('destinations').doc(destination.destinationId).update({
          'status': 'close',
        });
      }
    }
  }

  // Menjadwalkan fungsi untuk memeriksa dan mengubah status destination setiap interval tertentu (misalnya setiap 1 jam)
  void scheduleDestinationStatusCheck() {
    Timer.periodic(Duration(hours: 1), (timer) {
      checkAndCloseExpireddestinations();
    });
  }
}
