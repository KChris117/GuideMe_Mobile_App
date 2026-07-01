// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:double_back_to_exit/double_back_to_exit.dart';
// // import 'package:flutter/material.dart';
// // import 'package:guideme/core/services/firebase_auth_service.dart';
// // import 'package:guideme/core/utils/auth_utils.dart';
// // import 'package:guideme/widgets/custom_appbar.dart';
// // import 'package:guideme/widgets/custom_navbar.dart';
// // import 'package:guideme/widgets/custom_search.dart';
// // import 'package:guideme/widgets/custom_sidebar.dart';
// // import 'package:guideme/widgets/custom_title.dart';

// // class SearchScreen extends StatefulWidget {
// //   const SearchScreen({super.key});

// //   @override
// //   _SearchScreenState createState() => _SearchScreenState();
// // }

// // class _SearchScreenState extends State<SearchScreen> {
// //   String page = 'ticket';

// //   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
// //   final TextEditingController searchController = TextEditingController();
// //   final FirebaseAuthService _auth = FirebaseAuthService();

// //   bool _isLoggedIn = false;
// //   List<Map<String, dynamic>> _searchResults = [];
// //   bool _isSearching = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _checkLoginStatus();
// //   }

// //   // Memeriksa status login dan memperbarui state
// //   Future<void> _checkLoginStatus() async {
// //     bool loggedIn = await _auth.isLoggedIn();
// //     setState(() {
// //       _isLoggedIn = loggedIn;
// //     });
// //   }

// //   // Fungsi untuk menangani perubahan pencarian
// //   Future<List<Map<String, dynamic>>> _searchData(String query) async {
// //     if (query.isEmpty) return [];
// //     try {
// //       List<Map<String, dynamic>> results = [];

// //       // Query koleksi 'destinations'
// //       final destinations = await FirebaseFirestore.instance
// //           .collection('destinations')
// //           .where('name', isGreaterThanOrEqualTo: query)
// //           .where('name', isLessThanOrEqualTo: query + '\uf8ff')
// //           .get();
// //       results.addAll(destinations.docs.map((doc) => {'type': 'Destination', ..doc.data()}));

// //       // Query koleksi 'events'
// //       final events =
// //           await FirebaseFirestore.instance.collection('events').where('name', isGreaterThanOrEqualTo: query).where('name', isLessThanOrEqualTo: query + '\uf8ff').get();
// //       results.addAll(events.docs.map((doc) => {'type': 'Event', ..doc.data()}));

// //       // Query koleksi 'tickets'
// //       final tickets =
// //           await FirebaseFirestore.instance.collection('tickets').where('name', isGreaterThanOrEqualTo: query).where('name', isLessThanOrEqualTo: query + '\uf8ff').get();
// //       results.addAll(tickets.docs.map((doc) => {'type': 'Ticket', ..doc.data()}));

// //       return results;
// //     } catch (e) {
// //       print('Error fetching search results: $e');
// //       return [];
// //     }
// //   }

// //   void search(String query) async {
// //     setState(() {
// //       _isSearching = true;
// //     });

// //     List<Map<String, dynamic>> results = await _searchData(query);

// //     setState(() {
// //       _searchResults = results;
// //       _isSearching = false;
// //     });
// //   }

// //   Future<List<Map<String, dynamic>>> _fetchInitialData() async {
// //     try {
// //       List<Map<String, dynamic>> results = [];

// //       final destinations = await FirebaseFirestore.instance.collection('destinations').limit(3).get();
// //       results.addAll(destinations.docs.map((doc) => {'type': 'Destination', ..doc.data()}));

// //       final events = await FirebaseFirestore.instance.collection('events').limit(3).get();
// //       results.addAll(events.docs.map((doc) => {'type': 'Event', ..doc.data()}));

// //       final tickets = await FirebaseFirestore.instance.collection('tickets').limit(3).get();
// //       results.addAll(tickets.docs.map((doc) => {'type': 'Ticket', ..doc.data()}));

// //       return results;
// //     } catch (e) {
// //       print('Error fetching initial data: $e');
// //       return [];
// //     }
// //   }

// //   void _showSearchResults(BuildContext context) async {
// //     final initialResults = await _fetchInitialData();
// //     final overlay = Overlay.of(context);

// //     // Buat OverlayEntry
// //     OverlayEntry overlayEntry = OverlayEntry(
// //       builder: (context) {
// //         return Positioned(
// //           top: 100.0, // Sesuaikan dengan posisi kolom pencarian
// //           left: 0,
// //           right: 0,
// //           child: Material(
// //             color: Colors.transparent,
// //             child: Container(
// //               padding: const EdgeInsets.all(16.0),
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 borderRadius: BorderRadius.circular(8.0),
// //                 boxShadow: [
// //                   BoxShadow(color: Colors.black26, blurRadius: 4.0),
// //                 ],
// //               ),
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   const SizedBox(height: 16),
// //                   if (_searchResults.isEmpty) const Text('No results found'),
// //                   if (_searchResults.isNotEmpty)
// //                     Expanded(
// //                       child: ListView.builder(
// //                         shrinkWrap: true,
// //                         itemCount: _searchResults.length,
// //                         itemBuilder: (context, index) {
// //                           final result = _searchResults[index];
// //                           return ListTile(
// //                             title: Text(result['name']),
// //                             subtitle: Text(result['type']),
// //                             onTap: () {
// //                               Navigator.pop(context); // Tutup overlay
// //                               print('Selected: ${result['name']}');
// //                             },
// //                           );
// //                         },
// //                       ),
// //                     ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         );
// //       },
// //     );

// //     // Tampilkan overlay
// //     overlay.insert(overlayEntry);

