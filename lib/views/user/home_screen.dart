import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/core/services/auth_provider.dart';
import 'package:guideme/core/services/firebase_auth_service.dart';
import 'package:guideme/core/utils/auth_utils.dart';
import 'package:guideme/core/utils/text_utils.dart';
import 'package:guideme/models/destination_model.dart';
import 'package:guideme/models/event_model.dart';
import 'package:guideme/views/user/detail_screen.dart';
import 'package:guideme/widgets/custom_carousel.dart';
// import 'package:guideme/core/services/midtrans_service.dart';
import 'package:guideme/widgets/custom_sidebar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/widgets/widgets.dart';
import 'package:guideme/views/user/list_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuthService _auth = FirebaseAuthService();

  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.initialize(); // Pastikan initialize dipanggil untuk memastikan data pengguna dimuat
    // Supabase.initialize(
    //   url: 'https://errgdpvuqptgmkobutnt.supabase.co',
    //   anonKey:
    //       'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVycmdkcHZ1cXB0Z21rb2J1dG50Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMzOTg2MTAsImV4cCI6MjA0ODk3NDYxMH0.bOPICi0eFnqBFiNyufFgrVtXvradIylCNMenDFE0XHk',
    // );
  }

  // Memeriksa status login dan memperbarui state
  Future<void> _checkLoginStatus() async {
    bool loggedIn = await _auth.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Daftar gambar yang akan ditampilkan di carousel
    List<String> images = [
      'assets/images/carousel.jpeg',
      'assets/images/carousel2.jpeg',
      'assets/images/carousel3.jpeg',
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: BurgerAppBar(
        scaffoldKey: _scaffoldKey,
        actions: _isLoggedIn
            ? [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                  onPressed: () {
                    // Panggil handleLogout dari auth_utils.dart
                    handleLogout(context);
                  },
                ),
              ]
            : [],
      ),
      drawer: CustomSidebar(
        isLoggedIn: _isLoggedIn,
        onLogout: () {
          // Panggil handleLogout juga di sini
          handleLogout(context);
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTitle(
              firstText: 'Hi, Tourist!',
              secondText: 'Start Your Best Experience With GuideME',
            ),
            SizedBox(height: 16),
            CarouselWidget(imageAssets: images), // Memanggil widget carousel
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row yang ada di dalam Padding
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Destination',
                        style: AppTextStyles.mediumBold,
                      ),
                      GestureDetector(
                        onTap: () {
                          // Kirimkan nama koleksi (destinations atau events) ke ListScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListScreen(
                                data: 'Destinations', // Contoh mengirim koleksi 'destinations'
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'View all',
                          style: AppTextStyles.smallStyle.copyWith(
                            color: AppColors.secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                // StreamBuilder untuk destination
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('destinations')
                      .where('status', isEqualTo: 'open')
                      .orderBy('rating', descending: true) // Urutkan berdasarkan timestamp (waktu)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    // Batasi jumlah data maksimal 5
                    final docs = snapshot.data!.docs.take(5).toList();

                    return SizedBox(
                      height: 200, // Tinggi yang sesuai untuk daftar horizontal
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal, // Scroll horizontal
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          var doc = snapshot.data!.docs[index];
                          Map<String, dynamic> event = doc.data() as Map<String, dynamic>;
                          DestinationModel newDestinationModel = DestinationModel.fromMap(event, doc.id);

                          // Tentukan padding untuk item pertama dan terakhir
                          EdgeInsetsGeometry padding = EdgeInsets.symmetric(horizontal: 0.0); // Default padding

                          if (index == 0) {
                            // Padding kiri untuk item pertama
                            padding = EdgeInsets.only(left: 12.0);
                          } else if (docs.length == 5 && index == 4) {
                            // Jika ada 5 data, padding kanan hanya untuk item ke-4 (terakhir)
                            padding = EdgeInsets.only(right: 8.0);
                          } else if (docs.length < 5 && index == docs.length - 1) {
                            // Jika kurang dari 5 data, padding kanan untuk item terakhir
                            padding = EdgeInsets.only(right: 12.0);
                          }

                          return Padding(
                            padding: padding,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.44, // 50% dari lebar layar
                                  // margin: EdgeInsets.symmetric(horizontal: 8.0), // Margin antar card
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailScreen(
                                            data: newDestinationModel,
                                            collectionName: 'destinations',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      color: AppColors.backgroundColor,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(5),
                                              bottom: Radius.circular(5),
                                            ),
                                            child: (!kIsWeb && newDestinationModel.imageUrl.startsWith('/'))
                                                ? Image.file(
                                                    File(newDestinationModel.imageUrl),
                                                    fit: BoxFit.cover,
                                                    height: 100,
                                                    width: double.infinity,
                                                  )
                                                : Image.network(
                                                    newDestinationModel.imageUrl,
                                                    fit: BoxFit.cover,
                                                    height: 100,
                                                    width: double.infinity,
                                                  ),
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Membatasi nama agar hanya setengah lebar dan berpindah ke baris berikutnya jika panjang
                                              Flexible(
                                                flex: 3, // Membuat nama mengambil 3/4 dari lebar
                                                child: Text(
                                                  truncateText(capitalizeEachWord(newDestinationModel.name), 15),
                                                  style: AppTextStyles.mediumBold,
                                                  maxLines: 2, // Membatasi hanya dua baris
                                                  overflow: TextOverflow.ellipsis, // Menambahkan ellipsis jika teks terlalu panjang
                                                ),
                                              ),
                                              // Spacer(), // Menambahkan ruang agar rating tetap sejajar dengan nama
                                              // Menampilkan rating
                                              Row(
                                                children: [
                                                  Icon(
                                                    AppIcons.rating,
                                                    size: 16,
                                                  ),
                                                  SizedBox(width: 2),
                                                  Text(
                                                    '${newDestinationModel.rating}',
                                                    style: AppTextStyles.mediumBold,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Menampilkan harga
                                              Text(
                                                truncateText(capitalizeEachWord(newDestinationModel.location), 15),
                                                style: AppTextStyles.smallGrey,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Menampilkan harga
                                              Text(
                                                newDestinationModel.price == 0
                                                    ? 'Free' // Jika rating = 0, tampilkan "Free"
                                                    : 'Rp ${NumberFormat('#,##0', 'id_ID').format(newDestinationModel.price)}', // Jika rating != 0, tampilkan harga
                                                style: AppTextStyles.smallBold,
                                              ),

                                              // SmallButton(
                                              //   onPressed: () {
                                              //     // Navigator.push(
                                              //     //   context,
                                              //     //   MaterialPageRoute(
                                              //     //     builder: (context) => DetailScreen(data: 'destinations', id: doc.id),
                                              //     //   ),
                                              //     // );
                                              //     Navigator.push(
                                              //       context,
                                              //       MaterialPageRoute(
                                              //         builder: (context) => DetailScreen(data: newDestinationModel),
                                              //       ),
                                              //     );
                                              //   },
                                              //   label: 'View',
                                              // ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (index < snapshot.data!.docs.length - 1) // Jangan tambahkan pada Card terakhir
                                  SizedBox(width: 4.0), // Jarak antar Card
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row yang ada di dalam Padding
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Event',
                        style: AppTextStyles.mediumBold,
                      ),
                      GestureDetector(
                        onTap: () {
                          // Kirimkan nama koleksi (destinations atau events) ke ListScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListScreen(
                                data: 'Events', // Contoh mengirim koleksi 'destinations'
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'View all',
                          style: AppTextStyles.smallStyle.copyWith(
                            color: AppColors.secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                // StreamBuilder untuk event
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('events')
                      .where('status', isEqualTo: 'open')
                      .orderBy('rating', descending: true) // Urutkan berdasarkan timestamp (waktu)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    // Batasi jumlah data maksimal 5
                    final docs = snapshot.data!.docs.take(5).toList();

                    return SizedBox(
                      height: 200, // Tinggi yang sesuai untuk daftar horizontal
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal, // Scroll horizontal
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          var doc = snapshot.data!.docs[index];
                          Map<String, dynamic> event = doc.data() as Map<String, dynamic>;
                          EventModel newEventModel = EventModel.fromMap(event, doc.id);

                          // Tentukan padding untuk item pertama dan terakhir
                          EdgeInsetsGeometry padding = EdgeInsets.symmetric(horizontal: 0.0); // Default padding

                          if (index == 0) {
                            // Padding kiri untuk item pertama
                            padding = EdgeInsets.only(left: 12.0);
                          } else if (docs.length == 5 && index == 4) {
                            // Jika ada 5 data, padding kanan hanya untuk item ke-4 (terakhir)
                            padding = EdgeInsets.only(right: 8.0);
                          } else if (docs.length < 5 && index == docs.length - 1) {
                            // Jika kurang dari 5 data, padding kanan untuk item terakhir
                            padding = EdgeInsets.only(right: 12.0);
                          }

                          return Padding(
                            padding: padding,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.44,
                                  // margin: EdgeInsets.symmetric(horizontal: 8.0), // Margin antar card
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailScreen(
                                            data: newEventModel,
                                            collectionName: 'events',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      color: AppColors.backgroundColor,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(5),
                                              bottom: Radius.circular(5),
                                            ),
                                            child: (!kIsWeb && newEventModel.imageUrl.startsWith('/'))
                                                ? Image.file(
                                                    File(newEventModel.imageUrl),
                                                    fit: BoxFit.cover,
                                                    height: 100,
                                                    width: double.infinity,
                                                  )
                                                : Image.network(
                                                    newEventModel.imageUrl,
                                                    fit: BoxFit.cover,
                                                    height: 100,
                                                    width: double.infinity,
                                                  ),
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Membatasi nama agar hanya setengah lebar dan berpindah ke baris berikutnya jika panjang
                                              Flexible(
                                                flex: 3, // Membuat nama mengambil 3/4 dari lebar
                                                child: Text(
                                                  capitalizeEachWord(newEventModel.name),
                                                  style: AppTextStyles.mediumBold,
                                                  maxLines: 2, // Membatasi hanya dua baris
                                                  overflow: TextOverflow.ellipsis, // Menambahkan ellipsis jika teks terlalu panjang
                                                ),
                                              ),
                                              // Spacer(), // Menambahkan ruang agar rating tetap sejajar dengan nama
                                              // Menampilkan rating
                                              Row(
                                                children: [
                                                  Icon(
                                                    AppIcons.rating,
                                                    size: 16,
                                                  ),
                                                  SizedBox(width: 2),
                                                  Text(
                                                    '${newEventModel.rating}',
                                                    style: AppTextStyles.mediumBold,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Menampilkan harga
                                              Text(
                                                truncateText(capitalizeEachWord(newEventModel.location), 15),
                                                style: AppTextStyles.smallGrey,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Menampilkan harga
                                              Text(
                                                newEventModel.price == 0
                                                    ? 'Free' // Jika rating = 0, tampilkan "Free"
                                                    : 'Rp ${NumberFormat('#,##0', 'id_ID').format(newEventModel.price)}', // Jika rating != 0, tampilkan harga
                                                style: AppTextStyles.smallBold,
                                              ),
                                              // SmallButton(
                                              //   onPressed: () {
                                              //     Navigator.push(
                                              //       context,
                                              //       MaterialPageRoute(
                                              //         builder: (context) => DetailScreen(data: newEventModel),
                                              //       ),
                                              //     );
                                              //   },
                                              //   label: 'View',
                                              // ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (index < snapshot.data!.docs.length - 1) // Jangan tambahkan pada Card terakhir
                                  SizedBox(width: 4.0), // Jarak antar Card
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(
              height: 32,
            ),
            Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 48.0),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.tertiaryColor, // Warna border
                      width: 1.0, // Ketebalan border
                    ),
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Made by PBL-IF 12',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'GuideME',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: UserBottomNavBar(selectedIndex: 0),
    );
  }
}
