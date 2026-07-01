import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  String ticketId;
  String? recommendationId;
  String? name;
  String? title;
  String? location;
  String? imageUrl;
  String? organizer;
  String? category;
  String? subcategory;
  String? description;
  String? information;
  double? rating;
  int? price;
  int? stock;
  String? status;
  Timestamp? openingTime;
  Timestamp? closingTime;
  Timestamp? createdAt;
  Timestamp? updatedAt;

  TicketModel({
    required this.ticketId,
    this.recommendationId,
    this.name,
    this.title,
    this.location,
    this.imageUrl,
    this.organizer,
    this.category,
    this.subcategory,
    this.description,
    this.information,
    this.rating,
    this.stock,
    this.price,
    this.status,
    this.openingTime,
    this.closingTime,
    this.createdAt,
    this.updatedAt,
  });

  factory TicketModel.fromMap(Map<String, dynamic> map, String TicketId) {
    return TicketModel(
      ticketId: map['ticketId'] ?? 'Id not found',
      recommendationId: map['recommendationId'] ?? 'Id not found',
      name: map['name'] ?? 'Name not found',
      title: map['title'],
      location: map['location'] ?? 'Location not found',
      imageUrl: map['imageUrl'] ?? 'Image not found',
      organizer: map['organizer'] ?? 'Organizer not found',
      category: map['category'] ?? 'Category not found',
      subcategory: map['subcategory'] ?? 'Subcategory not found',
      description: map['description'] ?? 'Description not found',
      information: map['information'] ?? 'Information not found',
      rating: (map['rating'] is double) ? map['rating'] : 0.0, // Default 0.0 for numeric rating
      price: (map['price'] is int) ? map['price'] : 0, // Default 0.0 for price
      stock: map['stock'] ?? 0, // Default 0 for stock
      status: map['status'] ?? 'Status not found',
      openingTime: map['openingTime'],
      closingTime: map['closingTime'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
  // Fungsi tambahan untuk mengambil TicketModel dari DocumentSnapshot
  static TicketModel fromFirestore(DocumentSnapshot snapshot) {
    return TicketModel.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id);
  }

  // Mengonversi instance Event ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'ticketId': ticketId,
      'recommendationId': recommendationId,
      'name': name,
      'title': title,
      'location': location,
      'imageUrl': imageUrl,
      'organizer': organizer,
      'category': category,
      'subcategory': subcategory,
      'description': description,
      'information': information,
      'rating': rating,
      'price': price,
      'stock': stock,
      'status': status,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Menambahkan copyWith method
  TicketModel copyWith({
    String? ticketId,
    String? recommendationId,
    String? name,
    String? title,
    String? location,
    double? latitude,
    double? longitude,
    String? imageUrl,
    String? organizer,
    String? category,
    String? subcategory,
    String? description,
    String? information,
    double? rating,
    int? price,
    String? status,
    Timestamp? openingTime,
    Timestamp? closingTime,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return TicketModel(
      ticketId: ticketId ?? this.ticketId,
      recommendationId: recommendationId ?? this.recommendationId,
      name: name ?? this.name,
      title: title ?? this.title,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      organizer: organizer ?? this.organizer,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      description: description ?? this.description,
      information: information ?? this.information,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      status: status ?? this.status,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

}
