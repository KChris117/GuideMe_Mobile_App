import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data'; // Menambahkan import untuk File
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:guideme/controllers/gallery_controller.dart';
import 'package:guideme/core/constants/colors.dart';
import 'package:guideme/core/constants/text_styles.dart';
import 'package:guideme/core/utils/auth_utils.dart';
import 'package:guideme/core/utils/text_utils.dart';
import 'package:guideme/models/gallery_model.dart';
import 'package:guideme/widgets/custom_navbar.dart';
import 'package:guideme/widgets/custom_button.dart';
import 'package:guideme/widgets/custom_sidebar.dart';
import 'package:guideme/widgets/custom_title.dart';

class GalleryManagementScreen extends StatefulWidget {
  const GalleryManagementScreen({super.key});

  @override
  _GalleryManagementScreenState createState() => _GalleryManagementScreenState();
}

class _GalleryManagementScreenState extends State<GalleryManagementScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String page = 'gallery';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: BurgerAppBar(scaffoldKey: scaffoldKey),
      drawer: CustomAdminSidebar(
        onLogout: () {
          handleLogout(context);
        },
      ),
      body: GalleryManagementScreenContent(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: AddButton(page),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: AdminBottomNavBar(selectedIndex: 4),
    );
  }
}

class GalleryManagementScreenContent extends StatelessWidget {
  final GalleryController _galleryController = GalleryController();

  GalleryManagementScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomTitle(firstText: 'Hi, Admin!', secondText: 'Design your data exactly how you want it'),
            ],
          ),
          SizedBox(height: 16),
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('galleries').orderBy('createdAt', descending: true).snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

              // Mengelompokkan data berdasarkan nama dan kategori
              Map<String, Map<String, List<GalleryModel>>> groupedByNameAndCategory = {};
              for (var doc in snapshot.data!.docs) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                GalleryModel newGalleryModel = GalleryModel.fromMap(data, doc.id);

                // Mengelompokkan berdasarkan nama
                if (groupedByNameAndCategory[newGalleryModel.name] == null) {
                  groupedByNameAndCategory[newGalleryModel.name] = {};
                }

                // Mengelompokkan berdasarkan kategori
                if (groupedByNameAndCategory[newGalleryModel.name]![newGalleryModel.category] == null) {
                  groupedByNameAndCategory[newGalleryModel.name]![newGalleryModel.category] = [];
                }

                groupedByNameAndCategory[newGalleryModel.name]![newGalleryModel.category]!.add(newGalleryModel);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: groupedByNameAndCategory.entries.map((nameEntry) {
                  String name = nameEntry.key;
                  Map<String, List<GalleryModel>> categories = nameEntry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categories.entries.map((categoryEntry) {
                      // String category = categoryEntry.key;
                      List<GalleryModel> galleries = categoryEntry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              capitalizeEachWord(name),
                              style: AppTextStyles.mediumBlackBold,
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 1 / 4.2, // Adjust height as needed for other content
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.horizontal,
                              itemCount: galleries.length,
                              itemBuilder: (context, index) {
                                final newGalleryModel = galleries[index];

                                // Tentukan padding untuk item pertama dan terakhir
                                EdgeInsetsGeometry padding = EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0); // Default padding

                                if (index == 0) {
                                  // Padding kiri 12 untuk data pertama
                                  padding = EdgeInsets.only(left: 12.0, right: 4.0, top: 8, bottom: 8);
                                } else if (index == galleries.length - 1) {
                                  // Padding kanan 12 untuk data terakhir
                                  padding = EdgeInsets.only(right: 12.0, left: 4.0, top: 8, bottom: 8);
                                }

                                return Padding(
                                  padding: padding,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 1 / 2, // Width for the image
                                    height: MediaQuery.of(context).size.height * 1 / 2, // Adjust height as needed for other content
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                          child: (!kIsWeb && newGalleryModel.imageUrl.startsWith('/'))
                                              ? Image.file(
                                                  File(newGalleryModel.imageUrl),
                                                  fit: BoxFit.cover,
                                                  width: MediaQuery.of(context).size.width * 1 / 2,
                                                  height: (MediaQuery.of(context).size.width * 1 / 2) * (2 / 3), // Maintain 3:2 ratio
                                                )
                                              : Image.network(
                                                  newGalleryModel.imageUrl,
                                                  fit: BoxFit.cover,
                                                  width: MediaQuery.of(context).size.width * 1 / 2,
                                                  height: (MediaQuery.of(context).size.width * 1 / 2) * (2 / 3), // Maintain 3:2 ratio
                                                ),
                                        ),
                                        // Menambahkan Row untuk posisi tombol Detail dan tombol Aksi
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Tombol Detail di pojok kiri
                                            IconButton(
                                              onPressed: () {
                                                // Menampilkan dialog dengan informasi lengkap
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      backgroundColor: AppColors.backgroundColor,
                                                      title: Text(capitalizeEachWord(newGalleryModel.name)),
                                                      content: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          // Menampilkan imageUrl sebagai teks
                                                          Text('Image URL: ${newGalleryModel.imageUrl}'),
                                                          SizedBox(height: 8),
                                                          Text('Category: ${newGalleryModel.category}'),
                                                          Text('Subcategory: ${newGalleryModel.subcategory}'),
                                                          Text('Uploaded At: ${newGalleryModel.createdAt.toDate()}'),
                                                        ],
                                                      ),
                                                      actions: [
                                                        MediumButton(
                                                          label: 'Close',
                                                          onPressed: () {
                                                            // Menutup dialog
                                                            Navigator.pop(context);
                                                          },
                                                        )
                                                      ],
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(5),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              icon: Icon(Icons.info, color: Colors.blue),
                                            ),
                                            // Tombol Action di pojok kanan
                                            Row(
                                              children: [
                                                EditButton(data: newGalleryModel, page: 'gallery'),
                                                SizedBox(width: 8),
                                                DeleteButton(
                                                  itemId: newGalleryModel.galleryId,
                                                  itemType: 'gallery',
                                                  controller: _galleryController,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      );
                    }).toList(),
                  );
                }).toList(),
              );
            },
          ),
          SizedBox(height: 60),
        ],
      ),
    );
  }
}
    // return Column(
    //   mainAxisAlignment: MainAxisAlignment.start,
    //   children: [
    //     Row(
    //       children: [
    //         CustomTitle(firstText: 'Hi, Admin!', secondText: 'Design your data exactly how you want it'),
    //       ],
    //     ),
    //     SizedBox(
    //       height: 16,
    //     ),
    //     Expanded(
    //       child: StreamBuilder(
    //         stream: FirebaseFirestore.instance.collection('galleries').snapshots(),
    //         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
    //           if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

    //           // Mengelompokkan data berdasarkan nama
    //           Map<String, List<GalleryModel>> groupedByName = {};
    //           for (var doc in snapshot.data!.docs) {
    //             Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    //             GalleryModel newGalleryModel = GalleryModel.fromMap(data, doc.id);

    //             // Kelompokkan berdasarkan name
    //             if (groupedByName[newGalleryModel.name] == null) {
    //               groupedByName[newGalleryModel.name] = [];
    //             }
    //             groupedByName[newGalleryModel.name]!.add(newGalleryModel);
    //           }

    //           return Column(
    //             children: [
    //               Expanded(
    //                 child: ListView.builder(
    //                   padding: const EdgeInsets.only(bottom: 60.0), // Tambahkan jarak bawah
    //                   itemCount: groupedByName.entries.length,
    //                   itemBuilder: (context, index) {
    //                     var entry = groupedByName.entries.toList()[index];
    //                     String name = entry.key; // Mendapatkan name untuk judul grup
    //                     List<GalleryModel> galleries = entry.value;

    //                     return Column(
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: [
    //                         // Judul untuk setiap grup berdasarkan name
    //                         Padding(
    //                           padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
    //                           child: Text(
    //                             capitalizeEachWord(name), // Menampilkan name sebagai title
    //                             style: AppTextStyles.bodyBlack.copyWith(fontWeight: FontWeight.bold),
    //                           ),
    //                         ),
    //                         // Membuat SingleChildScrollView untuk menggulir horizontal
    //                         SingleChildScrollView(
    //                           scrollDirection: Axis.horizontal,
    //                           child: Row(
    //                             children: galleries.map((newGalleryModel) {
    //                               return Padding(
    //                                 padding: const EdgeInsets.symmetric(horizontal: 12.0),
    //                                 child: SizedBox(
    //                                   width: MediaQuery.of(context).size.width * 1 - 24,
    //                                   child: Card(
    //                                     color: AppColors.backgroundColor,
    //                                     elevation: 3,
    //                                     shape: RoundedRectangleBorder(
    //                                       borderRadius: BorderRadius.circular(5),
    //                                     ),
    //                                     child: Column(
    //                                       children: [
    //                                         ClipRRect(
    //                                           borderRadius: BorderRadius.vertical(
    //                                             top: Radius.circular(5),
    //                                           ),
    //                                           child: newGalleryModel.imageUrl.startsWith('/')
    //                                               ? Image.file(
    //                                                   File(newGalleryModel.imageUrl),
    //                                                   fit: BoxFit.cover,
    //                                                   height: 150,
    //                                                   width: double.infinity,
    //                                                 )
    //                                               : Image.network(
    //                                                   newGalleryModel.imageUrl,
    //                                                   fit: BoxFit.cover,
    //                                                   height: 150,
    //                                                   width: double.infinity,
    //                                                 ),
    //                                         ),
    //                                         SizedBox(height: 4),
    //                                         Center(
    //                                           child: Text(
    //                                             capitalizeEachWord(newGalleryModel.name),
    //                                             style: AppTextStyles.mediumBlack.copyWith(fontWeight: FontWeight.bold),
    //                                           ),
    //                                         ),
    //                                         // Menambahkan Row untuk posisi tombol Detail dan tombol Aksi
    //                                         Row(
    //                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                                           children: [
    //                                             // Tombol Detail di pojok kiri
    //                                             TextButton(
    //                                               onPressed: () {
    //                                                 // Menampilkan dialog dengan informasi lengkap
    //                                                 showDialog(
    //                                                   context: context,
    //                                                   builder: (BuildContext context) {
    //                                                     return AlertDialog(
    //                                                       backgroundColor: AppColors.backgroundColor,
    //                                                       title: Text(capitalizeEachWord(newGalleryModel.name)),
    //                                                       content: Column(
    //                                                         crossAxisAlignment: CrossAxisAlignment.start,
    //                                                         mainAxisSize: MainAxisSize.min,
    //                                                         children: [
    //                                                           // Menampilkan imageUrl sebagai teks
    //                                                           Text('Image URL: ${newGalleryModel.imageUrl}'),
    //                                                           SizedBox(height: 8),
    //                                                           Text('Category: ${newGalleryModel.category}'),
    //                                                           Text('Subcategory: ${newGalleryModel.subcategory}'),
    //                                                           Text('Uploaded At: ${newGalleryModel.createdAt.toDate()}'),
    //                                                         ],
    //                                                       ),
    //                                                       actions: [
    //                                                         MediumButton(
    //                                                           label: 'Close',
    //                                                           onPressed: () {
    //                                                             // Menutup dialog
    //                                                             Navigator.pop(context);
    //                                                           },
    //                                                         )
    //                                                       ],
    //                                                       shape: RoundedRectangleBorder(
    //                                                         borderRadius: BorderRadius.circular(5),
    //                                                       ),
    //                                                     );
    //                                                   },
    //                                                 );
    //                                               },
    //                                               child: Text(
    //                                                 'Detail',
    //                                                 style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
    //                                               ),
    //                                             ),
    //                                             // Tombol Action di pojok kanan
    //                                             Padding(
    //                                               padding: const EdgeInsets.symmetric(horizontal: 8.0),
    //                                               child: Row(
    //                                                 children: [
    //                                                   EditButton(data: newGalleryModel, page: 'gallery'),
    //                                                   SizedBox(width: 8),
    //                                                   DeleteButton(
    //                                                     itemId: newGalleryModel.galleryId,
    //                                                     itemType: 'gallery',
    //                                                     controller: _galleryController,
    //                                                   ),
    //                                                 ],
    //                                               ),
    //                                             )
    //                                           ],
    //                                         ),
    //                                       ],
    //                                     ),
    //                                   ),
    //                                 ),
    //                               );
    //                             }).toList(),
    //                           ),
    //                         ),
    //                         SizedBox(height: 16), // Spasi antar grup
    //                       ],
    //                     );
    //                   },
    //                 ),
    //               ),
    //             ],
    //           );
    //         },
    //       ),
    //     ),
    //   ],
    // );

