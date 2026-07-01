import 'package:flutter/material.dart';
import 'package:guideme/controllers/dashboard_controller.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/core/services/firebase_auth_service.dart';
import 'package:guideme/core/utils/auth_utils.dart';
import 'package:guideme/dummy/xdashboard_screen.dart';
import 'package:guideme/views/admin/destination_management/destination_screen.dart';
import 'package:guideme/views/admin/event_management/event_screen.dart';
import 'package:guideme/views/admin/gallery_management/gallery_screen.dart';
import 'package:guideme/views/admin/ticket_management/ticket_screen.dart';
import 'package:guideme/views/admin/user_management/user_screen.dart';
import 'package:guideme/views/admin/user_managements/user_screen.dart';
import 'package:guideme/views/admin/category_management/category_screen.dart';
import 'package:guideme/views/auth/login_screen.dart';
import 'package:guideme/views/user/home_screen.dart';
import 'package:guideme/widgets/custom_navbar.dart';
import 'package:guideme/widgets/custom_sidebar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuthService _auth = FirebaseAuthService();
  final DashboardController _dashboardController = DashboardController();
  int _ticketCount = 0;
  int _userCount = 0;
  int _reviewCount = 0;
  int _destinationCount = 0;
  int _eventCount = 0;
  int _galleryCount = 0;

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
    _fetchTicketCount();
    _fetchUserCount();
    _fetchEventCount();
    _fetchDestinationCount();
    _fetchReviewCount();
    _fetchGalleryCount();
  }

  Future<void> _checkAdminRole() async {
    var currentUser = await _auth.getCurrentUser();
    if (currentUser != null) {
      String role = currentUser['role']!;
      if (role != 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  Future<void> _fetchUserCount() async {
    int count = await _dashboardController.getUserCount();
    setState(() {
      _userCount = count;
    });
  }

  Future<void> _fetchEventCount() async {
    int count = await _dashboardController.getEventCount();
    setState(() {
      _eventCount = count;
    });
  }

  Future<void> _fetchDestinationCount() async {
    int count = await _dashboardController.getDestinationCount();
    setState(() {
      _destinationCount = count;
    });
  }

  Future<void> _fetchTicketCount() async {
    int count = await _dashboardController.getTicketCount();
    setState(() {
      _ticketCount = count;
    });
  }

  Future<void> _fetchReviewCount() async {
    int count = await _dashboardController.getReviewCount();
    setState(() {
      _reviewCount = count;
    });
  }

  Future<void> _fetchGalleryCount() async {
    int count = await _dashboardController.getGalleryCount();
    setState(() {
      _galleryCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: BurgerAppBar(scaffoldKey: scaffoldKey),
      drawer: CustomAdminSidebar(
        onLogout: () {
          handleLogout(context);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: [
            _buildDashboardCard(
              context,
              collectionCount: _userCount,
              icon: AppIcons.profile,
              title: 'Manage Users',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserScreen()),
                );
              },
            ),
            _buildDashboardCard(
              context,
              collectionCount: 2,
              icon: AppIcons.category,
              title: 'Manage Categories',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoryManagementScreen()),
                );
              },
            ),
            _buildDashboardCard(
              context,
              collectionCount: _destinationCount,
              icon: AppIcons.destination,
              title: 'Manage Destinations',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DestinationManagementScreen()),
                );
              },
            ),
            _buildDashboardCard(
              context,
              collectionCount: _eventCount,
              icon: AppIcons.event,
              title: 'Manage Events',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventManagementScreen()),
                );
              },
            ),
            _buildDashboardCard(
              context,
              collectionCount: _galleryCount,
              icon: AppIcons.gallery,
              title: 'Manage Galleries',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GalleryManagementScreen()),
                );
              },
            ),
            _buildDashboardCard(
              context,
              collectionCount: _ticketCount,
              icon: AppIcons.ticket,
              title: 'Manage Tickets',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TicketManagementScreen()),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdminBottomNavBar(selectedIndex: 0),
      backgroundColor: AppColors.backgroundColor,
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Function onTap,
    required int collectionCount,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Card(
        elevation: 5,
        color: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${collectionCount}', // Menampilkan jumlah tiket
                    style: AppTextStyles.titleWhiteStyle,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Icon(icon, size: 24, color: Colors.white),
                ],
              ),
              SizedBox(height: 10),
              Text(
                title,
                style: AppTextStyles.headingWhiteBold,
                // textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
