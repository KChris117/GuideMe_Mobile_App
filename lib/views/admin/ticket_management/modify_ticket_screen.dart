import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guideme/controllers/category_controller.dart';
import 'package:guideme/controllers/ticket_controller.dart';
import 'package:guideme/models/ticket_model.dart';
import 'package:guideme/widgets/custom_form.dart';
import 'package:guideme/widgets/widgets.dart';

class ModifyTicketManagementScreen extends StatefulWidget {
  final TicketModel newTicketModel;

  const ModifyTicketManagementScreen({Key? key, required this.newTicketModel}) : super(key: key);

  @override
  _ModifyTicketManagementScreenState createState() => _ModifyTicketManagementScreenState();
}

class _ModifyTicketManagementScreenState extends State<ModifyTicketManagementScreen> {
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

  @override
  void initState() {
    super.initState();
    // Mengisi controller dengan data dari newTicketModel
    _titleController.text = widget.newTicketModel.title ?? '';
    _descriptionController.text = widget.newTicketModel.description ?? '';
    _informationController.text = widget.newTicketModel.information ?? '';
    _priceController.text = widget.newTicketModel.price.toString();
    _stockController.text = widget.newTicketModel.stock.toString();
    _openingTime = widget.newTicketModel.openingTime;
    _closingTime = widget.newTicketModel.closingTime;
    selectedCategory = widget.newTicketModel.category;
    selectedSubcategory = widget.newTicketModel.subcategory;
    selectedName = widget.newTicketModel.name;
    selectedRecommendationId = widget.newTicketModel.recommendationId;
    selectedStatus = widget.newTicketModel.status;
  }

  Future<void> saveTicket() async {
    if (_formKey.currentState!.validate()) {
      // Validasi form
      if (selectedCategory != null && selectedName != null) {
        TicketModel updatedTicketModel = TicketModel(
          ticketId: widget.newTicketModel.ticketId,
          recommendationId: selectedRecommendationId ?? '',
          name: selectedName,
          title: _titleController.text.isEmpty ? null : _titleController.text,
          location: widget.newTicketModel.location,
          organizer: widget.newTicketModel.organizer,
          category: selectedCategory!,
          subcategory: selectedSubcategory!,
          description: _descriptionController.text,
          information: _informationController.text,
          imageUrl: widget.newTicketModel.imageUrl,
          rating: widget.newTicketModel.rating,
          stock: int.tryParse(_stockController.text) ?? widget.newTicketModel.stock,
          price: int.tryParse(_priceController.text) ?? widget.newTicketModel.price,
          status: selectedStatus ?? 'available',
          openingTime: _openingTime ?? widget.newTicketModel.openingTime,
          closingTime: _closingTime ?? widget.newTicketModel.closingTime,
          createdAt: widget.newTicketModel.createdAt,
          updatedAt: Timestamp.now(), // Update timestamp saat diubah
        );

        try {
          // Memanggil fungsi updateTicket untuk memperbarui tiket di Firestore
          await _ticketController.updateTicket(updatedTicketModel);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Ticket updated successfully'),
          ));
          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to update ticket: $e'),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please complete all fields'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please complete all fields correctly'),
      ));
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
                CustomFormTitle(firstText: 'Modify Ticket', secondText: 'Update your ticket details.'),
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
                      value: selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
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
                  stream: selectedSubcategory != null ? _ticketController.getTicketNames(selectedCategory!, selectedSubcategory!) : Stream.value([]),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return TextDropdown(
                        label: 'Name',
                        items: [],
                        enabled: false,
                      );
                    }

                    List<Map<String, String>> tickets = snapshot.data!;

                    return TextDropdown(
                      label: 'Name',
                      items: tickets.map((ticket) => ticket['name']!).toList(),
                      value: selectedName,
                      onChanged: (value) {
                        final selectedTicket = tickets.firstWhere((ticket) => ticket['name'] == value);
                        setState(() {
                          selectedRecommendationId = selectedTicket['recommendationId'];
                          selectedName = value;
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return null; // Tidak ada kesalahan
                    }
                    return null; // Atau kembalikan null jika tidak ada kesalahan
                  },
                ),
                SizedBox(height: 16),

                // deskripsi Ticket
                TextArea(
                  controller: _descriptionController,
                  label: 'Ticket Description',
                  hintText: 'Enter ticket description here..',
                  validator: (value) => value == null || value.isEmpty ? 'Description is required' : null,
                ),
                SizedBox(height: 16),

                // informasi Ticket
                TextArea(
                  controller: _informationController,
                  label: 'Ticket Information',
                  hintText: 'Enter ticket information here..',
                  validator: (value) => value == null || value.isEmpty ? 'Information is required' : null,
                ),
                SizedBox(height: 16),

                // price Ticket
                TextForm(
                  controller: _priceController,
                  label: 'Ticket Price',
                  hintText: "Enter ticket price here",
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                SizedBox(height: 16),

                // stock Ticket
                TextForm(
                  controller: _stockController,
                  label: 'Ticket Stock',
                  hintText: "Enter ticket stock here",
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                SizedBox(height: 16),

                TextDropdown(
                  label: 'Status',
                  hint: "Select a ticket status",
                  items: ['available', 'unavailable'],
                  value: selectedStatus,
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
                  subtitle: "You've set a closing date time before",
                  selectedTime: _closingTime,
                  onDateTimeSelected: (selectedTime) {
                    setState(() {
                      _closingTime = selectedTime;
                    });
                  },
                ),
                // SizedBox(height: 16),

                // // Tombol Simpan Ticket
                // Align(
                //   alignment: Alignment.bottomRight,
                //   child: MediumButton(
                //     onPressed: saveTicket,
                //     label: 'Update',
                //   ),
                // ),
                SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: MediumButton(
        onPressed: saveTicket,
        label: 'Save Changes',
      ),
      bottomNavigationBar: AdminBottomNavBar(selectedIndex: 0),
    );
  }
}
