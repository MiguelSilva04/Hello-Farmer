import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:harvestly/core/models/chat.dart';
import 'package:harvestly/core/models/chat_message.dart';
import 'package:harvestly/core/models/app_user.dart';
import 'package:harvestly/encryption/encryption_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../models/consumer_user.dart';
import '../../models/producer_user.dart';

class ChatService with ChangeNotifier {
  static final ChatService _instance = ChatService._internal();

  factory ChatService() {
    return _instance;
  }

  ChatService._internal();

  Chat? _currentChat;
  List<AppUser> _currentUsers = [];

  Chat? get currentChat => _currentChat;

  StreamSubscription<List<ChatMessage>>? _chatMessagesSubscription;

  void listenToChatMessages(
    String chatId,
    void Function(List<ChatMessage>) onNewMessages,
  ) {
    _chatMessagesSubscription?.cancel();
    _chatMessagesSubscription = messagesStream(chatId).listen(onNewMessages);
  }

  void listenToCurrentChatMessages(
    void Function(List<ChatMessage>) onNewMessages,
  ) {
    if (_currentChat == null) throw Exception('No current chat selected.');
    listenToChatMessages(_currentChat!.id, onNewMessages);
  }

  void stopListeningToCurrentChatMessages() {
    _chatMessagesSubscription?.cancel();
    _chatMessagesSubscription = null;
  }

