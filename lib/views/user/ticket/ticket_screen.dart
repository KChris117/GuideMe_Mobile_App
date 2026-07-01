import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guideme/core/constants/colors.dart';
import 'package:guideme/core/constants/icons.dart';
import 'package:guideme/core/constants/text_styles.dart';
import 'package:guideme/core/services/auth_provider.dart' as provider;
import 'package:guideme/core/services/firebase_auth_service.dart';
import 'package:guideme/core/utils/auth_utils.dart';
import 'package:guideme/core/utils/text_utils.dart';
import 'package:guideme/models/ticket_model.dart';
import 'package:guideme/views/auth/login_screen.dart';
import 'package:guideme/views/user/ticket/payment_screen.dart';
import 'package:guideme/views/user/ticket/detail_ticket_screen.dart';
import 'package:guideme/widgets/custom_appbar.dart';
import 'package:guideme/widgets/custom_button.dart';
import 'package:guideme/widgets/custom_card.dart';
import 'package:guideme/widgets/custom_navbar.dart';
import 'package:guideme/widgets/custom_sidebar.dart';
import 'package:guideme/widgets/custom_snackbar.dart';
import 'package:guideme/widgets/custom_title.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  String page = 'newTicketModel';

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  // final UserController _userController = UserController();
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController searchController = TextEditingController();
  bool _isLoggedIn = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    final authProvider = Provider.of<provider.AuthProvider>(context, listen: false);
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
      appBar: SearchAppBar(
        scaffoldKey: scaffoldKey,
        searchController: searchController,
        onSearch: search, // Fungsi pencarian
      ),
      drawer: CustomSidebar(
        isLoggedIn: _isLoggedIn,
        onLogout: () {
          // Panggil handleLogout juga di sini
          handleLogout(context);
        },
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 4,
              ),
              CustomTitle(firstText: 'Hi, Tourist!', secondText: "Discover the Ticket We've Selected for You"),
              SizedBox(
                height: 16,
              ),
              TicketScreenContent(
                searchQuery: _searchQuery,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: UserBottomNavBar(selectedIndex: 1),
    );
  }
}

class TicketScreenContent extends StatelessWidget {
  final String searchQuery;
  TicketScreenContent({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    // Stream untuk pencarian berdasarkan name
    final nameQuery = FirebaseFirestore.instance
        .collection('tickets')
        .where('name', isGreaterThanOrEqualTo: searchQuery)
        .where('name', isLessThanOrEqualTo: '$searchQuery\uf8ff')
        .where('stock', isNotEqualTo: 0)
        .snapshots();

    // Stream untuk pencarian berdasarkan title
    final titleQuery = FirebaseFirestore.instance
        .collection('tickets')
        .where('title', isGreaterThanOrEqualTo: searchQuery)
        .where('title', isLessThanOrEqualTo: '$searchQuery\uf8ff')
        .where('stock', isNotEqualTo: 0)
        .snapshots();

    return StreamBuilder<List<DocumentSnapshot>>(
      stream: searchQuery.isEmpty
          ? FirebaseFirestore.instance
              .collection('tickets')
              .where('stock', isNotEqualTo: 0)
              .orderBy('createdAt', descending: true)
              .snapshots()
              .map((snapshot) => snapshot.docs)
          : Rx.combineLatest2(nameQuery, titleQuery, (QuerySnapshot nameSnapshot, QuerySnapshot titleSnapshot) {
              final results = <DocumentSnapshot>[];

              results.addAll(nameSnapshot.docs);
              results.addAll(titleSnapshot.docs);

              // Menghapus duplikat berdasarkan ID dokumen
              return results.toSet().toList();
            }),
      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        }

        // Pastikan data tidak null
        var docs = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true, // Pastikan ListView hanya mengambil ruang yang diperlukan
          physics: NeverScrollableScrollPhysics(), // Mencegah scrolling ganda
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var doc = docs[index];
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            try {
              TicketModel newTicketModel = TicketModel.fromMap(data, doc.id);

              String formattedDate = '';
              String formattedTime = '';
              if (newTicketModel.openingTime != null) {
                DateTime openingTime = newTicketModel.openingTime!.toDate();

                // Memformat tanggal
                formattedDate = DateFormat('dd MMM yyyy').format(openingTime); // Contoh: 11 Jun 2024

                // Memformat waktu
                formattedTime = DateFormat('hh:mm a').format(openingTime); // Contoh: 07.00 PM
              }

              late String? ticketName;

              if (newTicketModel.title == null) {
                ticketName = newTicketModel.name;
              } else {
                ticketName = newTicketModel.title;
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
                          builder: (context) => DetailTicketScreen(
                            data: newTicketModel,
                            collectionName: 'tickets',
                            category: newTicketModel.category,
                            ticketName: ticketName,
                          ),
                        ),
                      );
                    },
                    child: MainCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5.0),
                                  child: Image.network(
                                    newTicketModel.imageUrl ?? 'Image not found', // URL gambar
                                    width: 110, // Lebar mengikuti lebar layar
                                    height: 110, // Tinggi gambar
                                    fit: BoxFit.cover, // Menyesuaikan gambar agar sesuai kotak
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        truncateText(capitalizeEachWord('${ticketName}'), 20),
                                        style: AppTextStyles.mediumBlack.copyWith(fontWeight: FontWeight.bold),
                                        maxLines: 2, // Membatasi hanya dua baris
                                        overflow: TextOverflow.ellipsis, // Menambahkan ellipsis jika teks terlalu panjang
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            AppIcons.rating,
                                            size: 12,
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            '${newTicketModel.rating}',
                                            style: AppTextStyles.smallStyle.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
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
                                        truncateText(capitalizeEachWord(newTicketModel.organizer ?? 'Organizer not found'), 12),
                                        style: AppTextStyles.smallBold,
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
                                                formattedDate,
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
                                                formattedTime,
                                                style: AppTextStyles.smallStyle,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                AppIcons.pin,
                                                size: 12,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                // capitalizeEachWord(newTicketModel.location ?? ''),
                                                truncateText(capitalizeEachWord(newTicketModel.location ?? ''), 10),
                                                style: AppTextStyles.smallStyle,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        newTicketModel.price == 0
                                            ? 'Free' // Jika rating = 0, tampilkan "Free"
                                            : 'Rp ${NumberFormat('#,##0', 'id_ID').format(newTicketModel.price)}', // Jika rating != 0, tampilkan harga
                                        style: AppTextStyles.smallBold,
                                      ),
                                      SmallIconButton(
                                        onPressed: () async {
                                          final authProvider = Provider.of<provider.AuthProvider>(context, listen: false);

                                          // Tunggu hingga data pengguna selesai diambil
                                          await authProvider.fetchCurrentUser();

                                          if (authProvider.isLoggedIn) {
                                            if (authProvider.isUser) {
                                              // Jika pengguna sudah login dengan role 'user', lanjutkan ke PaymentScreen
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => PaymentScreen(data: newTicketModel),
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
                                        icon: Icon(
                                          AppIcons.cart,
                                          color: AppColors.backgroundColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  // Column(
                                  //   children: [
                                  //     Text(
                                  //       'Starts from',
                                  //       style: AppTextStyles.tinyStyle.copyWith(color: AppColors.secondaryColor),
                                  //     ),
                                  //   ],
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } catch (e) {
              return Center(child: Text('Error parsing newTicketModel data: $e'));
            }
          },
        );
      },
    );
  }
}
