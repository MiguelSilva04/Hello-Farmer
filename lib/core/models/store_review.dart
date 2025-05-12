class StoreReview {
  static int _idCounter = 0;

  final String id;
  String? reviewerId;
  double? rating;
  String? description;
  DateTime? dateTime;

  StoreReview({this.reviewerId, this.rating, this.description, this.dateTime})
    : id = (_idCounter++).toString();
}
