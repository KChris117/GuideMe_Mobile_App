// import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:guideme/controllers/category_controller.dart';
import 'package:guideme/controllers/destination_controller.dart';
import 'package:guideme/models/destination_model.dart';
import 'package:guideme/widgets/custom_card.dart';
import 'package:guideme/widgets/custom_form.dart';
import 'package:guideme/widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModifyDestinationScreen extends StatefulWidget {
  final DestinationModel destinationModel; // menerima data yang akan diedit

  const ModifyDestinationScreen({super.key, required this.destinationModel});

  @override
  _ModifyDestinationScreenState createState() => _ModifyDestinationScreenState();
}

class _ModifyDestinationScreenState extends State<ModifyDestinationScreen> {
  final DestinationController _destinationController = DestinationController();
  final CategoryController _categoryController = CategoryController();
  final MapController _mapController = MapController();
  final _formKey = GlobalKey<FormState>();

  late ValueNotifier<String> nameNotifier;
  late ValueNotifier<String> locationNotifier;
  late ValueNotifier<String> organizerNotifier;
  late ValueNotifier<String> descriptionNotifier;
  late ValueNotifier<String> informationNotifier;
  late ValueNotifier<String> priceNotifier;
  late ValueNotifier<Timestamp> openingTimeNotifier;
  late ValueNotifier<Timestamp> closingTimeNotifier;
  // late ValueNotifier<double> latitude;

  LatLng? selectedLocation;
  String? selectedCategory;
  String? selectedSubcategory;
  String? selectedStatus;
  String? imageUrl;
  File? _imageFile;
  Uint8List? _imageBytes;
  bool _isMapExpanded = true;
  double? latitude;
  double? longitude;

  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _organizerController;
  late TextEditingController _descriptionController;
  late TextEditingController _informationController;
  late TextEditingController _ratingController;
  late TextEditingController _priceController;

  @override
  void initState() {
    _isMapExpanded = false;
    super.initState();
    // Inisialisasi ValueNotifier dengan nilai awal dari widget
    nameNotifier = ValueNotifier(widget.destinationModel.name);
    locationNotifier = ValueNotifier(widget.destinationModel.location);
    organizerNotifier = ValueNotifier(widget.destinationModel.organizer);
    descriptionNotifier = ValueNotifier(widget.destinationModel.description);
    informationNotifier = ValueNotifier(widget.destinationModel.information);
    priceNotifier = ValueNotifier(widget.destinationModel.price.toString());
    openingTimeNotifier = ValueNotifier(widget.destinationModel.openingTime);
    closingTimeNotifier = ValueNotifier(widget.destinationModel.closingTime);

    imageUrl = widget.destinationModel.imageUrl;
    selectedLocation = LatLng(widget.destinationModel.latitude, widget.destinationModel.longitude);
    latitude = widget.destinationModel.latitude;
    longitude = widget.destinationModel.longitude;
    selectedCategory = widget.destinationModel.category;
    selectedSubcategory = widget.destinationModel.subcategory;
    selectedStatus = widget.destinationModel.status;

    // Inisialisasi TextEditingController untuk input teks
    _nameController = TextEditingController(text: widget.destinationModel.name);
    _locationController = TextEditingController(text: widget.destinationModel.location);
    _organizerController = TextEditingController(text: widget.destinationModel.organizer);
    _descriptionController = TextEditingController(text: widget.destinationModel.description);
    _informationController = TextEditingController(text: widget.destinationModel.information);
    _ratingController = TextEditingController(text: widget.destinationModel.rating.toString());
    _priceController = TextEditingController(text: widget.destinationModel.price.toString());
  }

