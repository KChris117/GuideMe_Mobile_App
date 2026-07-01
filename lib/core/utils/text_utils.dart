import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String capitalizeEachWord(String text) {
  if (text.isEmpty) return text;
  return text
      .split(' ') // Pisahkan teks berdasarkan spasi
      .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : word) // Kapitalisasi huruf pertama
      .join(' '); // Gabungkan kembali kata-kata
}

String truncateText(String text, int maxLength) {
  return text.length > maxLength ? '${text.substring(0, maxLength)}..' : text;
}

String formatRupiah(int amount) {
  final numberFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  return numberFormat.format(amount);
}

String formatRupiahDouble(double amount) {
  final numberFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  return numberFormat.format(amount);
}

String formatPrice(int amount) {
  final numberFormat = NumberFormat.currency(locale: 'id_ID', symbol: ' ', decimalDigits: 0);
  return numberFormat.format(amount);
}

String formatToLowerCase(String input) {
  return input.trim().toLowerCase();
}

String formatDate(DateTime dateTime) {
  return DateFormat('dd-MM-yyyy').format(dateTime);
}

String formatTime(DateTime dateTime) {
  return DateFormat('hh:mm a').format(dateTime);
}

Timestamp convertToTimestamp(DateTime dateTime) {
  return Timestamp.fromDate(dateTime);
}