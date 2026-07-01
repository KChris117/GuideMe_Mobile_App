// import 'package:flutter/material.dart';
// // import 'package:guideme/core/constants/colors.dart';
// import 'package:guideme/core/constants/constants.dart';

// class SearchWidget extends StatefulWidget {
//   final Function(String) onSearchChanged;

//   const SearchWidget({super.key, required this.onSearchChanged});

//   @override
//   _SearchWidgetState createState() => _SearchWidgetState();
// }

// class _SearchWidgetState extends State<SearchWidget> {
//   // Mendeklarasikan controller di dalam State untuk menjaga status teks
//   late TextEditingController _searchController;

//   @override
//   void initState() {
//     super.initState();
//     // Menginisialisasi controller
//     _searchController = TextEditingController();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose(); // Pastikan untuk membersihkan controller saat widget dihancurkan
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12.0),
//       child: TextField(
//         controller: _searchController, // Menggunakan controller yang sudah dikelola
//         cursorColor: AppColors.primaryColor,
//         onChanged: (text) {
//           widget.onSearchChanged(text); // Mengirimkan perubahan teks ke callback
//         },
//         decoration: InputDecoration(
//           labelText: 'Search..',
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(
//               color: AppColors.primaryColor, // Warna border
//               width: 2.0, // Menambahkan ketebalan border
//             ),
//           ),
//           prefixIcon: Icon(AppIcons.searchBold),
//           suffixIcon: _searchController.text.isNotEmpty
//               ? IconButton(
//                   icon: const Icon(Icons.clear),
//                   onPressed: () {
//                     _searchController.clear(); // Menghapus teks menggunakan controller
//                     widget.onSearchChanged(''); // Mengirimkan pencarian kosong
//                     FocusScope.of(context).unfocus(); // Menutup keyboard
//                   },
//                 )
//               : null,
//           contentPadding: EdgeInsets.symmetric(vertical: 10.0),
//         ),
//       ),
//     );
//   }
// }

// // class SearchWidget extends StatefulWidget {
// //   final Function(String) onSearchChanged;

// //   const SearchWidget({super.key, required this.onSearchChanged});

// //   @override
// //   _SearchWidgetState createState() => _SearchWidgetState();
// // }

// // class _SearchWidgetState extends State<SearchWidget> {
// //   String searchText = ''; // Menyimpan status teks yang dimasukkan

// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 12.0),
// //       child: TextField(
// //         cursorColor: AppColors.primaryColor,
// //         onChanged: (text) {
// //           setState(() {
// //             searchText = text; // Menyimpan teks yang dimasukkan
// //           });
// //           widget.onSearchChanged(text); // Mengirimkan perubahan teks ke callback
// //         },
// //         controller: TextEditingController(text: searchText),
// //         decoration: InputDecoration(
// //           labelText: 'Search..',
// //           border: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(8.0),
// //             // borderSide: BorderSide(color: Colors.grey),
// //           ),
// //           focusedBorder: OutlineInputBorder(
// //             borderSide: BorderSide(
// //               color: AppColors.primaryColor, // Warna border
// //               width: 2.0, // Menambahkan ketebalan border
// //             ),
// //           ),
// //           prefixIcon: Icon(AppIcons.searchBold),
// //           suffixIcon: searchText.isNotEmpty
// //               ? IconButton(
// //                   icon: const Icon(Icons.clear),
// //                   onPressed: () {
// //                     setState(() {
// //                       searchText = ''; // Menghapus teks
// //                     });
// //                     widget.onSearchChanged(''); // Mengirimkan pencarian kosong
// //                     FocusScope.of(context).unfocus(); // Menutup keyboard
// //                   },
// //                 )
// //               : null,
// //           contentPadding: EdgeInsets.symmetric(vertical: 10.0),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // import 'package:flutter/material.dart';

// class buttonSearch extends StatefulWidget {
//   final Function(String) onSearchChanged;

//   const buttonSearch({super.key, required this.onSearchChanged});

//   @override
//   _buttonSearchState createState() => _buttonSearchState();
// }

// class _buttonSearchState extends State<buttonSearch> {
//   bool _isSearchActive = false;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12.0),
//       child: _isSearchActive
//           ? TextField(
//               onChanged: widget.onSearchChanged,
//               decoration: InputDecoration(
//                 labelText: 'Search..',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                   borderSide: BorderSide(color: Colors.grey),
//                 ),
//                 prefixIcon: Icon(Icons.search),
//                 contentPadding: EdgeInsets.symmetric(vertical: 10.0),
//               ),
//             )
//           : IconButton(
//               icon: Icon(Icons.search),
//               onPressed: () {
//                 setState(() {
//                   _isSearchActive = true; // Menyembunyikan tombol pencarian dan menampilkan TextField
//                 });
//               },
//             ),
//     );
//   }
// }

// class SearchWidget2 extends StatefulWidget {
//   final Function(String) onSearchChanged;

//   const SearchWidget2({super.key, required this.onSearchChanged});

//   @override
//   _SearchWidget2State createState() => _SearchWidget2State();
// }

// class _SearchWidget2State extends State<SearchWidget2> {
//   String searchText = ''; // Menyimpan status teks yang dimasukkan

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       onChanged: (text) {
//         setState(() {
//           searchText = text; // Menyimpan teks yang dimasukkan
//         });
//         widget.onSearchChanged(text); // Menyampaikan perubahan teks
//       },
//       // onChanged: onSearchChanged,
//       decoration: InputDecoration(
//         labelText: 'Search..',
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8.0),
//           borderSide: BorderSide(color: Colors.grey),
//         ),
//         prefixIcon: Icon(Icons.search),
//         suffixIcon: searchText.isNotEmpty
//             ? IconButton(
//                 icon: const Icon(Icons.clear),
//                 onPressed: () {
//                   setState(() {
//                     searchText = ''; // Menghapus teks
//                   });
//                   widget.onSearchChanged(''); // Mengirimkan pencarian kosong
//                   FocusScope.of(context).unfocus(); // Menutup keyboard
//                 },
//               )
//             : null,
//         contentPadding: EdgeInsets.symmetric(vertical: 10.0),
//       ),
//     );
//   }
// }
