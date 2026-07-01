import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  String uid;
  String username;
  String name;
  String review;
  double rating;
  Timestamp createdAt;
  Timestamp? updatedAt;

  ReviewModel({
    required this.uid,
    required this.username,
    required this.name,
    required this.review,
    required this.rating,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'name': name,
      'review': review,
      'rating': rating,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Membuat instance Event dari Map (data Firestore)
  factory ReviewModel.fromMap(Map<String, dynamic> map, String eventId) {
    return ReviewModel(
      uid: map['uid'],
      username: map['username'],
      name: map['name'],
      review: map['review'],
      // category: map['category'],
      // subcategory: map['subcategory'],
      rating: map['rating'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
}
