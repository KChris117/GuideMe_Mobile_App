// class LocationController {
//   // Fungsi untuk mengambil lokasi
//   Stream<List<LocationModel>> getLocations() {
//     return LocationModel.getLocations();
//   }

//   // Fungsi untuk menyimpan lokasi
//   Future<void> saveLocation(String name, LatLng location) async {
//     final newLocation = LocationModel(
//       name: name,
//       latitude: location.latitude,
//       longitude: location.longitude,
//     );
//     await newLocation.saveLocation();
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/dummy/map_model.dart';

class LocationController {
  // Menyimpan lokasi ke Firestore
  Future<void> saveLocation(LocationModel location) async {
    try {
      final collection = FirebaseFirestore.instance.collection('locations');
      await collection.add(location.toMap());
    } catch (e) {
      print('Error saving location to Firebase: $e');
    }
  }

  // Mengambil semua lokasi dari Firestore
  Future<List<LocationModel>> getAllLocations() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('locations').get();
      return snapshot.docs.map((doc) => LocationModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error retrieving locations from Firebase: $e');
      return [];
    }
  }
}
