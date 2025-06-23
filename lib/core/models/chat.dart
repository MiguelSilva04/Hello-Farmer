import 'dart:io';
import 'package:harvestly/core/models/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatData {
  String? id;
  String? name;
  String? description;
  String? consumerId;
  String? producerId;
  String? imageUrl;
  File? localImageFile;
  DateTime? createdAt;
  ChatMessage? lastMessage;

  ChatData({
    this.id,
    this.name,
    this.description,
    this.consumerId,
    this.producerId,
    this.imageUrl,
    this.localImageFile,
    this.createdAt,
    this.lastMessage,
  });
}

class Chat {
  final String id;
  String? name;
  String? description;
  String consumerId;
  String producerId;
  String? imageUrl;
  File? localImageFile;
  DateTime? createdAt;
  ChatMessage? lastMessage;
  int? unreadMessages;

  Chat({
    required this.id,
    this.name,
    this.description,
    required this.consumerId,
    required this.producerId,
    this.imageUrl,
    this.localImageFile,
    this.createdAt,
    this.lastMessage,
    this.unreadMessages,
  });

  String getName() => name ?? '';

  void setName(String name) => this.name = name;
  void setDescription(String description) => this.description = description;
  void setImage(String url) => imageUrl = url;

  factory Chat.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime? createdAt;
    if (data['createdAt'] is String) {
      createdAt = DateTime.tryParse(data['createdAt']);
    } else if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    }

    ChatMessage? lastMessage;
    if (data['lastMessage'] != null) {
      lastMessage = ChatMessage.fromMap(
        Map<String, dynamic>.from(data['lastMessage']),
      );
    }

    return Chat(
      id: doc.id,
      name: data['name'],
      description: data['description'],
      imageUrl: data['imageUrl'],
      createdAt: createdAt,
      lastMessage: lastMessage,
      consumerId: data['consumerId'],
      producerId: data['producerId'],
      unreadMessages: data['unreadMessages'] ?? null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt?.toIso8601String(),
      'lastMessage': lastMessage?.toMap(),
      'consumerId': consumerId,
      'producerId': producerId,
      'unreadMessages': unreadMessages,
    };
  }

  static Chat fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] ?? '',
      consumerId: map['consumerId'] ?? '',
      producerId: map['producerId'] ?? '',
      createdAt:
          map['createdAt'] is DateTime
              ? map['createdAt']
              : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      unreadMessages: map['unreadMessages'] ?? null
    );
  }
}
