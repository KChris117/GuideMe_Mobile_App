// import 'package:flutter/material.dart';
// import 'package:guideme/models/category_controller.dart';
// import 'package:guideme/widgets/admin_bottom_navbar.dart';

// class CreateCategoryScreen extends StatefulWidget {
//   const CreateCategoryScreen({super.key});

//   @override
//   _CreateCategoryScreenState createState() => _CreateCategoryScreenState();
// }

// class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
//   final CategoryController _categoryController = CategoryController();
//   final TextEditingController _categoryNameController = TextEditingController();

//   void _submitCategory() async {
//     String name = _categoryNameController.text.trim();

//     if (name.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Category name cannot be empty")),
//       );
//       return;
//     }

//     try {
//       await _categoryController.addCategory(name);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Category added successfully")),
//       );

//       // Kosongkan field setelah berhasil menyimpan
//       _categoryNameController.clear();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error adding category: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Category'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Form input untuk nama kategori
//             TextField(
//               controller: _categoryNameController,
//               decoration: InputDecoration(
//                 label: 'Category Name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             // Tombol untuk menyimpan kategori
//             ElevatedButton(
//               onPressed: _submitCategory,
//               child: Text('Add Category'),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: AdminBottomNavBar(selectedIndex: 3),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:guideme/controllers/category_controller.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/models/category_model.dart';
import 'package:guideme/widgets/custom_appbar.dart';
import 'package:guideme/widgets/custom_button.dart';
import 'package:guideme/widgets/custom_form.dart';
import 'package:guideme/widgets/custom_navbar.dart';
import 'package:guideme/widgets/custom_snackbar.dart';
import 'package:guideme/widgets/custom_title.dart';

class CreateCategoryScreen extends StatefulWidget {
  const CreateCategoryScreen({super.key});

  @override
  _CreateCategoryScreenState createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>(); // Kunci untuk Form
  final CategoryController _categoryController = CategoryController();
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _subCategoryNameController = TextEditingController();

  List<String> _subcategories = [];
  String? _selectedCategory;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Tambahkan listener untuk mendeteksi perubahan tab
    _tabController.addListener(() {
      setState(() {}); // Memanggil setState untuk memperbarui tampilan
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _submitCategory() async {
    String name = _categoryNameController.text.trim().toLowerCase();
    // Memeriksa apakah form valid
    if (_formKey.currentState!.validate()) {
      try {
        // Tambahkan kategori baru dengan subkategori kosong
        await _categoryController.addCategory(name, _subcategories);
        SuccessSnackBar.show(context, 'Category added successfully');
        _categoryNameController.clear();
        setState(() {
          _subcategories.clear(); // Reset subcategories after adding category
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error adding category: $e")),
        );
      }
      Navigator.pop(context);
      return; // Hentikan eksekusi jika ada kesalahan
    }
  }

  void _submitSubcategory() async {
    String subcategoryName = _subCategoryNameController.text.trim().toLowerCase();

    if (_formKey.currentState!.validate()) {
      try {
        // Memanggil addSubcategory dengan ID kategori yang dipilih
        await _categoryController.addSubcategory(_selectedCategory!, subcategoryName);
        SuccessSnackBar.show(context, 'Subcategory added successfully');
        _subCategoryNameController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error adding subcategory: $e")),
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(
        title: 'Back',
        bottom: TabBar(
          dividerColor: Colors.transparent,
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                children: [
                  Icon(AppIcons.category),
                  SizedBox(width: 8),
                  Text('Category'),
                ],
              ),
            ),
            Tab(
              child: Row(
                children: [
                  Icon(AppIcons.subcategory),
                  SizedBox(width: 8),
                  Text('Subcategory'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Tab pertama: Menambahkan kategori
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomFormTitle(firstText: 'Create Category', secondText: 'Design your data exactly how you want it.'),
                  // SizedBox(height: 16),
                  TextForm(
                    label: 'Category Name',
                    controller: _categoryNameController,
                    hintText: 'Enter category here..',
                    validator: (value) => value == null || value.isEmpty ? 'Category is required' : null,
                    onChanged: (value) {
                      _categoryNameController.value = TextEditingValue(
                        text: value.toLowerCase(),
                        selection: _categoryNameController.selection,
                      );
                    },
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),

            // Tab kedua: Menambahkan subkategori
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomFormTitle(firstText: 'Create Subcategory', secondText: 'Design your data exactly how you want it.'),
                  // Dropdown untuk memilih kategori
                  StreamBuilder<List<CategoryModel>>(
                    stream: _categoryController.getCategoriesList(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No categories available');
                      }

                      // Mendapatkan daftar kategori dengan id
                      List<CategoryModel> categories = snapshot.data!;

                      return DropdownCategory(
                        selectedCategory: _selectedCategory,
                        onChanged: (String? newValue) {
                          setState(() {
                            // Menyimpan ID kategori yang dipilih
                            _selectedCategory = newValue;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty ? 'Category is required' : null,
                        categories: categories,
                        label: 'Category', // Label untuk dropdown
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  TextForm(
                    label: 'Subcategory',
                    controller: _subCategoryNameController,
                    hintText: 'Enter subcategory here..',
                    validator: (value) => value == null || value.isEmpty ? 'Subcategory is required' : null,
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? MediumButton(
              label: 'Add Category',
              onPressed: _submitCategory,
            )
          : MediumButton(
              label: 'Add Subcategory',
              onPressed: _submitSubcategory,
            ),
      bottomNavigationBar: AdminBottomNavBar(selectedIndex: 3),
    );
  }
}