// //     // Hapus overlay setelah pencarian selesai atau pengguna menutupnya
// //     Future.delayed(const Duration(seconds: 5), () {
// //       overlayEntry.remove();
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return DoubleBackToExit(
// //       snackBarMessage: 'Press back again to exit',
// //       child: Scaffold(
// //         key: scaffoldKey,
// //         appBar: SearchAppBar(
// //           scaffoldKey: scaffoldKey,
// //           onSearchTap: () => _showSearchResults(context),
// //           onSearchChanged: (query) {
// //             print("Search query: $query");
// //           },
// //           searchController: searchController,
// //           actions: [
// //             IconButton(
// //               icon: const Icon(Icons.notifications),
// //               onPressed: () {
// //                 print("Notifications clicked");
// //               },
// //             ),
// //           ],
// //           // _showSearchResults(context),
// //         ),
// //         drawer: CustomSidebar(
// //           isLoggedIn: _isLoggedIn,
// //           onLogout: () {
// //             // Panggil handleLogout juga di sini
// //             handleLogout(context);
// //           },
// //         ),
// //         body: Column(
// //           mainAxisAlignment: MainAxisAlignment.start,
// //           children: [
// //             SizedBox(
// //               height: 4,
// //             ),
// //             // SearchWidget(onSearchChanged: search),
// //             SizedBox(
// //               height: 16,
// //             ),
// //             // DestinationSearchScreenContent(
// //             //   searchQuery: _searchQuery,
// //             // ),
// //           ],
// //         ),
// //         bottomNavigationBar: UserBottomNavBar(selectedIndex: 2),
// //       ),
// //     );
// //   }
// // }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:guideme/core/constants/constants.dart';
// import 'package:guideme/core/services/auth_provider.dart' as provider;
// import 'package:guideme/core/services/firebase_auth_service.dart';
// import 'package:guideme/core/utils/auth_utils.dart';
// import 'package:guideme/core/utils/text_utils.dart';
// import 'package:guideme/models/destination_model.dart';
// import 'package:guideme/models/event_model.dart';
// import 'package:guideme/models/ticket_model.dart';
// import 'package:guideme/views/auth/login_screen.dart';
// import 'package:guideme/views/user/detail_screen.dart';
// import 'package:guideme/views/user/list_screen.dart';
// import 'package:guideme/views/user/ticket/payment_screen.dart';
// import 'package:guideme/views/user/ticket/detail_ticket_screen.dart';
// import 'package:guideme/widgets/custom_appbar.dart';
// import 'package:guideme/widgets/custom_button.dart';
// import 'package:guideme/widgets/custom_card.dart';
// import 'package:guideme/widgets/custom_sidebar.dart';
// import 'package:guideme/widgets/custom_navbar.dart';
// import 'package:guideme/widgets/custom_snackbar.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   String page = 'ticket';

//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//   final TextEditingController searchController = TextEditingController();
//   final FirebaseAuthService _auth = FirebaseAuthService();

//   bool _isLoggedIn = false;

//   Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>> _searchResults = {};

//   OverlayEntry? _overlayEntry; // Menyimpan entry overlay

//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }

//   Future<void> _checkLoginStatus() async {
//     bool loggedIn = await _auth.isLoggedIn();
//     setState(() {
//       _isLoggedIn = loggedIn;
//     });
//   }

// // Fungsi pencarian untuk mencari 'name' di koleksi 'tickets', 'destinations', dan 'events'
//   Future<void> search(String query) async {
//     if (query.isEmpty) {
//       setState(() {
//         _searchResults = {
//           'tickets': [],
//           'destinations': [],
//           'events': [],
//         };
//       });
//       _removeOverlay();
//       return;
//     }

//     // Query untuk mencari 'name' di koleksi 'tickets'
//     var ticketResults = await FirebaseFirestore.instance
//         .collection('tickets')
//         .where('status', isEqualTo: 'available')
//         .where('name', isGreaterThanOrEqualTo: query)
//         .where('name', isLessThanOrEqualTo: query + '\uf8ff')
//         .get();

//     // Query untuk mencari 'name' di koleksi 'destinations'
//     var destinationResults = await FirebaseFirestore.instance
//         .collection('destinations')
//         .where('status', isEqualTo: 'open')
//         .where('name', isGreaterThanOrEqualTo: query)
//         .where('name', isLessThanOrEqualTo: query + '\uf8ff')
//         .get();

//     // Query untuk mencari 'name' di koleksi 'events'
//     var eventResults = await FirebaseFirestore.instance
//         .collection('events')
//         .where('status', isEqualTo: 'open')
//         .where('name', isGreaterThanOrEqualTo: query)
//         .where('name', isLessThanOrEqualTo: query + '\uf8ff')
//         .get();

//     setState(() {
//       // Gabungkan hasil pencarian dari ketiga koleksi dalam kategori terpisah
//       _searchResults = {
//         'tickets': ticketResults.docs,
//         'destinations': destinationResults.docs,
//         'events': eventResults.docs,
//       };
//     });

//     // Menampilkan overlay jika ada hasil pencarian
//     if (_searchResults['tickets']!.isNotEmpty || _searchResults['destinations']!.isNotEmpty || _searchResults['events']!.isNotEmpty) {
//       _showOverlay();
//     } else {
//       _removeOverlay();
//     }
//   }

// // Menampilkan hasil pencarian dalam overlay
//   void _showOverlay() {
//     if (_overlayEntry != null) return;

//     _overlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         top: kToolbarHeight + 32, // Menempatkan overlay tepat di bawah app bar
//         left: 0,
//         right: 0,
//         child: Material(
//           color: Colors.transparent,
//           child: Container(
//             padding: EdgeInsets.only(top: 48),
//             // padding: EdgeInsets.zero, // Menghilangkan padding
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                 ),
//               ],
//             ),
//             child: SingleChildScrollView(
//               // Use ScrollView to make sure it's scrollable
//               child: Column(
//                 children: [
//                   // Display Tickets
//                   if (_searchResults['tickets']!.isNotEmpty) _buildCategorySection('Tickets', _searchResults['tickets']!),
//                   // Display Destinations
//                   if (_searchResults['destinations']!.isNotEmpty) _buildCategorySection('Destinations', _searchResults['destinations']!),
//                   // Display Events
//                   if (_searchResults['events']!.isNotEmpty) _buildCategorySection('Events', _searchResults['events']!),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );

