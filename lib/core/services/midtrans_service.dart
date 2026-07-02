import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class MidtransService {
  final String clientKey = 'Mid-client-URvcqjstpihnT4rh';
  final String serverKey = 'Mid-server-swBvviREWhtoH1jyB_g7Z-Pm';

  final String snapApiUrl = 'https://app.sandbox.midtrans.com/snap/v1/transactions';
  final String statusApiUrl = 'https://api.sandbox.midtrans.com/v2';

  // Fungsi untuk mendapatkan URL Snap
  Future<String> getPaymentUrl(double amount, String orderId) async {
    try {
      final String basicAuth = base64Encode(utf8.encode('$serverKey:'));

      final response = await http.post(
        Uri.parse(snapApiUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Basic $basicAuth',
        },
        body: jsonEncode({
          'transaction_details': {
            'order_id': orderId,
            'gross_amount': amount.toInt(),
          },
          'enabled_payments': [
            'qris',
            'gopay',
            'shopeepay',
            'credit_card',
            'bca_va',
            'mandiri_clickpay',
            'echannel', // echannel is Mandiri VA
            'bni_va',
            'bri_va',
            'other_va'
          ],
          'credit_card': {
            'secure': true
          }
        }),
      );

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        return responseBody['redirect_url'];
      } else {
        throw Exception("Midtrans Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error memproses Midtrans: $e");
      throw e;
    }
  }

  // Cek status transaksi via Midtrans Core API
  Future<String> checkTransactionStatus(String orderId) async {
    try {
      final String basicAuth = base64Encode(utf8.encode('$serverKey:'));
      final response = await http.get(
        Uri.parse('$statusApiUrl/$orderId/status'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Basic $basicAuth',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['transaction_status'] ?? 'pending';
      }
      return 'pending'; // Jika gagal cek atau belum selesai
    } catch (e) {
      print("Gagal cek status transaksi: $e");
      return 'pending';
    }
  }
}

