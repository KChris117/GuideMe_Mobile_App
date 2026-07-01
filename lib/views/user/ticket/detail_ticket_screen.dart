import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/core/services/auth_provider.dart';
import 'package:guideme/core/utils/text_utils.dart';
import 'package:guideme/models/destination_model.dart';
import 'package:guideme/models/event_model.dart';
import 'package:guideme/views/auth/login_screen.dart';
import 'package:guideme/views/user/detail_screen.dart';
import 'package:guideme/views/user/ticket/payment_screen.dart';
import 'package:guideme/widgets/custom_card.dart';
import 'package:guideme/widgets/custom_snackbar.dart';
import 'package:guideme/widgets/custom_text.dart';
import 'package:guideme/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:guideme/widgets/custom_carousel.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

class DetailTicketScreen extends StatefulWidget {
  final dynamic data;
  final String collectionName;
  final String? category;
  final String? ticketName;

  const DetailTicketScreen({Key? key, required this.data, required this.collectionName, this.category, this.ticketName}) : super(key: key);

  @override
  _DetailTicketScreenState createState() => _DetailTicketScreenState();
}

class _DetailTicketScreenState extends State<DetailTicketScreen> {
  final TextEditingController reviewController = TextEditingController();

  // late String dataModel;
  late AuthProvider authProvider;
  late String collectionName;
  late dynamic data;
  late String uid;
  late String name;
  late String ticketName;
  late String username;
  late String location;
  late double rating;
  late int price;
  late String description;
  late String information;
  late String imageUrl;
  late String imageName;
  late List<String> images = [];

  var targetLocation;
  var currentLocation;

  String review = '';
  int selectedRating = 0;

  @override
  void initState() {
    super.initState();
    data = widget.data;
    print(data);
    collectionName = widget.collectionName;
    name = capitalizeEachWord(widget.data.name.toString());
    ticketName = capitalizeEachWord(widget.ticketName.toString());
    location = capitalizeEachWord(widget.data.location.toString());
    rating = widget.data.rating;
    price = widget.data.price;
    description = widget.data.description;
    information = widget.data.information;
    imageUrl = widget.data.imageUrl;
    _loadImages();

    // Ambil nilai default dari Provider
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    uid = authProvider.uid ?? 'not found';
    username = authProvider.username ?? 'not found';

    reviewController.addListener(() {
      setState(() {
        review = reviewController.text; // Perbarui nilai nameValue
      });
    });
  }

  Future<void> _loadImages() async {
    imageName = name.toLowerCase();
    final querySnapshot = await FirebaseFirestore.instance.collection('galleries').where('name', isEqualTo: imageName).get();

    List<String> loadedImages = [];
    for (var doc in querySnapshot.docs) {
      loadedImages.add(doc['imageUrl']);
    }

    setState(() {
      images = loadedImages;
    });
  }