  void cancelMessagesListener() {
    _chatMessagesSubscription?.cancel();
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future<void> editMessage(
    String chatId,
    String messageId,
    String newText,
  ) async {
    final encryptedText = EncryptionService.encryptMessage(newText);
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'text': encryptedText});
  }

  Stream<List<AppUser>> membersStream(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('members')
        .snapshots()
        .asyncMap((snapshot) async {
          List<AppUser> members = [];
          for (var doc in snapshot.docs) {
            final userDoc =
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(doc.id)
                    .get();
            if (userDoc.exists) {
              final userData = userDoc.data()!;
              if (userData['isProducer'] == true) {
                members.add(ProducerUser.fromMap(userData));
              } else {
                members.add(ConsumerUser.fromMap(userData));
              }
            }
          }
          return members;
        });
  }

  void updateCurrentChat(Chat newChat) {
    _currentChat = newChat;
    loadCurrentChatMembersAndAdmins();
    notifyListeners();
  }

  Future<void> loadCurrentChatMembersAndAdmins() async {
    if (_currentChat == null) return;

    final chatDoc =
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(_currentChat!.id)
            .get();

    if (!chatDoc.exists) return;

    final data = chatDoc.data();
    if (data == null || !data.containsKey('members')) return;

    _currentChat!.consumerId = data['consumerId'];
    _currentChat!.producerId = data['producerId'];

    notifyListeners();
  }

  List<AppUser>? get currentUsers => _currentUsers;

  void updateCurrentUsers(List<AppUser> newUsers) {
    _currentUsers = newUsers;
    notifyListeners();
  }

  Stream<List<ChatMessage>> messagesStream(String chatId) {
    final store = FirebaseFirestore.instance;
    return store
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .asyncMap((snapshot) async {
          List<ChatMessage> messages = [];
          for (var doc in snapshot.docs) {
            var data = doc.data();
            String decryptedText = EncryptionService.decryptMessage(
              data['text'],
            );
            final userDoc =
                await store.collection('users').doc(data['userId']).get();
            final userData = userDoc.data();

            messages.add(
              ChatMessage(
                id: doc.id,
                text: decryptedText,
                createdAt:
                    data['createdAt'] is Timestamp
                        ? (data['createdAt'] as Timestamp).toDate()
                        : DateTime.parse(data['createdAt']),
                userId: data['userId'],
                userName:
                    userData?['firstName'] + " " + userData?['lastName'] ??
                    'Utilizador desconhecido',
                userImageUrl: userData?['imageUrl'] ?? '',
                seen: userData?['seen'] ?? false,
              ),
            );
          }
          return messages;
        });
  }

  Future<Chat> createChat(String consumerId, String producerId) async {
    final store = FirebaseFirestore.instance;
    final docRef = store.collection('chats').doc();
    final dateTime = DateTime.now().toIso8601String();

    await docRef.set({
      'createdAt': dateTime,
      'consumerId': consumerId,
      'producerId': producerId,
    });

    final chat = Chat(
      id: docRef.id,
      consumerId: consumerId,
      producerId: producerId,
      createdAt: DateTime.now(),
    );

    _currentChat = chat;
    notifyListeners();

    return chat;
  }

  Future<void> updateChatInfo(ChatData updatedChat) async {
    final store = FirebaseFirestore.instance;

    if (updatedChat.localImageFile != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child('${_currentChat!.id}.jpg');

      final uploadTask = storageRef.putFile(updatedChat.localImageFile!);
      final snapshot = await uploadTask;
      final imageUrl = await snapshot.ref.getDownloadURL();

      await store.collection("chats").doc('${_currentChat!.id}').update({
        "imageUrl": imageUrl,
      });

      _currentChat!.setImage(imageUrl);
      notifyListeners();
    }

    await store.collection("chats").doc('${_currentChat!.id}').update({
      "name": updatedChat.name ?? _currentChat!.name,
      "description": updatedChat.description ?? _currentChat!.description,
    });

    if (updatedChat.name != null) _currentChat!.setName(updatedChat.name!);
    if (updatedChat.description != null)
      _currentChat!.setDescription(updatedChat.description!);

    notifyListeners();
  }

  Future<void> removeChat([Chat? chat]) async {
    final store = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    final messagesCollection = store
        .collection('chats')
        .doc('${chat ?? _currentChat!.id}')
        .collection('messages');
    final messagesSnapshot = await messagesCollection.get();
    for (var doc in messagesSnapshot.docs) {
      await doc.reference.delete();
    }

    final membersCollection = store
        .collection('chats')
        .doc(_currentChat!.id)
        .collection('members');
    final membersSnapshot = await membersCollection.get();
    for (var doc in membersSnapshot.docs) {
      await doc.reference.delete();
    }

    await store.collection('chats').doc('${_currentChat!.id}').delete();

    try {
      await storage
          .ref()
          .child('chat_images')
          .child('${_currentChat!.id}.jpg')
          .delete();
    } catch (e) {}
  }

  Map<String, dynamic> _toFirestore(ChatMessage msg, SetOptions? options) {
    return {
      'text': msg.text,
      'createdAt': msg.createdAt.toIso8601String(),
      'userId': msg.userId,
      'userName': msg.userName,
      'userImageUrl': msg.userImageUrl,
    };
  }

  ChatMessage _fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    final data = doc.data()!;

    return ChatMessage(
      id: doc.id,
      text: data['text'],
      createdAt: DateTime.parse(data['createdAt']),
      userId: data['userId'],
      userName:
          data.containsKey('userName') && data['userName'] != null
              ? data['userName']
              : "Utilizador Desconhecido",
      userImageUrl:
          data.containsKey('userImageUrl') && data['userImageUrl'] != null
              ? data['userImageUrl']
              : "",
      seen: data['seen']
    );
  }

  Stream<List<Chat>> getMembersChats(String userId) {
    final consumerStream =
        FirebaseFirestore.instance
            .collection('chats')
            .where('consumerId', isEqualTo: userId)
            .snapshots();

    final producerStream =
        FirebaseFirestore.instance
            .collection('chats')
            .where('producerId', isEqualTo: userId)
            .snapshots();

    return Rx.zip2(consumerStream, producerStream, (
      QuerySnapshot consumerSnap,
      QuerySnapshot producerSnap,
    ) {
      final allDocs = [...consumerSnap.docs, ...producerSnap.docs];

      // Remover duplicados com base no ID do documento
      final uniqueDocs = {for (var doc in allDocs) doc.id: doc}.values.toList();

      return uniqueDocs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        final chat = Chat.fromDocument(doc);
        chat.consumerId = data['consumerId'];
        chat.producerId = data['producerId'];

        return chat;
      }).toList();
    });
  }

  Future<DateTime?> getUserJoinDate(String userId, String chatId) async {
    final chatDoc =
        await FirebaseFirestore.instance.collection('chats').doc(chatId).get();

    if (chatDoc.exists) {
      final data = chatDoc.data();
      if (data != null && data.containsKey('members')) {
        final membersMap = data['members'] as Map<String, dynamic>;
        if (membersMap.containsKey(userId) &&
            membersMap[userId]['joinedIn'] != null) {
          return DateTime.parse(membersMap[userId]['joinedIn']);
        }
      }
    }
    return null;
  }

  Future<ChatMessage?> save(String text, AppUser user, String chatId) async {
    final store = FirebaseFirestore.instance;

    String encryptedText = EncryptionService.encryptMessage(text);

    final userName =
        (user.firstName.isNotEmpty || user.lastName.isNotEmpty)
            ? "${user.firstName} ${user.lastName}".trim()
            : "Utilizador Desconhecido";

    final msg = ChatMessage(
      id: '',
      text: encryptedText,
      createdAt: DateTime.now(),
      userId: user.id,
      userName: userName,
      userImageUrl: user.imageUrl,
      seen: false,
    );

    final docRef = await store
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .withConverter(fromFirestore: _fromFirestore, toFirestore: _toFirestore)
        .add(msg);

    final doc = await docRef.get();
    return doc.data();
  }
}
