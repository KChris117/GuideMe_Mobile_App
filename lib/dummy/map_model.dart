
// class LocationModel {
//   final String name;
//   final double latitude;
//   final double longitude;

//   LocationModel({
//     required this.name,
//     required this.latitude,
//     required this.longitude,
//   });

//   // Fungsi untuk menyimpan data lokasi ke Firebase
//   Future<void> saveLocation() async {
//     final firestore = FirebaseFirestore.instance;
//     await firestore.collection('locations').add({
//       'name': name,
//       'latitude': latitude,
//       'longitude': longitude,
//     });
//   }

//   // Fungsi untuk mengambil daftar lokasi dari Firebase
//   static Stream<List<LocationModel>> getLocations() {
//     final firestore = FirebaseFirestore.instance;
//     return firestore.collection('locations').snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         return LocationModel(
//           name: doc['name'],
//           latitude: doc['latitude'],
//           longitude: doc['longitude'],
//         );
//       }).toList();
//     });
//   }
// }


class LocationModel {
  final String name;
  final double latitude;
  final double longitude;

  LocationModel({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  // Mengonversi Map menjadi objek LocationModel
  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      name: map['name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  // Mengonversi objek LocationModel menjadi Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

