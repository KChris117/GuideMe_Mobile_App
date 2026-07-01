import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryModel {
  String ticketId;
  String uid;
  String customerName;
  String customerEmail;
  String ticketName;
  String location;
  String imageUrl;
  String organizer;
  String category;
  String? subcategory;
  double rating;
  int price;
  double totalPrice;
  int quantity;
  Timestamp openingDate;
  Timestamp openingTime;
  Timestamp closingDate;
  Timestamp closingTime;
  Timestamp purchaseAt;
  Timestamp? updatedAt;

  HistoryModel({
    required this.ticketId,
    required this.uid,
    required this.customerName,
    required this.customerEmail,
    required this.ticketName,
    required this.location,
    required this.imageUrl,
    required this.organizer,
    required this.category,
    this.subcategory,
    required this.rating,
    required this.price,
    required this.totalPrice,
    required this.quantity,
    required this.openingDate,
    required this.openingTime,
    required this.closingDate,
    required this.closingTime,
    required this.purchaseAt,
    this.updatedAt,
  });

  // Membuat instance Event dari Map (data Firestore)
  factory HistoryModel.fromMap(Map<String, dynamic> map, String eventId) {
    return HistoryModel(
      ticketId: map['ticketId'],
      uid: map['uid'],
      customerName: map['customerName'],
      customerEmail: map['customerEmail'],
      ticketName: map['ticketName'],
      location: map['location'],
      imageUrl: map['imageUrl'],
      organizer: map['organizer'],
      category: map['category'],
      subcategory: map['subcategory'],
      rating: map['rating'],
      price: map['price'],
      totalPrice: map['totalPrice'],
      quantity: map['quantity'],
      openingDate: map['openingDate'],
      openingTime: map['openingTime'],
      closingDate: map['closingDate'],
      closingTime: map['closingTime'],
      purchaseAt: map['purchaseAt'],
      updatedAt: map['updatedAt'],
    );
  }

  // Mengonversi instance Event ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'ticketId': ticketId,
      'uid': uid,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'ticketName': ticketName,
      'location': location,
      'imageUrl': imageUrl,
      'organizer': organizer,
      'category': category,
      'subcategory': subcategory,
      'rating': rating,
      'price': price,
      'totalPrice': totalPrice,
      'quantity': quantity,
      'openingDate': openingDate,
      'openingTime': openingTime,
      'closingDate': closingDate,
      'closingTime': closingTime,
      'purchaseAt': purchaseAt,
      'updatedAt': updatedAt,
    };
  } // Menambahkan copyWith method

  HistoryModel copyWith({
    String? ticketId,
    String? uid,
    String? customerName,
    String? customerEmail,
    String? ticketName,
    String? location,
    String? imageUrl,
    String? organizer,
    String? category,
    String? subcategory,
    double? rating,
    int? price,
    int? totalPrice,
    int? quantity,
    String? status,
    Timestamp? openingDate,
    Timestamp? openingTime,
    Timestamp? closingDate,
    Timestamp? closingTime,
    Timestamp? purchaseAt,
    Timestamp? updatedAt,
  }) {
    return HistoryModel(
      ticketId: ticketId ?? this.ticketId,
      uid: uid ?? this.uid,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      ticketName: ticketName ?? this.ticketName,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      organizer: organizer ?? this.organizer,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      totalPrice: (totalPrice ?? this.totalPrice).toDouble(),
      quantity: quantity ?? this.quantity,
      openingDate: openingDate ?? this.openingDate,
      openingTime: openingTime ?? this.openingTime,
      closingDate: closingDate ?? this.closingDate,
      closingTime: closingTime ?? this.closingTime,
      purchaseAt: purchaseAt ?? this.purchaseAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
