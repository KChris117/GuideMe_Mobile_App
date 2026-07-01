import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:guideme/dummy/map_controller.dart'; // Gantilah dengan path yang sesuai
import 'package:guideme/dummy/map_model.dart'; // Pastikan path model sesuai

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationController _controller = LocationController();
  final MapController _mapController = MapController();
  final TextEditingController _locationController = TextEditingController();
  bool _isMapExpanded = true;
  LatLng? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pilih Lokasi')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Masukkan Nama Lokasi',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isMapExpanded = !_isMapExpanded;
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: _isMapExpanded ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height / 3,
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
                          if (_selectedLocation != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _selectedLocation!,
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.location_pin, color: Colors.red),
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
                    child: IconButton(
                      icon: Icon(
                        _isMapExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _isMapExpanded = !_isMapExpanded;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_selectedLocation != null && _locationController.text.isNotEmpty) {
                      // Membuat model lokasi berdasarkan input pengguna
                      final location = LocationModel(
                        name: _locationController.text,
                        latitude: _selectedLocation!.latitude,
                        longitude: _selectedLocation!.longitude,
                      );
                      // Memanggil fungsi untuk menyimpan lokasi ke Firestore
                      await _controller.saveLocation(location);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lokasi berhasil disimpan!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Harap pilih lokasi dan masukkan nama!')),
                      );
                    }
                  },
                  child: Text('Simpan Lokasi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
