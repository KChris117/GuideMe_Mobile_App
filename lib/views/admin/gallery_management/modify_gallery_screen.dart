import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:guideme/controllers/gallery_controller.dart';
import 'package:guideme/controllers/category_controller.dart';
import 'package:guideme/models/gallery_model.dart';
import 'package:guideme/widgets/custom_appbar.dart';
import 'package:guideme/widgets/custom_button.dart';
import 'package:guideme/widgets/custom_form.dart';
import 'package:guideme/widgets/custom_navbar.dart';
import 'package:guideme/widgets/custom_snackbar.dart';
import 'package:guideme/widgets/custom_title.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModifyGalleryManagementScreen extends StatefulWidget {
  final GalleryModel galleryModel;

  const ModifyGalleryManagementScreen({Key? key, required this.galleryModel}) : super(key: key);

  @override
  _ModifyGalleryManagementScreenState createState() => _ModifyGalleryManagementScreenState();
}

class _ModifyGalleryManagementScreenState extends State<ModifyGalleryManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(); // Tambahkan Controller
  final GalleryController _galleryController = GalleryController();
  final CategoryController _categoryController = CategoryController();

  late ValueNotifier<String> descriptionNotifier;
  late ValueNotifier<GalleryModel> galleryNotifier;
  late TextEditingController _descriptionController;

  String? selectedCategory;
  String? selectedSubcategory;
  String? selectedName;
  String? imageUrl;
  File? imageFile;
  Uint8List? _imageBytes;
  String? description;
  bool? existingMainImage;

  @override
  void initState() {
    super.initState();
    galleryNotifier = ValueNotifier(widget.galleryModel);
    descriptionNotifier = ValueNotifier(widget.galleryModel.description.toString());

    selectedCategory = widget.galleryModel.category;
    selectedSubcategory = widget.galleryModel.subcategory;
    selectedName = widget.galleryModel.name;
    imageUrl = widget.galleryModel.imageUrl;
    _descriptionController = TextEditingController(text: widget.galleryModel.description);
    print(imageUrl);
    existingMainImage = widget.galleryModel.mainImage;

    // _nameController.text = widget.galleryModel.name ?? ''; // Inisialisasi nama
  }

  @override
  void dispose() {
    _nameController.dispose(); // Hapus controller
    galleryNotifier.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        try { imageFile = File(pickedFile.path); } catch(e) {}
        _imageBytes = bytes;
          imageUrl = null; // Reset URL jika file baru dipilih
        });
    }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<String?> _uploadImage(String name, String category) async {
    if (_imageBytes == null) return imageUrl;

    final sanitizedFileName = '${name}_gallery_${category}_${DateTime.now().millisecondsSinceEpoch}'.replaceAll(' ', '_');
    final path = 'uploads/$sanitizedFileName';

    try {
      final uploadPath = await Supabase.instance.client.storage.from('images').uploadBinary(path, _imageBytes!);

      if (uploadPath.isNotEmpty) {
        final publicUrl = Supabase.instance.client.storage.from('images').getPublicUrl(path);
        if (publicUrl.isNotEmpty) {
          return publicUrl;
        } else {
          throw Exception('Failed to retrieve public URL.');
        }
      } else {
        throw Exception('Upload failed: No valid upload path returned.');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $error')),
      );
      return null;
    }
  }

  Future<void> _saveChanges() async {
    FocusScope.of(context).unfocus(); // Tutup keyboard
    if (!_formKey.currentState!.validate()) return;

    // final name = _nameController.text.trim();
    final name = selectedName ?? 'Default name';
    final category = selectedCategory ?? 'Uncategorized';

    // Upload image jika ada file baru
    final finalImageUrl = await _uploadImage(name, category);

    if (finalImageUrl == null) return; // Hentikan proses jika upload gagal
    // var exisitingMainImage = widget.galleryModel.mainImage;

    // Update data galeri
    final updatedGallery = galleryNotifier.value.copyWith(
      name: name,
      category: selectedCategory,
      subcategory: selectedSubcategory,
      imageUrl: finalImageUrl,
      description: _descriptionController.text,
      mainImage: existingMainImage != true ? false : existingMainImage,
    );

    try {
      await _galleryController.updateGallery(updatedGallery);
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text('Gallery updated successfully'),
      // ));
      SuccessSnackBar.show(context, 'Gallery updated successfully', duration: Duration(seconds: 1));
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to save changes: $e')),
      // );
      DangerSnackBar.show(context, 'Failed to save changes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(title: 'back'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomFormTitle(firstText: 'Modify Gallery', secondText: 'Design your data exactly how you want it.'),
                // Dropdown untuk memilih kategori
                StreamBuilder<List<String>>(
                  stream: _categoryController.getCategories(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    return TextDropdown(
                      label: 'Category',
                      items: snapshot.data ?? [],
                      value: selectedCategory,
                      onChanged: existingMainImage == true
                          ? null
                          : (value) {
                              setState(() {
                                selectedCategory = value; // Simpan kategori yang dipilih
                                selectedSubcategory = null; // Reset subkategori
                                selectedName = null; // Reset name
                              });
                            },
                    );
                  },
                ),
                SizedBox(height: 16),

                // Dropdown untuk memilih subkategori
                if (selectedCategory != null)
                  StreamBuilder<List<String>>(
                    stream: _categoryController.getSubcategories(selectedCategory!),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      return TextDropdown(
                        label: 'Subcategory',
                        items: snapshot.data ?? [],
                        value: selectedSubcategory,
                        onChanged: existingMainImage == true
                            ? null
                            : (value) {
                                setState(() {
                                  selectedSubcategory = value;
                                });
                              },
                      );
                    },
                  ),
                SizedBox(height: selectedCategory != null ? 16 : 0),

                // Dropdown untuk memuat dokumen berdasarkan kategori
                if (selectedCategory != null)
                  StreamBuilder<List<String>>(
                    stream: _galleryController.getNamesByCategory(selectedCategory!),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      return TextDropdown(
                        label: 'Name',
                        items: snapshot.data ?? [],
                        value: selectedName,
                        onChanged: existingMainImage == true
                            ? null
                            : (value) {
                                setState(() {
                                  selectedName = value; // Simpan nama yang dipilih
                                });
                              },
                      );
                    },
                  ),
                SizedBox(height: selectedCategory != null ? 16 : 0),

                ValueListenableBuilder<String>(
                  valueListenable: descriptionNotifier,
                  builder: (context, description, _) {
                    return TextArea(
                      controller: _descriptionController,
                      label: 'Gallery description',
                      onChanged: existingMainImage == true
                          ? null // Disable onChanged jika existingMainImage true
                          : (value) => descriptionNotifier.value = value,
                      validator: (value) => value == null || value.isEmpty ? 'description is required' : null,
                    );
                  },
                ),
                SizedBox(height: 16),

                NewUploadImageWithPreview(
                  imageFile: imageFile,
                  imageBytes: _imageBytes,
                  imageUrl: imageUrl ?? '',
                  onPressed: _pickImage,
                ),
                SizedBox(height: 60),
                // LargeButton(
                //   onPressed: _saveChanges,
                //   label: 'Save Changes',
                // ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: MediumButton(
        onPressed: _saveChanges,
        label: 'Save Changes',
      ),
      bottomNavigationBar: AdminBottomNavBar(selectedIndex: 4),
    );
  }
}































