import 'package:flutter/material.dart';
import 'package:guideme/core/services/auth_provider.dart';
import 'package:guideme/views/user/profile/detail_profile_screen.dart';
import 'package:guideme/widgets/custom_snackbar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/core/services/auth_provider.dart' as provider;
import 'package:guideme/core/services/firebase_auth_service.dart';
import 'package:guideme/core/utils/auth_utils.dart';
import 'package:guideme/views/auth/login_screen.dart';
import 'package:guideme/views/auth/register_screen.dart';
import 'package:guideme/views/user/ticket/history_screen.dart';
import 'package:guideme/widgets/custom_button.dart';
import 'package:guideme/widgets/custom_divider.dart';
import 'package:guideme/widgets/custom_navbar.dart';
import 'package:guideme/widgets/custom_sidebar.dart';
import 'package:guideme/widgets/custom_title.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuthService _auth = FirebaseAuthService();

  bool _isLoggedIn = false;
  String _version = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _getVersion();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.initialize(); // Pastikan initialize dipanggil untuk memastikan data pengguna dimuat
  }

  // Memeriksa status login dan memperbarui state
  Future<void> _checkLoginStatus() async {
    bool loggedIn = await _auth.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  Future<void> _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version; // Ambil versi aplikasi
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: BurgerAppBar(
        scaffoldKey: _scaffoldKey,
        actions: _isLoggedIn
            ? [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                  onPressed: () {
                    // Panggil handleLogout dari auth_utils.dart
                    handleLogout(context);
                  },
                ),
              ]
            : [],
      ),
      drawer: CustomSidebar(
        isLoggedIn: _isLoggedIn,
        onLogout: () {
          // Panggil handleLogout juga di sini
          handleLogout(context);
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              alignment: Alignment.topLeft,
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TitlePage(title: 'Your Profile', subtitle: 'Log in to start planning your trip'),
                  SizedBox(height: 16), // Space before the divider

                  // Profile Logo with ListTile below
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      if (authProvider.isLoggedIn) {
                        return GestureDetector(
                          onTap: () {
                            // Navigasi ke ProfileDetailScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DetailProfileScreen()),
                            );
                          },
                          child: Container(
                            // Membungkus Row dengan Container
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    FutureBuilder<String?>(
                                      future: authProvider.getProfilePicture(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return CircleAvatar(
                                            radius: 24,
                                            backgroundColor: AppColors.secondaryColor,
                                            child: CircularProgressIndicator(),
                                          );
                                        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                                          return CircleAvatar(
                                            radius: 24,
                                            backgroundColor: AppColors.secondaryColor,
                                            backgroundImage: AssetImage('assets/images/profile.jpg'),
                                          );
                                        } else {
                                          return CircleAvatar(
                                            radius: 24,
                                            backgroundColor: AppColors.secondaryColor,
                                            backgroundImage: NetworkImage(snapshot.data!),
                                          );
                                        }
                                      },
                                    ),
                                    SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          authProvider.username ?? 'Loading username..',
                                          style: AppTextStyles.bodyBold,
                                        ),
                                        Text(
                                          authProvider.email ?? 'Loading email..',
                                          style: AppTextStyles.mediumGrey,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Icon(Icons.chevron_right)
                              ],
                            ),
                          ),
                        );
                      } else {
                        // Tampilan ketika belum login
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.43,
                              child: ProfileButton(
                                label: 'Login',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => LoginScreen()),
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.43,
                              child: ProfileButton(
                                label: 'Register',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),

                  SizedBox(height: 24), // Space after the divider
                  Text(
                    'Settings',
                    style: AppTextStyles.bodyBold,
                  ),
                  SizedBox(height: 8), // Space after the divider

                  GestureDetector(
                    onTap: () async {
                      final authProvider = Provider.of<provider.AuthProvider>(context, listen: false);

                      // Tunggu hingga data pengguna selesai diambil
                      await authProvider.fetchCurrentUser();

                      if (!authProvider.isLoggedIn) {
                        FloatingSnackBar.show(
                          context: context,
                          message: "You must login first to access this page.",
                          // backgroundColor: Colors.red,
                          textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          duration: Duration(seconds: 5),
                        );

                        // Setelah menampilkan SnackBar, arahkan ke halaman login
                        Future.delayed(Duration(seconds: 1), () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        });
                        return;
                      }

                      if (authProvider.isUser) {
                        // Jika pengguna sudah login dengan role 'user', lanjutkan ke HistoryScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HistoryScreen(),
                          ),
                        );
                      } else {
                        // Jika role bukan 'user', tampilkan pesan atau arahkan ke halaman lain
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('You must be a user to access this page'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    child: Container(
                      color: Colors.transparent, // Ensure the entire row is tappable
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(AppIcons.history, size: 24, color: AppColors.primaryColor),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'History',
                                    style: AppTextStyles.mediumBold,
                                  ),
                                  Text(
                                    'Check your past purchases',
                                    style: AppTextStyles.smallGrey,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                  greyDivider(),
                  GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => ChooseLanguage(),
                      //   ),
                      // );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(AppIcons.language, size: 24, color: AppColors.primaryColor),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Languages',
                                  style: AppTextStyles.mediumBold,
                                ),
                                Text(
                                  'Choose your preferred language',
                                  style: AppTextStyles.smallGrey,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                  greyDivider(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(AppIcons.notification, size: 24, color: AppColors.primaryColor),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Notification',
                                  style: AppTextStyles.mediumBold,
                                ),
                                Text(
                                  'Manage your notifications',
                                  style: AppTextStyles.smallGrey,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                  greyDivider(),
                  GestureDetector(
                    onTap: () {
                      // Handle get help
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(AppIcons.getHelp, size: 24, color: AppColors.primaryColor),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Get Help',
                                  style: AppTextStyles.mediumBold,
                                ),
                                Text(
                                  'Find answers to your questions',
                                  style: AppTextStyles.smallGrey,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                  greyDivider(),
                ],
              ),
            ),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.isLoggedIn) {
                  return GestureDetector(
                    onTap: () {
                      // Panggil handleLogout dari auth_utils.dart
                      handleLogout(context);
                    },
                    child: Column(
                      children: [
                        thickGreyDivider(),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Version: ${_version}', // Menampilkan versi aplikasi
                                style: AppTextStyles.mediumGrey,
                              ),
                              Row(
                                children: [
                                  Icon(Icons.logout, size: 24, color: AppColors.redColor),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    'Logout',
                                    style: AppTextStyles.mediumBold.copyWith(color: AppColors.redColor),
                                  ),
                                  // Text(
                                  //   'Sign out of your account',
                                  //   style: AppTextStyles.smallGrey,
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        thickGreyDivider(),
                      ],
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: UserBottomNavBar(selectedIndex: 4),
    );
  }
}
