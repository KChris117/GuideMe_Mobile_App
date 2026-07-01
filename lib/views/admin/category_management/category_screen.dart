// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:guideme/controllers/category_controller.dart';
// import 'package:guideme/models/category_model.dart';
// import 'package:guideme/views/admin/category_management/create_category_screen.dart';
// import 'package:guideme/widgets/admin_bottom_navbar.dart';
// import 'package:guideme/widgets/widgets.dart';

// class CategoryManagementScreen extends StatefulWidget {
//   const CategoryManagementScreen({super.key});

//   @override
//   _CategoryScreenState createState() => _CategoryScreenState();
// }

// class _CategoryScreenState extends State<CategoryManagementScreen> {
//   final CategoryController _categoryController = CategoryController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Category Management"),
//       ),
//       body: CategoryScreenContent(),
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(bottom: 80.0),
//         child: AddCategoryButton(),
//       ),
//       floatingActionButtonLocation:
//           FloatingActionButtonLocation.endDocked, // Posisi di kanan bawah
//       bottomNavigationBar: AdminBottomNavBar(selectedIndex: 3),
//     );
//   }
// }

// // Widget terpisah untuk konten CategoryManagementScreen
// class CategoryScreenContent extends StatelessWidget {
//   final CategoryController _categoryController = CategoryController();

//   CategoryScreenContent({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: FirebaseFirestore.instance.collection('categories').snapshots(),
//       builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (!snapshot.hasData) {
//           return Center(child: CircularProgressIndicator());
//         }

//         return ListView.builder(
//           itemCount: snapshot.data!.docs.length,
//           itemBuilder: (context, index) {
//             var doc = snapshot.data!.docs[index];
//             Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//             CategoryModel category = CategoryModel.fromMap(data, doc.id);

//             return Padding(
//               padding: EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 5.0),
//               child: Card(
//                 elevation: 5,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: ListTile(
//                   contentPadding: EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 5.0),
//                   title: Text(category.name),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize
//                         .min, // Agar tombol tidak melebar memenuhi ruang
//                     children: [
//                       // Tombol Delete (merah)
//                       FloatingActionButton(
//                         onPressed: () async {
//                           bool? confirmDelete = await showDialog(
//                             context: context,
//                             builder: (context) {
//                               return AlertDialog(
//                                 title: Text('Delete Category'),
//                                 content: Text(
//                                     'Are you sure you want to delete this category?'),
//                                 actions: [
//                                   TextButton(
//                                     onPressed: () =>
//                                         Navigator.of(context).pop(false),
//                                     child: Text('Cancel'),
//                                   ),
//                                   TextButton(
//                                     onPressed: () =>
//                                         Navigator.of(context).pop(true),
//                                     child: Text('Delete'),
//                                   ),
//                                 ],
//                               );
//                             },
//                           );

//                           // if (confirmDelete == true) {
//                           //   await _categoryController.deleteCategory(
//                           //       category.id);
//                           // }
//                         },
//                         mini: true, // Membuat ukuran tombol lebih kecil
//                         backgroundColor: Colors.red, // Warna merah untuk Delete
//                         child: Icon(Icons.delete,
//                             color: Colors.white), // Ikon delete berwarna putih
//                       ),

//                       // DeleteCategoryButton(
//                       //   categoryId: category.dokumentId, // Mengirimkan eventId ke widget DeleteButton
//                       //   categoryController:
//                       //       _categoryController, // Mengirimkan controller ke widget DeleteButton
//                       // ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/controllers/category_controller.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/core/utils/auth_utils.dart';
import 'package:guideme/models/category_model.dart';
import 'package:guideme/widgets/custom_sidebar.dart';
// import 'package:guideme/views/admin/category_management/create_category_screen.dart';
// import 'package:guideme/widgets/custom_navbar.dart';
import 'package:guideme/widgets/widgets.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryManagementScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String page = 'category';

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
      body: CategoryScreenContent(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 140.0),
        child: AddButton(page),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked, // Posisi di kanan bawah
      bottomNavigationBar: AdminBottomNavBar(selectedIndex: 3),
    );
  }
}

// Widget terpisah untuk konten CategoryManagementScreen
class CategoryScreenContent extends StatelessWidget {
  final CategoryController _categoryController = CategoryController();

  CategoryScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTitle(
                  firstText: 'Hi, Admin!',
                  secondText: 'Design your data exactly how you want it',
                ),
                SizedBox(
                  height: 16,
                )
              ],
            ),
          ),
        ];
      },
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              CategoryModel category = CategoryModel.fromMap(data, doc.id);

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Card(
                  elevation: 5,
                  color: AppColors.backgroundColor, // Background untuk card
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ExpansionTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    iconColor: AppColors.primaryColor, // Warna ikon saat tile aktif
                    backgroundColor: AppColors.backgroundColor,
                    title: Text(category.name),
                    leading: Icon(AppIcons.category),
                    children: [
                      // Menampilkan subkategori saat kategori diklik
                      if (category.subcategories.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 50.0),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: category.subcategories.length,
                            itemBuilder: (context, subIndex) {
                              return Row(
                                children: [
                                  Icon(
                                    AppIcons.subcategory,
                                    size: 12,
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      title: Text(category.subcategories[subIndex]),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      // Tombol Hapus Kategori
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            DeleteButton(
                              itemId: category.categoryId,
                              itemType: 'category',
                              controller: _categoryController,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
