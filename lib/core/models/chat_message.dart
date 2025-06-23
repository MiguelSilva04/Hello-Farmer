import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  String text;
  final DateTime createdAt;
  final String userId;
  final String userName;
  final String userImageUrl;
  bool seen = false;

  ChatMessage({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    required this.seen,
  });

  // Método para criar um ChatMessage a partir de um Map (como o Firestore retorna)
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userImageUrl: map['userImageUrl'] ?? '',
      seen: map['seen'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'seen': seen
    };
  }

  ChatMessage copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    String? userId,
    String? userName,
    String? userImageUrl,
    bool? seen
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      seen: seen ?? this.seen,
    );
  }
}