//     Overlay.of(context).insert(_overlayEntry!);
//   }

// // Helper function to build each category section
//   Widget _buildCategorySection(String title, List<DocumentSnapshot> results) {
//     return Container(
//       padding: EdgeInsets.only(left: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: AppTextStyles.mediumBold, // Gunakan style teks yang telah didefinisikan
//           ),
//           ListView.builder(
//             shrinkWrap: true,
//             itemCount: results.length,
//             itemBuilder: (context, index) {
//               var result = results[index];
//               return Column(
//                 children: [
//                   ListTile(
//                     title: Text(result['name'] ?? 'No name'),
//                     subtitle: Text(result['location'] ?? 'No description'),
//                     onTap: () {
//                       _removeOverlay();
//                       searchController.clear(); // Bersihkan controller untuk menghindari kebocoran memori

//                       // Mengarahkan ke halaman detail sesuai jenis item
//                       if (title == 'Tickets') {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => DetailTicketScreen(
//                               data: TicketModel.fromFirestore(result),
//                               collectionName: 'tickets',
//                             ),
//                           ),
//                         );
//                       } else if (title == 'Destinations') {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => DetailScreen(
//                               data: DestinationModel.fromFirestore(result),
//                               collectionName: 'destinations',
//                             ),
//                           ),
//                         );
//                       } else if (title == 'Events') {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => DetailScreen(
//                               data: EventModel.fromFirestore(result),
//                               collectionName: 'events',
//                             ),
//                           ),
//                         );
//                       }
//                     },
//                   ),
//                   Divider(
//                     thickness: 1.0,
//                     color: AppColors.tertiaryColor,
//                   ),
//                   SizedBox(
//                     height: 4,
//                   ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // Widget _buildCategorySection(String title, List<DocumentSnapshot> results) {
//   //   return Container(
//   //     padding: EdgeInsets.only(left: 16),
//   //     child: Column(
//   //       crossAxisAlignment: CrossAxisAlignment.start,
//   //       children: [
//   //         Text(
//   //           title,
//   //           style: AppTextStyles.mediumBold, // Gunakan style teks yang telah didefinisikan),
//   //         ),
//   //         ListView.builder(
//   //           shrinkWrap: true,
//   //           itemCount: results.length,
//   //           itemBuilder: (context, index) {
//   //             var result = results[index];
//   //             return Column(
//   //               children: [
//   //                 ListTile(
//   //                   title: Text(result['name'] ?? 'No name'),
//   //                   subtitle: Text(result['location'] ?? 'No description'),
//   //                 ),
//   //                 Divider(
//   //                   thickness: 1.0,
//   //                   color: AppColors.tertiaryColor,
//   //                 ),
//   //                 SizedBox(
//   //                   height: 4,
//   //                 ),
//   //               ],
//   //             );
//   //           },
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   // Menghapus overlay
//   void _removeOverlay() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//   }

//   @override
//   void dispose() {
//     _removeOverlay(); // Pastikan overlay dihapus
//     searchController.dispose(); // Bersihkan controller untuk menghindari kebocoran memori
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: scaffoldKey,
//       appBar: SearchAppBar(
//         scaffoldKey: scaffoldKey,
//         searchController: searchController,
//         onSearch: search, // Fungsi pencarian
//       ),
//       drawer: CustomSidebar(
//         isLoggedIn: _isLoggedIn,
//         onLogout: () {
//           // Panggil handleLogout juga di sini
//           handleLogout(context);
//         },
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 16),
//               // Menampilkan teks jika tidak ada hasil pencarian
//               // if (_searchResults.isEmpty) Center(child: Text('No results found')),
//               DestinationSearchScreenContent(),
//               SizedBox(height: 16),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16),
//                 child: Text(
//                   'Suggested for you',
//                   style: AppTextStyles.mediumBold,
//                 ),
//               ),
//               // SizedBox(height: 8),
//               TicketSearchScreenContent(),
//               // SizedBox(height: 16),
//               EventSearchScreenContent(),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: UserBottomNavBar(selectedIndex: 2),
//     );
//   }
// }

// class DestinationSearchScreenContent extends StatelessWidget {
//   const DestinationSearchScreenContent({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: Text(
//               'Explore destinations',
//               style: AppTextStyles.mediumBold,
//             ),
//           ),
//           SizedBox(height: 8),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 12),
//             child: GridView.count(
//               shrinkWrap: true, // Agar grid hanya mengambil ruang yang dibutuhkan
//               physics: NeverScrollableScrollPhysics(), // Menonaktifkan scroll pada GridView
//               crossAxisCount: 2, // Menentukan jumlah kolom (2 kolom per baris)
//               crossAxisSpacing: 8.0, // Jarak antar kolom
//               mainAxisSpacing: 8.0, // Jarak antar baris
//               childAspectRatio: 3 / 1, // Mengatur rasio lebar dan tinggi setiap item grid
//               children: [
//                 buildDestinationRow(context, 'Beach', AppIcons.beach),
//                 buildDestinationRow(context, 'Cafetaria', AppIcons.cafe),
//                 buildDestinationRow(context, 'Historical', AppIcons.historical),
//                 buildDestinationRow(context, 'Cultural', AppIcons.cultural),
//                 buildDestinationRow(context, 'Religious', AppIcons.religious),
//                 buildDestinationRow(context, 'Culinary', AppIcons.culinary),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class TicketSearchScreenContent extends StatelessWidget {
//   TicketSearchScreenContent({super.key});

