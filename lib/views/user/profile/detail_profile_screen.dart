import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guideme/widgets/custom_appbar.dart';
import 'package:guideme/widgets/custom_button.dart';
import 'package:guideme/widgets/custom_navbar.dart';
import 'package:guideme/widgets/custom_title.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class DetailProfileScreen extends StatefulWidget {
  const DetailProfileScreen({Key? key}) : super(key: key);

  @override
  _DetailProfileScreenState createState() => _DetailProfileScreenState();
}

class _DetailProfileScreenState extends State<DetailProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;

  // Controllers for each form field
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _profileImageUrlController = TextEditingController();

  String? _profileImageUrl;
  File? _profileImage;
  String? _selectedCountry; // Make _selectedCountry a String
  final List<String> _countries = [
    'Afghanistan',
    'Albania',
    'Algeria',
    'Andorra',
    'Angola',
    'Antigua and Barbuda',
    'Argentina',
    'Armenia',
    'Australia',
    'Austria',
    'Azerbaijan',
    'Bahamas',
    'Bahrain',
    'Bangladesh',
    'Barbados',
    'Belarus',
    'Belgium',
    'Belize',
    'Benin',
    'Bhutan',
    'Bolivia',
    'Bosnia and Herzegovina',
    'Botswana',
    'Brazil',
    'Brunei',
    'Bulgaria',
    'Burkina Faso',
    'Burundi',
    'Cabo Verde',
    'Cambodia',
    'Cameroon',
    'Canada',
    'Central African Republic',
    'Chad',
    'Chile',
    'China',
    'Colombia',
    'Comoros',
    'Congo (Congo-Brazzaville)',
    'Costa Rica',
    'Croatia',
    'Cuba',
    'Cyprus',
    'Czech Republic (Czechia)',
    'Denmark',
    'Djibouti',
    'Dominica',
    'Dominican Republic',
    'Ecuador',
    'Egypt',
    'El Salvador',
    'Equatorial Guinea',
    'Eritrea',
    'Estonia',
    'Eswatini',
    'Ethiopia',
    'Fiji',
    'Finland',
    'France',
    'Gabon',
    'Gambia',
    'Georgia',
    'Germany',
    'Ghana',
    'Greece',
    'Grenada',
    'Guatemala',
    'Guinea',
    'Guinea-Bissau',
    'Guyana',
    'Haiti',
    'Honduras',
    'Hungary',
    'Iceland',
    'India',
    'Indonesia',
    'Iran',
    'Iraq',
    'Ireland',
    'Israel',
    'Italy',
    'Jamaica',
    'Japan',
    'Jordan',
    'Kazakhstan',
    'Kenya',
    'Kiribati',
    'Korea (North)',
    'Korea (South)',
    'Kuwait',
    'Kyrgyzstan',
    'Laos',
    'Latvia',
    'Lebanon',
    'Lesotho',
    'Liberia',
    'Libya',
    'Liechtenstein',
    'Lithuania',
    'Luxembourg',
    'Madagascar',
    'Malawi',
    'Malaysia',
    'Maldives',
    'Mali',
    'Malta',
    'Marshall Islands',
    'Mauritania',
    'Mauritius',
    'Mexico',
    'Micronesia',
    'Moldova',
    'Monaco',
    'Mongolia',
    'Montenegro',
    'Morocco',
    'Mozambique',
    'Myanmar (Burma)',
    'Namibia',
    'Nauru',
    'Nepal',
    'Netherlands',
    'New Zealand',
    'Nicaragua',
    'Niger',
    'Nigeria',
    'North Macedonia',
    'Norway',
    'Oman',
    'Pakistan',
    'Palau',
    'Panama',
    'Papua New Guinea',
    'Paraguay',
    'Peru',
    'Philippines',
    'Poland',
    'Portugal',
    'Qatar',
    'Romania',
    'Russia',
    'Rwanda',
    'Saint Kitts and Nevis',
    'Saint Lucia',
    'Saint Vincent and the Grenadines',
    'Samoa',
    'San Marino',
    'Sao Tome and Principe',
    'Saudi Arabia',
    'Senegal',
    'Serbia',
    'Seychelles',
    'Sierra Leone',
    'Singapore',
    'Slovakia',
    'Slovenia',
    'Solomon Islands',
    'Somalia',
    'South Africa',
    'South Sudan',
    'Spain',
    'Sri Lanka',
    'Sudan',
    'Suriname',
    'Sweden',
    'Switzerland',
    'Syria',
    'Taiwan',
    'Tajikistan',
    'Tanzania',
    'Thailand',
    'Timor-Leste',
    'Togo',
    'Tonga',
    'Trinidad and Tobago',
    'Tunisia',
    'Turkey',
    'Turkmenistan',
    'Tuvalu',
    'Uganda',
    'Ukraine',
    'United Arab Emirates',
    'United Kingdom',
    'United States of America',
    'Uruguay',
    'Uzbekistan',
    'Vanuatu',
    'Vatican City',
    'Venezuela',
    'Vietnam',
    'Yemen',
    'Zambia',
    'Zimbabwe'
  ];
  // Example country list

  @override
  void initState() {
    super.initState();
    _loadData(); // Load data from Firestore when the widget is initialized
    _selectedCountry = 'Indonesia';
  }

  Future<void> _saveData() async {
    try {
      print(user!.uid);
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'uid': user!.uid,
        'username': _usernameController.text,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'country': _selectedCountry, // Save the selected country
        'province': _stateController.text,
        'city': _cityController.text,
        'street': _streetController.text,
        'post_code': _postalCodeController.text,
        'birth_date': _birthDateController.text,
        'role': _roleController.text,
        'email': user?.email,
        'profilePicture': _profileImageUrlController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your data has been saved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving your data, please try again $e')),
      );
    }
  }

  Future<void> _loadData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _usernameController.text = data['username'] ?? '';
          _firstNameController.text = data['first_name'] ?? '';
          _lastNameController.text = data['last_name'] ?? '';
          // _selectedCountry = data['country'] ?? _countries.first; // Set to first country if null
          _selectedCountry = data['country'] ?? 'Indonesia';
          _stateController.text = data['province'] ?? '';
          _cityController.text = data['city'] ?? '';
          _streetController.text = data['street'] ?? '';
          _postalCodeController.text = data['post_code'] ?? '';
          _birthDateController.text = data['birth_date'] ?? '';
          _roleController.text = data['role'] ?? '';
          _profileImageUrlController.text = data['profilePicture'] ?? '';
          _profileImageUrl = data['profilePicture'];
        });
      } else {
        // Jika dokumen tidak ada, set _selectedCountry ke 'Indonesia'
        setState(() {
          _selectedCountry = 'Indonesia';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(title: ''),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TitlePage(title: 'Your Details', subtitle: ' Enhance your information'),
              const SizedBox(height: 20),
              _profileImage != null
                  ? CircleAvatar(
                      radius: 50,
                      backgroundImage: FileImage(_profileImage!),
                    )
                  : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                      ? CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(_profileImageUrl!),
                        )
                      : CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey,
                          child: const Icon(Icons.person, size: 40),
                        ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _profileImageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Profile Picture URL',
                ),
              ),
              // Tampilkan email (readonly)
              TextFormField(
                initialValue: user?.email ?? 'No email available',
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              // TextFormField untuk Username dan lainnya
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
              ),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                ),
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                ),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCountry,
                decoration: const InputDecoration(
                  labelText: 'Country',
                ),
                items: _countries.map((String country) {
                  return DropdownMenuItem<String>(
                    value: country,
                    child: Text(country),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCountry = newValue;
                  });
                },
                // Add an additional check to ensure that the value is valid.
                validator: (value) {
                  if (value == null || !_countries.contains(value)) {
                    return 'Please select a valid country';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(
                  labelText: 'Province',
                ),
              ),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                ),
              ),
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                ),
              ),
              TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(
                  labelText: 'Postal Code',
                ),
              ),
              TextFormField(
                controller: _birthDateController,
                readOnly: true, // Agar tidak bisa mengetik manual
                decoration: const InputDecoration(
                  labelText: 'Birth Date',
                  suffixIcon: Icon(Icons.calendar_today), // Menambahkan ikon kalender
                ),
                onTap: () async {
                  // Menampilkan date picker
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900), // Tanggal awal yang bisa dipilih
                    lastDate: DateTime.now(), // Tanggal akhir yang bisa dipilih
                  );

                  if (selectedDate != null) {
                    // Jika pengguna memilih tanggal, format dan simpan
                    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate); // Format tanggal
                    setState(() {
                      _birthDateController.text = formattedDate; // Menampilkan tanggal yang dipilih
                    });
                  }
                },
              ),
              TextFormField(
                readOnly: true,
                controller: _roleController,
                decoration: const InputDecoration(
                  labelText: 'Role',
                ),
              ),
              const SizedBox(height: 30),

              Align(
                alignment: Alignment.centerRight,
                child: SmallButton(
                  label: 'Save',
                  onPressed: _saveData,
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: UserBottomNavBar(selectedIndex: 4),
    );
  }
}
