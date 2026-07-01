// import 'package:flutter/material.dart';
// import 'package:midtrans_sdk/midtrans_sdk.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Midtrans Payment Example',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const PaymentPage(),
//     );
//   }
// }

// class PaymentPage extends StatefulWidget {
//   const PaymentPage({Key? key}) : super(key: key);

//   @override
//   _PaymentPageState createState() => _PaymentPageState();
// }

// class _PaymentPageState extends State<PaymentPage> {
//   late MidtransSDK _midtrans;

//   @override
//   void initState() {
//     super.initState();
//     _initMidtrans();
//   }

//   Future<void> _initMidtrans() async {
//     try {
//       // _midtrans = await MidtransSDK.init(
//       //   clientKey: 'SB-Mid-client-orlL8l97SywgmGoy', // Ganti dengan client key Anda
//       //   merchantBaseUrl: 'https://your-server-url.com/', config: null, // Ganti dengan URL server backend Anda
//       // );

//       _midtrans = await MidtransSDK.init(
//         config: MidtransConfig(
//           clientKey: 'SB-Mid-client-orlL8l97SywgmGoy', // Client key Anda
//           merchantBaseUrl: 'https://your-server-url.com/', // URL backend Anda
//         ),
//       );

//       _midtrans.setUIKitCustomSetting(skipCustomerDetailsPages: true);
//     } catch (e) {
//       debugPrint("Error initializing Midtrans SDK: $e");
//     }
//   }

//   void _startPayment() async {
//     try {
//       final result = await _midtrans.startPaymentUiFlow(
//         transactionDetails: {
//           'order_id': 'ORDER_ID_${DateTime.now().millisecondsSinceEpoch}',
//           'gross_amount': 100000, // Jumlah pembayaran
//         },
//         customerDetails: {
//           'first_name': 'John',
//           'last_name': 'Doe',
//           'email': 'johndoe@example.com',
//           'phone': '+628123456789',
//         },
//       );

//       if (result['status_code'] == '200') {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Pembayaran berhasil!')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Pembayaran dibatalkan.')),
//         );
//       }
//     } catch (e) {
//       debugPrint("Error during payment: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Terjadi kesalahan saat pembayaran.')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Midtrans Payment Example')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: _startPayment,
//           child: const Text('Bayar Sekarang'),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class PaymentPage extends StatefulWidget {
//   const PaymentPage({Key? key}) : super(key: key);

//   @override
//   _PaymentPageState createState() => _PaymentPageState();
// }

// class _PaymentPageState extends State<PaymentPage> {
//   final String _backendUrl = "http://localhost:3000"; // Ganti dengan URL backend Anda

//   void _startPayment() async {
//     final Map<String, String> cardDetails = {
//       'card_number': '5264221038874659', // Nomor kartu
//       'card_exp_month': '12', // Bulan kedaluwarsa
//       'card_exp_year': '2025', // Tahun kedaluwarsa
//       'card_cvv': '123', // CVV
//       'gross_amount': '100000', // Jumlah pembayaran
//     };

//     try {
//       final response = await http.post(
//         Uri.parse("$_backendUrl/process-payment"),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(cardDetails),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status_code'] == '200') {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Pembayaran berhasil!')),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Pembayaran gagal: ${data['status_message']}')),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Gagal memproses pembayaran di server.')),
//         );
//       }
//     } catch (e) {
//       debugPrint("Error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Terjadi kesalahan saat memproses pembayaran.')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Midtrans Payment Example')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: _startPayment,
//           child: const Text('Bayar Sekarang'),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:midtrans_sdk/midtrans_sdk.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Midtrans Payment Example',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const PaymentPage(),
//     );
//   }
// }

// class PaymentPage extends StatefulWidget {
//   const PaymentPage({Key? key}) : super(key: key);

//   @override
//   _PaymentPageState createState() => _PaymentPageState();
// }

// class _PaymentPageState extends State<PaymentPage> {
//   late MidtransSDK _midtrans;

//   @override
//   void initState() {
//     super.initState();
//     _initMidtrans();
//   }

//   Future<void> _initMidtrans() async {
//     try {
//       _midtrans = await MidtransSDK.init(
//         clientKey: 'SB-Mid-client-orlL8l97SywgmGoy', // Ganti dengan client key Anda
//         merchantBaseUrl: 'https://your-server-url.com/', config: null, // Ganti dengan URL server backend Anda
//       );

