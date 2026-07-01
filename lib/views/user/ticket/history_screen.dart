import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:guideme/controllers/user_controller.dart';
import 'package:guideme/core/constants/colors.dart';
import 'package:guideme/core/constants/icons.dart';
import 'package:guideme/core/constants/text_styles.dart';
import 'package:guideme/core/services/auth_provider.dart';
import 'package:guideme/core/services/firebase_auth_service.dart';
import 'package:guideme/core/utils/auth_utils.dart';
import 'package:guideme/core/utils/text_utils.dart';
import 'package:guideme/models/history_model.dart';
import 'package:guideme/views/user/ticket/detail_history_screen.dart';
import 'package:guideme/widgets/custom_appbar.dart';
// import 'package:guideme/views/auth/login_screen.dart';
import 'package:guideme/widgets/custom_button.dart';
import 'package:guideme/widgets/custom_card.dart';
import 'package:guideme/widgets/custom_divider.dart';
import 'package:guideme/widgets/custom_navbar.dart';
import 'package:guideme/widgets/custom_search.dart';
import 'package:guideme/widgets/custom_title.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String page = 'newHistoryModel';

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController searchController = TextEditingController();
  final FirebaseAuthService _auth = FirebaseAuthService();

  late String formattedPurchaseDate;

  bool _isLoggedIn = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.initialize(); // Pastikan initialize dipanggil untuk memastikan data pengguna dimuat
  }

  // Memeriksa status login dan memperbarui state
  Future<void> _checkLoginStatus() async {
    bool loggedIn = await _auth.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  // Fungsi untuk menangani perubahan pencarian
  void search(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: BackSearchAppBar(
        scaffoldKey: scaffoldKey,
        searchController: searchController,
        onSearch: search,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 4,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TitlePage(title: "History", subtitle: "View Your Purchasing History"),
              ),
              SizedBox(
                height: 16,
              ),
              HistoryScreenContent(
                searchQuery: _searchQuery,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: UserBottomNavBar(selectedIndex: 4),
    );
  }
}

class HistoryScreenContent extends StatelessWidget {
  final String searchQuery;
  HistoryScreenContent({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    var userUid = authProvider.uid;
    return StreamBuilder(
      // stream: FirebaseFirestore.instance.collection('historys').snapshots(),
      stream: searchQuery.isEmpty
          ? FirebaseFirestore.instance
              .collection('histories')
              .where('uid', isEqualTo: userUid) // Filter berdasarkan uid
              .orderBy('purchaseAt', descending: true)
              .snapshots()
          : FirebaseFirestore.instance
              .collection('histories')
              .where('uid', isEqualTo: userUid)
              .where('ticketName', isGreaterThanOrEqualTo: searchQuery)
              .where('ticketName', isLessThanOrEqualTo: '$searchQuery\uf8ff')
              .orderBy('ticketName')
              .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No data available'));
        }

        // Pastikan data tidak null
        var docs = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true, // Pastikan ListView hanya mengambil ruang yang diperlukan
          physics: NeverScrollableScrollPhysics(), // Mencegah scrolling ganda
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            try {
              HistoryModel newHistoryModel = HistoryModel.fromMap(data, doc.id);

              final DateTime purchaseDate = newHistoryModel.purchaseAt.toDate();

              var formattedPurchaseDate = formatDate(purchaseDate);

              String formattedOpeningDate = '';
              // String formattedTime = '';
              if (newHistoryModel.openingDate != '') {
                DateTime openingDate = newHistoryModel.openingDate.toDate();

                // Memformat tanggal
                formattedOpeningDate = DateFormat('dd MMM yyyy').format(openingDate); // Contoh: 11 Jun 2024
              }

              return Container(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailHistoryScreen(
                            data: newHistoryModel,
                          ),
                        ),
                      );
                    },
                    child: MainCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          AppIcons.shop, // Ganti dengan ikon yang sesuai
                                          size: 20.0, // Ukuran ikon, sesuaikan sesuai kebutuhan
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Text(
                                          formattedPurchaseDate,
                                          style: AppTextStyles.mediumBold,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Completed',
                                          style: AppTextStyles.mediumBold.copyWith(color: AppColors.greenColor),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            greyDivider(),
                            SizedBox(
                              height: 4,
                            ),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: Image.network(
                                        newHistoryModel.imageUrl, // URL gambar
                                        width: 60, // Lebar mengikuti lebar layar
                                        height: 60, // Tinggi gambar
                                        fit: BoxFit.cover, // Menyesuaikan gambar agar sesuai kotak
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        capitalizeEachWord(newHistoryModel.ticketName),
                                        style: AppTextStyles.bodyBold,
                                        maxLines: 2, // Membatasi hanya dua baris
                                        overflow: TextOverflow.ellipsis, // Menambahkan ellipsis jika teks terlalu panjang
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Icon(
                                          //   AppIcons.date,
                                          //   size: 12,
                                          // ),
                                          Text(
                                            'Trip start:',
                                            style: AppTextStyles.tinyStyle,
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            formattedOpeningDate,
                                            style: AppTextStyles.tinyStyle,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${newHistoryModel.quantity}",
                                            style: AppTextStyles.tinyStyle,
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            "tickets",
                                            style: AppTextStyles.tinyStyle,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Total",
                                          style: AppTextStyles.mediumBold,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "${formatRupiahDouble(newHistoryModel.totalPrice)}",
                                          style: AppTextStyles.mediumBold,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    SmallButton(
                                      onPressed: () {
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) => PaymentScreen(data: newHistoryModel),
                                        //     // builder: (context) => DetailScreen(data: collectionName, id: doc.id),
                                        //   ),
                                        // );
                                      },
                                      label: 'Re-purchase',
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } catch (e) {
              return Center(child: Text('Error parsing newHistoryModel data: $e'));
            }
          },
        );
      },
    );
  }
}
