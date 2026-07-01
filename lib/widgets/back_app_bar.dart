import 'package:flutter/material.dart';

// konstanta
import 'package:guideme/core/constants/constants.dart';

class cBackAppBar extends StatelessWidget implements PreferredSizeWidget {
  const cBackAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryColor, // Warna background tetap
      leadingWidth: 40, // Atur lebar area leading jika perlu
      leading: Padding(
        padding: const EdgeInsets.only(left: 20.0), // Padding sebelum icon
        child: IconButton(
          icon: Icon(
            AppIcons.back,
            color: AppColors.secondaryprimaryColor, // Warna ikon back
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Fungsi untuk kembali ke halaman sebelumnya
          },
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(right: 20.0), // Padding setelah icon, memberi jarak
        child: MouseRegion(
          onEnter: (_) {
            // Mengganti kursor saat mouse hover di atas teks
            SystemMouseCursors.click;
          },
          onExit: (_) {
            // Mengembalikan kursor saat mouse keluar dari area teks
            SystemMouseCursors.basic;
          },
          child: InkWell(
            onTap: () {
              Navigator.of(context).pop(); // Fungsi untuk kembali ke halaman sebelumnya
            },
            child: Text(
              'Back', // Judul tetap
              style: TextStyle(
                color: AppColors.secondaryprimaryColor, // Warna teks back
                fontFamily: 'Inter', // Menggunakan font Inter
                fontWeight: FontWeight.w600, // Menggunakan SemiBold
              ),
            ),
          ),
        ),
      ),
      toolbarHeight: kToolbarHeight, // Mengatur tinggi toolbar
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // Ukuran standar AppBar
}
