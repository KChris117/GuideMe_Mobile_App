// import 'package:midtrans_sdk/midtrans_sdk.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter/material.dart';

// class MidtransService {
//   MidtransSDK? _midtrans;

//   // Inisialisasi SDK Midtrans
//   Future<void> initSDK(BuildContext context) async {
//     _midtrans = await MidtransSDK.init(
//       config: MidtransConfig(
//         clientKey: dotenv.env['MIDTRANS_CLIENT_KEY'] ?? "", // Pastikan clientKey sudah ada di .env
//         merchantBaseUrl: dotenv.env['MIDTRANS_MERCHANT_BASE_URL'] ?? "", // URL Merchant
//         colorTheme: ColorTheme(
//           colorPrimary: Theme.of(context).colorScheme.secondary,
//           colorPrimaryDark: Theme.of(context).colorScheme.secondary,
//           colorSecondary: Theme.of(context).colorScheme.secondary,
//         ),
//       ),
//     );
//     _midtrans?.setUIKitCustomSetting(
//       skipCustomerDetailsPages: true,
//     );
//     _midtrans!.setTransactionFinishedCallback((result) {
//       print(result.toJson()); // Callback setelah transaksi selesai
//     });
//   }

//   // Fungsi untuk memulai pembayaran
//   Future<void> startPayment(String token) async {
//     await _midtrans?.startPaymentUiFlow(
//       token: token,
//     );
//   }

//   // Hapus callback transaksi selesai
//   void dispose() {
//     _midtrans?.removeTransactionFinishedCallback();
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;

class MidtransService {
  // URL server atau endpoint untuk mendapatkan token
  final String apiUrl = 'http://192.168.1.5:3000/api/get-snap-token';

  // Fungsi untuk mengambil token dari backend
  Future<void> getTokenFromBackend() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json'
        }, // Pastikan format header benar
        body: jsonEncode({
          'orderId': 'order123',
          'amount': 100000,
        }),
      );

      if (response.statusCode == 200) {
        String token = json.decode(response.body)['snapToken'];
        print("Token: $token"); // Debug token yang diterima
      } else {
        print("Server response: ${response.body}"); // Debug respons server
        throw Exception("Failed to get token");
      }
    } catch (e) {
      print("Error: $e");
      throw e;
    }
  }
}
