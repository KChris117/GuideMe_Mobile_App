import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:double_back_to_exit/double_back_to_exit.dart';
import 'package:flutter/material.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/core/services/firebase_auth_service.dart';
import 'package:guideme/core/utils/auth_utils.dart';
import 'package:guideme/core/utils/search_utils.dart';
import 'package:guideme/core/utils/text_utils.dart';
import 'package:guideme/widgets/custom_sidebar.dart';
import 'package:guideme/widgets/widgets.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController searchController = TextEditingController();
  final FirebaseAuthService _auth = FirebaseAuthService();

  List<Map<String, dynamic>> galleries = [];
  Map<String, List<Map<String, dynamic>>> groupedGalleries = {};

  bool _isLoggedIn = false;
  // String _searchQuery = '';
  List<Map<String, dynamic>> searchResults = [];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchGalleries();
  }

  // Memeriksa status login dan memperbarui state
  Future<void> _checkLoginStatus() async {
    bool loggedIn = await _auth.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  // Fetch galleries from Firestore and group by 'name'
  Future<void> _fetchGalleries() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('galleries').get();

    setState(() {
      galleries = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      // Group galleries by 'name'
      groupedGalleries = {};
      for (var gallery in galleries) {
        String name = gallery['name'] ?? 'Unknown';
        if (!groupedGalleries.containsKey(name)) {
          groupedGalleries[name] = [];
        }
        groupedGalleries[name]?.add(gallery);
      }
    });
  }

  // Fungsi untuk menangani perubahan pencarian
  void search(String query) async {
    List<Map<String, dynamic>> results = await searchGalleries(query);
    setState(() {
      searchResults = results; // Update hasil pencarian
    });
  }

  @override
  Widget build(BuildContext context) {
    return DoubleBackToExit(
      snackBarMessage: 'Press back again to exit',
      child: Scaffold(
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
            color: Colors.white,
            alignment: Alignment.topLeft,
            // padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 4,
                ),
                CustomTitle(
                  firstText: 'Hi, Tourist!',
                  secondText: "Discover the Gallery We've Selected for You",
                ),
                SizedBox(
                  height: 16,
                ),
                ..._buildGalleryRows(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: UserBottomNavBar(selectedIndex: 3),
      ),
    );
  }

  // Fungsi untuk membangun baris galeri
  List<Widget> _buildGalleryRows() {
    List<Map<String, dynamic>> galleriesToDisplay = searchResults.isEmpty ? galleries : searchResults;

    Map<String, List<Map<String, dynamic>>> groupedGalleries = {};

    for (var gallery in galleriesToDisplay) {
      final name = capitalizeEachWord(gallery['name'] as String? ?? 'Unknown');
      if (!groupedGalleries.containsKey(name)) {
        groupedGalleries[name] = [];
      }
      groupedGalleries[name]!.add(gallery);
    }

    return groupedGalleries.entries.map((entry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(entry.key, style: AppTextStyles.mediumBold),
          ),
          // const SizedBox(height: 10),
          Container(
            height: 120,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              itemCount: entry.value.length,
              itemBuilder: (context, index) {
                final imageUrl = entry.value[index]['imageUrl'] as String? ?? '';
                // Tentukan padding untuk item pertama dan terakhir
                EdgeInsetsGeometry padding = EdgeInsets.symmetric(vertical: 8.0, horizontal: 4); // Default padding

                if (index == 0) {
                  // Padding kiri 16 untuk data pertama
                  padding = EdgeInsets.only(left: 16.0, right: 4.0, top: 8, bottom: 8);
                } else if (index == entry.value.length - 1) {
                  // Padding kanan 16 untuk data terakhir
                  padding = EdgeInsets.only(right: 16.0, left: 4.0, top: 8, bottom: 8);
                }

                return GestureDetector(
                  onTap: () {
                    // Tampilkan gambar dengan ukuran penuh
                    showDialog(
                      context: context,
                      builder: (context) => ZoomImage(imageUrl: imageUrl),
                    );
                  },
                  child: Padding(
                    padding: padding,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        // width: 100,
                        width: MediaQuery.of(context).size.width * 0.4, // Lebar mengikuti layar
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.broken_image, size: 100);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    }).toList();
  }
}

class ZoomImage extends StatelessWidget {
  final String imageUrl;

  const ZoomImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop(); // Menutup modal saat area di luar gambar diklik
        },
        child: FutureBuilder(
          future: _getImageSize(imageUrl),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return const Center(child: Icon(Icons.broken_image, size: 100));
            }

            // final aspectRatio = snapshot.data as double;

            return SizedBox(
              width: MediaQuery.of(context).size.width, // Lebar mengikuti layar
              child: Image.network(
                imageUrl,
                fit: BoxFit.fitWidth, // Menyesuaikan lebar gambar dengan lebar layar
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.broken_image, size: 100));
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // Fungsi untuk mendapatkan ukuran gambar (lebar dan tinggi) dan menghitung aspect ratio
  Future<double> _getImageSize(String imageUrl) async {
    final image = NetworkImage(imageUrl);
    final Completer<ImageInfo> completer = Completer();
    final ImageStream stream = image.resolve(const ImageConfiguration());
    stream.addListener(ImageStreamListener((ImageInfo info, bool synchronousCall) {
      completer.complete(info);
    }));
    final imageInfo = await completer.future;
    final width = imageInfo.image.width.toDouble();
    final height = imageInfo.image.height.toDouble();
    return width / height; // Menghitung aspect ratio
  }
}


























//   List<Widget> _buildGalleryRows() {
//     Map<String, List<Map<String, dynamic>>> groupedGalleries = {};

//     // Mengelompokkan gambar berdasarkan 'name'
//     for (var gallery in galleries) {
//       final name = capitalizeEachWord(gallery['name'] as String? ?? 'Unknown');
//       if (!groupedGalleries.containsKey(name)) {
//         groupedGalleries[name] = [];
//       }
//       groupedGalleries[name]!.add(gallery);
//     }

//     // Membuat widget List berdasarkan kelompok
//     return groupedGalleries.entries.map((entry) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             entry.key,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             height: 120, // Sesuaikan tinggi ListView
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: entry.value.length,
//               itemBuilder: (context, index) {
//                 final imageUrl = entry.value[index]['imageUrl'] as String? ?? '';
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10.0),
//                     child: Image.network(
//                       imageUrl,
//                       fit: BoxFit.cover,
//                       width: 100,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Icon(Icons.broken_image, size: 100);
//                       },
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           const SizedBox(height: 20),
//         ],
//       );
//     }).toList();
//   }