// import 'dart:io';
import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:guideme/controllers/category_controller.dart';
// import 'package:guideme/controllers/gallery_controller.dart';
// import 'package:guideme/models/gallery_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:guideme/widgets/custom_form.dart';
// import 'package:guideme/widgets/custom_button.dart';
// import 'package:image_picker/image_picker.dart';

// import 'package:supabase_flutter/supabase_flutter.dart';

// class CreateGalleryManagementScreen extends StatefulWidget {
//   const CreateGalleryManagementScreen({super.key});

//   @override
//   _CreateGalleryManagementScreenState createState() => _CreateGalleryManagementScreenState();
// }

// class _CreateGalleryManagementScreenState extends State<CreateGalleryManagementScreen> {
//   final GalleryController _galleryController = GalleryController();
//   final CategoryController _categoryController = CategoryController();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();

//   String _imageUrl = '';
//   String? selectedCategory;
//   String? selectedSubcategory;

//   // Fungsi untuk memilih gambar dan memperbarui UI
//   Future<void> _pickImage() async {
//     String? imagePath = await _galleryController.pickImage();
//     if (imagePath != null) {
//       setState(() {
//         _imageUrl = imagePath;
//       });
//     }
//   }

//   // Fungsi untuk menyimpan galeri ke Firestore
//   Future<void> _saveGallery() async {
//     if (_nameController.text.isNotEmpty && _descriptionController.text.isNotEmpty && _imageUrl.isNotEmpty) {
//       File imageFile = File(_imageUrl);

//       // Menyimpan gambar secara lokal terlebih dahulu
//       String localImagePath = await _galleryController.saveImageLocally(imageFile);

//       // Membuat objek GalleryModel dengan path gambar lokal
//       GalleryModel newGallery = GalleryModel(
//         galleryId: '',
//         name: _nameController.text,
//         category: selectedCategory!,
//         subcategory: selectedSubcategory!,
//         description: _descriptionController.text,
//         imageUrl: localImagePath,
//         createdAt: Timestamp.now(),
//       );

//       // Menyimpan atau memperbarui galeri ke Firestore
//       await _galleryController.addGallery(newGallery);

//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Please fill all fields and upload an image.'),
//       ));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Create New Gallery')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               //nama galeri
//               CustomTextField(
//                 controller: _nameController,
//                 label: 'Name',
//               ),
//               SizedBox(height: 16),

//               // Dropdown untuk memilih category
//               StreamBuilder<List<String>>(
//                 stream: _categoryController.getCategories(), // Aliran kategori
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return CircularProgressIndicator();
//                   }
//                   return CustomDropdown(
//                     label: 'Category',
//                     items: snapshot.data!, // Menggunakan data kategori yang diterima
//                     onChanged: (value) {
//                       setState(() {
//                         selectedCategory = value;
//                         selectedSubcategory = null; // Reset subcategory ketika kategori berubah
//                       });
//                     },
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please select a category';
//                       }
//                       return null;
//                     },
//                   );
//                 },
//               ),
//               SizedBox(height: 16),

//               // Dropdown untuk memilih subcategory berdasarkan kategori yang dipilih
//               if (selectedCategory != null)
//                 StreamBuilder<List<String>>(
//                   stream: _categoryController.getSubcategories(selectedCategory!), // Ambil subcategories berdasarkan kategori
//                   builder: (context, snapshot) {
//                     if (!snapshot.hasData) {
//                       return CircularProgressIndicator();
//                     }
//                     return CustomDropdown(
//                       label: 'Subcategory',
//                       items: snapshot.data!, // Menggunakan subcategories yang diterima
//                       onChanged: (value) {
//                         setState(() {
//                           selectedSubcategory = value;
//                         });
//                       },
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please select a subcategory';
//                         }
//                         return null;
//                       },
//                     );
//                   },
//                 ),
//               SizedBox(height: 16),

//               //deskripsi galeri
//               CustomTextField(
//                 controller: _descriptionController,
//                 label: 'Description',
//               ),
//               SizedBox(height: 16),

//               // UploadImageWithPreview(
//               //   imageUrl: _imageUrl, // Gantilah dengan URL gambar yang dipilih
//               //   onPressed: _pickImage, // Fungsi untuk memilih gambar
//               // ),