// import 'package:flutter/material.dart';
// import 'package:guideme/controllers/gallery_controller.dart';
// import 'package:guideme/controllers/category_controller.dart';
// import 'package:guideme/models/gallery_model.dart';
// import 'package:guideme/widgets/custom_button.dart';
// import 'package:guideme/widgets/custom_form.dart';
// // import 'package:guideme/widgets/upload_image_with_preview.dart';

// class ModifyGalleryManagementScreen extends StatefulWidget {
//   final GalleryModel galleryModel;

//   const ModifyGalleryManagementScreen({Key? key, required this.galleryModel}) : super(key: key);

//   @override
//   _ModifyGalleryManagementScreenState createState() => _ModifyGalleryManagementScreenState();
// }

// class _ModifyGalleryManagementScreenState extends State<ModifyGalleryManagementScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final GalleryController _galleryController = GalleryController();
//   final CategoryController _categoryController = CategoryController();

//   late ValueNotifier<GalleryModel> galleryNotifier;

//   String? selectedCategory;
//   String? selectedSubcategory;
//   String? imageUrl; // Variabel untuk menyimpan URL gambar yang dipilih

//   @override
//   void initState() {
//     super.initState();
//     galleryNotifier = ValueNotifier(widget.galleryModel);

//     selectedCategory = widget.galleryModel.category;
//     selectedSubcategory = widget.galleryModel.subcategory;
//     imageUrl = widget.galleryModel.imageUrl; // Inisialisasi gambar awal
//   }

//   @override
//   void dispose() {
//     galleryNotifier.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImage() async {
//     String? imagePath = await _galleryController.pickImage();
//     if (imagePath != null) {
//       setState(() {
//         imageUrl = imagePath;
//       });
//     }
//   }

//   Future<void> _saveChanges() async {
//     if (_formKey.currentState!.validate()) {
//       GalleryModel updatedGallery = galleryNotifier.value.copyWith(
//         category: selectedCategory,
//         subcategory: selectedSubcategory,
//         imageUrl: imageUrl, // Simpan URL gambar baru
//       );

//       await _galleryController.updateGallery(updatedGallery);
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Modify Gallery'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ValueListenableBuilder<GalleryModel>(
//                   valueListenable: galleryNotifier,
//                   builder: (context, galleryModel, child) {
//                     return Column(
//                       children: [
//                         TextFormField(
//                           initialValue: galleryModel.name,
//                           decoration: InputDecoration(label: 'Gallery Name'),
//                           onChanged: (value) => galleryModel.name = value,
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return 'Please enter a name';
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: 16),
//                         StreamBuilder<List<String>>(
//                           stream: _categoryController.getCategories(),
//                           builder: (context, snapshot) {
//                             if (!snapshot.hasData) {
//                               return CircularProgressIndicator();
//                             }
//                             return TextDropdown(
//                               label: 'Category',
//                               items: snapshot.data!,
//                               value: selectedCategory,
//                               onChanged: (value) {
//                                 setState(() {
//                                   selectedCategory = value;
//                                   selectedSubcategory = null;
//                                 });
//                               },
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please select a category';
//                                 }
//                                 return null;
//                               },
//                             );
//                           },
//                         ),
//                         SizedBox(height: 16),
//                         if (selectedCategory != null)
//                           StreamBuilder<List<String>>(
//                             stream: _categoryController.getSubcategories(selectedCategory!),
//                             builder: (context, snapshot) {
//                               if (!snapshot.hasData) {
//                                 return CircularProgressIndicator();
//                               }
//                               return TextDropdown(
//                                 label: 'Subcategory',
//                                 items: snapshot.data!,
//                                 value: selectedSubcategory,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     selectedSubcategory = value;
//                                   });
//                                 },
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Please select a subcategory';
//                                   }
//                                   return null;
//                                 },
//                               );
//                             },
//                           ),
//                         SizedBox(height: 16),
//                         UploadImageWithPreview(
//                           imageUrl: imageUrl ?? '',
//                           onPressed: _pickImage,
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//                 SizedBox(height: 16),
//                 LargeButton(
//                   onPressed: _saveChanges,
//                   label: 'Save Changes',
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// Pilih gambar dari galeri
// Future<void> _pickImage() async {
//   final ImagePicker picker = ImagePicker();
//   final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

//   if (pickedFile != null) {
//     setState(() {
//       try { imageFile = File(pickedFile.path); } catch(e) {}
//     });
//   }
// }

// Unggah gambar ke Supabase
// Future<void> _uploadImage() async {
//   if (_imageBytes == null) return;

//   final fileName = DateTime.now().millisecondsSinceEpoch.toString();
//   final path = 'uploads/$fileName';

//   final response = await Supabase.instance.client.storage.from('images').uploadBinary(path, _imageBytes!);

//   if (response.error == null) {
//     final imageUrlResponse = await Supabase.instance.client.storage.from('images').getPublicUrl(path);
//     setState(() {
//       imageUrl = imageUrlResponse.data!;
//     });
//   } else {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Failed to upload image.')),
//     );
//   }
// }

// Simpan perubahan galeri
// Future<void> _saveChanges() async {
//   if (_formKey.currentState!.validate()) {
//     if (imageFile != null) {
//       await _uploadImage(); // Unggah gambar baru jika dipilih
//     }

//     GalleryModel updatedGallery = galleryNotifier.value.copyWith(
//       category: selectedCategory,
//       subcategory: selectedSubcategory,
//       imageUrl: imageUrl,
//     );

//     await _galleryController.updateGallery(updatedGallery);
//     Navigator.pop(context);
//   }
// }