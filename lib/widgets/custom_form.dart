import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'dart:io';
// konstanta
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/models/category_model.dart';
import 'package:guideme/widgets/custom_button.dart';
import 'package:guideme/widgets/custom_card.dart';

class TextForm extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final ValueChanged<String>? onChanged; // Menambahkan parameter onChanged
  bool useDefaultValidator;
  final String? Function(String?)? validator;
  final bool? isDense;
  final bool isMultiline; // Menambahkan parameter untuk mendukung multiline
  final List<TextInputFormatter>? inputFormatters; // Menambahkan parameter inputFormatters
  final TextInputType? keyboardType; // Menambahkan parameter keyboardType

  TextForm({
    required this.controller,
    this.label,
    this.hintText,
    this.onChanged,
    this.useDefaultValidator = true, // Default ke true
    this.validator,
    this.isDense,
    this.isMultiline = false, // Default ke false
    List<TextInputFormatter>? inputFormatters, // Menambahkan parameter inputFormatters
    TextInputType? keyboardType,
  })  : inputFormatters = inputFormatters ?? [FilteringTextInputFormatter.allow(RegExp(r'.*'))], // Default input formatter
        keyboardType = keyboardType ?? (isMultiline ? TextInputType.multiline : TextInputType.text); // Mengatur keyboardType berdasarkan isMultiline

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: AppColors.primaryColor, // Anda bisa mengganti dengan warna yang diinginkan
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: label,
        hintText: hintText ?? 'Enter some hint here..',
        hintStyle: AppTextStyles.mediumGrey,
        labelStyle: AppTextStyles.headingBold,
        isDense: isDense ?? true, // Ukuran kotak lebih kecil
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.primaryColor, // Warna border saat fokus
            width: 2.0, // Menambahkan ketebalan border
          ),
        ),
      ),
      onChanged: onChanged,
      validator: (value) {
        // Pertama, jalankan validator khusus jika ada
        if (validator != null) {
          final customValidationResult = validator!(value);
          if (customValidationResult != null) {
            return customValidationResult; // Kembalikan hasil dari validator khusus jika ada kesalahan
          }
        }

        // Jika tidak ada kesalahan dari validator khusus dan useDefaultValidator adalah true, jalankan validator default
        if (useDefaultValidator) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value'; // Pesan kesalahan default
          }
        }

        return null; // Jika tidak ada kesalahan
      },
      maxLines: isMultiline ? null : 1, // Mengatur maxLines berdasarkan isMultiline
      inputFormatters: inputFormatters, // Mengatur inputFormatters
      keyboardType: keyboardType, // Mengatur keyboardType
    );
  }
}

class TextArea extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final ValueChanged<String>? onChanged; // Menambahkan parameter onChanged
  bool useDefaultValidator;
  final String? Function(String?)? validator;
  final bool? isDense;
  final int? maxLines;

  TextArea({
    required this.controller,
    this.label,
    this.hintText,
    this.onChanged,
    this.useDefaultValidator = true, // Default ke true
    this.validator,
    this.isDense,
    this.maxLines = null, // Default to 1 line, can be set to more for textarea
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: AppColors.primaryColor, // Anda bisa mengganti dengan warna yang diinginkan
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: label,
        hintText: hintText ?? 'Enter some hint here..',
        hintStyle: AppTextStyles.mediumBlack.copyWith(color: AppColors.secondaryColor),
        labelStyle: AppTextStyles.headingBold,
        isDense: isDense ?? true, // Ukuran kotak lebih kecil
        // contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Mengatur padding konten agar lebih kecil
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.primaryColor, // Warna border saat fokus
            width: 2.0, // Menambahkan ketebalan border
          ),
        ),
      ),
      onChanged: onChanged,
      validator: (value) {
        // Pertama, jalankan validator khusus jika ada
        if (validator != null) {
          final customValidationResult = validator!(value);
          if (customValidationResult != null) {
            return customValidationResult; // Kembalikan hasil dari validator khusus jika ada kesalahan
          }
        }

        // Jika tidak ada kesalahan dari validator khusus dan useDefaultValidator adalah true, jalankan validator default
        if (useDefaultValidator) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value'; // Pesan kesalahan default
          }
        }

        return null; // Jika tidak ada kesalahan
      },
      maxLines: maxLines, // Set maxLines to allow for textarea
    );
  }
}

class TextDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? value; // Parameter untuk menampilkan nilai yang dipilih
  final String? Function(String?)? validator; // Validator opsional
  final ValueChanged<String?>? onChanged; // Fungsi callback untuk menangani perubahan nilai dropdown
  final String? hint;
  final bool? enabled;

  const TextDropdown({
    super.key,
    required this.label,
    required this.items,
    this.value, // Menambahkan value untuk menampilkan pilihan yang sudah dipilih
    this.validator, // Validator opsional
    this.onChanged, // Menambahkan onChanged untuk menangani perubahan nilai
    this.hint,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value, // Menampilkan nilai yang dipilih
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: AppTextStyles.mediumBlack.copyWith(fontWeight: FontWeight.normal)),
              ))
          .toList(),
      onChanged: enabled == true ? onChanged : null,
      hint: Text(
        hint ?? 'Select an option..',
        style: AppTextStyles.mediumGrey,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.headingBold,
        isDense: true, // Ukuran kotak lebih kecil
        border: OutlineInputBorder(), // Menggunakan OutlineInputBorder
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: AppColors.primaryColor, // Border berubah warna saat fokus
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10), // Mengatur padding konten
      ),
      validator: validator, // Menambahkan validator di sini
    );
  }
}

class DateTimePicker extends StatelessWidget {
  final String title;
  final String subtitle;
  final Timestamp? selectedTime; // Mengganti nama menjadi lebih umum
  final Function(Timestamp) onDateTimeSelected;

  const DateTimePicker({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.selectedTime, // Mengganti nama parameter
    required this.onDateTimeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: AppColors.primaryColor, // Ganti dengan AppColors.primaryColor jika perlu
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.mediumWhiteBold, // Ganti dengan AppTextStyles.bodyWhiteBold jika perlu
                ),
                SizedBox(height: 4.0),
                Text(
                  selectedTime != null ? selectedTime!.toDate().toString() : subtitle,
                  style: AppTextStyles.mediumWhite, // Ganti dengan AppTextStyles.mediumWhite jika perlu
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              // Menampilkan DatePicker untuk memilih tanggal
              DatePicker.showDateTimePicker(
                context,
                showTitleActions: true,
                onConfirm: (date) {
                  onDateTimeSelected(Timestamp.fromDate(date));
                },
                currentTime: DateTime.now(),
                locale: LocaleType.en,
              );
            },
            icon: Icon(
              AppIcons.date, // Ganti dengan ikon yang sesuai
              color: AppColors.backgroundColor,
            ),
          ),
        ],
      ),
    );
  }
}

class DropdownCategory extends StatelessWidget {
  final String? selectedCategory;
  final Function(String?) onChanged;
  final List<CategoryModel> categories;
  final String label;
  final String? Function(String?)? validator;

