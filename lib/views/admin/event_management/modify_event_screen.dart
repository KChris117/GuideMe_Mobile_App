import 'package:guideme/models/gallery_model.dart';
// import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:guideme/controllers/category_controller.dart';
import 'package:guideme/controllers/event_controller.dart';
import 'package:guideme/models/event_model.dart';
import 'package:guideme/widgets/custom_form.dart';
import 'package:guideme/widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModifyEventScreen extends StatefulWidget {
  final EventModel eventModel; // menerima data yang akan diedit

  const ModifyEventScreen({super.key, required this.eventModel});

  @override
  _ModifyEventScreenState createState() => _ModifyEventScreenState();
}

class _ModifyEventScreenState extends State<ModifyEventScreen> {
  final EventController _eventController = EventController();
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
    nameNotifier = ValueNotifier(widget.eventModel.name);
    locationNotifier = ValueNotifier(widget.eventModel.location);
    organizerNotifier = ValueNotifier(widget.eventModel.organizer);
    descriptionNotifier = ValueNotifier(widget.eventModel.description);
    informationNotifier = ValueNotifier(widget.eventModel.information);
    priceNotifier = ValueNotifier(widget.eventModel.price.toString());
    openingTimeNotifier = ValueNotifier(widget.eventModel.openingTime);
    closingTimeNotifier = ValueNotifier(widget.eventModel.closingTime);

    imageUrl = widget.eventModel.imageUrl;
    // Mencetak nilai imageUrl pada saat pertama kali membuka halaman
    print("Nilai imageUrl saat pertama kali membuka halaman: $imageUrl");
    selectedLocation = LatLng(widget.eventModel.latitude, widget.eventModel.longitude);
    latitude = widget.eventModel.latitude;
    longitude = widget.eventModel.longitude;
    selectedCategory = widget.eventModel.category;
    selectedSubcategory = widget.eventModel.subcategory;
    selectedStatus = widget.eventModel.status;

