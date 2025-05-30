import 'dart:async';
import 'dart:io';
import 'package:harvestly/core/models/chat.dart';
import 'package:harvestly/core/models/chat_message.dart';
import 'package:harvestly/core/models/app_user.dart';
import 'package:harvestly/core/services/chat/chat_service.dart';
import 'package:harvestly/encryption/encryption_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../models/consumer_user.dart';
import '../../models/producer_user.dart';

class ChatFirebaseService with ChangeNotifier implements ChatService {
  static final ChatFirebaseService _instance = ChatFirebaseService._internal();

  factory ChatFirebaseService() {
    return _instance;
  }

  ChatFirebaseService._internal();

  Chat? _currentChat;
  List<AppUser> _currentUsers = [];

  @override
  Chat? get currentChat => _currentChat;

  StreamSubscription<List<ChatMessage>>? _chatMessagesSubscription;

  void listenToChatMessages(
    String chatId,
    void Function(List<ChatMessage>) onNewMessages,
  ) {
    _chatMessagesSubscription?.cancel();
    _chatMessagesSubscription = messagesStream(chatId).listen(onNewMessages);
  }

  @override
  void listenToCurrentChatMessages(
    void Function(List<ChatMessage>) onNewMessages,
  ) {
    if (_currentChat == null) throw Exception('No current chat selected.');
    listenToChatMessages(_currentChat!.id!, onNewMessages);
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

  Future<void> leaveChat(String userId, String chatId) async {
    await removeMemberFromChat(userId, chatId);
    if (_currentChat?.id == chatId) {
      _currentChat = null;
      _currentUsers = [];
      notifyListeners();
    }
  }

  @override
  void updateCurrentChat(Chat newChat) {
    _currentChat = newChat;
    loadCurrentChatMembersAndAdmins();
    notifyListeners();
  }

  @override
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

    Map<String, dynamic> membersMap = Map<String, dynamic>.from(
      data['members'],
    );

    List<String> membersIds = membersMap.keys.toList();
    List<String> adminIds =
        membersMap.entries
            .where((entry) => entry.value['isAdmin'] == true)
            .map((entry) => entry.key)
            .toList();

    _currentChat!.membersIds = membersIds;
    _currentChat!.adminIds = adminIds;

    notifyListeners();
  }

  @override
  List<AppUser>? get currentUsers => _currentUsers;

  @override
  void updateCurrentUsers(List<AppUser> newUsers) {
    _currentUsers = newUsers;
    notifyListeners();
  }

  @override
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
              ),
            );
          }
          return messages;
        });
  }

  @override
  Future<Chat> createChat(
    String name,
    String description,
    List<String> members,
    File? image,
    List<String> adminIds,
  ) async {
    final store = FirebaseFirestore.instance;
    final docRef = store.collection('chats').doc();
    final dateTime = DateTime.now().toIso8601String();
    String? imageUrl;
    if (image != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child('${docRef.id}.jpg');
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() {});
      imageUrl = await snapshot.ref.getDownloadURL();
    }

    Map<String, dynamic> membersMap = {};
    for (final memberId in members) {
      membersMap[memberId] = {
        'joinedIn': dateTime,
        'isAdmin': adminIds.contains(memberId),
      };
    }

    await docRef.set({
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': dateTime,
      'members': membersMap,
    });

    final chat = Chat(
      id: docRef.id,
      name: name,
      description: description,
      adminIds: adminIds,
      membersIds: members,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );

    _currentChat = chat;
    notifyListeners();

    return chat;
  }

  @override
  Future<void> addMemberToChat(String userId) async {
    if (_currentChat == null) throw Exception('No current chat selected.');

    final chatRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(_currentChat!.id);

    await chatRef.update({
      'members.$userId': {
        'joinedIn': DateTime.now().toIso8601String(),
        'isAdmin': false,
      },
    });

    _currentChat!.membersIds.add(userId);
    notifyListeners();
  }

  @override
  Future<void> removeMemberFromChat(String userId, String? chatId) async {
    if (chatId == null) return;

    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) return;

    final data = chatDoc.data();
    if (data == null || !data.containsKey('members')) return;

    Map<String, dynamic> membersMap = Map<String, dynamic>.from(
      data['members'],
    );
    if (!membersMap.containsKey(userId)) return;

    membersMap.remove(userId);

    await chatRef.update({'members': membersMap});

    _currentUsers.removeWhere((u) => u.id == userId);
    if (_currentChat != null) {
      _currentChat!.membersIds.remove(userId);
      notifyListeners();
    }
  }

  @override
  Future<void> updateChatInfo(Chat updatedChat) async {
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

  @override
  Future<void> removeChat() async {
    final store = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    final messagesCollection = store
        .collection('chats')
        .doc('${_currentChat!.id}')
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

  // ChatMessage => Map<String, dynamic>
  Map<String, dynamic> _toFirestore(ChatMessage msg, SetOptions? options) {
    return {
      'text': msg.text,
      'createdAt': msg.createdAt.toIso8601String(),
      'userId': msg.userId,
      'userName': msg.userName,
      'userImageUrl': msg.userImageUrl,
    };
  }

  // Map<String, dynamic> => ChatMessage
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
    );
  }

  @override
  Stream<List<Chat>> getMembersChats(String userId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('membersIds', arrayContains: userId)
        .snapshots()
        .map((querySnapshot) {
          return querySnapshot.docs.map((doc) {
            final data = doc.data();
            final Map<String, dynamic> membersMap = data['members'] ?? {};

            List<String> membersIds = membersMap.keys.toList();
            List<String> adminIds =
                membersMap.entries
                    .where((entry) => entry.value['isAdmin'] == true)
                    .map((entry) => entry.key)
                    .toList();

            final chat = Chat.fromDocument(doc);
            chat.membersIds = membersIds;
            chat.adminIds = adminIds;

            return chat;
          }).toList();
        });
  }

  @override
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

  @override
  Future<void> makeUserAdmin(String userId) async {
    if (_currentChat == null) throw Exception("No current chat selected.");

    final chatDoc =
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(_currentChat!.id)
            .get();

    if (!chatDoc.exists) throw Exception("Chat not found.");

    final chatData = chatDoc.data();
    if (chatData == null || !chatData.containsKey('members')) {
      throw Exception("No members data found in chat.");
    }

    final members = chatData['members'] as Map<String, dynamic>;

    if (!members.containsKey(userId)) {
      throw Exception("User not found in the chat.");
    }

    members[userId]['isAdmin'] = true;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(_currentChat!.id)
        .update({'members': members});

    if (!_currentChat!.adminIds!.contains(userId)) {
      _currentChat!.adminIds!.add(userId);
      notifyListeners();
    }
  }

  @override
  Future<void> removeUserAdmin(String userId) async {
    if (_currentChat == null) throw Exception("No current chat selected.");

    final memberDoc =
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(_currentChat!.id)
            .collection('members')
            .doc(userId)
            .get();

    if (!memberDoc.exists) throw Exception("User not found in chat.");

    // Atualiza o status de admin apenas se necessário
    if (memberDoc.data()?['isAdmin'] == true) {
      await memberDoc.reference.update({'isAdmin': false});

      if (_currentChat!.adminIds!.contains(userId)) {
        _currentChat!.adminIds!.remove(userId);
        notifyListeners();
      }
    }
  }

  @override
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
    );

    // Adiciona a mensagem na coleção de mensagens
    final docRef = await store
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .withConverter(fromFirestore: _fromFirestore, toFirestore: _toFirestore)
        .add(msg);

    // Obtém os dados da mensagem recém-criada
    final doc = await docRef.get();
    return doc.data();
  }
}
