import 'package:guideme/models/gallery_model.dart';
// import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:guideme/controllers/category_controller.dart';
import 'package:guideme/controllers/destination_controller.dart';
import 'package:guideme/models/destination_model.dart';
import 'package:guideme/widgets/custom_card.dart';
import 'package:guideme/widgets/custom_form.dart';
import 'package:guideme/widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateDestinationScreen extends StatefulWidget {
  const CreateDestinationScreen({super.key});

  @override
  _createDestinationScreenState createState() => _createDestinationScreenState();
}

class _createDestinationScreenState extends State<CreateDestinationScreen> {
  final DestinationController _destinationController = DestinationController();
  // final GalleryController _galleryController = GalleryController();
  final CategoryController _categoryController = CategoryController();
  final MapController _mapController = MapController();
  final _formKey = GlobalKey<FormState>();

  // Input field controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _organizerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _informationController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController(text: '0.0');
  final TextEditingController _priceController = TextEditingController();

  // Waktu buka dan tutup
  Timestamp? _openingTime;
  Timestamp? _closingTime;

  String _imageUrl = '';
  bool _isMapExpanded = true;
  LatLng? _selectedLocation;
  String? _selectedCategory = 'destination';
  String? _selectedSubcategory;
  String? selectedStatus;

  File? _imageFile;
  List<Uint8List> _imageBytesList = [];
  bool _isLoading = false;

  // mereset map setiap membuat halaman
  @override
  void initState() {
    super.initState();
    _isMapExpanded = false;
  }

  // // Fungsi untuk memilih gambar dan memperbarui UI
  // Future<void> _pickImage() async {
  //   String? imagePath = await _galleryController.pickImage();
  //   if (imagePath != null) {
  //     setState(() {
  //       _imageUrl = imagePath;
  //     });
  //   }
  // }

  Future<void> _pickImage() async {
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
  }

