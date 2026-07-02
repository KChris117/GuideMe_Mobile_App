import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guideme/core/constants/constants.dart';
import 'dart:io';

class CarouselWidget extends StatefulWidget {
  final List<String> imageAssets;

  CarouselWidget({required this.imageAssets});

  @override
  _CarouselWidgetState createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Mendapatkan lebar layar perangkat
    double screenWidth = MediaQuery.of(context).size.width;

    // Padding horizontal
    double horizontalPadding = 16.0;

    return Column(
      children: [
        // Carousel dengan padding horizontal
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: CarouselSlider(
            items: widget.imageAssets.map((imageAsset) {
              return Builder(
                builder: (BuildContext context) {
                  return SizedBox(
                    width: screenWidth - 2 * horizontalPadding, // Ukuran carousel disesuaikan dengan padding
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0), // Border radius
                      child: Image.asset(
                        imageAsset,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
            options: CarouselOptions(
              height: 160.0,
              enlargeCenterPage: true,
              autoPlay: true,
              aspectRatio: 20 / 9,
              viewportFraction: 1.0, // Carousel menggunakan seluruh lebar
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ),
        SizedBox(height: 8),
        // Indikator Slider (Persegi Panjang)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.imageAssets.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = entry.key;
                });
              },
              child: Container(
                width: _currentIndex == entry.key ? 30.0 : 20.0,
                height: 5.0,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  color: _currentIndex == entry.key ? AppColors.primaryColor : AppColors.tertiaryColor,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class DynamicCarouselWidget extends StatefulWidget {
  final List<String> imageAssets;

  DynamicCarouselWidget({required this.imageAssets});

  @override
  Dynamic_CarouselWidgetState createState() => Dynamic_CarouselWidgetState();
}

class Dynamic_CarouselWidgetState extends State<DynamicCarouselWidget> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Mendapatkan lebar layar perangkat
    double screenWidth = MediaQuery.of(context).size.width;

    // Padding horizontal
    double horizontalPadding = 16.0;

    return Column(
      children: [
        // Carousel dengan padding horizontal
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: CarouselSlider(
            items: widget.imageAssets.map((imageAsset) {
              return Builder(
                builder: (BuildContext context) {
                  // Pengecekan apakah gambar lokal atau URL
                  bool isLocalImage = imageAsset.startsWith('/'); // Pengecekan untuk file lokal

                  return SizedBox(
                    width: screenWidth - 2 * horizontalPadding, // Ukuran carousel disesuaikan dengan padding
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0), // Border radius
                      child: (!kIsWeb && isLocalImage)
                          ? Image.file(
                              File(imageAsset), // Menampilkan gambar lokal
                              fit: BoxFit.cover,
                              height: 100,
                              width: double.infinity,
                            )
                          : Image.network(
                              imageAsset, // Menampilkan gambar dari URL
                              fit: BoxFit.cover,
                              height: 100,
                              width: double.infinity,
                            ),
                    ),
                  );
                },
              );
            }).toList(),
            options: CarouselOptions(
              height: 160.0,
              enlargeCenterPage: true,
              autoPlay: true,
              aspectRatio: 20 / 9,
              viewportFraction: 1.0, // Carousel menggunakan seluruh lebar
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ),
        SizedBox(height: 8),
        // Indikator Slider (Persegi Panjang)
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: widget.imageAssets.asMap().entries.map((entry) {
        //     return GestureDetector(
        //       onTap: () {
        //         setState(() {
        //           _currentIndex = entry.key;
        //         });
        //       },
        //       child: Container(
        //         width: _currentIndex == entry.key ? 30.0 : 20.0,
        //         height: 5.0,
        //         margin: EdgeInsets.symmetric(horizontal: 5.0),
        //         decoration: BoxDecoration(
        //           color: _currentIndex == entry.key ? AppColors.primaryColor : AppColors.tertiaryColor,
        //         ),
        //       ),
        //     );
        //   }).toList(),
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.imageAssets.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = entry.key;
                });
              },
              child: Container(
                width: _currentIndex == entry.key ? 30.0 : 20.0,
                height: 5.0,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  color: _currentIndex == entry.key ? AppColors.primaryColor : AppColors.tertiaryColor,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}




// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:guideme/core/constants/constants.dart';

// class CarouselWidget extends StatefulWidget {
//   final List<String> imageAssets;

//   CarouselWidget({required this.imageAssets});

//   @override
//   _CarouselWidgetState createState() => _CarouselWidgetState();
// }

// class _CarouselWidgetState extends State<CarouselWidget> {
//   int _currentIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     // Mendapatkan lebar layar perangkat
//     double screenWidth = MediaQuery.of(context).size.width;

//     // Padding kiri dan kanan
//     double padding = 40.0;

//     // Menghitung lebar carousel
//     double carouselWidth = screenWidth - 2 * padding;

//     return Column(
//       children: [
//         // Carousel dengan ukuran yang disesuaikan
//         CarouselSlider(
//           items: widget.imageAssets.map((imageAsset) {
//             return Builder(
//               builder: (BuildContext context) {
//                 return SizedBox(
//                   width: carouselWidth, // Ukuran carousel disesuaikan
//                   // margin: EdgeInsets.symmetric(horizontal: 5.0),
//                   child: Image.asset(imageAsset, fit: BoxFit.cover),
//                 );
//               },
//             );
//           }).toList(),
//           options: CarouselOptions(
//             height: 160.0,
//             // autoPlay: true,
//             enlargeCenterPage: true,
//             aspectRatio: 20 / 9,
//             viewportFraction: 0.8,
//             onPageChanged: (index, reason) {
//               setState(() {
//                 _currentIndex = index;
//               });
//             },
//           ),
//         ),
//         SizedBox(height: 8),
//         // Indikator Slider (Persegi Panjang)
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: widget.imageAssets.asMap().entries.map((entry) {
//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _currentIndex = entry.key;
//                 });
//               },
//               child: Container(
//                 width: _currentIndex == entry.key ? 30.0 : 20.0,
//                 height: 5.0,
//                 margin: EdgeInsets.symmetric(horizontal: 5.0),
//                 decoration: BoxDecoration(
//                   color: _currentIndex == entry.key ? AppColors.primaryColor : AppColors.tertiaryColor,
//                   // borderRadius: BorderRadius.circular(5.0),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
// }
