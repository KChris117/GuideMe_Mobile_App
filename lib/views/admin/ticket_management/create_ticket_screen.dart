import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guideme/controllers/category_controller.dart';
import 'package:guideme/controllers/ticket_controller.dart';
import 'package:guideme/models/ticket_model.dart';
import 'package:guideme/widgets/custom_form.dart';
import 'package:guideme/widgets/custom_snackbar.dart';
import 'package:guideme/widgets/widgets.dart';

class CreateTicketManagementScreen extends StatefulWidget {
  const CreateTicketManagementScreen({super.key});

  @override
  _CreateTicketManagementScreenState createState() => _CreateTicketManagementScreenState();
}

class _CreateTicketManagementScreenState extends State<CreateTicketManagementScreen> {
  final TicketController _ticketController = TicketController();
  final CategoryController _categoryController = CategoryController();
  final _formKey = GlobalKey<FormState>();

  // Input field controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _informationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  // Waktu buka dan tutup
  Timestamp? _openingTime;
  Timestamp? _closingTime;

  String? selectedCategory;
  String? selectedSubcategory;
  String? selectedName;
  String? selectedRecommendationId;
  String? selectedStatus;
  double? rating;
  // int? stock;

  // mereset map setiap membuat halaman
  @override
  void initState() {
    super.initState();
  }

