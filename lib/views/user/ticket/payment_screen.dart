import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guideme/controllers/purchase_controller.dart';
import 'package:guideme/core/constants/colors.dart';
import 'package:guideme/core/constants/icons.dart';
import 'package:guideme/core/constants/text_styles.dart';
import 'package:guideme/core/services/auth_provider.dart';
import 'package:guideme/core/services/midtrans_service.dart';
import 'package:guideme/core/utils/text_utils.dart';
import 'package:guideme/models/history_model.dart';
import 'package:guideme/views/user/ticket/history_screen.dart';
import 'package:guideme/widgets/custom_appbar.dart';
import 'package:guideme/widgets/custom_button.dart';
import 'package:guideme/widgets/custom_card.dart';
import 'package:guideme/widgets/custom_navbar.dart';
import 'package:guideme/widgets/custom_snackbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentScreen extends StatefulWidget {
  final dynamic data;

  const PaymentScreen({super.key, required this.data});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final PurchaseController _purchaseController = PurchaseController();

  late AuthProvider authProvider;
  late String ticketId;
  late String uid;
  late String name;
  late String organizer;
  late String location;
  late String imageUrl;
  late double rating;
  late String category;
  late String subcategory;
  late int price;
  late int stock;
  late Timestamp openingTime;
  late Timestamp closingTime;

  late String formattedOpeningDate; // Tambahkan variabel di sini
  late String formattedOpeningTime;
  late String formattedClosingDate;
  late String formattedClosingTime;

  TextEditingController quantityController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  int quantity = 1; // Tambahkan variabel quantity
  double totalPrice = 0.0;

  // String? _selectedOption = 'credit_card'; // Opsi default
  // String? _selectedOption = null; // Opsi default
  String customerName = '';
  String customerEmail = '';

  bool isProcessing = false;
  final MidtransService _midtransService = MidtransService();

  void _processMidtransPayment() async {
    setState(() {
      isProcessing = true;
    });
    try {
      String orderId = 'ORDER-${DateTime.now().millisecondsSinceEpoch}';
      
      // 1. Dapatkan URL Snap dari Midtrans Service
      String redirectUrl = await _midtransService.getPaymentUrl(totalPrice, orderId);
      
      // 2. Simpan ke Firestore sebagai PENDING (belum dibayar)
      String? historyId = await saveHistory(orderId, redirectUrl, 'pending');
      
      if (historyId != null) {
        // 3. Buka WebView untuk pembayaran
        final Uri url = Uri.parse(redirectUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.inAppBrowserView);
          
          // 4. Setelah WebView ditutup, cek status ke Midtrans
          String status = await _midtransService.checkTransactionStatus(orderId);
          
          // 5. Update status di Firestore
          await _purchaseController.updatePaymentStatus(historyId, status);
          
          if (status == 'settlement' || status == 'capture') {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Successful!')));
            Navigator.pop(context); // Kembali atau sesuaikan alur aplikasi
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment is $status. Check history to resume.')));
            Navigator.pop(context);
          }
        } else {
          throw Exception("Could not launch payment URL.");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to initialize payment data.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }
  // late TextEditingController nameController;
  // late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    ticketId = widget.data.ticketId;
    name = widget.data.name;
    organizer = widget.data.organizer;
    location = widget.data.location;
    imageUrl = widget.data.imageUrl;
    category = widget.data.category;
    subcategory = widget.data.subcategory;
    rating = widget.data.rating;
    price = widget.data.price;
    stock = widget.data.stock;
    openingTime = widget.data.openingTime;
    closingTime = widget.data.closingTime;

    final DateTime openingDateTime = openingTime.toDate();
    final DateTime closingDateTime = closingTime.toDate();

    formattedOpeningDate = formatDate(openingDateTime);
    formattedOpeningTime = formatTime(openingDateTime);

    formattedClosingDate = formatDate(closingDateTime);
    formattedClosingTime = formatTime(closingDateTime);

    // Menyimpan tanggal dan waktu secara terpisah dalam format Timestamp
    Timestamp openingDateTimestamp = Timestamp.fromDate(DateTime(openingDateTime.year, openingDateTime.month, openingDateTime.day));
    Timestamp openingTimeTimestamp =
        Timestamp.fromDate(DateTime(openingDateTime.year, openingDateTime.month, openingDateTime.day, openingDateTime.hour, openingDateTime.minute));

    Timestamp closingDateTimestamp = Timestamp.fromDate(DateTime(closingDateTime.year, closingDateTime.month, closingDateTime.day));
    Timestamp closingTimeTimestamp =
        Timestamp.fromDate(DateTime(closingDateTime.year, closingDateTime.month, closingDateTime.day, closingDateTime.hour, closingDateTime.minute));

    quantityController.text = quantity.toString(); // Set nilai awal untuk TextField
    calculateTotalPrice(); // Hitung total price saat pertama kali diinisialisasi

    // Ambil nilai default dari Provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    uid = authProvider.uid ?? 'not found';
    customerName = authProvider.username ?? 'not found';
    customerEmail = authProvider.email ?? 'not found';

    // Inisialisasi TextEditingController dengan nilai default
    nameController = TextEditingController(text: customerName);
    emailController = TextEditingController(text: customerEmail);

    // Tambahkan listener ke nameController
    nameController.addListener(() {
      setState(() {
        customerName = nameController.text; // Perbarui nilai nameValue
      });
    });
    emailController.addListener(() {
      setState(() {
        customerEmail = emailController.text; // Perbarui nilai nameValue
      });
    });
  }

  // Fungsi untuk menghitung total harga
  void calculateTotalPrice() {
    setState(() {
      totalPrice = price * quantity.toDouble();
    });
  }

  void increaseQuantity() {
    if (quantity < stock) {
      setState(() {
        quantity++;
        quantityController.text = quantity.toString();
        calculateTotalPrice();
      });
    } else {
      null;
    }
  }

  void decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
        quantityController.text = quantity.toString();
        calculateTotalPrice();
      });
    }
  }

  void updateQuantity(String value) {
    int? newQuantity = int.tryParse(value);
    if (newQuantity != null && newQuantity > 0 && newQuantity <= stock) {
      setState(() {
        quantity = newQuantity;
        quantityController.text = value;
        calculateTotalPrice();
      });
    } else {
      quantityController.text = quantity.toString();
    }
  }

  Future<String?> saveHistory(String orderId, String paymentUrl, String paymentStatus) async {
    if (_formKey.currentState!.validate()) {
      if (quantityController != 'not found' && nameController != 'not found' && emailController != 'not found') {
        DateTime openingDateTime = DateFormat('yyyy-MM-dd').parse(formattedOpeningDate);
        DateTime openingTime = DateFormat('hh:mm a').parse(formattedOpeningTime);

        DateTime closingDateTime = DateFormat('yyyy-MM-dd').parse(formattedClosingDate);
        DateTime closingTime = DateFormat('hh:mm a').parse(formattedClosingTime);

        Timestamp openingTimestamp = Timestamp.fromDate(openingDateTime);
        Timestamp openingTimeTimestamp = Timestamp.fromDate(openingTime);
        Timestamp closingTimestamp = Timestamp.fromDate(closingDateTime);
        Timestamp closingTimeTimestamp = Timestamp.fromDate(closingTime);

        if (stock != 0) {
          HistoryModel dataPurchase = HistoryModel(
            orderId: orderId,
            paymentUrl: paymentUrl,
            paymentStatus: paymentStatus,
            ticketId: ticketId,
            uid: uid,
            customerName: nameController.text,
            customerEmail: emailController.text,
            ticketName: name,
            location: location,
            imageUrl: imageUrl,
            organizer: organizer,
            category: category,
            subcategory: subcategory,
            rating: rating,
            price: price,
            totalPrice: totalPrice,
            quantity: quantity,
            openingDate: openingTimestamp,
            closingDate: closingTimestamp,
            openingTime: openingTimeTimestamp,
            closingTime: closingTimeTimestamp,
            purchaseAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
          );
          try {
            String historyId = await _purchaseController.addHistory(dataPurchase);
            return historyId;
          } catch (e) {
            print('Error creating history: $e');
            return null;
          }
        } else {
          DangerFloatingSnackBar.show(context: context, message: 'Ticket out of stock.');
          return null;
        }
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text('Please complete all fields'),
        // ));
        DangerFloatingSnackBar.show(context: context, message: 'Please complete all fields');
      }
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text('Please complete all fields correctly'),
      // ));
      DangerFloatingSnackBar.show(context: context, message: 'Please complete all fields correctly');
    }
    return null;
  }

  @override
  void dispose() {
    // Hapus listener dan bersihkan controller
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      MainCard(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: Image.network(
                                      imageUrl, // URL gambar
                                      width: 110, // Lebar mengikuti lebar layar
                                      height: 110, // Tinggi gambar
                                      fit: BoxFit.cover, // Menyesuaikan gambar agar sesuai kotak
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    capitalizeEachWord(name),
                                    style: AppTextStyles.bodyBold,
                                    maxLines: 2, // Membatasi hanya dua baris
                                    overflow: TextOverflow.ellipsis, // Menambahkan ellipsis jika teks terlalu panjang
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'organized by',
                                        style: AppTextStyles.smallStyle,
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        capitalizeEachWord(organizer),
                                        style: AppTextStyles.smallBold,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        AppIcons.pin,
                                        size: 12,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        capitalizeEachWord(location),
                                        style: AppTextStyles.smallStyle,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                AppIcons.date,
                                                size: 12,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                formattedOpeningDate,
                                                style: AppTextStyles.smallStyle,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                AppIcons.time,
                                                size: 12,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                formattedOpeningTime,
                                                style: AppTextStyles.smallStyle,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '-',
                                                style: AppTextStyles.smallStyle,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                '-',
                                                style: AppTextStyles.smallStyle,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                formattedClosingDate,
                                                style: AppTextStyles.smallStyle,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                formattedClosingTime,
                                                style: AppTextStyles.smallStyle,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        formatRupiah(price),
                                        style: AppTextStyles.mediumBold,
                                      )
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      MainCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Purchase details',
                                    style: AppTextStyles.bodyBold,
                                  ),
                                ],
                              ),
                              SizedBox(height: 16), // Spasi antar elemen
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      textCapitalization: TextCapitalization.words,
                                      cursorColor: AppColors.primaryColor,
                                      controller: nameController,
                                      decoration: InputDecoration(
                                        labelText: 'Name',
                                        labelStyle: AppTextStyles.mediumBlack,
                                        isDense: true, // Ukuran kotak lebih kecil      isDense: isDense ?? true, // Ukuran kotak lebih kecil
                                        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Mengatur padding konten agar lebih kecil
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColors.primaryColor, // Warna border
                                            width: 2.0, // Menambahkan ketebalan border
                                          ),
                                        ),
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')), // Hanya huruf dan spasi
                                      ],
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your name';
                                        }
                                        return null; // Input valid
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16), // Spasi antar elemen
                              Row(
                                children: [
                                  // Input Email
                                  Expanded(
                                    child: TextFormField(
                                      cursorColor: AppColors.primaryColor,
                                      controller: emailController,
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        labelStyle: AppTextStyles.mediumBlack,
                                        isDense: true, // Ukuran kotak lebih kecil     isDense: isDense ?? true, // Ukuran kotak lebih kecil
                                        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Mengatur padding konten agar lebih kecil
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColors.primaryColor, // Warna border
                                            width: 2.0, // Menambahkan ketebalan border
                                          ),
                                        ),
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')) // Hanya karakter yang sah untuk email
                                      ],
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter an email address';
                                        }
                                        // Regex untuk email
                                        String pattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
                                        RegExp regex = RegExp(pattern);
                                        if (!regex.hasMatch(value)) {
                                          return 'Please enter a valid email address';
                                        }
                                        return null; // Valid email
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4), // Spasi antar elemen
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Quantity:',
                                    style: AppTextStyles.mediumBlack,
                                  ),
                                  // const SizedBox(width: 16),
                                  // Quantity controls
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      // border: Border.all(color: Colors.grey),
                                    ),
                                    child: Column(
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          // mainAxisAlignment: MainAxisAlignment.end,
                                          // crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Tombol kurangi
                                            IconButton(
                                              icon: Icon(Icons.remove),
                                              onPressed: quantity > 0 ? decreaseQuantity : null, // Tombol hanya aktif jika quantity > 0
                                            ),
                                            SizedBox(
                                              width: 40,
                                              height: 30,
                                              child: Center(
                                                // alignment: Alignment.center,
                                                child: TextField(
                                                  cursorColor: AppColors.primaryColor,
                                                  controller: quantityController,
                                                  keyboardType: TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  onChanged: updateQuantity,
                                                  style: AppTextStyles.mediumBlack,
                                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                  decoration: InputDecoration(
                                                    // isDense: true,
                                                    border: OutlineInputBorder(),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppColors.primaryColor, // Warna border
                                                        width: 2.0, // Menambahkan ketebalan border
                                                      ),
                                                    ),
                                                    isDense: true, // Ukuran kotak lebih kecil
                                                    contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Mengatur padding konten agar lebih kecil
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Tombol tambah
                                            IconButton(
                                              icon: Icon(Icons.add),
                                              onPressed: quantity < stock ? increaseQuantity : null, // Tombol hanya aktif jika quantity < stock
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 16.0),
                                          child: Text(
                                            'Available stock: $stock',
                                            style: AppTextStyles.smallStyle.copyWith(color: Colors.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      MainCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Price details',
                                    style: AppTextStyles.bodyBold,
                                  ),
                                ],
                              ),
                              SizedBox(height: 8), // Spasi antar elemen
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        '${quantity} items',
                                        style: AppTextStyles.smallStyle,
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '${formatRupiah(totalPrice.toInt())}',
                                        style: AppTextStyles.smallStyle,
                                      )
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 8), // Spasi antar elemen
                              const Divider(thickness: 1, color: Colors.grey), // Divider below text
                              const SizedBox(height: 8), // Spasi antar elemen
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        'Total',
                                        style: AppTextStyles.mediumBold,
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '${formatRupiah(totalPrice.toInt())}',
                                        style: AppTextStyles.mediumBold,
                                      )
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 16), // Spasi antar elemen
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [],
                              ),
                            ],
                          ),
                        ),
                      ),
                      MainCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Purchase summary',
                                    style: AppTextStyles.bodyBold,
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [Text('Name:')],
                                      ),
                                      Column(
                                        children: [Text(customerName)],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [Text('Email:')],
                                      ),
                                      Column(
                                        children: [Text(customerEmail)],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [Text('Ticket Name:')],
                                      ),
                                      Column(
                                        children: [Text(name)],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [Text('Organizer:')],
                                      ),
                                      Column(
                                        children: [Text(organizer)],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [Text('Location:')],
                                      ),
                                      Column(
                                        children: [Text(location)],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [Text('Date:')],
                                      ),
                                      Column(
                                        children: [Text('${formattedOpeningDate} to ${formattedClosingDate}')],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [Text('Time:')],
                                      ),
                                      Column(
                                        children: [Text('${formattedOpeningTime} to ${formattedClosingTime}')],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [Text('Ticket Price:')],
                                      ),
                                      Column(
                                        children: [Text('${formatRupiah(price)}')],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [Text('Quantity:')],
                                      ),
                                      Column(
                                        children: [Text('${quantity} items')],
                                      ),
                                    ],
                                  ),
                                  const Divider(thickness: 1, color: Colors.grey), // Divider below text
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            'Total:',
                                            style: AppTextStyles.mediumBold,
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            '${formatRupiah(totalPrice.toInt())}',
                                            style: AppTextStyles.mediumBold,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'WARNING: DUMMY PAYMENT ONLY!\nDO NOT use your real money or real credit card to pay. This is a Sandbox testing mode.',
                                style: AppTextStyles.smallBold.copyWith(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      MainCard(
                        child: // Button Purchase
                            LargeButton(
                          label: isProcessing ? 'Processing...' : 'Purchase',
                          onPressed: isProcessing
                              ? null
                              : () {
                                  // Validasi Form
                                  if (stock != 0) {
                                    if (_formKey.currentState?.validate() == true) {
                                      _processMidtransPayment();
                                    } else {
                                      DangerTopFloatingSnackBar.show(context: context, message: 'Please fill in all required fields');
                                    }
                                  } else {
                                    DangerFloatingSnackBar.show(context: context, message: 'Ticket out of stock.');
                                    return;
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: UserBottomNavBar(selectedIndex: 1),
    );
  }

}

