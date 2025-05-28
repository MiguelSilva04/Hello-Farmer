class StoreReview {
  static int _idCounter = 0;

  final String id;
  String? reviewerId;
  double? rating;
  String? description;
  DateTime? dateTime;

  StoreReview({
    String? id,
    this.reviewerId,
    this.rating,
    this.description,
    this.dateTime,
  }) : id = id ?? (_idCounter++).toString();

  factory StoreReview.fromJson(Map<String, dynamic> json) {
    return StoreReview(
      id: json['id'] ?? '',
      reviewerId: json['reviewerId'] ?? '',
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'])
          : DateTime.now(),
    );
  }
}