//               // LargeButton(
//               //   onPressed: _saveGallery,
//               //   label: 'Save Gallery',
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:guideme/controllers/category_controller.dart';
import 'package:guideme/controllers/gallery_controller.dart';
import 'package:guideme/controllers/ticket_controller.dart';
import 'package:guideme/models/gallery_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/widgets/custom_appbar.dart';
import 'package:guideme/widgets/custom_form.dart';
import 'package:guideme/widgets/custom_button.dart';
import 'package:guideme/widgets/custom_navbar.dart';
import 'package:guideme/widgets/custom_snackbar.dart';
import 'package:guideme/widgets/custom_title.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateGalleryManagementScreen extends StatefulWidget {
  const CreateGalleryManagementScreen({super.key});

  @override
  _CreateGalleryManagementScreenState createState() => _CreateGalleryManagementScreenState();
}

class _CreateGalleryManagementScreenState extends State<CreateGalleryManagementScreen> {
  final GalleryController _galleryController = GalleryController();
  final CategoryController _categoryController = CategoryController();
  // final TicketController _ticketController = TicketController();

  final TextEditingController _descriptionController = TextEditingController();

  String _imageUrl = ''; // Menyimpan URL gambar yang sudah diunggah
  String? selectedCategory;
  String? selectedName;
  String? selectedSubcategory;
  String? selectedRecommendationId;

  File? _imageFile;
  Uint8List? _imageBytes;