    // Inisialisasi TextEditingController untuk input teks
    _nameController = TextEditingController(text: widget.eventModel.name);
    _locationController = TextEditingController(text: widget.eventModel.location);
    _organizerController = TextEditingController(text: widget.eventModel.organizer);
    _descriptionController = TextEditingController(text: widget.eventModel.description);
    _informationController = TextEditingController(text: widget.eventModel.information);
    _ratingController = TextEditingController(text: widget.eventModel.rating.toString());
    _priceController = TextEditingController(text: widget.eventModel.price.toString());
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
    EventModel updatedEvent = widget.eventModel.copyWith(
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Event updated successfully'),
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
      appBar: BackAppBar(
        title: 'Back',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomFormTitle(firstText: 'Modify Event', secondText: 'Update your event details.'),
                ValueListenableBuilder<String>(
                  valueListenable: nameNotifier,
                  builder: (context, name, _) {
                    return TextForm(
                      controller: _nameController,
                      label: 'Event Name',
                      // onChanged: (value) => nameNotifier.value = value,
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
                SizedBox(height: 16),

                ValueListenableBuilder<String>(
                  valueListenable: locationNotifier,
                  builder: (context, location, _) {
                    return TextForm(
                      controller: _locationController,
                      label: 'Event Location',
                      // onChanged: (value) => locationNotifier.value = value,
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
                SizedBox(height: 16),

                // map
                Stack(
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
                                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", userAgentPackageName: 'com.example.guideme', // Updated URL without subdomains
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
                SizedBox(height: 16),

                ValueListenableBuilder<String>(
                  valueListenable: organizerNotifier,
                  builder: (context, organizer, _) {
                    return TextForm(
                      controller: _organizerController,
                      label: 'Event Organizer',
                      // onChanged: (value) => organizerNotifier.value = value,
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
                SizedBox(height: 16),

                // Dropdown untuk memilih category
                StreamBuilder<List<String>>(
                  stream: _categoryController.getCategories(), // Aliran kategori
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    return TextDropdown(
                      label: 'Category',
                      items: ['event'], // Hanya memiliki satu item tetap
                      value: selectedCategory, // Menampilkan nilai selectedCategory
                      enabled: false, // Dropdown dapat dipilih (diubah)
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value ?? 'event'; // Memperbarui selectedCategory ketika ada perubahan
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
                if (selectedCategory != null)
                  StreamBuilder<List<String>>(
                    stream: _categoryController.getSubcategories(selectedCategory!),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      return TextDropdown(
                        label: 'Subcategory',
                        items: snapshot.data!,
                        value: selectedSubcategory,
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
                      label: 'Event Description',
                      onChanged: (value) => descriptionNotifier.value = value,
                      validator: (value) => value == null || value.isEmpty ? 'Description is required' : null,
                    );
                  },
                ),
                SizedBox(height: 16),

                ValueListenableBuilder<String>(
                  valueListenable: informationNotifier,
                  builder: (context, information, _) {
                    return TextArea(
                      controller: _informationController,
                      label: 'Event Information',
                      onChanged: (value) => informationNotifier.value = value,
                      validator: (value) => value == null || value.isEmpty ? 'Information is required' : null,
                    );
                  },
                ),
                SizedBox(height: 16),

                ValueListenableBuilder<String>(
                  valueListenable: priceNotifier,
                  builder: (context, price, _) {
                    return TextForm(
                      controller: _priceController,
                      label: 'Event Price',
                      onChanged: (value) => priceNotifier.value = value,
                      validator: (value) => value == null || value.isEmpty ? 'Price is required' : null,
                    );
                  },
                ),
                SizedBox(height: 16),

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
                SizedBox(height: 16),

                MultiUploadImageWithPreview(
                  imageBytesList: _imageBytesList,
                  imageUrl: imageUrl,
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
                SizedBox(height: 16),

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
      bottomNavigationBar: AdminBottomNavBar(selectedIndex: 2),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:guideme/controllers/event_controller.dart';
// import 'package:guideme/models/event_model.dart';
// import 'package:guideme/widgets/custom_appbar.dart';
// import 'package:guideme/widgets/widgets.dart';

// class ModifyEventScreen extends StatefulWidget {
//   final EventModel eventModel;

//   const ModifyEventScreen({super.key, required this.eventModel});

//   @override
//   _ModifyEventScreenState createState() => _ModifyEventScreenState();
// }

// class _ModifyEventScreenState extends State<ModifyEventScreen> {
//   // Menggunakan ValueNotifier untuk melacak perubahan
//   late ValueNotifier<EventModel> _eventNotifier;

//   // EventController untuk update data
//   final EventController _eventController = EventController();

//   @override
//   void initState() {
//     super.initState();
//     // Inisialisasi ValueNotifier dengan nilai eventModel yang ada
//     _eventNotifier = ValueNotifier(widget.eventModel);
//   }

//   @override
//   void dispose() {
//     _eventNotifier.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: BackAppBar(
//         title: 'Back',
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Menggunakan ValueListenableBuilder untuk memperbarui UI saat data berubah
//             ValueListenableBuilder<EventModel>(
//               valueListenable: _eventNotifier,
//               builder: (context, eventModel, child) {
//                 return Column(
//                   children: [
//                     // Form field untuk nama eventModel
//                     TextFormField(
//                       initialValue: eventModel.name,
//                       decoration: InputDecoration(labelText: 'Event Name'),
//                       onChanged: (value) {
//                         // Menyimpan perubahan nama
//                         eventModel.name = value;
//                       },
//                     ),
//                     SizedBox(height: 16),

//                     TextFormField(
//                       initialValue: eventModel.location,
//                       decoration: InputDecoration(labelText: 'Event Location'),
//                       onChanged: (value) {
//                         // Menyimpan perubahan nama
//                         eventModel.location = value;
//                       },
//                     ),
//                     SizedBox(height: 16),

//                     TextFormField(
//                       initialValue: eventModel.organizer,
//                       decoration: InputDecoration(labelText: 'Event organizer'),
//                       onChanged: (value) {
//                         // Menyimpan perubahan nama
//                         eventModel.organizer = value;
//                       },
//                     ),
//                     SizedBox(height: 16),

//                     TextFormField(
//                       initialValue: eventModel.description,
//                       decoration: InputDecoration(labelText: 'Event description'),
//                       onChanged: (value) {
//                         // Menyimpan perubahan nama
//                         eventModel.description = value;
//                       },
//                     ),
//                     SizedBox(height: 16),

//                     TextFormField(
//                       initialValue: eventModel.information,
//                       decoration: InputDecoration(labelText: 'Event information'),
//                       onChanged: (value) {
//                         // Menyimpan perubahan nama
//                         eventModel.information = value;
//                       },
//                     ),
//                     SizedBox(height: 16),
//                   ],
//                 );
//               },
//             ),
//             LargeButton(
//               onPressed: () {
//                 // Simpan perubahan ke Firestore
//                 _eventController.updateEvent(_eventNotifier.value).then((_) {
//                   // Kembali ke halaman sebelumnya setelah update
//                   Navigator.pop(context);
//                 }).catchError((e) {
//                   // Tampilkan pesan error jika gagal
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Failed to update eventModel: $e')),
//                   );
//                 });
//               },
//               label: 'Save Changes',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
