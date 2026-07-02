import re

with open('lib/views/admin/event_management/create_event_screen.dart', 'r') as f:
    content = f.read()

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

start_marker = '  // Fungsi untuk mengunggah gambar ke Supabase'
end_marker = "  @override\n  Widget build(BuildContext context) {"

idx1 = content.find(start_marker)
idx2 = content.find(end_marker)

if idx1 != -1 and idx2 != -1:
    new_funcs = '''  Future<String?> uploadImage(Uint8List bytes, int index) async {
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

  Future<void> saveEvent() async {
    if (_formKey.currentState!.validate()) {
      if (_imageBytesList.isNotEmpty && _openingTime != null && _closingTime != null && _selectedLocation != null && _selectedCategory != null && selectedStatus != null) {
        setState(() { _isLoading = true; });
        String? mainImageUrl = await uploadImage(_imageBytesList.first, 0);
        if (mainImageUrl == null) {
           setState(() { _isLoading = false; });
           return;
        }
        
        double _rating = double.tryParse(_ratingController.text) ?? 0.0;
        EventModel dataEvent = EventModel(
          eventId: '',
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
          await _eventController.addEvent(dataEvent, mainImageUrl);
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Event created!'), backgroundColor: Colors.green));
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
  }\n\n'''
    content = content[:idx1] + new_funcs + content[idx2:]

# Replace floatingActionButton onPressed
content = content.replace('onPressed: uploadImage,', 'onPressed: saveEvent,')

with open('lib/views/admin/event_management/create_event_screen.dart', 'w') as f:
    f.write(content)

print("Part 3b finished")