//   @override
//   Widget build(BuildContext context) {
//     FirebaseFirestore.instance.collection('tickets').snapshots().map((snapshot) {
//       final docs = snapshot.docs;
//       docs.shuffle(); // Acak urutan dokumen
//       return docs.take(3).toList(); // Ambil 5 dokumen pertama
//     });
//     return StreamBuilder<List<DocumentSnapshot>>(
//       stream: FirebaseFirestore.instance.collection('tickets').snapshots().map((snapshot) {
//         final docs = snapshot.docs;
//         docs.shuffle(); // Mengacak dokumen
//         return docs.take(3).toList(); // Ambil 5 dokumen
//       }),
//       builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }
//         if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return Center(child: Text('No data available'));
//         }

//         // Pastikan data tidak null
//         var docs = snapshot.data!;
//         return snapshot.hasData && snapshot.data!.isNotEmpty
//             ? Container(
//                 // padding: EdgeInsets.symmetric(vertical: 16),
//                 height: 150,
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children: List.generate(docs.length, (index) {
//                       var doc = docs[index];
//                       Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

//                       // Tentukan padding untuk item pertama dan terakhir
//                       EdgeInsetsGeometry padding = EdgeInsets.symmetric(horizontal: 0); // Default padding

//                       if (index == 0) {
//                         // Padding kiri 10 untuk data pertama
//                         padding = EdgeInsets.only(left: 10);
//                       } else if (index == docs.length - 1) {
//                         // Padding kanan 10 untuk data terakhir
//                         padding = EdgeInsets.only(right: 10);
//                       }

//                       if (data == null) {
//                         return Center(child: Text('Data not found'));
//                       }
//                       try {
//                         TicketModel newTicketModel = TicketModel.fromMap(data, doc.id);

//                         String formattedDate = '';
//                         String formattedTime = '';
//                         if (newTicketModel.openingTime != null) {
//                           DateTime openingTime = newTicketModel.openingTime!.toDate();

//                           formattedDate = DateFormat('dd MMM yyyy').format(openingTime);
//                           formattedTime = DateFormat('hh:mm a').format(openingTime);
//                         }

//                         // Pastikan bahwa MediaQuery.of(context).size.width adalah angka yang valid
//                         double width = MediaQuery.of(context).size.width * 0.85;
//                         if (width.isNaN || width.isInfinite) {
//                           width = 250; // Lebar cadangan jika perhitungan tidak valid
//                         }

//                         return Container(
//                           padding: padding,
//                           width: width,
//                           margin: EdgeInsets.symmetric(horizontal: 2),
//                           child: GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => DetailTicketScreen(
//                                     data: newTicketModel,
//                                     collectionName: 'tickets',
//                                     category: newTicketModel.category,
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: MainCard(
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//                                 child: Container(
//                                   width: double.infinity,
//                                   height: 100,
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                     children: [
//                                       ClipRRect(
//                                         borderRadius: BorderRadius.circular(5.0),
//                                         child: Image.network(
//                                           newTicketModel.imageUrl ?? 'Image not found',
//                                           width: 88,
//                                           height: 88,
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                       SizedBox(width: 8),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           mainAxisAlignment: MainAxisAlignment.center,
//                                           children: [
//                                             Row(
//                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                               children: [
//                                                 Text(
//                                                   truncateText(capitalizeEachWord(newTicketModel.name ?? 'Name not found'), 15),
//                                                   style: AppTextStyles.mediumBold,
//                                                   maxLines: 2, // Membatasi hanya dua baris
//                                                   overflow: TextOverflow.ellipsis, // Menambahkan ellipsis jika teks terlalu panjang
//                                                 ),
//                                                 Row(
//                                                   children: [
//                                                     Icon(
//                                                       AppIcons.rating,
//                                                       size: 12,
//                                                     ),
//                                                     SizedBox(width: 2),
//                                                     Text(
//                                                       '${newTicketModel.rating}',
//                                                       style: AppTextStyles.smallStyle.copyWith(fontWeight: FontWeight.bold),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                             SizedBox(height: 4),
//                                             Row(
//                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               children: [
//                                                 Column(
//                                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                                   children: [
//                                                     Row(
//                                                       children: [
//                                                         Icon(
//                                                           AppIcons.date,
//                                                           size: 12,
//                                                         ),
//                                                         SizedBox(width: 2),
//                                                         Text(
//                                                           formattedDate,
//                                                           style: AppTextStyles.tinyStyle,
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     SizedBox(
//                                                       height: 2,
//                                                     ),
//                                                     Row(
//                                                       children: [
//                                                         Icon(
//                                                           AppIcons.time,
//                                                           size: 12,
//                                                         ),
//                                                         SizedBox(width: 2),
//                                                         Text(
//                                                           formattedTime,
//                                                           style: AppTextStyles.tinyStyle,
//                                                         ),
//                                                       ],
//                                                     )
//                                                   ],
//                                                 ),
//                                                 Column(
//                                                   children: [
//                                                     Row(
//                                                       children: [
//                                                         Icon(
//                                                           AppIcons.pin,
//                                                           size: 12,
//                                                         ),
//                                                         SizedBox(width: 2),
//                                                         Text(
//                                                           // capitalizeEachWord(newTicketModel.location ?? ''),
//                                                           truncateText(capitalizeEachWord(newTicketModel.location ?? ''), 10),
//                                                           style: AppTextStyles.tinyStyle,
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                             SizedBox(
//                                               height: 4,
//                                             ),
//                                             Row(
//                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   newTicketModel.price == 0
//                                                       ? 'Free' // Jika rating = 0, tampilkan "Free"
//                                                       : 'Rp ${NumberFormat('#,##0', 'id_ID').format(newTicketModel.price)}', // Jika rating != 0, tampilkan harga
//                                                   style: AppTextStyles.smallBold,
//                                                 ),
//                                                 SmallIconButton(
//                                                   onPressed: () async {
//                                                     final authProvider = Provider.of<provider.AuthProvider>(context, listen: false);

//                                                     // Tunggu hingga data pengguna selesai diambil
//                                                     await authProvider.fetchCurrentUser();

//                                                     if (authProvider.isLoggedIn) {
//                                                       if (authProvider.isUser) {
//                                                         // Jika pengguna sudah login dengan role 'user', lanjutkan ke PaymentScreen
//                                                         Navigator.push(
//                                                           context,
//                                                           MaterialPageRoute(
//                                                             builder: (context) => PaymentScreen(data: newTicketModel),
//                                                           ),
//                                                         );
//                                                       } else {
//                                                         // Jika role bukan 'user', tampilkan pesan atau arahkan ke halaman lain
//                                                         FloatingSnackBar.show(
//                                                           context: context,
//                                                           message: "You must login first to access this page.",
//                                                           // backgroundColor: Colors.red,
//                                                           textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                                                           duration: Duration(seconds: 5),
//                                                         );
//                                                       }
//                                                     } else {
//                                                       // Jika pengguna belum login, tampilkan SnackBar dan arahkan ke LoginScreen
//                                                       FloatingSnackBar.show(
//                                                         context: context,
//                                                         message: "You must login first to access this page.",
//                                                         // backgroundColor: Colors.red,
//                                                         textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                                                         duration: Duration(seconds: 5),
//                                                       );

//                                                       // Setelah menampilkan SnackBar, arahkan ke halaman login
//                                                       Future.delayed(Duration(seconds: 1), () {
//                                                         Navigator.pushReplacement(
//                                                           context,
//                                                           MaterialPageRoute(
//                                                             builder: (context) => LoginScreen(), // Ganti dengan LoginScreen Anda
//                                                           ),
//                                                         );
//                                                       });
//                                                     }
//                                                   },
//                                                   icon: Icon(
//                                                     AppIcons.cart,
//                                                     color: AppColors.backgroundColor,
//                                                   ),
//                                                 )
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       } catch (e) {
//                         return Center(child: Text('Error parsing newTicketModel data: $e'));
//                       }
//                     }).toList(),
//                   ),
//                 ),
//               )
//             : Center(child: Text('No data available'));
//       },
//     );
//   }
// }

// class EventSearchScreenContent extends StatelessWidget {
//   const EventSearchScreenContent({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: Text(
//               'Explore events',
//               style: AppTextStyles.mediumBold,
//             ),
//           ),
//           SizedBox(height: 8),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 12),
//             child: GridView.count(
//               shrinkWrap: true, // Agar grid hanya mengambil ruang yang dibutuhkan
//               physics: NeverScrollableScrollPhysics(), // Menonaktifkan scroll pada GridView
//               crossAxisCount: 2, // Menentukan jumlah kolom (2 kolom per baris)
//               crossAxisSpacing: 8.0, // Jarak antar kolom
//               mainAxisSpacing: 8.0, // Jarak antar baris
//               childAspectRatio: 3 / 1, // Mengatur rasio lebar dan tinggi setiap item grid
//               children: [
//                 buildEventRow(context, 'Bazaar', AppIcons.culinary),
//                 buildEventRow(context, 'Music', AppIcons.music),
//                 buildEventRow(context, 'Cultural', AppIcons.cultural),
//                 buildEventRow(context, 'Sport', AppIcons.sport),
//                 buildEventRow(context, 'Social', AppIcons.historical),
//                 buildEventRow(context, 'Education', AppIcons.education),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// Widget buildDestinationRow(BuildContext context, String subcategory, IconData icon) {
//   return GestureDetector(
//     // onTap: () => fetchDataAndNavigate(context, category),
//     onTap: () {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ListScreen(
//             data: 'destinations', // Pastikan 'data' sesuai dengan tipe yang diperlukan oleh ListScreen
//             subcategory: subcategory,
//           ),
//         ),
//       );
//     },
//     child: MainCard(
//       child: Container(
//         width: MediaQuery.of(context).size.width * 0.445,
//         padding: const EdgeInsets.all(16.0),
//         child: Expanded(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 subcategory,
//                 style: AppTextStyles.mediumBlack,
//               ),
//               Icon(icon),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }

// Widget buildEventRow(BuildContext context, String subcategory, IconData icon) {
//   return GestureDetector(
//     // onTap: () => fetchDataAndNavigate(context, category),
//     onTap: () {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ListScreen(
//             data: 'events', // Pastikan 'data' sesuai dengan tipe yang diperlukan oleh ListScreen
//             subcategory: subcategory,
//           ),
//         ),
//       );
//     },
//     child: MainCard(
//       child: Container(
//         width: MediaQuery.of(context).size.width * 0.445,
//         padding: const EdgeInsets.all(16.0),
//         child: Expanded(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 subcategory,
//                 style: AppTextStyles.bodyBlack,
//               ),
//               Icon(icon),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:double_back_to_exit/double_back_to_exit.dart';
// import 'package:flutter/material.dart';
// import 'package:guideme/core/services/firebase_auth_service.dart';
// import 'package:guideme/core/utils/auth_utils.dart';
// import 'package:guideme/widgets/custom_appbar.dart';
// import 'package:guideme/widgets/custom_navbar.dart';
// import 'package:guideme/widgets/custom_search.dart';
// import 'package:guideme/widgets/custom_sidebar.dart';
// import 'package:guideme/widgets/custom_title.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   String page = 'ticket';

//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//   final TextEditingController searchController = TextEditingController();
//   final FirebaseAuthService _auth = FirebaseAuthService();

//   bool _isLoggedIn = false;
//   List<Map<String, dynamic>> _searchResults = [];
//   bool _isSearching = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }

//   // Memeriksa status login dan memperbarui state
//   Future<void> _checkLoginStatus() async {
//     bool loggedIn = await _auth.isLoggedIn();
//     setState(() {
//       _isLoggedIn = loggedIn;
//     });
//   }

//   // Fungsi untuk menangani perubahan pencarian
//   Future<List<Map<String, dynamic>>> _searchData(String query) async {
//     if (query.isEmpty) return [];
//     try {
//       List<Map<String, dynamic>> results = [];

//       // Query koleksi 'destinations'
//       final destinations = await FirebaseFirestore.instance
//           .collection('destinations')
//           .where('name', isGreaterThanOrEqualTo: query)
//           .where('name', isLessThanOrEqualTo: query + '\uf8ff')
//           .get();
//       results.addAll(destinations.docs.map((doc) => {'type': 'Destination', ...doc.data()}));

//       // Query koleksi 'events'
//       final events =
//           await FirebaseFirestore.instance.collection('events').where('name', isGreaterThanOrEqualTo: query).where('name', isLessThanOrEqualTo: query + '\uf8ff').get();
//       results.addAll(events.docs.map((doc) => {'type': 'Event', ...doc.data()}));

//       // Query koleksi 'tickets'
//       final tickets =
//           await FirebaseFirestore.instance.collection('tickets').where('name', isGreaterThanOrEqualTo: query).where('name', isLessThanOrEqualTo: query + '\uf8ff').get();
//       results.addAll(tickets.docs.map((doc) => {'type': 'Ticket', ...doc.data()}));

//       return results;
//     } catch (e) {
//       print('Error fetching search results: $e');
//       return [];
//     }
//   }

//   void search(String query) async {
//     setState(() {
//       _isSearching = true;
//     });

//     List<Map<String, dynamic>> results = await _searchData(query);

//     setState(() {
//       _searchResults = results;
//       _isSearching = false;
//     });
//   }

//   Future<List<Map<String, dynamic>>> _fetchInitialData() async {
//     try {
//       List<Map<String, dynamic>> results = [];

//       final destinations = await FirebaseFirestore.instance.collection('destinations').limit(3).get();
//       results.addAll(destinations.docs.map((doc) => {'type': 'Destination', ...doc.data()}));

//       final events = await FirebaseFirestore.instance.collection('events').limit(3).get();
//       results.addAll(events.docs.map((doc) => {'type': 'Event', ...doc.data()}));

//       final tickets = await FirebaseFirestore.instance.collection('tickets').limit(3).get();
//       results.addAll(tickets.docs.map((doc) => {'type': 'Ticket', ...doc.data()}));

//       return results;
//     } catch (e) {
//       print('Error fetching initial data: $e');
//       return [];
//     }
//   }

//   void _showSearchResults(BuildContext context) async {
//     final initialResults = await _fetchInitialData();
//     final overlay = Overlay.of(context);

//     // Buat OverlayEntry
//     OverlayEntry overlayEntry = OverlayEntry(
//       builder: (context) {
//         return Positioned(
//           top: 100.0, // Sesuaikan dengan posisi kolom pencarian
//           left: 0,
//           right: 0,
//           child: Material(
//             color: Colors.transparent,
//             child: Container(
//               padding: const EdgeInsets.all(16.0),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8.0),
//                 boxShadow: [
//                   BoxShadow(color: Colors.black26, blurRadius: 4.0),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const SizedBox(height: 16),
//                   if (_searchResults.isEmpty) const Text('No results found'),
//                   if (_searchResults.isNotEmpty)
//                     Expanded(
//                       child: ListView.builder(
//                         shrinkWrap: true,
//                         itemCount: _searchResults.length,
//                         itemBuilder: (context, index) {
//                           final result = _searchResults[index];
//                           return ListTile(
//                             title: Text(result['name']),
//                             subtitle: Text(result['type']),
//                             onTap: () {
//                               Navigator.pop(context); // Tutup overlay
//                               print('Selected: ${result['name']}');
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );

//     // Tampilkan overlay
//     overlay.insert(overlayEntry);

//     // Hapus overlay setelah pencarian selesai atau pengguna menutupnya
//     Future.delayed(const Duration(seconds: 5), () {
//       overlayEntry.remove();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DoubleBackToExit(
//       snackBarMessage: 'Press back again to exit',
//       child: Scaffold(
//         key: scaffoldKey,
//         appBar: SearchAppBar(
//           scaffoldKey: scaffoldKey,
//           onSearchTap: () => _showSearchResults(context),
//           onSearchChanged: (query) {
//             print("Search query: $query");
//           },
//           searchController: searchController,
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.notifications),
//               onPressed: () {
//                 print("Notifications clicked");
//               },
//             ),
//           ],
//           // _showSearchResults(context),
//         ),
//         drawer: CustomSidebar(
//           isLoggedIn: _isLoggedIn,
//           onLogout: () {
//             // Panggil handleLogout juga di sini
//             handleLogout(context);
//           },
//         ),
//         body: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             SizedBox(
//               height: 4,
//             ),
//             // SearchWidget(onSearchChanged: search),
//             SizedBox(
//               height: 16,
//             ),
//             // DestinationSearchScreenContent(
//             //   searchQuery: _searchQuery,
//             // ),
//           ],
//         ),
//         bottomNavigationBar: UserBottomNavBar(selectedIndex: 2),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/core/services/auth_provider.dart' as provider;
import 'package:guideme/core/services/firebase_auth_service.dart';
import 'package:guideme/core/utils/auth_utils.dart';
import 'package:guideme/core/utils/text_utils.dart';
import 'package:guideme/models/destination_model.dart';
import 'package:guideme/models/event_model.dart';
import 'package:guideme/models/ticket_model.dart';
import 'package:guideme/views/auth/login_screen.dart';
import 'package:guideme/views/user/detail_screen.dart';
import 'package:guideme/views/user/list_screen.dart';
import 'package:guideme/views/user/ticket/payment_screen.dart';
import 'package:guideme/views/user/ticket/detail_ticket_screen.dart';
import 'package:guideme/widgets/custom_appbar.dart';
import 'package:guideme/widgets/custom_button.dart';
import 'package:guideme/widgets/custom_card.dart';
import 'package:guideme/widgets/custom_sidebar.dart';
import 'package:guideme/widgets/custom_navbar.dart';
import 'package:guideme/widgets/custom_snackbar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String page = 'ticket';

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController searchController = TextEditingController();
  final FirebaseAuthService _auth = FirebaseAuthService();

  bool _isLoggedIn = false;

  Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>> _searchResults = {};

  OverlayEntry? _overlayEntry; // Menyimpan entry overlay

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    bool loggedIn = await _auth.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

// Fungsi pencarian untuk mencari 'name' di koleksi 'tickets', 'destinations', dan 'events'
  Future<void> search(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = {
          'tickets': [],
          'destinations': [],
          'events': [],
        };
      });
      _removeOverlay();
      return;
    }

    // Query untuk mencari 'name' di koleksi 'tickets'
    var ticketResults = await FirebaseFirestore.instance
        .collection('tickets')
        .where('status', isEqualTo: 'available')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    // Query untuk mencari 'name' di koleksi 'destinations'
    var destinationResults = await FirebaseFirestore.instance
        .collection('destinations')
        .where('status', isEqualTo: 'open')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    // Query untuk mencari 'name' di koleksi 'events'
    var eventResults = await FirebaseFirestore.instance
        .collection('events')
        .where('status', isEqualTo: 'open')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    setState(() {
      // Gabungkan hasil pencarian dari ketiga koleksi dalam kategori terpisah
      _searchResults = {
        'tickets': ticketResults.docs,
        'destinations': destinationResults.docs,
        'events': eventResults.docs,
      };
    });

    // Menampilkan overlay jika ada hasil pencarian
    if (_searchResults['tickets']!.isNotEmpty || _searchResults['destinations']!.isNotEmpty || _searchResults['events']!.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

// Menampilkan hasil pencarian dalam overlay
  void _showOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: kToolbarHeight + 32, // Menempatkan overlay tepat di bawah app bar
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.only(top: 48),
            // padding: EdgeInsets.zero, // Menghilangkan padding
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: SingleChildScrollView(
              // Use ScrollView to make sure it's scrollable
              child: Column(
                children: [
                  // Display Tickets
                  if (_searchResults['tickets']!.isNotEmpty) _buildCategorySection('Tickets', _searchResults['tickets']!),
                  // Display Destinations
                  if (_searchResults['destinations']!.isNotEmpty) _buildCategorySection('Destinations', _searchResults['destinations']!),
                  // Display Events
                  if (_searchResults['events']!.isNotEmpty) _buildCategorySection('Events', _searchResults['events']!),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

// Helper function to build each category section
  Widget _buildCategorySection(String title, List<DocumentSnapshot> results) {
    return Container(
      padding: EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.mediumBold, // Gunakan style teks yang telah didefinisikan
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: results.length,
            itemBuilder: (context, index) {
              var result = results[index];
              return Column(
                children: [
                  ListTile(
                    title: Text(result['name'] ?? 'No name'),
                    subtitle: Text(result['location'] ?? 'No description'),
                    onTap: () {
                      _removeOverlay();
                      searchController.clear(); // Bersihkan controller untuk menghindari kebocoran memori

                      // Mengarahkan ke halaman detail sesuai jenis item
                      if (title == 'Tickets') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailTicketScreen(
                              data: TicketModel.fromFirestore(result),
                              collectionName: 'tickets',
                            ),
                          ),
                        );
                      } else if (title == 'Destinations') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              data: DestinationModel.fromFirestore(result),
                              collectionName: 'destinations',
                            ),
                          ),
                        );
                      } else if (title == 'Events') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              data: EventModel.fromFirestore(result),
                              collectionName: 'events',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  Divider(
                    thickness: 1.0,
                    color: AppColors.tertiaryColor,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget _buildCategorySection(String title, List<DocumentSnapshot> results) {
  //   return Container(
  //     padding: EdgeInsets.only(left: 16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           title,
  //           style: AppTextStyles.mediumBold, // Gunakan style teks yang telah didefinisikan),
  //         ),
  //         ListView.builder(
  //           shrinkWrap: true,
  //           itemCount: results.length,
  //           itemBuilder: (context, index) {
  //             var result = results[index];
  //             return Column(
  //               children: [
  //                 ListTile(
  //                   title: Text(result['name'] ?? 'No name'),
  //                   subtitle: Text(result['location'] ?? 'No description'),
  //                 ),
  //                 Divider(
  //                   thickness: 1.0,
  //                   color: AppColors.tertiaryColor,
  //                 ),
  //                 SizedBox(
  //                   height: 4,
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Menghapus overlay
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay(); // Pastikan overlay dihapus
    searchController.dispose(); // Bersihkan controller untuk menghindari kebocoran memori
    super.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              // Menampilkan teks jika tidak ada hasil pencarian
              // if (_searchResults.isEmpty) Center(child: Text('No results found')),
              DestinationSearchScreenContent(),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Suggested for you',
                  style: AppTextStyles.mediumBold,
                ),
              ),
              // SizedBox(height: 8),
              TicketSearchScreenContent(),
              // SizedBox(height: 16),
              EventSearchScreenContent(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: UserBottomNavBar(selectedIndex: 2),
    );
  }
}

class DestinationSearchScreenContent extends StatelessWidget {
  const DestinationSearchScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Explore destinations',
              style: AppTextStyles.mediumBold,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: GridView.count(
              shrinkWrap: true, // Agar grid hanya mengambil ruang yang dibutuhkan
              physics: NeverScrollableScrollPhysics(), // Menonaktifkan scroll pada GridView
              crossAxisCount: 2, // Menentukan jumlah kolom (2 kolom per baris)
              crossAxisSpacing: 12.0, // Jarak antar kolom
              mainAxisSpacing: 12.0, // Jarak antar baris
              childAspectRatio: 3 / 1, // Mengatur rasio lebar dan tinggi setiap item grid
              children: [
                buildDestinationRow(context, 'Beach', AppIcons.beach),
                buildDestinationRow(context, 'Cafetaria', AppIcons.cafe),
                buildDestinationRow(context, 'Historical', AppIcons.historical),
                buildDestinationRow(context, 'Cultural', AppIcons.cultural),
                buildDestinationRow(context, 'Religious', AppIcons.religious),
                buildDestinationRow(context, 'Culinary', AppIcons.culinary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TicketSearchScreenContent extends StatelessWidget {
  TicketSearchScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore.instance.collection('tickets').snapshots().map((snapshot) {
      final docs = snapshot.docs;
      docs.shuffle(); // Acak urutan dokumen
      return docs.take(3).toList(); // Ambil 5 dokumen pertama
    });
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: FirebaseFirestore.instance.collection('tickets').snapshots().map((snapshot) {
        final docs = snapshot.docs;
        docs.shuffle(); // Mengacak dokumen
        return docs.take(3).toList(); // Ambil 5 dokumen
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
        return snapshot.hasData && snapshot.data!.isNotEmpty
            ? Container(
                // padding: EdgeInsets.symmetric(vertical: 16),
                height: 150,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(docs.length, (index) {
                      var doc = docs[index];
                      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

                      // Tentukan padding untuk item pertama dan terakhir
                      EdgeInsetsGeometry padding = EdgeInsets.symmetric(horizontal: 0); // Default padding

                      if (index == 0) {
                        // Padding kiri 10 untuk data pertama
                        padding = EdgeInsets.only(left: 10);
                      } else if (index == docs.length - 1) {
                        // Padding kanan 10 untuk data terakhir
                        padding = EdgeInsets.only(right: 10);
                      }

                      if (data == null) {
                        return Center(child: Text('Data not found'));
                      }
                      try {
                        TicketModel newTicketModel = TicketModel.fromMap(data, doc.id);

                        String formattedDate = '';
                        String formattedTime = '';
                        if (newTicketModel.openingTime != null) {
                          DateTime openingTime = newTicketModel.openingTime!.toDate();

                          formattedDate = DateFormat('dd MMM yyyy').format(openingTime);
                          formattedTime = DateFormat('hh:mm a').format(openingTime);
                        }

                        // Pastikan bahwa MediaQuery.of(context).size.width adalah angka yang valid
                        double width = MediaQuery.of(context).size.width * 0.85;
                        if (width.isNaN || width.isInfinite) {
                          width = 250; // Lebar cadangan jika perhitungan tidak valid
                        }

                        return Container(
                          padding: padding,
                          width: width,
                          margin: EdgeInsets.symmetric(horizontal: 2),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailTicketScreen(
                                    data: newTicketModel,
                                    collectionName: 'tickets',
                                    category: newTicketModel.category,
                                  ),
                                ),
                              );
                            },
                            child: MainCard(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 95,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(5.0),
                                        child: Image.network(
                                          newTicketModel.imageUrl ?? 'Image not found',
                                          width: 94,
                                          height: 94,
                                          fit: BoxFit.cover,
                                        ),
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
                                                  capitalizeEachWord(newTicketModel.name ?? 'Name not found'),
                                                  style: AppTextStyles.mediumBold,
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
                                                  capitalizeEachWord(newTicketModel.organizer ?? 'Organizer not found'),
                                                  style: AppTextStyles.smallStyle.copyWith(fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4),
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
                                                          style: AppTextStyles.tinyStyle,
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
                                                          style: AppTextStyles.tinyStyle,
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
                                                          truncateText(capitalizeEachWord(newTicketModel.location ?? ''), 15),
                                                          style: AppTextStyles.tinyStyle,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                                )
                                              ],
                                            ),
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
                    }).toList(),
                  ),
                ),
              )
            : Center(child: Text('No data available'));
      },
    );
  }
}

class EventSearchScreenContent extends StatelessWidget {
  const EventSearchScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Explore events',
              style: AppTextStyles.mediumBold,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: GridView.count(
              shrinkWrap: true, // Agar grid hanya mengambil ruang yang dibutuhkan
              physics: NeverScrollableScrollPhysics(), // Menonaktifkan scroll pada GridView
              crossAxisCount: 2, // Menentukan jumlah kolom (2 kolom per baris)
              crossAxisSpacing: 12.0, // Jarak antar kolom
              mainAxisSpacing: 12.0, // Jarak antar baris
              childAspectRatio: 3 / 1, // Mengatur rasio lebar dan tinggi setiap item grid
              children: [
                buildEventRow(context, 'Bazaar', AppIcons.culinary),
                buildEventRow(context, 'Music', AppIcons.music),
                buildEventRow(context, 'Cultural', AppIcons.cultural),
                buildEventRow(context, 'Sport', AppIcons.sport),
                buildEventRow(context, 'Social', AppIcons.historical),
                buildEventRow(context, 'Education', AppIcons.education),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildDestinationRow(BuildContext context, String subcategory, IconData icon) {
  return GestureDetector(
    // onTap: () => fetchDataAndNavigate(context, category),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ListScreen(
            data: 'destinations', // Pastikan 'data' sesuai dengan tipe yang diperlukan oleh ListScreen
            subcategory: subcategory,
          ),
        ),
      );
    },
    child: MainCard(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.445,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subcategory,
              style: AppTextStyles.mediumBlack,
            ),
            Icon(icon),
          ],
        ),
      ),
    ),
  );
}

Widget buildEventRow(BuildContext context, String subcategory, IconData icon) {
  return GestureDetector(
    // onTap: () => fetchDataAndNavigate(context, category),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ListScreen(
            data: 'events', // Pastikan 'data' sesuai dengan tipe yang diperlukan oleh ListScreen
            subcategory: subcategory,
          ),
        ),
      );
    },
    child: MainCard(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.445,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subcategory,
              style: AppTextStyles.mediumBlack,
            ),
            Icon(icon),
          ],
        ),
      ),
    ),
  );
}
