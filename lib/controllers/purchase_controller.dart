import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/models/history_model.dart';

class PurchaseController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addHistory(HistoryModel dataPurchase) async {
    // Tambahkan data ke koleksi 'histories'
    DocumentReference historyRef = await _firestore.collection('histories').add(dataPurchase.toMap());

    // Ambil ID tiket yang ingin diupdate dari dataPurchase
    String ticketId = dataPurchase.ticketId; // Pastikan ada field ticketId di HistoryModel
    int quantity = dataPurchase.quantity; // Pastikan ada field quantity di HistoryModel

    // Update stock di koleksi 'tickets'
    await _firestore.collection('tickets').doc(ticketId).update({
      'stock': FieldValue.increment(-quantity), // Mengurangi stock dengan quantity
      'status': 'unavailable',
    });
  }
}
