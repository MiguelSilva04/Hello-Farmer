import 'dart:io';

import 'package:harvestly/core/models/chat_message.dart';
import 'package:harvestly/core/models/chat_user.dart';
import 'package:flutter/material.dart';
import '../../models/chat.dart';
import 'chat_firebase_service.dart';

abstract class ChatService extends ChangeNotifier {
  Chat? get currentChat;
  List<ClientUser>? get currentUsers;
  Stream<List<ChatMessage>> messagesStream(String chatId);
  Future<ChatMessage?> save(String texto, ClientUser user, String chatId);
  Future<Chat> createChat(
    String name,
    String description,
    List<String> members,
    File? image,
    List<String> adminIds,
  );

  Stream<List<Chat>> getMembersChats(String userId);

  void updateCurrentChat(Chat newChat);

  void updateCurrentUsers(List<ClientUser> newUsers);

  Future<void> addMemberToChat(String userId);

  Future<void> removeMemberFromChat(String userId, String? chatId);

  Future<void> makeUserAdmin(String userId);

  Future<void> removeUserAdmin(String userId);

  Future<void> updateChatInfo(Chat updatedChat);

  Future<void> removeChat();

  Future<void> loadCurrentChatMembersAndAdmins();

  Future<DateTime?> getUserJoinDate(String userId, String chatId);

  void listenToCurrentChatMessages(
    void Function(List<ChatMessage>) onNewMessages,
  );

  factory ChatService() {
    // return ChatMockService();
    return ChatFirebaseService();
  }
}