//       _midtrans.setUIKitCustomSetting(skipCustomerDetailsPages: true);
//     } catch (e) {
//       debugPrint("Error initializing Midtrans SDK: $e");
//     }
//   }

//   Future<void> _startPayment() async {
//     try {
//       // Mengambil token transaksi dari server
//       final response = await http.post(
//         Uri.parse('https://your-server-url.com/transaction'), // Ganti dengan endpoint server Anda
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'order_id': 'ORDER_ID_${DateTime.now().millisecondsSinceEpoch}',
//           'gross_amount': 100000, // Jumlah pembayaran
//           'customer_details': {
//             'first_name': 'John',
//             'last_name': 'Doe',
//             'email': 'johndoe@example.com',
//             'phone': '+628123456789',
//           },
//         }),
//       );

//       if (response.statusCode == 200) {
//         final transactionToken = jsonDecode(response.body)['token']; // Ambil token dari response

//         // Memulai alur pembayaran
//         final result = await _midtrans.startPaymentUiFlow(
//           transactionToken: transactionToken,
//         );

//         if (result['status_code'] == '200') {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Pembayaran berhasil!')),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Pembayaran dibatalkan.')),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Gagal mendapatkan token transaksi.')),
//         );
//       }
//     } catch (e) {
//       debugPrint("Error during payment: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Terjadi kesalahan saat pembayaran.')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Midtrans Payment Example')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: _startPayment,
//           child: const Text('Bayar Sekarang'),
//         ),
//       ),
//     );
//   }
// }

// test
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:midtrans_sdk/midtrans_sdk.dart'; // Pastikan nama paket sesuai

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  // Variabel untuk menyimpan input dari user
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expMonthController = TextEditingController();
  final TextEditingController _expYearController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _grossAmountController = TextEditingController();

  // URL backend
  final String url = 'http://192.168.1.3:3000/process-payment'; // Ganti dengan IP dan port backend Anda

// // snap
//   @override
//   void initState() {
//     super.initState();
//     initializeMidtrans();
//   }

//   void initializeMidtrans() {
//     UiKitApi.Builder()
//         .withMerchantClientKey('YOUR_CLIENT_KEY') // Ganti dengan client_key Anda
//         .withContext(context) // Konteks aplikasi
//         .withMerchantUrl('YOUR_BASE_URL') // URL server merchant Anda
//         .enableLog(true) // Aktifkan log SDK (opsional)
//         .build();
//   }

  // Fungsi untuk mengirimkan data ke backend
  Future<void> processPayment() async {
    final cardNumber = _cardNumberController.text;
    final expMonth = _expMonthController.text;
    final expYear = _expYearController.text;
    final cvv = _cvvController.text;
    final grossAmount = int.tryParse(_grossAmountController.text) ?? 0;

    if (cardNumber.isEmpty || expMonth.isEmpty || expYear.isEmpty || cvv.isEmpty || grossAmount == 0) {
      // Validasi input kosong
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    try {
      // Membuat data yang akan dikirim
      final Map<String, dynamic> data = {
        'card_number': cardNumber,
        'card_exp_month': expMonth,
        'card_exp_year': expYear,
        'card_cvv': cvv,
        'gross_amount': grossAmount,
      };

      // Mengirimkan data ke backend dengan POST
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data), // Mengirimkan data dalam format JSON
      );

      if (response.statusCode == 200) {
        // Jika berhasil
        final responseBody = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment processed successfully')));
        print('Payment processed successfully: $responseBody');
      } else {
        // Jika gagal
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to process payment')));
        print('Failed to process payment: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _cardNumberController,
              decoration: InputDecoration(labelText: 'Card Number'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _expMonthController,
              decoration: InputDecoration(labelText: 'Expiration Month (MM)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _expYearController,
              decoration: InputDecoration(labelText: 'Expiration Year (YYYY)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _cvvController,
              decoration: InputDecoration(labelText: 'CVV'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _grossAmountController,
              decoration: InputDecoration(labelText: 'Gross Amount'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: processPayment,
              child: Text('Process Payment'),
            ),
          ],
        ),
      ),
    
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PaymentPage(),
  ));
}
