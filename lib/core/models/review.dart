import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  static int _idCounter = 0;

  final String id;
  String? reviewerId;
  String? replyTo;
  double? rating;
  String? description;
  DateTime? dateTime;

  Review({
    String? id,
    this.replyTo,
    this.reviewerId,
    this.rating,
    this.description,
    this.dateTime,
  }) : id = id ?? (_idCounter++).toString();

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      reviewerId: json['reviewerId'] ?? '',
      replyTo: json['replyTo'] ?? '',
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      dateTime:
          json['createdAt'] != null
              ? (json['createdAt'] is Timestamp
                  ? (json['createdAt'] as Timestamp).toDate()
                  : DateTime.parse(json['createdAt']))
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewerId': reviewerId,
      'rating': rating,
      'description': description,
      'dateTime': dateTime?.toIso8601String(),
      'replyTo': replyTo
    };
  }
}
