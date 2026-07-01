import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/core/services/firebase_auth_service.dart';
import 'package:guideme/core/utils/text_utils.dart';
import 'package:guideme/models/destination_model.dart';
// import 'package:guideme/controllers/user_controller.dart';
import 'package:guideme/models/event_model.dart';
import 'package:guideme/widgets/custom_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:guideme/views/user/detail_screen.dart';

class ListScreen extends StatefulWidget {
  final dynamic data;
  final String? subcategory;
  const ListScreen({super.key, required this.data, this.subcategory});

  @override
  createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController searchController = TextEditingController();

  String _searchQuery = '';
  String collectionName = '';
  String subcategory = '';

  @override
  void initState() {
    super.initState();
    // _checkLoginStatus();
    collectionName = widget.data.toLowerCase();
    subcategory = widget.subcategory?.toLowerCase() ?? '';
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 4,
            ),
            CustomTitle(firstText: 'Hi, Tourist!', secondText: "Discover the ${widget.data} We've Selected for You"),
            SizedBox(
              height: 16,
            ),
            ListScreenContent(
              searchQuery: _searchQuery,
              subcategory: subcategory,
              collectionName: collectionName,
            ),
          ],
        ),
      ),
      bottomNavigationBar: UserBottomNavBar(selectedIndex: 0),
    );
  }
}

extension FirebaseQueryExtension on CollectionReference {
  Query applyQuery({String? subcategory, String? searchQuery}) {
    // Kondisi 1: Tidak ada subcategory dan tidak ada searchQuery
    if (subcategory == null || subcategory.isEmpty) {
      if (searchQuery == null || searchQuery.isEmpty) {
        // Kondisi: Tidak ada subcategory dan tidak ada searchQuery
        return this.orderBy('createdAt', descending: true);
      } else {
        // Kondisi: Tidak ada subcategory tapi ada searchQuery
        return this
            .where('status', isEqualTo: 'open')
            .where('name', isGreaterThanOrEqualTo: searchQuery)
            .where('name', isLessThanOrEqualTo: '$searchQuery\uf8ff')
            .orderBy('name'); // Cocok dengan kolom pencarian
      }
    } else {
      // Kondisi 2: Ada subcategory, tapi tidak ada searchQuery
      if (searchQuery == null || searchQuery.isEmpty) {
        return this.where('subcategory', isEqualTo: subcategory).orderBy('createdAt', descending: true);
      } else {
        // Kondisi 3: Ada subcategory dan ada searchQuery
        return this
            .where('status', isEqualTo: 'open')
            .where('subcategory', isEqualTo: subcategory)
            .where('name', isGreaterThanOrEqualTo: searchQuery)
            .where('name', isLessThanOrEqualTo: '$searchQuery\uf8ff')
            .orderBy('name'); // Cocok dengan kolom pencarian
      }
    }
  }
}

class ListScreenContent extends StatelessWidget {
  final String searchQuery;
  final String subcategory;
  final String collectionName;

  // Constructor accepting the parameters
  const ListScreenContent({
    Key? key,
    required this.searchQuery,
    required this.subcategory,
    required this.collectionName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
        // stream: searchQuery.isEmpty
        //     // Kondisi jika subcategory kosong
        //     ? (subcategory.isEmpty
        //         ? FirebaseFirestore.instance.collection(collectionName).orderBy('createdAt', descending: true).snapshots()
        //         : FirebaseFirestore.instance
        //             .collection(collectionName)
        //             .where('subcategory', isEqualTo: subcategory) // Menambah kondisi pencarian berdasarkan subcategory
        //             .orderBy('createdAt', descending: true)
        //             .snapshots())
        //     // Kondisi jika subcategory tidak kosong dan ada query pencarian
        //     : FirebaseFirestore.instance
        //         .collection(collectionName)
        //         .where('name', isGreaterThanOrEqualTo: searchQuery)
        //         .where('name', isLessThanOrEqualTo: '$searchQuery\uf8ff')
        //         .orderBy('name') // Cocok dengan kolom pencarian
        //         .snapshots(),
        stream: FirebaseFirestore.instance.collection(collectionName).applyQuery(subcategory: subcategory, searchQuery: searchQuery).snapshots(),

        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // if (!snapshot.hasData) {
          //   return Center(child: CircularProgressIndicator());
          // }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No destinations found in this category', // Teks ketika tidak ada data
                style: AppTextStyles.bodyBold,
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: GridView.builder(
              shrinkWrap: true, // Agar GridView tidak memakan ruang lebih
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Dua card per baris
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                // childAspectRatio: 0.9,
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                // Model sesuai dengan koleksi yang diterima
                var newDataModel;
                if (collectionName == 'destinations') {
                  newDataModel = DestinationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                } else if (collectionName == 'events') {
                  newDataModel = EventModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(data: newDataModel, collectionName: collectionName),
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
                          ),
                          child: (!kIsWeb && newDataModel.imageUrl.startsWith('/'))
                              ? Image.file(
                                  File(newDataModel.imageUrl),
                                  fit: BoxFit.cover,
                                  height: 100,
                                  width: double.infinity,
                                )
                              : Image.network(
                                  newDataModel.imageUrl,
                                  fit: BoxFit.cover,
                                  height: 100,
                                  width: double.infinity,
                                ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 3,
                              child: Text(
                                truncateText(capitalizeEachWord(newDataModel.name), 15),
                                style: AppTextStyles.mediumBold,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(AppIcons.rating, size: 16),
                                SizedBox(width: 2),
                                Text(
                                  '${newDataModel.rating}',
                                  style: AppTextStyles.mediumBold,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              truncateText(capitalizeEachWord(newDataModel.location), 15),
                              style: AppTextStyles.smallGrey,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              newDataModel.price == 0
                                  ? 'Free' // Jika rating = 0, tampilkan "Free"
                                  : 'Rp ${NumberFormat('#,##0', 'id_ID').format(newDataModel.price)}', // Jika rating != 0, tampilkan harga
                              style: AppTextStyles.smallBold,
                            ),

                            // SmallButton(
                            //   onPressed: () {
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (context) => DetailScreen(data: newDataModel),
                            //         // builder: (context) => DetailScreen(data: collectionName, id: doc.id),
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
                );
              },
            ),
          );
        },
      ),
    );
  }
}