  DropdownCategory({
    required this.selectedCategory,
    required this.onChanged,
    required this.categories,
    required this.label,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      hint: Text(
        'Select a category..',
        style: AppTextStyles.mediumGrey,
      ),
      value: selectedCategory,
      onChanged: onChanged,
      items: categories.map<DropdownMenuItem<String>>((CategoryModel category) {
        return DropdownMenuItem<String>(
          value: category.categoryId, // Menggunakan categoryId sebagai value
          child: Text(
            category.name,
            style: AppTextStyles.mediumBlack,
          ), // Menampilkan name sebagai teks di dropdown
        );
      }).toList(),

      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.headingBold,
        isDense: true, // Ukuran kotak lebih kecil
        border: OutlineInputBorder(), // Menggunakan OutlineInputBorder
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: AppColors.primaryColor, // Border berubah warna saat fokus
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10), // Mengatur padding konten
        floatingLabelBehavior: FloatingLabelBehavior.always, // Label selalu mengambang
      ),
      // focusedBorder: UnderlineInputBorder(
      //   borderSide: BorderSide(
      //     width: 2,
      //     color: Colors.blue, // Border berubah warna saat fokus
      //   ),
      // ),
      validator: validator, // Menambahkan validator di sini
    );
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class CustomSmallTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool? isDense;
  final int? maxLines;

  CustomSmallTextFormField({
    required this.controller,
    this.label,
    this.hintText,
    this.validator,
    this.isDense,
    this.maxLines = 1, // Default to 1 line, can be set to more for textarea
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: AppColors.primaryColor, // Anda bisa mengganti dengan warna yang diinginkan
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: AppTextStyles.smallStyle.copyWith(color: AppColors.secondaryColor),
        labelStyle: AppTextStyles.mediumBlack,
        isDense: isDense ?? true, // Ukuran kotak lebih kecil
        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Mengatur padding konten agar lebih kecil
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.primaryColor, // Warna border saat fokus
            width: 2.0, // Menambahkan ketebalan border
          ),
        ),
      ),
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a value';
            }
            return null;
          },
      maxLines: maxLines, // Set maxLines to allow for textarea
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final void Function(String)? onChanged; // Tambahkan onChanged untuk menangani perubahan
  final String? hint; // Tambahkan hint sebagai parameter opsional
  final int? minLines;
  final int? maxLines;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
    this.onChanged, // Menambahkan parameter onChanged
    this.hint, // Menambahkan parameter hint
    this.minLines,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryColor,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: const EdgeInsets.only(bottom: 8),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: AppColors.primaryColor,
            ),
          ),
          hintText: hint ?? 'Enter your data here..', // Menambahkan hint
          hintStyle: AppTextStyles.mediumBlack.copyWith(color: AppColors.secondaryColor, fontWeight: FontWeight.normal)),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged, // Menghubungkan onChanged ke widget TextFormField
      minLines: minLines ?? 1, // Menentukan jumlah baris minimum
      maxLines: null,
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? value; // Parameter untuk menampilkan nilai yang dipilih
  final String? Function(String?)? validator; // Validator opsional
  final ValueChanged<String?>? onChanged; // Fungsi callback untuk menangani perubahan nilai dropdown
  final String? hint;
  final bool? enabled;
  // final List<DropdownMenuItem<String>>? itemsDropdown;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.items,
    // this.itemsDropdown,
    this.value, // Menambahkan value untuk menampilkan pilihan yang sudah dipilih
    this.validator, // Validator opsional
    this.onChanged, // Menambahkan onChanged untuk menangani perubahan nilai
    this.hint,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value, // Menampilkan nilai yang dipilih
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
              ))
          .toList(),
      onChanged: enabled == true ? onChanged : null,
      hint: Text(hint ?? 'Select an option..', style: AppTextStyles.mediumBlack.copyWith(color: AppColors.secondaryColor, fontWeight: FontWeight.normal)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryColor, // Sesuaikan dengan warna label
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always, // Label selalu mengambang
        contentPadding: const EdgeInsets.only(bottom: 8),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey), // Border default
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: AppColors.primaryColor, // Border berubah warna saat fokus
          ),
        ),
      ),
      validator: validator, // Menambahkan validator di sini
    );
  }
}

class UploadImageWithPreview extends StatelessWidget {
  final String imageUrl; // Untuk menyimpan URL gambar yang dipilih
  final VoidCallback onPressed;