  Future<void> saveTicket() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      // Validasi form
      if (selectedCategory != null && selectedName != null && selectedName != null) {
        var ticketData = await _ticketController.getTicketData(selectedCategory!, selectedName!);

        if (ticketData != null) {
          double mainRating = (ticketData['rating'] ?? 0.0) as double;
          int mainPrice = (ticketData['price'] ?? 0);
          String mainImageUrl = ticketData['imageUrl'] ?? ''; // Gantilah default jika diperlukan
          String mainLocation = ticketData['location'] ?? ''; // Gantilah default jika diperlukan
          String mainOrganizer = ticketData['organizer'] ?? ''; // Gantilah default jika diperlukan
          String mainDescription = ticketData['description'] ?? ''; // Gantilah default jika diperlukan
          String mainInformation = ticketData['information'] ?? ''; // Gantilah default jika diperlukan
          // String mainStatus = ticketData['status'];
          Timestamp mainClosingTime = (ticketData['closingTime'] ?? Timestamp.now());
          Timestamp mainOpeningTime = (ticketData['openingTime'] ?? Timestamp.now());

          TicketModel newTicketModel = TicketModel(
            ticketId: '',
            recommendationId: selectedRecommendationId ?? '',
            name: selectedName,
            title: _titleController.text.isEmpty ? null : _titleController.text,
            location: mainLocation,
            organizer: mainOrganizer,
            category: selectedCategory!,
            subcategory: selectedSubcategory!,
            description: _descriptionController.text.isNotEmpty ? _descriptionController.text : mainDescription,
            information: _informationController.text.isNotEmpty ? _informationController.text : mainInformation,
            imageUrl: mainImageUrl,
            rating: mainRating,
            stock: int.tryParse(_stockController.text) ?? 100,
            price: int.tryParse(_priceController.text) ?? mainPrice,
            status: selectedStatus ?? 'available',
            openingTime: _openingTime ?? mainOpeningTime,
            closingTime: _closingTime ?? mainClosingTime,
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
          );
          try {
            // Memanggil fungsi addTicket untuk menyimpan event dan galeri ke Firestore
            await _ticketController.addTicket(newTicketModel);

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Ticket created successfully'),
            ));
            Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Failed to create ticket: $e'),
            ));
          }
        }
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text('Please complete all fields'),
        // ));
        DangerSnackBar.show(context, 'Please complete all fields');
      }
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text('Please complete all fields correctly'),
      // ));
      // DangerFloatingSnackBar.show(context: context, message: 'Please complete all fields correctly');
      DangerSnackBar.show(context, 'Please complete all fields correctly');
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
                CustomFormTitle(firstText: 'Create Ticket', secondText: 'Design your data exactly you want it.'),
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

                // StreamBuilder<List<String>>(
                //   stream: selectedSubcategory != null ? _ticketController.getTicketNames(selectedCategory!, selectedSubcategory!) : Stream.value([]),
                //   builder: (context, snapshot) {
                //     if (!snapshot.hasData) {
                //       return TextDropdown(
                //         label: 'Subcategory',
                //         items: snapshot.data ?? [],
                //         enabled: false,
                //       );
                //     }
                //     return TextDropdown(
                //       label: 'Name',
                //       items: snapshot.data ?? [],
                //       onChanged: (value) {
                //         setState(() {
                //           selectedName = value; // Simpan nama yang dipilih
                //         });
                //       },
                //       validator: (value) {
                //         if (value == null || value.isEmpty) {
                //           return 'Please select a name';
                //         }
                //         return null;
                //       },
                //     );
                //   },
                // ),

                // Dropdown untuk memilih name
                StreamBuilder<List<Map<String, String>>>(
                  stream: selectedSubcategory != null ? _ticketController.getTicketNames(selectedCategory!, selectedSubcategory!) : Stream.value([]),
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

                // deskripsi Ticket
                TextForm(
                  controller: _titleController,
                  label: 'Ticket Title',
                  hintText: 'Enter ticket title here..',
                  // validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
                  useDefaultValidator: false,
                ),
                SizedBox(height: 16),

                // deskripsi Ticket
                TextArea(
                  controller: _descriptionController,
                  label: 'Ticket Description',
                  hintText: 'You have already entered a description.',
                  useDefaultValidator: false,
                ),
                SizedBox(height: 16),

                // informasi Ticket
                TextArea(
                  controller: _informationController,
                  label: 'Ticket Information',
                  hintText: 'You have already entered a information.',
                  useDefaultValidator: false,
                ),
                SizedBox(height: 16),

                // price Ticket
                TextForm(
                  controller: _priceController,
                  label: 'Ticket Price',
                  hintText: "You've set a price before",
                  keyboardType: TextInputType.number, // Hanya angka yang dapat dimasukkan
                  useDefaultValidator: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Membatasi input hanya angka
                  ],
                ),
                SizedBox(height: 16),

                // price Ticket
                TextForm(
                  controller: _stockController,
                  label: 'Ticket Stock',
                  hintText: "Enter ticket stock here",
                  keyboardType: TextInputType.number, // Hanya angka yang dapat dimasukkan
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Membatasi input hanya angka
                  ],
                ),
                SizedBox(height: 16),

                TextDropdown(
                  label: 'Status',
                  hint: "Select a ticket status (Default value is available)",
                  items: ['available', 'unavalaible'],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                  },
                ),
                SizedBox(height: 16),

                // Waktu Buka
                DateTimePicker(
                  title: 'Opening Date Time',
                  subtitle: "You've set an opening date time before",
                  selectedTime: _openingTime,
                  onDateTimeSelected: (selectedTime) {
                    setState(() {
                      _openingTime = selectedTime;
                    });
                  },
                ),
                SizedBox(height: 16),

                // Waktu Tutup
                DateTimePicker(
                  title: 'Closing Date Time',
                  subtitle: "You've set an opening date time before",
                  selectedTime: _closingTime,
                  onDateTimeSelected: (selectedTime) {
                    setState(() {
                      _closingTime = selectedTime;
                    });
                  },
                ),
                SizedBox(height: 60),

                // Tombol Simpan Ticket
                // Align(
                //   alignment: Alignment.bottomRight,
                //   child: MediumButton(
                //     onPressed: saveTicket, // Memanggil fungsi saveTicket ketika tombol ditekan
                //     label: 'Save',
                //   ),
                // ),
                // SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: MediumButton(
        onPressed: saveTicket,
        label: 'Save Ticket',
      ),
      bottomNavigationBar: AdminBottomNavBar(selectedIndex: 0),
    );
  }
}