  // Fungsi untuk memilih gambar
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        try { _imageFile = File(pickedFile.path); } catch(e) {}
        _imageBytes = bytes; // Menyimpan file gambar yang dipilih
      });
    }
  }

  // Fungsi untuk mengunggah gambar ke Supabase
  Future uploadImage() async {
    if (_imageBytes == null) return;

    // Ambil teks dari field 'name' dan buat format nama file
    final name = selectedName;
    final category = selectedCategory ?? 'uncategorized';

    // if (name.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Please provide a name before uploading.')),
    //   );
    //   return;
    // }

    final fileName = '${name}_gallery_${category}_${DateTime.now().millisecondsSinceEpoch}';
    final path = 'uploads/$fileName';

    try {
      // Mengunggah gambar ke Supabase
      final uploadPath = await Supabase.instance.client.storage.from('images').uploadBinary(path, _imageBytes!);

      if (uploadPath.isNotEmpty) {
        // Mendapatkan URL publik untuk gambar yang diunggah
        final publicUrl = Supabase.instance.client.storage.from('images').getPublicUrl(path);

        if (publicUrl.isNotEmpty) {
          setState(() {
            _imageUrl = publicUrl; // Simpan URL publik ke variabel
          });

          // Simpan data galeri setelah berhasil mengunggah
          _saveGallery();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to retrieve public URL for the image.')),
          );
        }
      } else {
        throw Exception('Upload failed: No valid upload path returned.');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $error')),
      );
    }
  }

  // Fungsi untuk menyimpan galeri ke Firestore
  Future<void> _saveGallery() async {
    FocusScope.of(context).unfocus(); // Tutup keyboard
    if (selectedCategory == null || selectedSubcategory == null || selectedName == null || _imageUrl.isEmpty) {
      DangerSnackBar.show(context, 'Please fill all fields and upload an image.');
    }

    GalleryModel newGalleryModel = GalleryModel(
      galleryId: '',
      recommendationId: selectedRecommendationId!,
      name: selectedName!,
      category: selectedCategory!,
      subcategory: selectedSubcategory!,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : '',
      imageUrl: _imageUrl,
      createdAt: Timestamp.now(),
    );

    await _galleryController.addGallery(newGalleryModel);
    SuccessSnackBar.show(context, 'Gallery created successfully', duration: Duration(seconds: 1));
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(title: ''),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomFormTitle(firstText: 'Create Gallery', secondText: 'Design your data exactly how you want it.'),

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
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value; // Simpan kategori yang dipilih
                        selectedSubcategory = null; // Reset subkategori
                        selectedName = null; // Reset name
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  );
                },
              ),
              SizedBox(height: 16),

              // Dropdown untuk memilih subkategori
              StreamBuilder<List<String>>(
                stream: selectedCategory != null
                    ? _categoryController.getSubcategories(selectedCategory!) // Ambil subkategori hanya jika kategori dipilih
                    : Stream.value([]), // Jika kategori tidak dipilih, berikan stream kosong
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return TextDropdown(
                      label: 'Subcategory',
                      items: [],
                      enabled: false, // Disable jika kategori belum dipilih
                    );
                  }
                  return TextDropdown(
                    label: 'Subcategory',
                    items: snapshot.data ?? [],
                    enabled: selectedCategory != null, // Enable hanya jika kategori dipilih
                    onChanged: (value) {
                      setState(() {
                        selectedSubcategory = value;
                        selectedName = null; // Reset name ketika subkategori berubah
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a subcategory';
                      }
                      return null;
                    },
                  );
                },
              ),
              SizedBox(height: 16),

              // Dropdown untuk memilih name
              StreamBuilder<List<Map<String, String>>>(
                stream: selectedSubcategory != null ? _galleryController.getGalleryNames(selectedCategory!, selectedSubcategory!) : Stream.value([]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return TextDropdown(
                      label: 'Name',
                      items: [],
                      enabled: false,
                    );
                  }

                  // Ambil daftar tiket
                  List<Map<String, String>> tickets = snapshot.data!;

                  return TextDropdown(
                    label: 'Name',
                    items: tickets.map((ticket) => ticket['name']!).toList(), // Ambil nama dari tiket
                    onChanged: (value) {
                      // Temukan ticket berdasarkan nama yang dipilih
                      final selectedTicket = tickets.firstWhere((ticket) => ticket['name'] == value);
                      setState(() {
                        selectedRecommendationId = selectedTicket['recommendationId']; // Simpan recommendationId
                        selectedName = value; // Simpan nama yang dipilih
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a name';
                      }
                      return null;
                    },
                  );
                },
              ),
              SizedBox(height: 16),

              // // Dropdown untuk memilih kategori
              // StreamBuilder<List<String>>(
              //   stream: _categoryController.getCategories(),
              //   builder: (context, snapshot) {
              //     if (!snapshot.hasData) {
              //       return CircularProgressIndicator();
              //     }
              //     return CustomDropdown(
              //       label: 'Category',
              //       items: snapshot.data ?? [],
              //       onChanged: (value) {
              //         setState(() {
              //           selectedCategory = value; // Simpan kategori yang dipilih
              //           selectedSubcategory = null; // Reset subkategori
              //           selectedName = null; // Reset name
              //         });
              //       },
              //     );
              //   },
              // ),
              // SizedBox(height: 16),

              // // Dropdown untuk memilih subkategori
              // if (selectedCategory != null)
              //   StreamBuilder<List<String>>(
              //     stream: _categoryController.getSubcategories(selectedCategory!),
              //     builder: (context, snapshot) {
              //       if (!snapshot.hasData) {
              //         return CircularProgressIndicator();
              //       }
              //       return CustomDropdown(
              //         label: 'Subcategory',
              //         items: snapshot.data ?? [],
              //         onChanged: (value) {
              //           setState(() {
              //             selectedSubcategory = value;
              //             selectedName = null;
              //           });
              //         },
              //       );
              //     },
              //   ),
              // SizedBox(height: selectedCategory != null ? 16 : 0),

              // // Dropdown untuk memuat dokumen berdasarkan kategori
              // if (selectedCategory != null)
              //   StreamBuilder<List<String>>(
              //     stream: _galleryController.getNamesByCategory(selectedCategory!),
              //     builder: (context, snapshot) {
              //       if (!snapshot.hasData) {
              //         return CircularProgressIndicator();
              //       }
              //       return CustomDropdown(
              //         label: 'Name',
              //         items: snapshot.data ?? [],
              //         onChanged: (value) {
              //           setState(() {
              //             selectedName = value; // Simpan nama yang dipilih
              //           });
              //         },
              //       );
              //     },
              //   ),
              // SizedBox(height: selectedCategory != null ? 16 : 0),

              TextArea(
                controller: _descriptionController,
                label: 'Description',
                hintText: 'Enter gallery description here..',
              ),
              SizedBox(height: 16),

              // Preview gambar dengan tombol untuk memilih gambar
              NewUploadImageWithPreview(
                imageFile: _imageFile,
                  imageBytes: _imageBytes, // Menampilkan preview gambar
                onPressed: _pickImage, // Pilih gambar
              ),
             SizedBox(height: 60),
              // Align(
              //   alignment: Alignment.bottomRight, // Memposisikan ke kanan bawah
              //   child: MediumButton(
              //     onPressed: uploadImage, // Fungsi untuk mengunggah gambar
              //     label: 'Upload',
              //   ),
              // ),
            ],
          ),
        ),
      ),
      floatingActionButton: MediumButton(
        onPressed: uploadImage,
        label: 'Save Gallery',
      ),
      bottomNavigationBar: AdminBottomNavBar(selectedIndex: 4),
    );
  }
}