  @override
  void dispose() {
    // Dispose semua ValueNotifier dan TextEditingController
    nameNotifier.dispose();
    locationNotifier.dispose();
    organizerNotifier.dispose();
    descriptionNotifier.dispose();
    informationNotifier.dispose();
    priceNotifier.dispose();
    openingTimeNotifier.dispose();
    closingTimeNotifier.dispose();

    _nameController.dispose();
    _locationController.dispose();
    _organizerController.dispose();
    _descriptionController.dispose();
    _informationController.dispose();
    _ratingController.dispose();
    _priceController.dispose();

    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        try { _imageFile = File(pickedFile.path); } catch(e) {}
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

    final sanitizedFileName = '${name}_${category}_${DateTime.now().millisecondsSinceEpoch}'.replaceAll(' ', '_');
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
    if (!_formKey.currentState!.validate()) return;

    // if (imageUrl != null && openingTimeNotifier.value != null && closingTimeNotifier.value != null && selectedLocation != null) return;
    // final name = _nameController.text.trim();

    final name = nameNotifier.value;
    final category = selectedCategory ?? 'Uncategorized';

    // Upload image jika ada file baru
    final finalImageUrl = await _uploadImage(name, category);

    if (finalImageUrl == null) return; // Hentikan proses jika upload gagal

    // Menggunakan copyWith untuk membuat objek baru
    DestinationModel updatedDestination = widget.destinationModel.copyWith(
      name: nameNotifier.value.toLowerCase(),
      location: locationNotifier.value.toLowerCase(),
      latitude: selectedLocation!.latitude,
      longitude: selectedLocation!.longitude,
      imageUrl: finalImageUrl,
      organizer: organizerNotifier.value.toLowerCase(),
      category: selectedCategory!,
      subcategory: selectedSubcategory!,
      description: descriptionNotifier.value,
      information: informationNotifier.value,
      // rating: rating,
      price: int.tryParse(priceNotifier.value) ?? 0,
      status: selectedStatus!,
      openingTime: openingTimeNotifier.value,
      closingTime: closingTimeNotifier.value,
      updatedAt: Timestamp.now(),
    );

    try {
      await _destinationController.updateDestination(updatedDestination, finalImageUrl);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Destination updated successfully'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save changes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomFormTitle(firstText: 'Modify Destination', secondText: 'Update your destination details.'),
                ValueListenableBuilder<String>(
                  valueListenable: nameNotifier,
                  builder: (context, name, _) {
                    return TextForm(
                      controller: _nameController,
                      label: 'Destination Name',
                      // onChanged: (value) => nameNotifier.value = value,
                      onChanged: (value) {
                        nameNotifier.value = value;
                        _nameController.value = TextEditingValue(
                          text: value.toLowerCase(),
                          selection: _nameController.selection,
                        );
                      },
                      validator: (value) => value == null || value.isEmpty ? 'Name is required' : null,
                    );
                  },
                ),
                SizedBox(height: 20),

                ValueListenableBuilder<String>(
                  valueListenable: locationNotifier,
                  builder: (context, location, _) {
                    return TextForm(
                      controller: _locationController,
                      label: 'Destination Location',
                      // onChanged: (value) => locationNotifier.value = value,
                      onChanged: (value) {
                        locationNotifier.value = value;
                        _locationController.value = TextEditingValue(
                          text: value.toLowerCase(),
                          selection: _locationController.selection,
                        );
                      },
                      validator: (value) => value == null || value.isEmpty ? 'Location is required' : null,
                    );
                  },
                ),
                SizedBox(height: 20),

                // map
                MainCard(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isMapExpanded = !_isMapExpanded;
                          });
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            height: _isMapExpanded ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height / 4,
                            width: double.infinity,
                            child: FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                // initialCenter: LatLng(1.054507, 104.004120),
                                initialCenter: LatLng(latitude!, longitude!),
                                onTap: (_, point) {
                                  setState(() {
                                    selectedLocation = point;
                                  });
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", // Updated URL without subdomains
                                ),
                                if (selectedLocation != null)
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: selectedLocation!,
                                        width: 40,
                                        height: 40,
                                        child: Icon(Icons.location_pin, color: Colors.red),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          icon: Icon(
                            _isMapExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _isMapExpanded = !_isMapExpanded;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                ValueListenableBuilder<String>(
                  valueListenable: organizerNotifier,
                  builder: (context, organizer, _) {
                    return TextForm(
                      controller: _organizerController,
                      label: 'Destination Organizer',
                      // onChanged: (value) => organizerNotifier.value = value,
                      onChanged: (value) {
                        organizerNotifier.value = value;
                        _organizerController.value = TextEditingValue(
                          text: value.toLowerCase(),
                          selection: _organizerController.selection,
                        );
                      },
                      validator: (value) => value == null || value.isEmpty ? 'Organizer is required' : null,
                    );
                  },
                ),
                SizedBox(height: 20),

                // Dropdown untuk memilih kategori
                StreamBuilder<List<String>>(
                  stream: _categoryController.getCategories(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    return TextDropdown(
                      label: 'Category',
                      items: ['destination'], // Hanya memiliki satu item tetap
                      value: selectedCategory, // Menampilkan nilai _selectedCategory
                      enabled: false, // Dropdown dapat dipilih (diubah)
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value ?? 'destination'; // Memperbarui _selectedCategory ketika ada perubahan
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Category is required';
                        }
                        return null;
                      },
                      // label: 'Category',
                      // items: snapshot.data ?? [],
                      // value: selectedCategory,
                      // onChanged: (value) {
                      //   setState(() {
                      //     selectedCategory = value;
                      //     selectedSubcategory = null; // Reset subkategori
                      //   });
                      // },
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Please select a category';
                      //   }
                      //   return null;
                      // },
                    );
                  },
                ),
                SizedBox(height: 16),

