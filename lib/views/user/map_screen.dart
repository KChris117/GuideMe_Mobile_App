import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:guideme/core/constants/colors.dart';
import 'package:guideme/core/constants/icons.dart';
import 'package:guideme/widgets/widgets.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  final LatLng? currentLocation; // Koordinat lokasi pengguna
  final LatLng? targetLocation; // Koordinat tujuan

  MapScreen({this.currentLocation, this.targetLocation});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController _mapController;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.currentLocation != null && widget.targetLocation != null) {
      fetchRoute(); // Ambil rute saat inisialisasi
    }
  }

  // Fungsi untuk membuka Google Maps dengan rute
  Future<void> _openGoogleMaps() async {
    // Pastikan lokasi saat ini dan tujuan telah diperoleh
    if (widget.currentLocation != null && widget.targetLocation != null) {
      final String googleMapsUrl =
          "https://www.google.com/maps/dir/?api=1&origin=${widget.currentLocation!.latitude},${widget.currentLocation!.longitude}&destination=${widget.targetLocation!.latitude},${widget.targetLocation!.longitude}";

      final Uri googleMapsUri = Uri.parse(googleMapsUrl);

      // Periksa apakah URL dapat diluncurkan
      if (await canLaunch(googleMapsUri.toString())) {
        await launch(
          googleMapsUri.toString(),
          forceSafariVC: false, // Pastikan menggunakan aplikasi eksternal
          forceWebView: false,
        );
      } else {
        throw "Could not open Google Maps.";
      }
    } else {
      print("Current location or target location is not available.");
    }
  }

  Future<void> fetchRoute() async {
    final url =
        'http://router.project-osrm.org/route/v1/driving/${widget.currentLocation!.longitude},${widget.currentLocation!.latitude};${widget.targetLocation!.longitude},${widget.targetLocation!.latitude}?overview=full';

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

// Fungsi untuk memfokuskan peta pada lokasi pengguna
  void _focusOnCurrentLocation() {
    if (widget.currentLocation != null) {
      _mapController.move(widget.currentLocation!, 15.0); // Zoom level 15
    }
  }

  // Fungsi untuk memfokuskan peta pada lokasi tujuan
  void _focusOnTargetLocation() {
    if (widget.targetLocation != null) {
      _mapController.move(widget.targetLocation!, 15.0); // Zoom level 15
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.targetLocation ?? LatLng(0, 0),
              // zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
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
              MarkerLayer(
                markers: [
                  if (widget.currentLocation != null)
                    Marker(
                      point: widget.currentLocation!,
                      child: GestureDetector(
                        onTap: _focusOnCurrentLocation, // Fokus pada lokasi pengguna
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.gps_fixed,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  if (widget.targetLocation != null)
                    Marker(
                      point: widget.targetLocation!,
                      child: GestureDetector(
                        onTap: _focusOnTargetLocation, // Fokus pada lokasi tujuan
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          // Kotak Legenda
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _focusOnCurrentLocation, // Fokus pada lokasi pengguna
                    child: Row(
                      children: [
                        Icon(AppIcons.gps, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Current User'),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  GestureDetector(
                    onTap: _focusOnTargetLocation, // Fokus pada lokasi tujuan
                    child: Row(
                      children: [
                        Icon(AppIcons.pin, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Target Location'),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  GestureDetector(
                    onTap: _openGoogleMaps, // Panggil fungsi untuk membuka Google Maps
                    child: Row(
                      children: [
                        Icon(AppIcons.map, color: AppColors.blueColor),
                        SizedBox(width: 8),
                        Text('Link to Google Maps'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: 40,
            child: FloatingActionButton(
              mini: true,
              onPressed: _openGoogleMaps, // Panggil fungsi _openGoogleMaps
              backgroundColor: AppColors.blueColor,
              child: Icon(Icons.map, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
