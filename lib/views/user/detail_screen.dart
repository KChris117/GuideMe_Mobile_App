import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:guideme/views/user/map_screen.dart';
import 'package:guideme/widgets/custom_divider.dart';
import 'package:guideme/widgets/custom_snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guideme/controllers/destination_controller.dart';
import 'package:guideme/controllers/event_controller.dart';
import 'package:guideme/core/constants/constants.dart';
import 'package:guideme/core/services/auth_provider.dart';
import 'package:guideme/core/utils/text_utils.dart';
import 'package:guideme/models/review_model.dart';
import 'package:guideme/views/auth/login_screen.dart';
import 'package:guideme/widgets/custom_card.dart';
import 'package:guideme/widgets/custom_form.dart';
import 'package:guideme/widgets/custom_text.dart';
import 'package:guideme/widgets/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:guideme/widgets/custom_carousel.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart'; // Add this import
// import 'package:url_launcher/url_launcher_string.dart';

class RatingWidget extends StatefulWidget {
  final double initialRating;
  final Function(double) onRatingSelected;

  RatingWidget({required this.initialRating, required this.onRatingSelected});

  @override
  _RatingWidgetState createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  double _selectedRating = 0.0;
  // late int _selectedRating;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedRating = index + 1;
            });
            widget.onRatingSelected(_selectedRating);
          },
          child: Icon(
            AppIcons.rating,
            color: index < _selectedRating ? AppColors.primaryColor : AppColors.tertiaryColor,
            size: 20,
          ),
        );
      }),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final dynamic data;
  final String collectionName;
  final String? name;
  final double? rating;

  const DetailScreen({Key? key, required this.data, required this.collectionName, this.name, this.rating}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final MapController _mapController = MapController();
  final TextEditingController reviewController = TextEditingController();
  final EventController _eventController = EventController();
  final DestinationController _destinationController = DestinationController();

  // late String dataModel;
  late AuthProvider authProvider;
  late String collectionName;
  late String uid;
  late String name = widget.name ?? '';
  late String username;
  late String location;
  late double rating;
  late int price;
  late String description;
  late String information;
  late double targetLatitude;
  late double targetLongitude;
  late String imageUrl;
  late String imageName;
  late List<String> images = [];

  LatLng? _currentLocation;
  var targetLocation;
  var currentLocation;
  double? currentLatitude; // Menyimpan latitude
  double? currentLongitude; // Menyimpan longitude
  List<LatLng> _routePoints = []; // Menyimpan titik-titik rute

  String review = '';
  // late double selectedRating;
  double selectedRating = 0.0; // Nilai default

  @override
  void initState() {
    // Panggil _getCurrentLocation() untuk mengambil koordinat saat ini
    _getCurrentLocation().then((_) {
      // Setelah mendapatkan lokasi, ambil rute dari OSRM
      fetchRoute();
    });

    super.initState();
    collectionName = widget.collectionName;
    // Inisialisasi nilai collectionName
    name = capitalizeEachWord(widget.data.name.toString());
    location = capitalizeEachWord(widget.data.location.toString());
    rating = (widget.rating != null && widget.rating != 0.0) ? widget.rating! : widget.data.rating;

    // Inisialisasi selectedRating dengan nilai default
    selectedRating = 0.0; // Nilai default

    price = widget.data.price;
    description = widget.data.description;
    targetLatitude = widget.data.latitude;
    targetLongitude = widget.data.longitude;
    imageUrl = widget.data.imageUrl;
    targetLocation = LatLng(targetLatitude, targetLongitude);
    _loadImages();

    // authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Ambil nilai default dari Provider
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.initialize(); // Pastikan initialize dipanggil untuk memastikan data pengguna dimuat
    uid = authProvider.uid ?? '';
    username = authProvider.username ?? '';

    reviewController.addListener(() {
      setState(() {
        review = reviewController.text; // Perbarui nilai nameValue
      });
    });
  }

  Future<void> _loadImages() async {
    imageName = name.toLowerCase();
    final querySnapshot = await FirebaseFirestore.instance.collection('galleries').where('name', isEqualTo: imageName).get();

    List<String> loadedImages = [];
    for (var doc in querySnapshot.docs) {
      loadedImages.add(doc['imageUrl']);
    }

    setState(() {
      images = loadedImages;
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Periksa apakah layanan lokasi diaktifkan
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Layanan lokasi tidak diaktifkan, tidak dapat melanjutkan
      return;
    }

    // Periksa izin lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Izin lokasi ditolak, tidak dapat melanjutkan
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Izin lokasi ditolak secara permanen, tidak dapat melanjutkan
      return;
    }

// Dapatkan posisi saat ini
    Position position = await Geolocator.getCurrentPosition();

    // Set state untuk memperbarui tampilan dengan koordinat yang baru
    setState(() {
      // Mendapatkan latitude dan longitude secara terpisah
      currentLatitude = position.latitude;
      currentLongitude = position.longitude;
      _currentLocation = LatLng(currentLatitude!, currentLongitude!);
    });
  }

  // Fungsi untuk membuka Google Maps dengan rute
  Future<void> _openGoogleMaps() async {
    // Pastikan lokasi saat ini telah diperoleh
    if (currentLatitude != 0.0 && currentLongitude != 0.0) {
      final String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&origin=$currentLatitude,$currentLongitude&destination=$targetLatitude,$targetLongitude";

      final Uri googleMapsUri = Uri.parse(googleMapsUrl);

      // Periksa apakah URL dapat diluncurkan
      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(
          googleMapsUri,
          mode: LaunchMode.externalApplication, // Pastikan menggunakan aplikasi eksternal
        );
      } else {
        throw "Could not open Google Maps.";
      }
    } else {
      print("Current location is not available.");
    }
  }

  // Fetch route from OSRM API
  Future<void> fetchRoute() async {
    final url = 'http://router.project-osrm.org/route/v1/driving/${currentLongitude},${currentLatitude};${targetLongitude},${targetLatitude}?overview=full';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final encodedPolyline = data['routes'][0]['geometry'];

        // Gunakan FlutterPolylinePoints untuk mendekodekan polyline
        PolylinePoints polylinePoints = PolylinePoints();
        List<PointLatLng> decodedPolyline = polylinePoints.decodePolyline(encodedPolyline);

        final routePoints = decodedPolyline.map((point) => LatLng(point.latitude, point.longitude)).toList();

        setState(() {
          _routePoints = routePoints; // Menyimpan hasil koordinat ke _routePoints
        });
      } else {
        throw Exception('Failed to fetch route');
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  Future<void> saveReview() async {
    // if (_formKey.currentState!.validate()) {
    // Validasi form
    if (selectedRating != 0 || selectedRating != 0.0) {
      ReviewModel dataReview = ReviewModel(
        uid: uid, // Replace with actual uid
        username: username, // Replace with actual customer name
        name: name.toLowerCase(),
        review: review,
        // category: 'category', // Replace with actual category
        // subcategory: 'subcategory', // Replace with actual subcategory
        rating: selectedRating.toDouble(),
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );
      try {
        // Memanggil fungsi addHistory untuk menyimpan event dan galeri ke Firestore
        await FirebaseFirestore.instance.collection('reviews').add(dataReview.toMap());

        FloatingSnackBar.show(
          context: context,
          message: 'Review created successfully.',
        );

        if (collectionName == 'destinations') {
          await _destinationController.updateDestination(
            widget.data, // Pastikan widget.data adalah tipe DestinationModel
            imageUrl, // Pastikan imageUrl adalah tipe String
            newRating: selectedRating.toDouble(), // Pastikan selectedRating adalah tipe double
          );
        } else if (collectionName == 'events') {
          await _eventController.updateEvent(
            widget.data, // Pastikan widget.data adalah tipe DestinationModel
            imageUrl, // Pastikan imageName adalah tipe String
            newRating: selectedRating.toDouble(), // Pastikan selectedRating adalah tipe double
          );
        }
        setState(() {
          rating = selectedRating.toDouble();
          reviewController.clear(); // Bersihkan reviewController
          selectedRating = 0; // Reset selectedRating
        });
      } catch (e) {
        DangerFloatingSnackBar.show(context: context, message: 'Failed to create ticket: $e');
      }
      // }
    } else {
      DangerFloatingSnackBar.show(context: context, message: 'Please give some ratings.');
    }
  }

  Future<void> _updateAverageRating() async {
    try {
      final reviewsSnapshot = await FirebaseFirestore.instance.collection('reviews').where('name', isEqualTo: name.toLowerCase()).get();

      if (reviewsSnapshot.docs.isNotEmpty) {
        double totalRating = 0;
        for (var doc in reviewsSnapshot.docs) {
          totalRating += doc['rating'];
        }
        double averageRating = totalRating / reviewsSnapshot.docs.length;
        averageRating = double.parse(averageRating.toStringAsFixed(1)); // Round to 1 decimal place

        if (collectionName == 'destinations') {
          await _destinationController.updateDestination(
            widget.data,
            imageUrl,
            newRating: averageRating,
          );
        } else if (collectionName == 'events') {
          await _eventController.updateEvent(
            widget.data,
            imageUrl,
            newRating: averageRating,
          );
        }

        setState(() {
          rating = averageRating;
        });
      }
    } catch (e) {
      DangerFloatingSnackBar.show(context: context, message: 'Failed to update average rating: $e');
    }
  }

  Future<void> _deleteReview(String reviewId) async {
    try {
      await FirebaseFirestore.instance.collection('reviews').doc(reviewId).delete();
      FloatingSnackBar.show(context: context, message: 'Review deleted successfully.');

      // Jika perlu, panggil fungsi untuk memperbarui rating rata-rata setelah penghapusan
      await _updateAverageRating();
    } catch (e) {
      DangerFloatingSnackBar.show(context: context, message: 'Failed to delete review: $e');
    }
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(title: 'Back'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menampilkan teks menggunakan data
            CustomTitle(
              firstText: 'Hi, Tourist!',
              secondText: "Discover Everything About $name",
            ),
            const SizedBox(
              height: 16,
            ),
            if (images.isNotEmpty) DynamicCarouselWidget(imageAssets: images),
            if (images.isEmpty) Center(child: CircularProgressIndicator()), // Menampilkan carousel dengan gambar
            // Jika images kosong, bisa menampilkan widget loading atau lainnya
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: MainCard(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              name,
                              style: AppTextStyles.headingBold,
                            ),
                            Row(
                              children: [
                                Icon(
                                  AppIcons.rating,
                                  size: 16,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  '${rating}',
                                  style: AppTextStyles.bodyBold,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              location,
                              style: AppTextStyles.mediumGrey,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Column(
                          children: [
                            if (price > 0) // Tampilkan "Start from" hanya jika price > 0
                              Row(
                                children: [
                                  Text(
                                    'Start from',
                                    style: AppTextStyles.smallGrey,
                                  ),
                                ],
                              ),
                            Row(
                              children: [
                                Text(
                                  price == 0
                                      ? 'Free access' // Tampilkan "Free access" jika price == 0
                                      : '${formatRupiah(price)}',
                                  style: AppTextStyles.mediumBold,
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        LimitedTextWidget(description: '${description}'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GestureDetector(
                onDoubleTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(
                        currentLocation: _currentLocation, // Koordinat lokasi pengguna
                        targetLocation: LatLng(targetLatitude, targetLongitude), // Koordinat tujuan
                      ),
                    ),
                  );
                },
                child: MainCard(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          height: MediaQuery.of(context).size.height / 4,
                          width: double.infinity,
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: LatLng(targetLatitude, targetLongitude),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", // Updated URL without subdomains
                              ),
                              if (_routePoints.isNotEmpty)
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points: _routePoints,
                                      strokeWidth: 4.0,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                              if (targetLocation != null)
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: targetLocation!,
                                      width: 40,
                                      height: 40,
                                      child: Container(
                                        // padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: targetLocation != null
                                            ? Icon(
                                                Icons.location_on,
                                                color: Colors.red,
                                                size: 30,
                                              )
                                            : Container(), // Fallback to empty container if no location
                                      ),
                                    ),
                                  ],
                                ),
                              if (_currentLocation != null)
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: _currentLocation!,
                                      width: 40,
                                      height: 40,
                                      child: Container(
                                        // padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: _currentLocation != null
                                            ? Icon(
                                                AppIcons.gps,
                                                color: Colors.blue,
                                                size: 30,
                                              )
                                            : Container(), // Fallback to empty container if no location
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: AppColors.primaryColor, // Warna latar belakang
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapScreen(
                                  currentLocation: _currentLocation, // Koordinat lokasi pengguna
                                  targetLocation: LatLng(targetLatitude, targetLongitude), // Koordinat tujuan
                                ),
                              ),
                            );
                          },
                          child: Icon(
                            // isMapExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                            Icons.fullscreen,
                            color: AppColors.backgroundColor, // Warna ikon
                          ),
                        ),
                      ),

                      // Tombol untuk membuka Google Maps
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: FloatingActionButton(
                          mini: true,
                          onPressed: _openGoogleMaps, // Panggil fungsi _openGoogleMaps
                          backgroundColor: AppColors.blueColor,
                          child: Icon(AppIcons.map, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20, // Ukuran avatar
                          backgroundImage:
                              authProvider.profilePicture != null ? NetworkImage(authProvider.profilePicture!) : AssetImage('assets/images/profile.jpg') as ImageProvider,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomSmallTextFormField(
                                controller: reviewController,
                                hintText: 'Write your review here',
                                maxLines: null, // Allow unlimited lines
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a review';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  RatingWidget(
                                    initialRating: selectedRating,
                                    onRatingSelected: (rating) {
                                      setState(() {
                                        selectedRating = rating;
                                      });
                                    },
                                  ),
                                  SizedBox(width: 8),
                                  IconSmallButton(
                                    icon: Icons.send,
                                    onPressed: () async {
                                      if (uid == '' || username == '' || uid.isEmpty || username.isEmpty) {
                                        FloatingSnackBar.show(
                                          context: context,
                                          message: 'Please log in to submit a review.',
                                        );
                                        await Future.delayed(Duration(seconds: 1));
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => LoginScreen(),
                                          ),
                                        );
                                        return;
                                      }

                                      final existingReview = await FirebaseFirestore.instance
                                          .collection('reviews')
                                          .where('name', isEqualTo: name.toLowerCase())
                                          .where('uid', isEqualTo: uid)
                                          .get();

                                      if (existingReview.docs.isEmpty) {
                                        await saveReview();
                                        await _updateAverageRating();
                                      } else {
                                        final reviewDoc = existingReview.docs.first;
                                        if (selectedRating != 0 || selectedRating != 0.0) {
                                          await FirebaseFirestore.instance.collection('reviews').doc(reviewDoc.id).update({
                                            'review': reviewController.text,
                                            'rating': selectedRating.toDouble(),
                                            'updatedAt': Timestamp.now(),
                                          });
                                          await _updateAverageRating();
                                          FloatingSnackBar.show(
                                            context: context,
                                            message: 'Review update successfully.',
                                          );
                                          setState(() {
                                            reviewController.clear();
                                            selectedRating = 0;
                                            // rating = averageRating;
                                          });
                                        } else {
                                          DangerFloatingSnackBar.show(context: context, message: 'Please give some ratings.');
                                        }
                                      }
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance.collection('reviews').where('name', isEqualTo: name.toLowerCase()).orderBy('createdAt', descending: true).get(),
                      builder: (context, snapshot) {
                        // if (snapshot.connectionState == ConnectionState.waiting) {
                        //   return Center(child: CircularProgressIndicator());
                        // }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text('Please leave your review.'),
                            ),
                          );
                        }

                        // Ambil review pengguna saat ini
                        DocumentSnapshot? currentUserReview;
                        List<DocumentSnapshot> otherReviews = [];

                        for (var doc in snapshot.data!.docs) {
                          if (doc['uid'] == uid) {
                            currentUserReview = doc; // Simpan review pengguna saat ini
                          } else {
                            otherReviews.add(doc); // Tambahkan review lainnya
                          }
                        }
                        // Batasi jumlah review dari pengguna lain hingga 2
                        if (otherReviews.length > 2) {
                          otherReviews = otherReviews.sublist(0, 2); // Ambil 2 review pertama
                        }
                        // Gabungkan review pengguna saat ini dengan review lainnya
                        List<DocumentSnapshot> combinedReviews = [];
                        if (currentUserReview != null) {
                          combinedReviews.add(currentUserReview); // Tambahkan review pengguna saat ini
                        }
                        combinedReviews.addAll(otherReviews); // Tambahkan review lainnya

                        return Padding(
                          padding: const EdgeInsets.only(left: 48, top: 16),
                          child: Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: combinedReviews.length,
                                itemBuilder: (context, index) {
                                  var reviewData = combinedReviews[index];
                                  return FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance.collection('users').doc(reviewData['uid']).get(),
                                    builder: (context, userSnapshot) {
                                      // if (userSnapshot.connectionState == ConnectionState.waiting) {
                                      //   return Center(child: CircularProgressIndicator());
                                      // }
                                      if (userSnapshot.hasError) {
                                        return Center(child: Text('Error: ${userSnapshot.error}'));
                                      }
                                      if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                                        return Center(child: Text('Please leave your review.'));
                                      }

                                      var userData = userSnapshot.data!;
                                      return Container(
                                        padding: EdgeInsets.only(right: uid == reviewData['uid'] ? 0 : 32),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CircleAvatar(
                                                  radius: 14, // Ukuran avatar lebih kecil
                                                  backgroundImage: NetworkImage(userData['profilePicture'] ?? 'assets/images/profile.jpg'),
                                                ),
                                                SizedBox(width: 8), // Jarak antara avatar dan teks
                                                Expanded(
                                                  // Gunakan Expanded agar teks dapat mengisi ruang yang tersedia
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                userData['username'] ?? 'Anonymous',
                                                                style: AppTextStyles.mediumBold,
                                                              ),
                                                              SizedBox(width: 8), // Jarak antara username dan timestamp
                                                              Text(
                                                                timeago.format(reviewData['createdAt'].toDate()), // Format timestamp
                                                                style: AppTextStyles.greyTinyStle,
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(width: 16),
                                                          Row(
                                                            children: List.generate(5, (starIndex) {
                                                              return Icon(
                                                                AppIcons.rating,
                                                                color: starIndex < reviewData['rating'] ? AppColors.primaryColor : AppColors.tertiaryColor,
                                                                size: 10,
                                                              );
                                                            }),

                                                            // children: [
                                                            // Icon(
                                                            //   AppIcons.rating,
                                                            //   size: 14,
                                                            // ),
                                                            // SizedBox(
                                                            //   width: 2,
                                                            // ),
                                                            // Text(
                                                            //   '${reviewData['rating']}', // Menampilkan rating
                                                            //   style: AppTextStyles.mediumBold, // Gaya teks untuk rating
                                                            // ),
                                                            // ],
                                                          ),
                                                        ],
                                                      ),
                                                      // SizedBox(
                                                      //   height: 8,
                                                      // ),
                                                      Text(reviewData['review'], style: AppTextStyles.smallStyle),
                                                    ],
                                                  ),
                                                ),
                                                // Jika uid sama dengan reviewData['uid'], tampilkan tombol edit
                                                if (uid == reviewData['uid'])
                                                  Container(
                                                    width: 32, // Lebar yang diinginkan
                                                    height: 32, // Tinggi yang diinginkan
                                                    child: PopupMenuButton<String>(
                                                      icon: Icon(Icons.more_vert, size: 16), // Ikon titik tiga
                                                      onSelected: (String value) {
                                                        if (value == 'edit') {
                                                          // Aksi untuk edit
                                                          setState(() {
                                                            reviewController.text = reviewData['review'];
                                                            selectedRating = reviewData['rating'];
                                                            print("Selected Rating: $selectedRating"); // Debugging
                                                          });
                                                        } else if (value == 'delete') {
                                                          // Tampilkan dialog konfirmasi sebelum menghapus
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return AlertDialog(
                                                                title: Text('Delete Review'),
                                                                content: Text('Are you sure you want to delete this review?'),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () {
                                                                      Navigator.of(context).pop(); // Tutup dialog
                                                                    },
                                                                    child: Text('Cancel'),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed: () async {
                                                                      Navigator.of(context).pop(); // Tutup dialog
                                                                      await _deleteReview(reviewData.id); // Panggil fungsi untuk menghapus review
                                                                    },
                                                                    child: Text('Delete'),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        }
                                                      },
                                                      itemBuilder: (BuildContext context) {
                                                        return [
                                                          PopupMenuItem<String>(
                                                            value: 'edit',
                                                            child: Text('Edit'),
                                                          ),
                                                          PopupMenuItem<String>(
                                                            value: 'delete',
                                                            child: Text('Delete'),
                                                          ),
                                                        ];
                                                      },
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 12,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),

                              //modal see more review
                              if (snapshot.data!.docs.length > 2)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        final snapshot = await FirebaseFirestore.instance
                                            .collection('reviews')
                                            .where('name', isEqualTo: name.toLowerCase())
                                            // .where('uid', isNotEqualTo: uid)
                                            .orderBy('createdAt', descending: true)
                                            .get();

                                        if (snapshot.docs.isNotEmpty) {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                            ),
                                            builder: (context) {
                                              return DraggableScrollableSheet(
                                                initialChildSize: 0.33,
                                                minChildSize: 0.33,
                                                maxChildSize: 0.97,
                                                expand: false,
                                                builder: (context, scrollController) {
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      color: AppColors.backgroundColor,
                                                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          height: 5,
                                                          width: 50,
                                                          margin: EdgeInsets.symmetric(vertical: 10),
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey[300],
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                        Text(
                                                          'Comments',
                                                          style: AppTextStyles.mediumBold,
                                                        ),
                                                        greyDivider(),
                                                        Expanded(
                                                          child: ListView.builder(
                                                            controller: scrollController,
                                                            itemCount: snapshot.docs.length,
                                                            itemBuilder: (context, index) {
                                                              var reviewData = snapshot.docs[index];
                                                              return FutureBuilder<DocumentSnapshot>(
                                                                future: FirebaseFirestore.instance.collection('users').doc(reviewData['uid']).get(),
                                                                builder: (context, userSnapshot) {
                                                                  if (userSnapshot.hasError) {
                                                                    return Center(child: Text('Error: ${userSnapshot.error}'));
                                                                  }
                                                                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                                                                    return Container(
                                                                      color: AppColors.backgroundColor,
                                                                    );
                                                                  }

                                                                  var userData = userSnapshot.data!;
                                                                  return Container(
                                                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                                                    child: Column(
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            CircleAvatar(
                                                                              radius: 14, // Ukuran avatar lebih kecil
                                                                              backgroundImage: NetworkImage(userData['profilePicture'] ?? 'assets/images/profile.jpg'),
                                                                            ),
                                                                            SizedBox(width: 8), // Jarak antara avatar dan teks
                                                                            Expanded(
                                                                              // Gunakan Expanded agar teks dapat mengisi ruang yang tersedia
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Row(
                                                                                        children: [
                                                                                          Text(
                                                                                            userData['username'] ?? 'Anonymous',
                                                                                            style: AppTextStyles.mediumBold,
                                                                                          ),
                                                                                          SizedBox(width: 8), // Jarak antara username dan timestamp
                                                                                          Text(
                                                                                            timeago.format(reviewData['createdAt'].toDate()), // Format timestamp
                                                                                            style: AppTextStyles.greyTinyStle,
                                                                                          ),
                                                                                          // Text(
                                                                                          //   userData['uid'] == uid
                                                                                          //       ? 'You'
                                                                                          //       : userData['uid'], // Tampilkan 'You' jika uid sama
                                                                                          //   style: AppTextStyles.smallGrey,
                                                                                          // ),
                                                                                        ],
                                                                                      ),
                                                                                      SizedBox(width: 16),
                                                                                      Row(
                                                                                        children: List.generate(5, (starIndex) {
                                                                                          return Icon(
                                                                                            AppIcons.rating,
                                                                                            color: starIndex < reviewData['rating']
                                                                                                ? AppColors.primaryColor
                                                                                                : AppColors.tertiaryColor,
                                                                                            size: 10,
                                                                                          );
                                                                                        }),
                                                                                      ),
                                                                                      // Row(
                                                                                      //   children: [
                                                                                      //     Icon(
                                                                                      //       AppIcons.rating,
                                                                                      //       size: 14,
                                                                                      //     ),
                                                                                      //     SizedBox(
                                                                                      //       width: 2,
                                                                                      //     ),
                                                                                      //     Text(
                                                                                      //       '${reviewData['rating']}', // Menampilkan rating
                                                                                      //       style: AppTextStyles.mediumBold, // Gaya teks untuk rating
                                                                                      //     ),
                                                                                      //   ],
                                                                                      // ),
                                                                                    ],
                                                                                  ),
                                                                                  // SizedBox(
                                                                                  //   height: 8,
                                                                                  // ),
                                                                                  Container(
                                                                                      padding: EdgeInsets.only(right: 36),
                                                                                      child: Text(reviewData['review'], style: AppTextStyles.smallStyle)),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            // Jika uid sama dengan reviewData['uid'], tampilkan tombol edit
                                                                          ],
                                                                        ),
                                                                        SizedBox(
                                                                          height: 12,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                            content: Text('No reviews available.'),
                                          ));
                                        }
                                      },
                                      icon: Icon(AppIcons.chat),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 16, top: 4),
                                      child: Text(
                                        '${snapshot.data!.docs.length}', // Men ampilkan jumlah review yang ditemukan, dikurangi satu untuk mengabaikan review pengguna saat ini
                                        style: AppTextStyles.mediumBlack,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: UserBottomNavBar(selectedIndex: 0),
    );
  }
}