  Future<String?> uploadImage(Uint8List bytes, int index) async {
    final name = _nameController.text;
    final category = _selectedCategory ?? 'uncategorized';
    final sanitizedFileName = '${name}_${category}_${DateTime.now().millisecondsSinceEpoch}_$index'.replaceAll(' ', '_');
    final path = 'uploads/$sanitizedFileName.jpg';
    try {
      final uploadPath = await Supabase.instance.client.storage.from('images').uploadBinary(path, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));
      if (uploadPath.isNotEmpty) {
        return Supabase.instance.client.storage.from('images').getPublicUrl(path);
      }
    } catch (error) {
      print('Upload error: $error');
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
                CustomFormTitle(firstText: 'Create Destination', secondText: 'Design your data exactly you want it.'),
                // Nama Destination
                TextForm(
                  controller: _nameController,
                  label: 'Destination Name',
                  validator: (value) => value == null || value.isEmpty ? 'Name is required' : null,
                  onChanged: (value) {
                    _nameController.value = TextEditingValue(
                      text: value,
                      selection: _nameController.selection,
                    );
                  },
                ),
                SizedBox(height: 16),

                // lokasi Destination
                TextForm(
                  controller: _locationController,
                  label: 'Destination Location',
                  validator: (value) => value == null || value.isEmpty ? 'Location is required' : null,
                  onChanged: (value) {
                    _locationController.value = TextEditingValue(
                      text: value,
                      selection: _locationController.selection,
                    );
                  },
                ),
                SizedBox(height: 16),

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
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          height: _isMapExpanded ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height / 4,
                          width: double.infinity,
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: LatLng(1.1024563877808338, 104.03884839012828),
                              onTap: (_, point) {
                                setState(() {
                                  _selectedLocation = point;
                                });
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", userAgentPackageName: 'com.example.guideme', // Updated URL without subdomains
                              ),
                              if (_selectedLocation != null)
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: _selectedLocation!,
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
                SizedBox(height: 16),

                // organizer Destination
                TextForm(
                  label: 'Destination Organizer',
                  controller: _organizerController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Organizer is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _organizerController.value = TextEditingValue(
                      text: value,
                      selection: _organizerController.selection,
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
                    // return TextDropdown(
                    //   label: 'Category',
                    //   items: snapshot.data!, // Menggunakan data kategori yang diterima
                    //   onChanged: (value) {
                    //     setState(() {
                    //       _selectedCategory = value;
                    //       _selectedSubcategory = null; // Reset subcategory ketika kategori berubah
                    //     });
                    //   },
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Please select a category';
                    //     }
                    //     return null;
                    //   },
                    // );
                    return TextDropdown(
                      label: 'Category',
                      items: ['destination'], // Hanya memiliki satu item tetap
                      value: _selectedCategory, // Menampilkan nilai _selectedCategory
                      enabled: false, // Dropdown dapat dipilih (diubah)
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value ?? 'destination'; // Memperbarui _selectedCategory ketika ada perubahan
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

                // Dropdown untuk memilih subcategory berdasarkan kategori yang dipilih
                if (_selectedCategory != null)
                  StreamBuilder<List<String>>(
                    stream: _categoryController.getSubcategories(_selectedCategory!), // Ambil subcategories berdasarkan kategori
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      return TextDropdown(
                        label: 'Subcategory',
                        items: snapshot.data!, // Menggunakan subcategories yang diterima
                        onChanged: (value) {
                          setState(() {
                            _selectedSubcategory = value;
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
                SizedBox(height: _selectedCategory != null ? 16 : 0),

                // deskripsi Ticket
                TextArea(
                  controller: _descriptionController,
                  label: 'Destination Description',
                  hintText: 'Enter destination description here..',
                  validator: (value) => value == null || value.isEmpty ? 'Description is required' : null,
                ),
                SizedBox(height: 16),

                // informasi Destination
                TextArea(
                  controller: _informationController,
                  label: 'Destination Information',
                  hintText: 'Enter destination information here..',
                  validator: (value) => value == null || value.isEmpty ? 'Information is required' : null,
                ),
                SizedBox(height: 16),

                // price Destination
                TextForm(
                  controller: _priceController,
                  label: 'Destination Price',
                  hintText: 'Enter destination price here..',
                  keyboardType: TextInputType.number, // Hanya angka yang dapat dimasukkan
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Membatasi input hanya angka
                  ],
                  validator: (value) => value == null || value.isEmpty ? 'Price is required' : null,
                ),
                SizedBox(height: 16),

                TextDropdown(
                  label: 'Status',
                  items: ['open', 'close'],
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
                  onPressed: _pickImage,
                ),

                // Waktu Buka
                DateTimePicker(
                  title: 'Opening Date Time',
                  subtitle: _openingTime != null ? _openingTime!.toDate().toString() : 'Select opening time',
                  selectedTime: _openingTime, // Menggunakan Timestamp sebagai default
                  onDateTimeSelected: (selectedTime) {
                    setState(() {
                      _openingTime = selectedTime; // Mengupdate openingTimeNotifier
                    });
                  },
                ),
                SizedBox(height: 20),

                // Waktu Tutup
                DateTimePicker(
                  title: 'Closing Date Time',
                  subtitle: _closingTime != null ? _closingTime!.toDate().toString() : 'Select closing time',
                  selectedTime: _closingTime, // Menggunakan Timestamp sebagai default
                  onDateTimeSelected: (selectedTime) {
                    setState(() {
                      _closingTime = selectedTime; // Mengupdate closingTimeNotifier
                    });
                  },
                ),

                // // Waktu Tutup
                // ListTile(
                //   title: Text('Closing Time'),
                //   subtitle: Text(_closingTime != null ? _closingTime!.toDate().toString() : 'Select closing time'),
                //   trailing: Icon(Icons.access_time),
                //   onTap: () async {
                //     // Menampilkan DatePicker untuk memilih tanggal
                //     DateTime? selectedDate = await showDatePicker(
                //       context: context,
                //       initialDate: DateTime.now(),
                //       firstDate: DateTime(2000),
                //       lastDate: DateTime(2101),
                //     );

                //     // Jika tanggal dipilih, lanjutkan memilih waktu
                //     if (selectedDate != null) {
                //       TimeOfDay? time = await showTimePicker(
                //         context: context,
                //         initialTime: TimeOfDay.now(),
                //       );

                //       // Jika waktu dipilih, gabungkan dengan tanggal dan simpan
                //       if (time != null) {
                //         setState(() {
                //           _closingTime = Timestamp.fromDate(DateTime(
                //             selectedDate.year,
                //             selectedDate.month,
                //             selectedDate.day,
                //             time.hour,
                //             time.minute,
                //           ));
                //         });
                //       }
                //     }
                //   },
                // ),
                // SizedBox(height: 16),

                // Tombol Simpan Destination
                // Align(
                //   alignment: Alignment.bottomRight,
                //   child: MediumButton(
                //     onPressed: saveDestination, // Memanggil fungsi saveDestination ketika tombol ditekan
                //     label: 'Save',
                //   ),
                // ),
                SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: MediumButton(
        onPressed: saveDestination,
        label: 'Save Destination',
      ),
      bottomNavigationBar: AdminBottomNavBar(selectedIndex: 0),
    );
  }
}
