import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/main.dart';

class PrimarySnackBar {
  static void show(BuildContext context, String message, {Color? backgroundColor, Color? primaryColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.mediumWhiteBold),
        backgroundColor: backgroundColor ?? AppColors.primaryColor, // Default warna background
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
      ),
    );
  }
}


class DeleteSnackBar {
  static void show(String message, {Color? backgroundColor}) {
    final scaffoldMessengerState = scaffoldMessengerKey.currentState;

    // if (scaffoldMessengerState != null) {
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 92, // Atur posisi di bawah FloatingActionButton
        left: 16,
        right: 16,
        child: Material(
          elevation: 0.0, // Tidak ada elevasi
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.redColor, // Latar belakang transparan
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              message,
              style: AppTextStyles.mediumWhiteBold, // Ubah warna teks jika perlu
            ),
          ),
        ),
      ),
    );

    // Menampilkan overlay
    Overlay.of(scaffoldMessengerState!.context).insert(overlayEntry);

    // Menghapus overlay setelah durasi tertentu
    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
    // }
  }
}

class DangerSnackBar {
  static void show(BuildContext context, String message, {Color? backgroundColor}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 92, // Atur posisi di bawah FloatingActionButton
        left: 16,
        right: 16,
        child: Material(
          elevation: 0.0, // Tidak ada elevasi
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.redColor, // Latar belakang transparan
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              message,
              style: AppTextStyles.mediumWhiteBold, // Ubah warna teks jika perlu
            ),
          ),
        ),
      ),
    );

    // Menampilkan overlay
    overlay.insert(overlayEntry);

    // Menghapus overlay setelah durasi tertentu
    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}

// import 'package:flutter/material.dart';

class SuccessSnackBar {
  static void show(BuildContext context, String message, {dynamic? duration, Color? backgroundColor}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 92, // Atur posisi di bawah FloatingActionButton
        left: 16,
        right: 16,
        child: Material(
          borderRadius: BorderRadius.circular(8.0),
          elevation: 6.0,
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.green, // Default warna background
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              message,
              style: AppTextStyles.mediumWhiteBold,
            ),
          ),
        ),
      ),
    );

    // Menampilkan overlay
    overlay.insert(overlayEntry);

    // Menghapus overlay setelah durasi tertentu
    Future.delayed(duration ?? Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}

// class FloatingSnackBar {
//   /// Menampilkan Floating SnackBar dengan konfigurasi yang dapat disesuaikan
//   static void show({
//     required BuildContext context,
//     required String message,
//     Color backgroundColor = Colors.black,
//     TextStyle textStyle = const TextStyle(color: AppColors.backgroundColor),
//     Duration duration = const Duration(seconds: 2),
//     EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//     BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8)),
//     IconData? leadingIcon,
//     Color? iconColor,
//   }) {
//     final snackBar = SnackBar(
//       behavior: SnackBarBehavior.floating,
//       content: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (leadingIcon != null)
//             Padding(
//               padding: const EdgeInsets.only(right: 8.0),
//               child: Icon(leadingIcon, color: iconColor ?? AppColors.backgroundColor),
//             ),
//           Expanded(
//             child: Text(
//               message,
//               style: textStyle,
//             ),
//           ),
//         ],
//       ),
//       backgroundColor: backgroundColor,
//       duration: duration,
//       margin: margin,
//       shape: RoundedRectangleBorder(borderRadius: borderRadius),
//     );

//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }
// }

class FloatingSnackBar {
  /// Menampilkan Floating SnackBar dengan konfigurasi yang dapat disesuaikan
  static void show({
    required BuildContext context,
    required String message,
    Color backgroundColor = AppColors.primaryColor,
    TextStyle textStyle = AppTextStyles.mediumWhiteBold,
    Duration duration = const Duration(seconds: 2),
    EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8)),
    IconData? leadingIcon,
    Color? iconColor,
  }) {
    double bottomNavBarHeight = 74;

    Flushbar(
      messageText: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(leadingIcon, color: iconColor ?? AppColors.backgroundColor),
            ),
          Expanded(
            child: Text(
              message,
              style: textStyle.copyWith(color: AppColors.backgroundColor),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      margin: margin.copyWith(bottom: bottomNavBarHeight + 16),
      borderRadius: borderRadius,
      flushbarPosition: FlushbarPosition.BOTTOM, // Menampilkan di bagian atas
    )..show(context);
  }
}

