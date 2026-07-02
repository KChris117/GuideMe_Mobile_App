import re

with open('lib/views/admin/destination_management/create_destination_screen.dart', 'r') as f:
    content = f.read()

# Add import
content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:guideme/models/gallery_model.dart';")

# Change state variables
content = re.sub(r'Uint8List\?\s+_imageBytes;', r'List<Uint8List> _imageBytesList = [];\n  bool _isLoading = false;', content)

# Replace _pickImage
old_pickImage = r'''  // Fungsi untuk memilih gambar
  Future<void> _pickImage\(\) async \{
    final ImagePicker picker = ImagePicker\(\);
    final XFile\? pickedFile = await picker\.pickImage\(source: ImageSource\.gallery\);

    if \(pickedFile != null\) \{
      final bytes = await pickedFile\.readAsBytes\(\);
      setState\(\(\) \{
        try \{ _imageFile = File\(pickedFile\.path\); \} catch\(e\) \{\}
        _imageBytes = bytes; // Menyimpan file gambar yang dipilih
      \}\);
    \}
  \}'''
new_pickImage = '''  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      List<Uint8List> bytesList = [];
      for (var file in pickedFiles) {
        bytesList.add(await file.readAsBytes());
      }
      setState(() {
        _imageBytesList.addAll(bytesList);
      });
    }
  }'''
content = re.sub(old_pickImage, new_pickImage, content)

# Replace NewUploadImageWithPreview
content = re.sub(r'NewUploadImageWithPreview\([\s\S]*?onPressed: _pickImage, // Fungsi untuk memilih gambar[\s\S]*?\),', 
    r'''MultiUploadImageWithPreview(
                  imageBytesList: _imageBytesList,
                  onPressed: _pickImage,
                ),''', content)

# Replace uploadImage and saveDestination
old_block = r'''  // Fungsi untuk mengunggah gambar ke Supabase
  Future uploadImage\(\) async \{
    if \(_imageBytes == null\) return;

    // Ambil teks dari field 'name' dan buat format nama file
    final name = _nameController\.text;
    final category = _selectedCategory \?\? 'uncategorized';

    final fileName = '\$\{name\}_\$\{category\}_\$\{DateTime\.now\(\)\.millisecondsSinceEpoch\}';
    final path = 'uploads/\';

    try \{
      // Mengunggah gambar ke Supabase
      final uploadPath = await Supabase\.instance\.client\.storage\.from\('images'\)\.uploadBinary\(path, _imageBytes!, fileOptions: const FileOptions\(contentType: 'image/jpeg'\)\);

      if \(uploadPath\.isNotEmpty\) \{
        // Mendapatkan URL publik untuk gambar yang diunggah
        final publicUrl = Supabase\.instance\.client\.storage\.from\('images'\)\.getPublicUrl\(path\);

        if \(publicUrl\.isNotEmpty\) \{
          setState\(\(\) \{
            _imageUrl = publicUrl; // Simpan URL publik ke variabel
          \}\);

          // Simpan data galeri setelah berhasil mengunggah
          saveDestination\(\);
        \} else \{
          ScaffoldMessenger\.of\(context\)\.showSnackBar\(
            SnackBar\(content: Text\('Failed to retrieve public URL for the image\.'\)\),
          \);
        \}
      \} else \{
        throw Exception\('Upload failed: No valid upload path returned\.'\);
      \}
    \} catch \(error\) \{
      ScaffoldMessenger\.of\(context\)\.showSnackBar\(
        SnackBar\(content: Text\('Failed to upload image: \'\)\),
      \);
    \}
  \}

  Future<void> saveDestination\(\) async \{
    if \(_formKey\.currentState!\.validate\(\)\) \{
      // Validasi form
      if \(_imageUrl\.isNotEmpty && _openingTime != null && _closingTime != null && _selectedLocation != null && _selectedCategory != null && selectedStatus != null\) \{
        // Lanjutkan dengan menyimpan event
        // File imageFile = File\(_imageUrl\);
        // String localImagePath = await _galleryController\.saveImageLocally\(imageFile\);
        double _rating = double\.tryParse\(_ratingController\.text\) \?\? 0\.0;

        DestinationModel dataDestination = DestinationModel\(
          destinationId: '',
          name: _nameController\.text,
          location: _locationController\.text,
          latitude: _selectedLocation!\.latitude,
          longitude: _selectedLocation!\.longitude,
          imageUrl: _imageUrl,
          organizer: _organizerController\.text,
          category: _selectedCategory!,
          subcategory: _selectedSubcategory!,
          description: _descriptionController\.text,
          information: _informationController\.text,
          rating: _rating,
          price: int\.tryParse\(_priceController\.text\) \?\? 0,
          status: selectedStatus!,
          openingTime: _openingTime!,
          closingTime: _closingTime!,
          createdAt: Timestamp\.now\(\),
        \);

        try \{
          // Memanggil fungsi addDestination untuk menyimpan event dan galeri ke Firestore
          await _destinationController\.addDestination\(dataDestination, _imageUrl\);

          ScaffoldMessenger\.of\(context\)\.showSnackBar\(SnackBar\(
            content: Text\('Destination created successfully'\),
          \)\);
          Navigator\.pop\(context\);
        \} catch \(e\) \{
          ScaffoldMessenger\.of\(context\)\.showSnackBar\(SnackBar\(
            content: Text\('Failed to save Destination: \'\),
          \)\);
        \}
      \} else \{
        ScaffoldMessenger\.of\(context\)\.showSnackBar\(SnackBar\(
          content: Text\('Please complete all fields correctly'\),
        \)\);
      \}
    \}
  \}'''

