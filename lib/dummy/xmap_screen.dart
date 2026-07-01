import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:guideme/dummy/map_controller.dart'; // Gantilah dengan path yang sesuai
import 'package:guideme/dummy/map_model.dart'; // Pastikan path model sesuai

class DisplayMapScreen extends StatefulWidget {
  const DisplayMapScreen({super.key});

  @override
  _DisplayMapScreenState createState() => _DisplayMapScreenState();
}

class _DisplayMapScreenState extends State<DisplayMapScreen> {
  final LocationController _controller = LocationController();
  final MapController _mapController = MapController();
  List<LocationModel> _locations = [];
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  // Fungsi untuk mengambil semua lokasi dari Firestore
  void _loadLocations() async {
    List<LocationModel> locations = await _controller.getAllLocations();
    setState(() {
      _locations = locations;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lokasi yang Tersimpan')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 400.0,
                width: double.infinity,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(1.054507, 104.004120),
                    onTap: (_, point) {
                      setState(() {
                        _selectedLocation = point;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: _locations.map((location) {
                        return Marker(
                          point: LatLng(location.latitude, location.longitude),
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
