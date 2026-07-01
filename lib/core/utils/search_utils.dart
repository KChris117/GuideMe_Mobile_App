import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> searchGalleries(String query) async {
  if (query.isEmpty) {
    return []; // Jika query kosong, kembalikan list kosong
  }

  try {
    // Akses koleksi 'galleries' di Firestore
    QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('galleries')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff') // Range pencarian
        .get();

    // Konversi hasil ke list
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  } catch (e) {
    print("Error saat mencari: $e");
    return [];
  }
}