  const UploadImageWithPreview({
    super.key,
    required this.imageUrl,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Tombol Pilih Gambar
        UploadImageButton(
          onPressed: onPressed,
          label: 'Pick an image',
        ),
        SizedBox(height: 16), // Spacer di bawah tombol
        // Image Preview (Jika Gambar Tersedia)
        imageUrl.isNotEmpty
            ? GestureDetector(
                onTap: onPressed, // Pilih gambar lagi saat gambar ditekan
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15), // Sudut gambar melengkung
                  child: Container(
                    width: 200, // Lebar image
                    height: 200, // Tinggi image
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black45, // Shadow untuk efek depth
                          blurRadius: 10,
                          offset: Offset(5, 5),
                        ),
                      ],
                    ),
                    child: Image.file(
                      File(imageUrl), // Memuat gambar dari file
                      fit: BoxFit.cover, // Memastikan gambar penuh dalam kotak
                    ),
                  ),
                ),
              )
            : Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor, // Background abu-abu untuk preview kosong
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.image, // Ikon gambar jika belum ada gambar
                  size: 100,
                  color: AppColors.primaryColor,
                ),
              ),
        SizedBox(height: 16), // Spacer antara gambar dan tombol upload
      ],
    );
  }
}

class NewUploadImageWithPreview extends StatelessWidget {
  final File? imageFile;
  final Uint8List? imageBytes; // Untuk menyimpan file gambar yang dipilih
  final String? imageUrl; // URL gambar yang akan ditampilkan jika tidak ada file
  final VoidCallback onPressed; // Fungsi untuk memilih gambar

  const NewUploadImageWithPreview({
    super.key,
    required this.imageFile,
    this.imageBytes,
    required this.onPressed,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Tombol Pilih Gambar
        Align(
          alignment: Alignment.centerLeft,
          child: NewUploadImageButton(
            onPressed: onPressed,
            label: 'Pick an image',
          ),
        ),
        SizedBox(height: 8), // Spacer di bawah tombol
        // Image Preview (Jika Gambar Tersedia)
        imageBytes != null || imageFile != null || imageUrl != null
            ? GestureDetector(
                onTap: onPressed, // Pilih gambar lagi saat gambar ditekan
                child: MainCard(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5), // Sudut gambar melengkung
                    child: Container(
                      width: double.infinity, // Mengambil lebar penuh layar
                      height: 200, // Tinggi tetap untuk gambar
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.tertiaryColor, // Shadow untuk efek depth
                            blurRadius: 10,
                            offset: Offset(5, 5),
                          ),
                        ],
                      ),
                      child: imageBytes != null ? Image.memory(imageBytes!, fit: BoxFit.fitWidth) : imageFile != null
                          ? (kIsWeb
                              ? Image.network(
                                  imageFile!.path,
                                  fit: BoxFit.fitWidth,
                                )
                              : Image.file(
                                  imageFile!, // Memuat gambar dari file
                                  fit: BoxFit.fitWidth, // Memastikan gambar menyesuaikan lebar tanpa cropping
                                ))
                          : imageUrl != null
                              ? Image.network(
                                  imageUrl!, // Ganti dengan URL gambar dari network
                                  fit: BoxFit.fitWidth, // Memastikan gambar menyesuaikan lebar tanpa cropping
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.error); // Menampilkan ikon error jika gagal memuat gambar
                                  },
                                )
                              : Container(), // Jika tidak ada imageFile maupun imageUrl, kosong
                    ),
                  ),
                ),
              )
            : Container(
                width: double.infinity, // Lebar penuh
                height: 200, // Tinggi tetap
                decoration: BoxDecoration(
                  color: AppColors.tertiaryColor, // Background abu-abu untuk preview kosong
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondaryColor,
                      blurRadius: 5,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    AppIcons.gallery, // Ikon gambar jika belum ada gambar
                    size: 100,
                    color: AppColors.secondaryColor,
                  ),
                ),
              ),
        SizedBox(height: 24), // Spacer antara gambar dan tombol upload
      ],
    );
  }
}
