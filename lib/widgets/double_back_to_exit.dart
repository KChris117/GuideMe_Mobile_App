// import 'package:flutter/material.dart';
// import 'package:guideme/core/constants/colors.dart';
// import 'package:guideme/widgets/custom_snackbar.dart';

// class DoubleBackToExit extends StatefulWidget {
//   final Widget child;

//   const DoubleBackToExit({Key? key, required this.child}) : super(key: key);

//   @override
//   _DoubleBackToExitState createState() => _DoubleBackToExitState();
// }

// class _DoubleBackToExitState extends State<DoubleBackToExit> {
//   DateTime? _lastPressedTime;

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         final currentTime = DateTime.now();

//         if (_lastPressedTime == null || currentTime.difference(_lastPressedTime!) > Duration(seconds: 2)) {
//           _lastPressedTime = currentTime;

//           // Tampilkan pesan peringatan
//           FloatingSnackBar.show(
//             context: context,
//             message: "Double back to exit.",
//             backgroundColor: AppColors.primaryColor ,
//             textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//             duration: Duration(seconds: 5),
//           );

//           return false; // Jangan keluar
//         }

//         return true; // Keluar
//       },
//       child: widget.child, // Halaman anak yang dibungkus
//     );
//   }
// }
