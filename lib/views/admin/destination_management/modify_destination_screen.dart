import 'package:guideme/models/gallery_model.dart';
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
  List<Uint8List> _imageBytesList = [];
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<String?> _uploadImage(String name, String category, Uint8List bytes, int index) async {
    final sanitizedFileName = '${name}_${category}_${DateTime.now().millisecondsSinceEpoch}_$index'.replaceAll(' ', '_');
    final path = 'uploads/$sanitizedFileName.jpg';

    try {
      final uploadPath = await Supabase.instance.client.storage.from('images').uploadBinary(path, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));

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

    String finalImageUrl = imageUrl ?? '';
    if (_imageBytesList.isNotEmpty) {
      String? newMainImage = await _uploadImage(name, category, _imageBytesList.first, 0);
      if (newMainImage != null) {
        finalImageUrl = newMainImage;
      } else return;
    }

    // Menggunakan copyWith untuk membuat objek baru
    DestinationModel updatedDestination = widget.destinationModel.copyWith(
      name: nameNotifier.value,
      location: locationNotifier.value,
      latitude: selectedLocation!.latitude,
      longitude: selectedLocation!.longitude,
      imageUrl: finalImageUrl,
      organizer: organizerNotifier.value,
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
                      onChanged: (value) {
                        nameNotifier.value = value;
                        _nameController.value = TextEditingValue(
                          text: value,
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
                      onChanged: (value) {
                        locationNotifier.value = value;
                        _locationController.value = TextEditingValue(
                          text: value,
                          selection: _locationController.selection,
                        );
                      },
                      validator: (value) => value == null || value.isEmpty ? 'Location is required' : null,
                    );
                  },
                ),
                SizedBox(height: 20),

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
                                initialCenter: LatLng(latitude!, longitude!),
                                onTap: (_, point) {
                                  setState(() {
                                    selectedLocation = point;
                                  });
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", userAgentPackageName: 'com.example.guideme',
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
                      onChanged: (value) {
                        organizerNotifier.value = value;
                        _organizerController.value = TextEditingValue(
                          text: value,
                          selection: _organizerController.selection,
                        );
                      },
                      validator: (value) => value == null || value.isEmpty ? 'Organizer is required' : null,
                    );
                  },
                ),
                SizedBox(height: 20),

                StreamBuilder<List<String>>(
                  stream: _categoryController.getCategories(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    return TextDropdown(
                      label: 'Category',
                      items: ['destination'],
                      value: selectedCategory,
                      enabled: false,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value ?? 'destination';
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Category is required';
                        }
                        return null;
                      },
                    );
                  },
                ),
                SizedBox(height: 16),

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

                MultiUploadImageWithPreview(
                  imageBytesList: _imageBytesList,
                  imageUrl: imageUrl,
                  onPressed: _pickImage,
                ),

                DateTimePicker(
                  title: 'Opening Date Time',
                  subtitle: openingTimeNotifier.value != null ? (openingTimeNotifier.value).toDate().toString() : 'Select opening date time',
                  selectedTime: openingTimeNotifier.value,
                  onDateTimeSelected: (selectedTime) {
                    setState(() {
                      openingTimeNotifier.value = selectedTime;
                    });
                  },
                ),
                SizedBox(height: 20),

                DateTimePicker(
                  title: 'Closing Date Time',
                  subtitle: closingTimeNotifier.value != null ? (closingTimeNotifier.value).toDate().toString() : 'Select closing date time',
                  selectedTime: closingTimeNotifier.value,
                  onDateTimeSelected: (selectedTime) {
                    setState(() {
                      closingTimeNotifier.value = selectedTime;
                    });
                  },
                ),
                SizedBox(height: 60),
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
}

