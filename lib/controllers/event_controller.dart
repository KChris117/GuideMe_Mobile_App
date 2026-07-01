import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/controllers/gallery_controller.dart';
import 'package:guideme/models/gallery_model.dart';
import 'package:guideme/models/event_model.dart';
import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart'; // Untuk Timer

class EventController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GalleryController _galleryController = GalleryController();

  // Mendapatkan semua event dari Firestore
  Stream<List<EventModel>> getEvents() {
    return _firestore.collection('events').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return EventModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Menambahkan event baru dan galeri ke Firestore
  Future<void> addEvent(EventModel event, String imageUrl) async {
    // Mengecek apakah event dengan nama yang sama sudah ada
    var existingEvent = await _firestore.collection('events').where('name', isEqualTo: event.name).get();

    if (existingEvent.docs.isEmpty) {
      // Menambahkan event ke koleksi Firestore
      var docRef = await _firestore.collection('events').add(event.toMap());
      event.eventId = docRef.id;
      await docRef.update({'eventId': docRef.id});

      // Menambahkan galeri terkait event
      GalleryModel dataGallery = GalleryModel(
        galleryId: '',
        name: event.name,
        category: event.category,
        subcategory: event.subcategory,
        description: event.description,
        imageUrl: imageUrl,
        createdAt: Timestamp.now(),
        mainImage: true,
      );

      await _galleryController.addGallery(dataGallery);
    } else {
      throw Exception('Event with the same name already exists.');
    }
  }

  // Mengupdate event dan galeri terkait
  Future<void> updateEvent(EventModel event, String finalImageUrl, {double? newRating}) async {
    try {
      // Ambil data event sebelumnya dari Firestore
      final eventSnapshot = await _firestore.collection('events').doc(event.eventId).get();

      if (eventSnapshot.exists) {
        try {
          // Ambil URL gambar sebelumnya
          String previousImageUrl = eventSnapshot.data()?['imageUrl'] ?? '';
          print('Previous Image URL: $previousImageUrl');

          // Jika ada URL gambar sebelumnya, hapus dari Supabase Storage
          if (previousImageUrl.isNotEmpty && previousImageUrl != event.imageUrl) {
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
        // Update event di Firestore
        await _firestore.collection('events').doc(event.eventId).update({
          ...event.toMap(),
          if (newRating != null) 'rating': newRating,
        });

        // Jika rating diperbarui, perbarui juga koleksi tickets yang memiliki name yang sama
        if (newRating != null) {
          var ticketDocs = await _firestore.collection('tickets').where('name', isEqualTo: event.name).get();

          for (var doc in ticketDocs.docs) {
            await _firestore.collection('tickets').doc(doc.id).update({
              'rating': newRating,
              'updatedAt': Timestamp.now(), // Tambahkan timestamp pembaruan
            });
          }
        }
        //  await _firestore.collection('events').doc(event.eventId).update(event.toMap());

        // Query semua galeri terkait event
        var galleryDocs = await _firestore
            .collection('galleries')
            .where('name', isEqualTo: event.name) // Kondisi pertama
            .where('mainImage', isEqualTo: true) // Kondisi kedua
            .get();

        // Perbarui setiap dokumen galeri yang ditemukan
        for (var doc in galleryDocs.docs) {
          await _firestore.collection('galleries').doc(doc.id).update({
            'name': event.name,
            'category': event.category,
            'subcategory': event.subcategory,
            'description': event.description,
            'imageUrl': finalImageUrl, // Jika gambar galeri juga diperbarui
            'updatedAt': Timestamp.now(), // Tambahkan timestamp pembaruan
          });
        }
      } catch (e) {
        print('Error updating event or galleries: $e');
      }
    } catch (e) {
      print('Error in updateEvent function: $e');
    }
  }

// // Menambahkan event baru dan galeri ke Firestore
//   Future<void> addEvent(EventModel event, File imageFile) async {
//     // Mengecek apakah event dengan nama yang sama sudah ada
//     var existingEvent = await _firestore
//         .collection('events')
//         .where('name', isEqualTo: event.name)
//         .get();

//     if (existingEvent.docs.isEmpty) {
//       // Menambahkan event ke koleksi Firestore
//       var docRef = await _firestore.collection('events').add(event.toMap());
//       event.eventId = docRef.id;
//       await docRef.update({'eventId': docRef.id});
//     } else {
//       throw Exception('Event with the same name already exists.');
//     }
//   }

// // Menambahkan event baru dan galeri ke Firestore
//   Future<void> addEvent(EventModel event, File imageFile, String localImagePath) async {
//     // Mengecek apakah event dengan nama yang sama sudah ada
//     var existingEvent = await _firestore.collection('events').where('name', isEqualTo: event.name).get();

//     if (existingEvent.docs.isEmpty) {
//       // Menambahkan event ke koleksi Firestore
//       var docRef = await _firestore.collection('events').add(event.toMap());
//       event.eventId = docRef.id;
//       await docRef.update({'eventId': docRef.id});

//       // Menambahkan galeri terkait event
//       GalleryModel newGallery = GalleryModel(
//         galleryId: '',
//         name: event.name,
//         category: event.category,
//         subcategory: event.subcategory,
//         description: event.description,
//         imageUrl: localImagePath,
//         createdAt: Timestamp.now(),
//       );

//       await _galleryController.addGallery(newGallery);
//     } else {
//       throw Exception('Event with the same name already exists.');
//     }
//   }

  // // Mengupdate event yang sudah ada
  // Future<void> updateEvent(EventModel event) async {
  //   await _firestore.collection('events').doc(event.eventId).update(event.toMap());
  // }

  // Menghapus event berdasarkan eventId
  Future<void> deleteEvent(String eventId, String name) async {
    // Menghapus event berdasarkan eventId
    await _firestore.collection('events').doc(eventId).delete();

    // Menghapus dokumen pada koleksi tickets dengan recommendationId = eventId
    QuerySnapshot ticketsSnapshot = await _firestore.collection('tickets').where('recommendationId', isEqualTo: eventId).get();

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

    // Menghapus dokumen pada koleksi galleries dengan recommendationId = eventId
    QuerySnapshot gallerySnapshot = await _firestore.collection('galleries').where('recommendationId', isEqualTo: eventId).get();

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

  // Future<void> deleteEvent(String eventId) async {
  //   await _firestore.collection('events').doc(eventId).delete();
  // }

  // Fungsi untuk memeriksa apakah event sudah melewati closingTime dan mengubah statusnya
  Future<void> checkAndCloseExpiredEvents() async {
    DateTime now = DateTime.now();

    // Mendapatkan semua event dari Firestore
    var eventsSnapshot = await _firestore.collection('events').get();

    for (var eventDoc in eventsSnapshot.docs) {
      EventModel event = EventModel.fromMap(eventDoc.data(), eventDoc.id);

      // Periksa apakah closingTime sudah lewat
      if (event.closingTime.toDate().isBefore(now)) {
        // Jika sudah lewat, update status event ke 'close'
        await _firestore.collection('events').doc(event.eventId).update({
          'status': 'close',
        });
      }
    }
  }

  // Menjadwalkan fungsi untuk memeriksa dan mengubah status event setiap interval tertentu (misalnya setiap 1 jam)
  void scheduleEventStatusCheck() {
    Timer.periodic(Duration(hours: 1), (timer) {
      checkAndCloseExpiredEvents();
    });
  }

  // Menyimpan lokasi ke Firestore
  // Future<void> saveLocation(LocationModel location) async {
  //   try {
  //     final collection = FirebaseFirestore.instance.collection('locations');
  //     await collection.add(location.toMap());
  //   } catch (e) {
  //     print('Error saving location to Firebase: $e');
  //   }
  // }

  // // Mengambil semua lokasi dari Firestore
  // Future<List<LocationModel>> getAllLocations() async {
  //   try {
  //     QuerySnapshot snapshot =
  //         await FirebaseFirestore.instance.collection('locations').get();
  //     return snapshot.docs
  //         .map((doc) => LocationModel.fromMap(doc.data() as Map<String, dynamic>))
  //         .toList();
  //   } catch (e) {
  //     print('Error retrieving locations from Firebase: $e');
  //     return [];
  //   }
  // }
}