class DangerTopFloatingSnackBar {
  /// Menampilkan Floating SnackBar dengan konfigurasi yang dapat disesuaikan
  static void show({
    required BuildContext context,
    required String message,
    Color backgroundColor = Colors.red,
    TextStyle textStyle = AppTextStyles.mediumWhiteBold,
    Duration duration = const Duration(seconds: 2),
    EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8)),
    IconData? leadingIcon,
    Color? iconColor,
  }) {
    Flushbar(
      messageText: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(leadingIcon, color: iconColor ?? AppColors.backgroundColor),
            ),
          Expanded(
            child: Text(
              message,
              style: textStyle.copyWith(color: AppColors.backgroundColor),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      margin: margin,
      borderRadius: borderRadius,
      flushbarPosition: FlushbarPosition.TOP, // Menampilkan di bagian atas
    )..show(context);
  }
}

class DangerFloatingSnackBar {
  /// Menampilkan Floating SnackBar dengan konfigurasi yang dapat disesuaikan
  static void show({
    required BuildContext context,
    required String message,
    Color backgroundColor = Colors.red,
    TextStyle textStyle = AppTextStyles.mediumWhiteBold,
    Duration duration = const Duration(seconds: 2),
    EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8)),
    IconData? leadingIcon,
    Color? iconColor,
  }) {
    // double bottomNavBarHeight = 74;

    Flushbar(
      messageText: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(leadingIcon, color: iconColor ?? AppColors.backgroundColor),
            ),
          Expanded(
            child: Text(
              message,
              style: textStyle.copyWith(color: AppColors.backgroundColor),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      // margin: margin.copyWith(bottom: bottomNavBarHeight + 16),
      margin: margin,
      borderRadius: borderRadius,
      flushbarPosition: FlushbarPosition.BOTTOM, // Menampilkan di bagian atas
    )..show(context);
  }
}

class SuccessFloatingSnackBar {
  /// Menampilkan Floating SnackBar dengan konfigurasi yang dapat disesuaikan
  static void show({
    required BuildContext context,
    required String message,
    Color backgroundColor = AppColors.greenColor,
    TextStyle textStyle = AppTextStyles.mediumWhiteBold,
    Duration duration = const Duration(seconds: 2),
    EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8)),
    IconData? leadingIcon,
    Color? iconColor,
  }) {
    Flushbar(
      messageText: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(leadingIcon, color: iconColor ?? AppColors.backgroundColor),
            ),
          Expanded(
            child: Text(
              message,
              style: textStyle.copyWith(color: AppColors.backgroundColor),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      margin: margin,
      borderRadius: borderRadius,
      flushbarPosition: FlushbarPosition.BOTTOM, // Menampilkan di bagian atas
    )..show(context);
  }
}

class SuccessTopFloatingSnackBar {
  /// Menampilkan Floating SnackBar dengan konfigurasi yang dapat disesuaikan
  static void show({
    required BuildContext context,
    required String message,
    Color backgroundColor = AppColors.greenColor,
    TextStyle textStyle = AppTextStyles.mediumWhiteBold,
    Duration duration = const Duration(seconds: 2),
    EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8)),
    IconData? leadingIcon,
    Color? iconColor,
  }) {
    Flushbar(
      messageText: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(leadingIcon, color: iconColor ?? AppColors.backgroundColor),
            ),
          Expanded(
            child: Text(
              message,
              style: textStyle.copyWith(color: AppColors.backgroundColor),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      margin: margin,
      borderRadius: borderRadius,
      flushbarPosition: FlushbarPosition.TOP, // Menampilkan di bagian atas
    )..show(context);
  }
}