new_block = '''  Future<String?> uploadImage(Uint8List bytes, int index) async {
    final name = _nameController.text;
    final category = _selectedCategory ?? 'uncategorized';
    final fileName = '___'.replaceAll(' ', '_');
    final path = 'uploads/.jpg';
    try {
      final uploadPath = await Supabase.instance.client.storage.from('images').uploadBinary(path, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));
      if (uploadPath.isNotEmpty) {
        return Supabase.instance.client.storage.from('images').getPublicUrl(path);
      }
    } catch (error) {
      print('Upload error: ');
    }
    return null;
  }

  Future<void> saveDestination() async {
    if (_formKey.currentState!.validate()) {
      if (_imageBytesList.isNotEmpty && _openingTime != null && _closingTime != null && _selectedLocation != null && _selectedCategory != null && selectedStatus != null) {
        setState(() { _isLoading = true; });
        String? mainImageUrl = await uploadImage(_imageBytesList.first, 0);
        if (mainImageUrl == null) {
           setState(() { _isLoading = false; });
           return;
        }
        
        double _rating = double.tryParse(_ratingController.text) ?? 0.0;
        DestinationModel dataDestination = DestinationModel(
          destinationId: '',
          name: _nameController.text,
          location: _locationController.text,
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
          imageUrl: mainImageUrl,
          organizer: _organizerController.text,
          category: _selectedCategory!,
          subcategory: _selectedSubcategory ?? '',
          description: _descriptionController.text,
          information: _informationController.text,
          rating: _rating,
          price: int.tryParse(_priceController.text) ?? 0,
          status: selectedStatus!,
          openingTime: _openingTime!,
          closingTime: _closingTime!,
          createdAt: Timestamp.now(),
        );

        try {
          await _destinationController.addDestination(dataDestination, mainImageUrl);
          if (_imageBytesList.length > 1) {
            for (int i = 1; i < _imageBytesList.length; i++) {
              String? additionalUrl = await uploadImage(_imageBytesList[i], i);
              if (additionalUrl != null) {
                final galleryId = FirebaseFirestore.instance.collection('galleries').doc().id;
                final galleryModel = GalleryModel(
                  galleryId: galleryId,
                  name: _nameController.text,
                  imageUrl: additionalUrl,
                  category: _selectedCategory!,
                  subcategory: _selectedSubcategory ?? '',
                  description: _descriptionController.text,
                  createdAt: Timestamp.now(),
                  mainImage: false,
                );
                await FirebaseFirestore.instance.collection('galleries').doc(galleryId).set(galleryModel.toMap());
              }
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Destination created!'), backgroundColor: Colors.green));
          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: '), backgroundColor: Colors.red));
        } finally {
          setState(() { _isLoading = false; });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields and upload images'), backgroundColor: Colors.red));
      }
    }
  }'''
content = re.sub(old_block, new_block, content)

# Ensure the submit button calls saveDestination() instead of uploadImage()
content = re.sub(r'onPressed: \(\) \{\s*// Upload gambar lalu simpan data jika valid\s*uploadImage\(\);\s*\},', r'''onPressed: () { saveDestination(); },''', content)

with open('lib/views/admin/destination_management/create_destination_screen.dart', 'w') as f:
    f.write(content)

print("Part 2 finished")
