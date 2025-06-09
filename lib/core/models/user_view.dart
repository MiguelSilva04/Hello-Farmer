import 'package:cloud_firestore/cloud_firestore.dart' as cf;

class UserView {
  final DateTime date;
  final String user;

  UserView({required this.date, required this.user});

  factory UserView.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'];

    DateTime? parsedDate;
    if (rawDate is cf.Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate);
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    }

    if (parsedDate == null) {
      throw Exception("Invalid or missing 'date' in UserView JSON: $json");
    }

    return UserView(
      date: parsedDate,
      user: json['user'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String(), 'user': user};
  }
}
