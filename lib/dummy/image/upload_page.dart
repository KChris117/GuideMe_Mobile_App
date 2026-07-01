import 'dart:io';
import 'package:flutter/material.dart';
import 'package:guideme/controllers/category_controller.dart';
import 'package:guideme/controllers/gallery_controller.dart';
import 'package:guideme/models/gallery_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/widgets/custom_form.dart';
import 'package:guideme/widgets/custom_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final GalleryController _galleryController = GalleryController();
  final CategoryController _categoryController = CategoryController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _imageUrl = ''; // Menyimpan URL gambar yang sudah diunggah
  String? selectedCategory;
  String? selectedSubcategory;

  File? _imageFile;

  // Fungsi untuk memilih gambar
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Menyimpan file gambar yang dipilih
      });
    }
  }

  // Fungsi untuk mengunggah gambar ke Supabase
  Future uploadImage() async {
    if (_imageFile == null) return;

    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'uploads/$fileName';

    // Mengunggah gambar ke Supabase
    // final response = await Supabase.instance.client.storage.from('images').upload(path, _imageFile!);

    // Mendapatkan URL gambar yang diunggah
    final imageUrlResponse = await Supabase.instance.client.storage.from('images').getPublicUrl(path);

    final imageUrl = imageUrlResponse.toString(); // Mendapatkan URL gambar

    // Menyimpan URL gambar
    setState(() {
      _imageUrl = imageUrl;
    });

    _saveGallery(); // Menyimpan data galeri ke Firestore
  }

  // Fungsi untuk menyimpan galeri ke Firestore
  Future<void> _saveGallery() async {
    if (_nameController.text.isNotEmpty && _descriptionController.text.isNotEmpty && _imageUrl.isNotEmpty) {
      GalleryModel dataGallery = GalleryModel(
        galleryId: '',
        name: _nameController.text,
        category: selectedCategory!,
        subcategory: selectedSubcategory!,
        description: _descriptionController.text,
        imageUrl: _imageUrl,
        createdAt: Timestamp.now(),
      );

      await _galleryController.addGallery(dataGallery);

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all fields and upload an image.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create New Gallery')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomTextField(controller: _nameController, label: 'Name'),
              SizedBox(height: 20),

              // Dropdown untuk memilih kategori
              StreamBuilder<List<String>>(
                stream: _categoryController.getCategories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  return CustomDropdown(
                    label: 'Category',
                    items: snapshot.data!,
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                        selectedSubcategory = null;
                      });
                    },
                  );
                },
              ),
              SizedBox(height: 20),

              // Dropdown untuk memilih subkategori
              if (selectedCategory != null)
                StreamBuilder<List<String>>(
                  stream: _categoryController.getSubcategories(selectedCategory!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    return CustomDropdown(
                      label: 'Subcategory',
                      items: snapshot.data!,
                      onChanged: (value) {
                        setState(() {
                          selectedSubcategory = value;
                        });
                      },
                    );
                  },
                ),
              SizedBox(height: 20),

              CustomTextField(controller: _descriptionController, label: 'Description'),
              SizedBox(height: 20),

              // Preview gambar dengan tombol untuk memilih gambar
              NewUploadImageWithPreview(
                imageFile: _imageFile, // Menampilkan preview gambar
                onPressed: _pickImage, // Pilih gambar
              ),

              LargeButton(
                onPressed: uploadImage, // Fungsi untuk mengunggah gambar
                label: 'Upload Gallery',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
