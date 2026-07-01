import 'package:flutter/material.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/core/services/auth_provider.dart';
import 'package:guideme/views/admin/category_management/category_screen.dart';
import 'package:guideme/views/admin/category_management/create_category_screen.dart';
import 'package:guideme/views/admin/dashboard_screen.dart';
import 'package:guideme/views/admin/destination_management/destination_screen.dart';
import 'package:guideme/views/admin/event_management/event_screen.dart';
import 'package:guideme/views/admin/gallery_management/create_gallery_screen.dart';
import 'package:guideme/views/admin/gallery_management/gallery_screen.dart';
import 'package:guideme/views/admin/ticket_management/ticket_screen.dart';
import 'package:guideme/views/admin/user_managements/user_screen.dart';
import 'package:guideme/views/auth/login_screen.dart';
import 'package:guideme/views/user/gallery_screen.dart';
import 'package:guideme/views/user/home_screen.dart';
import 'package:guideme/views/user/list_screen.dart';
import 'package:guideme/views/user/profile/profile_screen.dart';
import 'package:guideme/views/user/ticket/ticket_screen.dart';
import 'package:provider/provider.dart';

class BurgerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final List<Widget>? actions;

  const BurgerAppBar({
    super.key,
    required this.scaffoldKey,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          scaffoldKey.currentState?.openDrawer();
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomSidebar extends StatelessWidget {
  final bool isLoggedIn;
  final VoidCallback onLogout;

  const CustomSidebar({
    super.key,
    required this.isLoggedIn,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    // return
    return Drawer(
        backgroundColor: AppColors.backgroundColor,
        width: MediaQuery.of(context).size.width / 2,
        child: Container(
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                ), // Warna latar belakang
                child: Align(
                  alignment: Alignment.topLeft, // M
                  child: Image.asset(
                    'assets/icons/launcher_icon.png',
                    width: 80, // Sesuaikan ukuran lebar
                    // height: 80, // Sesuaikan ukuran tinggi
                  ),
                ),
              ),
              // Menggunakan Consumer untuk mendengarkan perubahan pada AuthProvider
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return Column(
                    children: [
                      // Menampilkan ListTile hanya jika pengguna adalah admin
                      if (authProvider.isAdmin) // Cek apakah pengguna adalah admin
                        ListTile(
                          leading: Icon(AppIcons.userSwitch),
                          title: const Text('Switch to admin'),
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => DashboardScreen()),
                              (Route<dynamic> route) => false, // Menghapus semua rute sebelumnya
                            );
                          },
                        ),
                      // Tambahkan ListTile lain di sini jika diperlukan
                    ],
                  );
                },
              ),

              ListTile(
                leading: Icon(AppIcons.destination),
                title: const Text('Destination'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ListScreen(data: 'Destinations')),
                  );
                },
              ),
              ListTile(
                leading: Icon(AppIcons.event),
                title: const Text('Event'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ListScreen(data: 'Events')),
                  );
                },
              ),
              ListTile(
                leading: Icon(AppIcons.ticket),
                title: const Text('Ticket'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TicketScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(AppIcons.gallery),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GalleryScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(AppIcons.profile),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
              ),
              // ExpansionTile(
              //   // Hilangkan border atas dan bawah
              //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              //   collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              //   iconColor: AppColors.primaryColor, // Warna ikon saat tile aktif
              //   leading: const Icon(Icons.image),
              //   title: const Text('Gallery'),
              //   children: [
              //     Padding(
              //       padding: const EdgeInsets.only(left: 40.0), // Padding untuk semua ListTile
              //       child: Column(
              //         children: [
              //           ListTile(
              //             title: const Text('View Gallery'),
              //             onTap: () {
              //               Navigator.push(
              //                 context,
              //                 MaterialPageRoute(
              //                   builder: (context) => const GalleryManagementScreen(),
              //                 ),
              //               );
              //             },
              //           ),
              //           ListTile(
              //             title: const Text('Create Gallery'),
              //             onTap: () {
              //               Navigator.push(
              //                 context,
              //                 MaterialPageRoute(
              //                   builder: (context) => const CreateGalleryManagementScreen(),
              //                 ),
              //               );
              //             },
              //           ),
              //           ListTile(
              //             title: const Text('Modify Gallery'),
              //             onTap: () {
              //               Navigator.push(
              //                 context,
              //                 MaterialPageRoute(
              //                   builder: (context) => const CategoryManagementScreen(),
              //                 ),
              //               );
              //             },
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),

              if (isLoggedIn)
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  onTap: onLogout,
                )
              else
                ListTile(
                  leading: Icon(Icons.login),
                  title: Text('Login'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  },
                ),
              // ListTile(
              //   title: const Text('View Dashboard'),
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => const DashboardScreen(),
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
        ));
  }
}

class CustomAdminSidebar extends StatelessWidget {
  final bool? isLoggedIn;
  final VoidCallback onLogout;

  const CustomAdminSidebar({
    super.key,
    this.isLoggedIn,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    // return
    return Drawer(
        width: MediaQuery.of(context).size.width / 1.5,
        child: Container(
          color: AppColors.backgroundColor,
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                ), // Warna latar belakang
                child: Align(
                  alignment: Alignment.topLeft, // M
                  child: Image.asset(
                    'assets/icons/launcher_icon.png',
                    width: 80, // Sesuaikan ukuran lebar
                    // height: 80, // Sesuaikan ukuran tinggi
                  ),
                ),
              ),
              ListTile(
                leading: Icon(AppIcons.userSwitch),
                title: const Text('Switch to user'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(AppIcons.destination),
                title: const Text('Destination Management'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DestinationManagementScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(AppIcons.event),
                title: const Text('Event Management'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EventManagementScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(AppIcons.ticket),
                title: const Text('Ticket Management'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TicketManagementScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(AppIcons.profile),
                title: const Text('User Management'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserScreen()),
                  );
                },
              ),
              ExpansionTile(
                // Hilangkan border atas dan bawah
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                iconColor: AppColors.primaryColor, // Warna ikon saat tile aktif
                leading: Icon(AppIcons.category),
                title: Text('Category Management'),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0), // Padding untuk semua ListTile
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('View Category'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CategoryManagementScreen(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text('Create Category'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CreateCategoryScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                // Hilangkan border atas dan bawah
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                iconColor: AppColors.primaryColor, // Warna ikon saat tile aktif
                leading: Icon(AppIcons.gallery),
                title: Text('Gallery Management'),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0), // Padding untuk semua ListTile
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('View Gallery'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GalleryManagementScreen(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text('Create Gallery'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CreateGalleryManagementScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: AppColors.redColor,
                ),
                title: const Text('Logout', style: TextStyle(color: AppColors.redColor)),
                onTap: onLogout,
              ),
            ],
          ),
        ));
  }
}
