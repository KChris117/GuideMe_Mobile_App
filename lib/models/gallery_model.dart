import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryModel {
  String galleryId;
  String? recommendationId;
  String name;
  String category;
  String subcategory;
  String? description;
  String imageUrl;
  Timestamp createdAt;
  bool? mainImage;

  GalleryModel({
    required this.galleryId,
    this.recommendationId,
    required this.name,
    required this.category,
    required this.subcategory,
    this.description,
    required this.imageUrl,
    required this.createdAt,
    this.mainImage,
  });

  // Fungsi untuk mengonversi Map menjadi objek GalleryModel
  factory GalleryModel.fromMap(Map<String, dynamic> map, String id) {
    return GalleryModel(
      galleryId: id,
      recommendationId: map['recommendationId'],
      name: map['name'],
      category: map['category'],
      subcategory: map['subcategory'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      createdAt: map['createdAt'],
      mainImage: map['mainImage'] ?? false,
    );
  }

  // Fungsi untuk mengonversi objek GalleryModel menjadi Map
  Map<String, dynamic> toMap() {
    return {
      'recommendationId': recommendationId,
      'name': name,
      'category': category,
      'subcategory': subcategory,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'mainImage': mainImage
    };
  } // Fungsi copyWith untuk membuat salinan objek dengan perubahan tertentu

  GalleryModel copyWith({
    String? recommendationId,
    String? name,
    String? category,
    String? subcategory,
    String? description,
    String? imageUrl,
    bool? mainImage,
  }) {
    return GalleryModel(
      galleryId: this.galleryId, // Tidak diubah karena tetap sama
      recommendationId: this.recommendationId, // Tidak diubah karena tetap sama
      name: name ?? this.name,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: this.createdAt, // Tidak diubah karena tetap sama
      mainImage: mainImage ?? this.mainImage,
    );
  }
}
