import 'package:flutter/material.dart';
import 'package:guideme/core/services/auth_provider.dart' as provider;
import 'package:guideme/core/services/firebase_auth_service.dart';
import 'package:guideme/dummy/create_map.dart';
import 'package:guideme/dummy/image/upload_page.dart';
import 'package:guideme/dummy/xmap_screen.dart';
import 'package:guideme/dummy/payment/dummy_payment_screen.dart';
// import 'package:guideme/example/payment/payment_page.dart';
import 'package:guideme/views/auth/login_screen.dart';
import 'package:guideme/widgets/custom_navbar.dart';
import 'package:guideme/widgets/custom_sidebar.dart';
import 'package:provider/provider.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  _ExampleScreenState createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Mengecek status login pengguna
  Future<void> _checkLoginStatus() async {
    bool loggedIn = await _auth.isLoggedIn();
    if (loggedIn) {
      setState(() {
        _isLoggedIn = true;
      });
    } else {
      // Arahkan ke halaman login jika belum login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  // Menangani logout
  Future<void> _handleLogout() async {
    final authProvider = Provider.of<provider.AuthProvider>(context, listen: false);
    await authProvider.logout();

    // Menampilkan SnackBar setelah logout berhasil
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Logout successful")),
    );

    // Navigasi ke halaman login setelah logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BurgerAppBar(scaffoldKey: _scaffoldKey),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: GridView.count(
          crossAxisCount: 2, // Dua card per baris
          crossAxisSpacing: 8, // Jarak horizontal antar card
          mainAxisSpacing: 8, // Jarak vertikal antar card
          children: [
            _buildDashboardCard(
              context,
              icon: Icons.event,
              title: 'Manage Events',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapScreen()),
                );
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.event,
              title: 'Manage Events',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DisplayMapScreen()),
                );
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.event,
              title: 'Upload Image',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UploadPage()),
                );
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.event,
              title: 'Payment Page',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentPage()),
                );
              },
            ),
            // _buildDashboardCard(
            //   context,
            //   icon: Icons.event,
            //   title: 'Ticket Page',
            //   onTap: () {
            //     // Contoh data tiket yang diteruskan
            //     Ticket exampleTicket = Ticket(
            //       ticketId: 'ticket-001',
            //       name: 'Concert Ticket',
            //       price: 100.0,
            //     );

            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => TicketPage(ticket: exampleTicket),
            //       ),
            //     );
            //   },
            // ),
            // _buildDashboardCard(
            //   context,
            //   icon: Icons.event,
            //   title: 'History Page',
            //   onTap: () {
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => PaymentPage(),
            //         ));
            //   },
            // ),
          ],
        ),
      ),
      bottomNavigationBar: _isLoggedIn ? AdminBottomNavBar(selectedIndex: 0) : null,
    );
  }

  // Widget untuk Card Dashboard
  Widget _buildDashboardCard(BuildContext context, {required IconData icon, required String title, required Function onTap}) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.blue),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
