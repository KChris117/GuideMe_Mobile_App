// import 'package:flutter/material.dart';
// import 'package:guideme/views/admin/category_management/category_screen.dart';
// import 'package:guideme/views/admin/event_management/event_screen.dart';
// import 'package:guideme/views/admin/gallery_management/gallery_screen.dart';
// import 'package:guideme/views/admin/user_management/user_screen.dart';
// import 'package:guideme/views/admin/dashboard_screen.dart';
// import 'package:guideme/core/constants/constants.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart'; // Pastikan untuk mengimpor pustaka Phosphor Icons

// class AdminBottomNavBar extends StatelessWidget {
//   final int selectedIndex;

//   const AdminBottomNavBar({
//     Key? key,
//     required this.selectedIndex,
//   }) : super(key: key);

//   void _onItemTapped(BuildContext context, int index) {
//     Widget page;
//     switch (index) {
//       case 0:
//         page = DashboardScreen(); // Halaman Dashboard
//         break;
//       case 1:
//         page = UserManagementScreen(); // Halaman Manajemen Pengguna
//         break;
//       case 2:
//         page = EventManagementScreen(); // Halaman Manajemen Acara
//         break;
//       case 3:
//         page = CategoryManagementScreen(); // Halaman Manajemen Acara
//         break;
//       case 4:
//         page = GalleryManagementScreen(); // Halaman Manajemen Acara
//         break;
//       default:
//         page = DashboardScreen();
//     }

//     // Menggunakan PageRouteBuilder dengan fade transition dan durasi yang lebih lambat
//     Navigator.pushReplacement(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (context, animation, secondaryAnimation) => page,
//         transitionDuration: Duration(milliseconds: 300), // Durasi lebih lambat
//         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           return FadeTransition(
//             opacity: animation,
//             child: child,
//           );
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: selectedIndex,
//       onTap: (index) => _onItemTapped(context, index),
//       backgroundColor: AppColors.backgroundColor,
//       unselectedItemColor: AppColors.secondaryColor,
//       selectedItemColor: AppColors.primaryColor,
//       type: BottomNavigationBarType.fixed,
//       items: [
//         BottomNavigationBarItem(
//           icon: _buildIconWithBorder(AppIcons.dashboard, 0),
//           label: '',
//         ),
//         BottomNavigationBarItem(
//           icon: _buildIconWithBorder(AppIcons.profile, 1),
//           label: '',
//         ),
//         BottomNavigationBarItem(
//           icon: _buildIconWithBorder(AppIcons.event, 2),
//           label: '',
//         ),
//         BottomNavigationBarItem(
//           icon: _buildIconWithBorder(AppIcons.category, 3),
//           label: '',
//         ),
//         BottomNavigationBarItem(
//           icon: _buildIconWithBorder(AppIcons.gallery, 4),
//           label: 'Gallery',
//         ),
//       ],
//     );
//   }