  List<String> _splitTextWithNumbering(String text, double maxWidth, TextStyle style) {
    List<String> lines = [];
    String currentLine = '';
    int numbering = 1; // Awal nomor untuk setiap poin utama

    // Menggunakan TextPainter untuk menghitung ukuran teks
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: '', style: style),
      maxLines: 1,
      textDirection: ui.TextDirection.rtl, // Menggunakan konstanta langsung
    );

    // Membagi teks berdasarkan kalimat (menggunakan titik sebagai pemisah)
    List<String> sentences = text.split(RegExp(r'(?<=[.!?])\s+'));

    for (String sentence in sentences) {
      // Tambahkan numbering untuk kalimat baru
      currentLine = '$numbering. $sentence';
      numbering++;

      textPainter.text = TextSpan(text: currentLine, style: style);
      textPainter.layout(maxWidth: maxWidth);

      // Tangani overflow baris
      if (textPainter.didExceedMaxLines) {
        List<String> overflowLines = _splitIntoLines(currentLine, maxWidth, style);
        lines.addAll(overflowLines);
      } else {
        lines.add(currentLine);
      }
    }

    return lines;
  }

  List<String> _splitIntoLines(String text, double maxWidth, TextStyle style) {
    List<String> result = [];
    String currentLine = '';

    TextPainter textPainter = TextPainter(
      text: TextSpan(text: '', style: style),
      maxLines: 1,
      textDirection: ui.TextDirection.rtl, // Menggunakan konstanta langsung
    );

    for (String word in text.split(' ')) {
      String testLine = currentLine.isEmpty ? word : '${currentLine} $word';
      textPainter.text = TextSpan(text: testLine, style: style);
      textPainter.layout(maxWidth: maxWidth);

      if (textPainter.didExceedMaxLines) {
        result.add('$currentLine'); // Tambahkan 3 spasi di depan setiap baris baru
        currentLine = word; // Mulai baris baru
      } else {
        currentLine = testLine;
      }
    }

    // Tambahkan baris terakhir jika tidak kosong
    if (currentLine.isNotEmpty) {
      result.add('    $currentLine');
    }

    return result;
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(title: 'Back'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menampilkan teks menggunakan data
            CustomTitle(
              firstText: 'Hi, Tourist!',
              secondText: "Discover Everything About $name",
            ),
            const SizedBox(
              height: 16,
            ),
            if (images.isNotEmpty) DynamicCarouselWidget(imageAssets: images),
            if (images.isEmpty) Center(child: CircularProgressIndicator()), // Menampilkan carousel dengan gambar
            // Jika images kosong, bisa menampilkan widget loading atau lainnya
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                children: [
                  MainCard(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  capitalizeEachWord(ticketName),
                                  style: AppTextStyles.headingBold,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      AppIcons.rating,
                                      size: 16,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      '${widget.data.rating}',
                                      style: AppTextStyles.bodyBold,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  location,
                                  style: AppTextStyles.mediumGrey,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Ticket Price',
                                      style: AppTextStyles.smallGrey,
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      price == 0
                                          ? 'Free access' // Jika rating = 0, tampilkan "Free"
                                          : 'Rp ${NumberFormat('#,##0', 'id_ID').format(price)}', // Jika rating != 0, tampilkan harga
                                      style: AppTextStyles.mediumBold,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Ticket Informations',
                                      style: AppTextStyles.mediumBold,
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    SizedBox(height: 10), // Spacing
                                    // Menampilkan informasi
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        // Menghitung lebar maksimum yang tersedia
                                        double maxWidth = constraints.maxWidth;

                                        // Memecah teks menjadi baris
                                        List<String> lines = _splitTextWithNumbering(information, maxWidth, AppTextStyles.mediumBlack);

                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: lines.map((line) {
                                            return Text(
                                              line,
                                              style: AppTextStyles.mediumBlack,
                                              softWrap: true,
                                              overflow: TextOverflow.visible,
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            LimitedTextWidget(description: '${description}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MainCard(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.44,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      AppIcons.weather,
                                      size: 32,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          var model;
                          var newCollectionName = '${widget.category}s';
                          var ticketName = name.toLowerCase(); // Pastikan ticketName fdalam format yang sesuai

                          QuerySnapshot querySnapshot;

                          if (newCollectionName == 'destinations') {
                            // Mencari dokumen di koleksi destinations berdasarkan field name
                            querySnapshot = await FirebaseFirestore.instance.collection('destinations').where('name', isEqualTo: ticketName).get();

                            // Pastikan ada dokumen yang ditemukan
                            if (querySnapshot.docs.isNotEmpty) {
                              var data = querySnapshot.docs.first; // Ambil dokumen pertama
                              model = DestinationModel.fromMap(data.data() as Map<String, dynamic>, data.id);
                            } else {
                              // Tangani jika tidak ada dokumen ditemukan
                              print('No destination found with name: $ticketName');
                            }
                          } else if (newCollectionName == 'events') {
                            // Mencari dokumen di koleksi events berdasarkan field name
                            querySnapshot = await FirebaseFirestore.instance.collection('events').where('name', isEqualTo: ticketName).get();

                            // Pastikan ada dokumen yang ditemukan
                            if (querySnapshot.docs.isNotEmpty) {
                              var data = querySnapshot.docs.first; // Ambil dokumen pertama
                              model = EventModel.fromMap(data.data() as Map<String, dynamic>, data.id);
                            } else {
                              // Tangani jika tidak ada dokumen ditemukan
                              print('No event found with name: $ticketName');
                            }
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(
                                data: model,
                                collectionName: newCollectionName,
                                name: name,
                              ),
                            ),
                          );
                        },
                        child: MainCard(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.44,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        AppIcons.route,
                                        size: 24,
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        'Route',
                                        style: AppTextStyles.bodyBold,
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Click here to see the route', style: AppTextStyles.smallStyle),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: LargeButton(
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);

                  // Tunggu hingga data pengguna selesai diambil
                  await authProvider.fetchCurrentUser();

                  if (authProvider.isLoggedIn) {
                    if (authProvider.isUser) {
                      // Jika pengguna sudah login dengan role 'user', lanjutkan ke PaymentScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(data: data),
                        ),
                      );
                    } else {
                      // Jika role bukan 'user', tampilkan pesan atau arahkan ke halaman lain
                      FloatingSnackBar.show(
                        context: context,
                        message: "You must login first to access this page.",
                        // backgroundColor: Colors.red,
                        textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        duration: Duration(seconds: 5),
                      );
                    }
                  } else {
                    // Jika pengguna belum login, tampilkan SnackBar dan arahkan ke LoginScreen
                    FloatingSnackBar.show(
                      context: context,
                      message: "You must login first to access this page.",
                      // backgroundColor: Colors.red,
                      textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      duration: Duration(seconds: 5),
                    );

                    // Setelah menampilkan SnackBar, arahkan ke halaman login
                    Future.delayed(Duration(seconds: 1), () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(), // Ganti dengan LoginScreen Anda
                        ),
                      );
                    });
                  }
                },
                label: 'Purchase',
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: UserBottomNavBar(selectedIndex: 1),
    );
  }
}
