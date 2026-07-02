import re

with open('lib/views/admin/event_management/modify_event_screen.dart', 'r') as f:
    content = f.read()

# Replace variables
content = content.replace('Uint8List? _imageBytes;', 'List<Uint8List> _imageBytesList = [];')

# Replace _pickImage
old_pickImage = r'''  Future<void> _pickImage\(\) async \{
    try \{
      final picker = ImagePicker\(\);
      final pickedFile = await picker\.pickImage\(source: ImageSource\.gallery\);
      if \(pickedFile != null\) \{
      final bytes = await pickedFile\.readAsBytes\(\);
      setState\(\(\) \{
        try \{ _imageFile = File\(pickedFile\.path\); \} catch\(e\) \{\}
        _imageBytes = bytes;
          imageUrl = null; // Reset URL jika file baru dipilih
        \}\);
    \}
    \} catch \(e\) \{
      ScaffoldMessenger\.of\(context\)\.showSnackBar\(
        SnackBar\(content: Text\('Failed to pick image: \'\)\),
      \);
    \}
  \}'''
new_pickImage = '''  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final List<XFile> pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        List<Uint8List> bytesList = [];
        for (var file in pickedFiles) {
          bytesList.add(await file.readAsBytes());
        }
        setState(() {
          _imageBytesList.addAll(bytesList);
          imageUrl = null; // Reset URL jika file baru dipilih
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ')));
    }
  }'''
content = re.sub(old_pickImage, new_pickImage, content, flags=re.MULTILINE)

# Replace _uploadImage
old_uploadImage = r'''  Future<String\?> _uploadImage\(String name, String category\) async \{
    if \(_imageBytes == null\) return imageUrl;

    final sanitizedFileName = '\$\{name\}_\$\{category\}_\$\{DateTime\.now\(\)\.millisecondsSinceEpoch\}'\.replaceAll\(' ', '_'\);
    final path = 'uploads/\';

    try \{
      final uploadPath = await Supabase\.instance\.client\.storage\.from\('images'\)\.uploadBinary\(path, _imageBytes!, fileOptions: const FileOptions\(contentType: 'image/jpeg'\)\);

      if \(uploadPath\.isNotEmpty\) \{
        final publicUrl = Supabase\.instance\.client\.storage\.from\('images'\)\.getPublicUrl\(path\);
        if \(publicUrl\.isNotEmpty\) \{
          return publicUrl;
        \} else \{
          throw Exception\('Failed to retrieve public URL\.'\);
        \}
      \} else \{
        throw Exception\('Upload failed: No valid upload path returned\.'\);
      \}
    \} catch \(error\) \{
      ScaffoldMessenger\.of\(context\)\.showSnackBar\(
        SnackBar\(content: Text\('Failed to upload image: \'\)\),
      \);
      return null;
    \}
  \}'''
new_uploadImage = '''  Future<String?> _uploadImage(String name, String category, Uint8List bytes, int index) async {
    final sanitizedFileName = '___'.replaceAll(' ', '_');
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
  }'''
content = re.sub(old_uploadImage, new_uploadImage, content, flags=re.MULTILINE)

# Replace _saveChanges logic for finalImageUrl and gallery upload
old_saveChanges_start = r'''    // Upload image jika ada file baru
    final finalImageUrl = await _uploadImage\(name, category\);

    if \(finalImageUrl == null\) return; // Hentikan proses jika upload gagal'''

new_saveChanges_start = '''    String finalImageUrl = imageUrl ?? '';
    if (_imageBytesList.isNotEmpty) {
      String? newMainImage = await _uploadImage(name, category, _imageBytesList.first, 0);
      if (newMainImage != null) {
        finalImageUrl = newMainImage;
      } else return;
    }'''
content = re.sub(old_saveChanges_start, new_saveChanges_start, content)

old_saveChanges_end = r'''    try \{
      await _eventController\.updateEvent\(updatedEvent, finalImageUrl\);
      Navigator\.pop\(context\);
      ScaffoldMessenger\.of\(context\)\.showSnackBar\(SnackBar\('''
new_saveChanges_end = '''    try {
      await _eventController.updateEvent(updatedEvent, finalImageUrl);
      if (_imageBytesList.length > 1) {
        for (int i = 1; i < _imageBytesList.length; i++) {
          String? additionalUrl = await _uploadImage(name, category, _imageBytesList[i], i);
          if (additionalUrl != null) {
            final galleryId = FirebaseFirestore.instance.collection('galleries').doc().id;
            final galleryModel = GalleryModel(
              galleryId: galleryId,
              name: name,
              imageUrl: additionalUrl,
              category: category,
              subcategory: selectedSubcategory ?? '',
              description: descriptionNotifier.value,
              createdAt: Timestamp.now(),
              mainImage: false,
            );
            await FirebaseFirestore.instance.collection('galleries').doc(galleryId).set(galleryModel.toMap());
          }
        }
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar('''
content = re.sub(old_saveChanges_end, new_saveChanges_end, content)

content = re.sub(r'NewUploadImageWithPreview\([\s\S]*?imageBytes: _imageBytes,[\s\S]*?\),', 
    r'''MultiUploadImageWithPreview(
                  imageBytesList: _imageBytesList,
                  imageUrl: imageUrl,
                  onPressed: _pickImage,
                ),''', content)

with open('lib/views/admin/event_management/modify_event_screen.dart', 'w') as f:
    f.write(content)