                // Dropdown untuk memilih subkategori
                StreamBuilder<List<String>>(
                  stream: selectedCategory != null ? _categoryController.getSubcategories(selectedCategory!) : Stream.value([]),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return TextDropdown(
                        label: 'Subcategory',
                        items: [],
                        enabled: false,
                      );
                    }
                    return TextDropdown(
                      label: 'Subcategory',
                      items: snapshot.data ?? [],
                      value: selectedSubcategory,
                      enabled: selectedCategory != null,
                      onChanged: (value) {
                        setState(() {
                          selectedSubcategory = value;
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

                ValueListenableBuilder<String>(
                  valueListenable: descriptionNotifier,
                  builder: (context, description, _) {
                    return TextArea(
                      controller: _descriptionController,
                      label: 'Destination Description',
                      onChanged: (value) => descriptionNotifier.value = value,
                      validator: (value) => value == null || value.isEmpty ? 'Description is required' : null,
                    );
                  },
                ),
                SizedBox(height: 20),

                ValueListenableBuilder<String>(
                  valueListenable: informationNotifier,
                  builder: (context, information, _) {
                    return TextArea(
                      controller: _informationController,
                      label: 'Destination Information',
                      onChanged: (value) => informationNotifier.value = value,
                      validator: (value) => value == null || value.isEmpty ? 'Information is required' : null,
                    );
                  },
                ),
                SizedBox(height: 20),

                ValueListenableBuilder<String>(
                  valueListenable: priceNotifier,
                  builder: (context, price, _) {
                    return TextForm(
                      controller: _priceController,
                      label: 'Destination Price',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) => priceNotifier.value = value,
                      validator: (value) => value == null || value.isEmpty ? 'Price is required' : null,
                    );
                  },
                ),
                SizedBox(height: 20),

                TextDropdown(
                  label: 'Status',
                  items: ['open', 'close'],
                  value: selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Status is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                NewUploadImageWithPreview(
                  imageUrl: imageUrl, // Gantilah dengan URL gambar yang dipilih
                  imageFile: _imageFile,
                  imageBytes: _imageBytes,
                  onPressed: _pickImage, // Fungsi untuk memilih gambar
                ),

                // Waktu Buka
                DateTimePicker(
                  title: 'Opening Date Time',
                  subtitle: openingTimeNotifier.value != null ? (openingTimeNotifier.value).toDate().toString() : 'Select closing date time',
                  selectedTime: openingTimeNotifier.value, // Menggunakan Timestamp sebagai default
                  onDateTimeSelected: (selectedTime) {
                    setState(() {
                      openingTimeNotifier.value = selectedTime; // Mengupdate openingTimeNotifier
                    });
                  },
                ),
                SizedBox(height: 20),

                // Waktu Tutup
                DateTimePicker(
                  title: 'Closing Date Time',
                  subtitle: closingTimeNotifier.value != null ? (closingTimeNotifier.value).toDate().toString() : 'Select closing date time',
                  selectedTime: closingTimeNotifier.value, // Menggunakan Timestamp sebagai default
                  onDateTimeSelected: (selectedTime) {
                    setState(() {
                      closingTimeNotifier.value = selectedTime; // Mengupdate closingTimeNotifier
                    });
                  },
                ),
                SizedBox(height: 60),

                // Align(
                //   alignment: Alignment.bottomRight,
                //   child: MediumButton(
                //     onPressed: _saveChanges,
                //     label: 'Save',
                //   ),
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
      bottomNavigationBar: AdminBottomNavBar(selectedIndex: 1),
    );
  }
}










  // Future<void> _pickImage() async {
  //   String? imagePath = await _galleryController.pickImage();
  //   if (imagePath != null) {
  //     setState(() {
  //       imageUrl = imagePath;
  //     });
  //   }
  // }



      // try {
    //   // Memanggil fungsi untuk menyimpan perubahan
    //   await _destinationController.updateDestination(updatedDestination, 'localImagePath');

    //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //         content: Text('Destination updated successfully'),
    //       ));
    //       Navigator.pop(context);
    //     } catch (e) {
    //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //         content: Text('Failed to update destination: $e'),
    //       ));
    //     }
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //       content: Text('Please complete all fields and upload an image'),
    //     ));
    //   }
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text('Please complete all fields correctly'),
    //   ));
    // }




    
    // Update data galeri
    // final updatedDestination =descriptionNotifier.value.copyWith(
    //   name: name,
    //   location: _locationController.text.trim(),
    //   category: selectedCategory,
    //   subcategory: selectedSubcategory,
    //   imageUrl: finalImageUrl,
    //   description: _descriptionController.text.trim(),
    // );