//   // Fungsi untuk menambahkan border atas pada item yang aktif
//   Widget _buildIconWithBorder(PhosphorIconData icon, int index) {
//     return Container(
//       width: 50, // Menentukan lebar kontainer agar border lebih panjang
//       decoration: BoxDecoration(
//         border: Border(
//           top: BorderSide(
//             color: selectedIndex == index
//                 ? AppColors.primaryColor // Warna border saat aktif
//                 : Colors.transparent, // Transparan jika tidak aktif
//             width: 3.0, // Ketebalan border
//           ),
//         ),
//       ),
//       child: Center(
//         // Menjaga ikon tetap di tengah kontainer
//         child: Icon(icon),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:guideme/views/admin/category_management/category_screen.dart';
import 'package:guideme/views/admin/event_management/event_screen.dart';
import 'package:guideme/views/admin/gallery_management/gallery_screen.dart';
import 'package:guideme/views/admin/destination_management/destination_screen.dart';
import 'package:guideme/views/admin/dashboard_screen.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/views/user/home_screen.dart';
import 'package:guideme/views/user/gallery_screen.dart';
import 'package:guideme/views/user/profile/profile_screen.dart';
import 'package:guideme/views/user/search_screen.dart';
import 'package:guideme/views/user/ticket/ticket_screen.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class AdminBottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const AdminBottomNavBar({
    super.key,
    required this.selectedIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    Widget page;
    switch (index) {
      case 0:
        page = DashboardScreen();
        break;
      case 1:
        page = DestinationManagementScreen();
        break;
      case 2:
        page = EventManagementScreen();
        break;
      case 3:
        page = CategoryManagementScreen();
        break;
      case 4:
        page = GalleryManagementScreen();
        break;
      default:
        page = DashboardScreen();
    }

    // Menggunakan PageRouteBuilder dengan transisi fade
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 60.0, // Atur tinggi sesuai kebutuhan
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(context, index),
        backgroundColor: AppColors.backgroundColor,
        unselectedItemColor: AppColors.secondaryColor,
        selectedItemColor: AppColors.primaryColor,
        type: BottomNavigationBarType.fixed, // Menonaktifkan animasi skala
        items: [
          _buildNavItem(AppIcons.dashboard, 0, ''),
          _buildNavItem(AppIcons.destination, 1, ''),
          _buildNavItem(AppIcons.event, 2, ''),
          _buildNavItem(AppIcons.category, 3, ''),
          _buildNavItem(AppIcons.gallery, 4, ''),
        ],
      ),
    );
  }

  // Fungsi untuk membuat BottomNavigationBarItem dengan border di atas dan label di atas ikon
  BottomNavigationBarItem _buildNavItem(IconData icon, int index, String label) {
    return BottomNavigationBarItem(
      label: '',
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Border di atas label
          Container(
            width: 50,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: selectedIndex == index
                      ? AppColors.primaryColor // Warna border saat item aktif
                      : Colors.transparent, // Tidak ada border saat item tidak aktif
                  width: 3.0, // Ketebalan border
                ),
              ),
            ),
          ),
          // Label di atas ikon
          // Padding(
          //   padding: const EdgeInsets.only(top: 4.0), // Jarak antara border dan label
          //   child:
          Text(
            label,
            style: TextStyle(
              color: selectedIndex == index ? AppColors.primaryColor : AppColors.secondaryColor,
              fontSize: 12.0, // Ukuran font label
            ),
          ),
          // ),
          // Ikon
          Icon(icon)
          // Padding(
          //   padding: const EdgeInsets.only(top: 4.0), // Jarak antara label dan ikon
          //   child: Icon(icon),
          // ),
        ],
      ),
    );
  }
}

class UserBottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const UserBottomNavBar({
    super.key,
    required this.selectedIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    Widget page;
    switch (index) {
      case 0:
        page = HomeScreen();
        break;
      case 1:
        page = TicketScreen();
        break;
      case 2:
        page = SearchScreen();
        break;
      case 3:
        page = GalleryScreen();
        break;
      case 4:
        page = ProfileScreen();
        break;
      default:
        page = HomeScreen();
    }

    // Menggunakan PageRouteBuilder dengan transisi fade
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 60.0, // Atur tinggi sesuai kebutuhan
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(context, index),
        backgroundColor: AppColors.backgroundColor,
        unselectedItemColor: AppColors.secondaryColor,
        selectedItemColor: AppColors.primaryColor,
        type: BottomNavigationBarType.fixed, // Menonaktifkan animasi skala
        items: [
          _buildNavItem(AppIcons.home, 0, ''),
          _buildNavItem(AppIcons.ticket, 1, ''),
          _buildNavItem(AppIcons.search, 2, ''),
          _buildNavItem(AppIcons.gallery, 3, ''),
          _buildNavItem(AppIcons.profile, 4, ''),
        ],
      ),
    );
  }

  // Fungsi untuk membuat BottomNavigationBarItem dengan border di atas dan label di atas ikon
  BottomNavigationBarItem _buildNavItem(IconData icon, int index, String label) {
    return BottomNavigationBarItem(
      label: '',
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Border di atas label
          Container(
            width: 50,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: selectedIndex == index
                      ? AppColors.primaryColor // Warna border saat item aktif
                      : Colors.transparent, // Tidak ada border saat item tidak aktif
                  width: 3.0, // Ketebalan border
                ),
              ),
            ),
          ),
          // Label di atas ikon
          // Padding(
          //   padding: const EdgeInsets.only(top: 4.0), // Jarak antara border dan label
          //   child:
          Text(
            label,
            style: TextStyle(
              color: selectedIndex == index ? AppColors.primaryColor : AppColors.secondaryColor,
              fontSize: 12.0, // Ukuran font label
            ),
          ),
          // ),
          // Ikon
          Icon(icon)
          // Padding(
          //   padding: const EdgeInsets.only(top: 4.0), // Jarak antara label dan ikon
          //   child: Icon(icon),
          // ),
        ],
      ),
    );
  }
}
