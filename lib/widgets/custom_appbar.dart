import 'package:flutter/material.dart';

// konstanta
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/views/admin/dashboard_screen.dart';
import 'package:guideme/views/user/home_screen.dart';

class CloseAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CloseAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(
          AppIcons.close,
          color: AppColors.primaryColor,
        ),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false, // Menghapus semua rute sebelumnya
            );
          }
        },
      ),
      title: null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// import 'package:flutter/material.dart';

class BackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final PreferredSizeWidget? bottom; // Parameter opsional untuk TabBar
  final Color? backgroundColor;
  final Color? iconColor;

  const BackAppBar({
    super.key,
    this.title,
    this.bottom, // Nilai default adalah null
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.white, // Ganti dengan AppColors.backgroundColor jika digunakan
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(
          AppIcons.back, // Ganti dengan AppIcons.back jika digunakan
          color: iconColor ?? Colors.black, // Ganti dengan AppColors.primaryColor jika digunakan
        ),
        onPressed: () {
          Navigator.pop(context); // Menutup halaman dan kembali ke halaman sebelumnya
        },
      ),
      title: GestureDetector(
        onTap: () {
          Navigator.pop(context); // Menutup halaman dan kembali ke halaman sebelumnya
        },
        child: Text(
          '',
          style: AppTextStyles.headingBlack.copyWith(fontWeight: FontWeight.bold), // Ganti dengan AppTextStyles.bodyBlack jika digunakan
        ),
      ),
      bottom: bottom, // Menampilkan TabBar jika diberikan
    );
  }

  @override
  Size get preferredSize {
    // Kembalikan ukuran tinggi AppBar + tinggi bottom (jika ada)
    return Size.fromHeight(
      kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
    );
  }
}

class BackSearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final TextEditingController searchController;
  final Function(String) onSearch;
  final double appBarHeight;

  BackSearchAppBar({
    required this.scaffoldKey,
    required this.searchController,
    required this.onSearch,
    this.appBarHeight = kToolbarHeight, // Default tinggi AppBar
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(
          AppIcons.back, // Ganti dengan AppIcons.back jika digunakan
          color: Colors.black, // Ganti dengan AppColors.primaryColor jika digunakan
        ),
        onPressed: () {
          Navigator.pop(context); // Menutup halaman dan kembali ke halaman sebelumnya
        },
      ),
      title: Container(
        width: MediaQuery.of(context).size.width * 0.61, // Lebar TextFormField
        height: 36, // Tinggi TextFormField
        child: TextFormField(
          controller: searchController,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            hintText: "Search..",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear(); // Clear input
                      onSearch(''); // Clear hasil pencarian
                      FocusScope.of(context).unfocus(); // Menutup keyboard
                    },
                  )
                : null,
          ),
          onChanged: onSearch, // Fungsi pencarian saat mengetik
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight); // Ukuran AppBar
}

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final TextEditingController searchController;
  final Function(String) onSearch;
  final double appBarHeight;

  SearchAppBar({
    required this.scaffoldKey,
    required this.searchController,
    required this.onSearch,
    this.appBarHeight = kToolbarHeight, // Default tinggi AppBar
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          scaffoldKey.currentState?.openDrawer();
        },
      ),
      title: Container(
        width: MediaQuery.of(context).size.width * 0.61, // Lebar TextFormField
        height: 36, // Tinggi TextFormField
        child: TextFormField(
          controller: searchController,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            hintText: "Search..",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear(); // Clear input
                      onSearch(''); // Clear hasil pencarian
                      FocusScope.of(context).unfocus(); // Menutup keyboard
                    },
                  )
                : null,
          ),
          onChanged: onSearch, // Fungsi pencarian saat mengetik
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight); // Ukuran AppBar
}

// class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final GlobalKey<ScaffoldState> scaffoldKey;
//   final List<Widget>? actions;
//   final ValueChanged<String>? onSearchChanged;
//   final TextEditingController? searchController;
//   final VoidCallback? onSearchTap;

//   const SearchAppBar({
//     Key? key,
//     required this.scaffoldKey,
//     this.actions,
//     this.onSearchChanged,
//     this.searchController,
//     this.onSearchTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.white, // Ganti dengan AppColors jika ada
//       scrolledUnderElevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.menu),
//         onPressed: () {
//           scaffoldKey.currentState?.openDrawer();
//         },
//       ),
//       title: Container(
//         decoration: BoxDecoration(
//           color: Colors.grey[200],
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         child: TextField(
//           controller: searchController,
//           decoration: InputDecoration(
//             hintText: "Search..",
//             border: InputBorder.none,
//             prefixIcon: const Icon(Icons.search),
//             contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
//           ),
//           onChanged: onSearchChanged,
//           onTap: onSearchTap, // Memanggil fungsi _showSearchResults dari halaman yang lebih tinggi
//         ),
//       ),
//       actions: actions,
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }
