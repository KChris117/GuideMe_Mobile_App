import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/models/ticket_model.dart';

class TicketController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, String>>> getTicketNames(String category, String subcategory) {
    var collectionName = category + 's';

    return _firestore.collection(collectionName).where('price', isNotEqualTo: 0).where('subcategory', isEqualTo: subcategory).snapshots().map((snapshot) {
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

  Future<Map<String, dynamic>?> getTicketData(String category, String name) async {
    try {
      // Ambil data berdasarkan kategori dan subkategori
      var collectionName = category + 's';
      var snapshot = await _firestore
          .collection(collectionName)
          // .where('subcategory', isEqualTo: subcategory)
          .where('name', isEqualTo: name)
          .get();

      // Cek apakah data ditemukan
      if (snapshot.docs.isNotEmpty) {
        // Ambil data pertama dari hasil pencarian
        var doc = snapshot.docs.first;
        return doc.data();
      }
    } catch (e) {
      print('Error fetching ticket data: $e');
    }
    return null;
  }

  // Future<void> addTicket(TicketModel ticket) async {
  //   await _firestore.collection('tickets').add(ticket.toMap());
  // }
  Future<void> addTicket(TicketModel ticket) async {
    // Tambahkan tiket baru ke koleksi 'tickets'
    DocumentReference docRef = await _firestore.collection('tickets').add(ticket.toMap());

    // Ambil ID dokumen yang baru saja ditambahkan
    String ticketId = docRef.id;

    // Perbarui dokumen dengan ticketId
    await _firestore.collection('tickets').doc(ticketId).update({
      'ticketId': ticketId, // Menambahkan ticketId ke dokumen
    });
  }

  Future<void> updateTicket(TicketModel updatedTicketModel) async {
    try {
      // Get a reference to the tickets collection
      CollectionReference ticketsCollection = _firestore.collection('tickets');

      // Update the document with the ID of the ticket to be updated
      await ticketsCollection.doc(updatedTicketModel.ticketId).update({
        'title': updatedTicketModel.title,
        'description': updatedTicketModel.description,
        'information': updatedTicketModel.information,
        'price': updatedTicketModel.price,
        'stock': updatedTicketModel.stock,
        'status': updatedTicketModel.status,
        'openingTime': updatedTicketModel.openingTime,
        'closingTime': updatedTicketModel.closingTime,
        'updatedAt': Timestamp.now(), // Update the timestamp
      });

      print('Ticket updated successfully');
    } catch (e) {
      print('Failed to update ticket: $e');
      throw e; // Rethrow the error for further handling if needed
    }
  }

  // Menghapus kategori
  Future<void> deleteTicket(String ticketId) async {
    try {
      await _firestore.collection('tickets').doc(ticketId).delete();
    } catch (e) {
      throw Exception("Error deleting ticket: $e");
    }
  }
}
  // Stream<List<String>> getTicketNames(String category, String subcategory) {
  //   var collectionName = category + 's';

  //   return _firestore.collection(collectionName).where('subcategory', isEqualTo: subcategory).snapshots().map((snapshot) {
  //     // Menyimpan recommendationId dalam daftar
  //     List<String> recommendationId = [];

  //     snapshot.docs.forEach((doc) {
  //       recommendationId.add(doc.id); // Menyimpan doc.id
  //     });

  //     // Mengembalikan daftar nama
  //     return snapshot.docs.map((doc) => doc['name'] as String).toList();
  //   });
  // }


    // Stream<List<String>> getTicketNames(String category, String subcategory) {
  //   var collectionName = category + 's';

  //   // switch (category) {
  //   //   case 'event':
  //   //     collectionName = 'events';
  //   //     break;
  //   //   case 'destination':
  //   //     collectionName = 'destinations';
  //   //     break;
  //   //   case 'restaurants':
  //   //     collectionName = 'restaurants';
  //   //     break;
  //   //   default:
  //   //     collectionName = 'defaultCollection';
  //   // }

  //   return _firestore.collection(collectionName).where('subcategory', isEqualTo: subcategory).snapshots().map((snapshot) {
  //     // print("Documents fetched: ${snapshot.docs.length}");
  //     snapshot.docs.forEach((doc) {
  //       // print("Document data: ${doc.data()}");
  //     });
  //     return snapshot.docs.map((doc) => doc['name'] as String).toList();
  //   });
  // }