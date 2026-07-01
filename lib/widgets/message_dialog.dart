// import 'package:flutter/material.dart';

// // konstanta
// import 'package:guideme/core/constants/constants.dart';

// class MessageDialog extends StatelessWidget {
//   final String title;
//   final String content;

//   const MessageDialog({
//     super.key,
//     required this.title,
//     required this.content,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: AppColors.backgroundColor,
//       title: Text(
//         title,
//         style: AppTextStyles.subtitleStyle,
//       ),
//       content: Text(content),
//       actions: <Widget>[
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop(); // Menutup dialog
//           },
//           child: const Text(
//             'OK',
//             style: AppTextStyles.bodyBlack,
//           ),
//         ),
//       ],
//     );
//   }

//   // Fungsi untuk memanggil dialog ini dari luar dengan pesan yang dapat disesuaikan
//   static void showMessageDialog(BuildContext context, String title, String content) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return MessageDialog(
//           title: title, // Menampilkan judul yang diteruskan
//           content: content, // Menampilkan isi pesan yang diteruskan
//         );
//       },
//     );
//   }
// }
