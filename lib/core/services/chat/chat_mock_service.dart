import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:harvestly/core/models/chat.dart';
import 'package:harvestly/core/models/chat_message.dart';
import 'package:harvestly/core/models/client_user.dart';
import 'package:harvestly/core/services/chat/chat_service.dart';

class ChatMockService implements ChatService {
  static final List<ChatMessage> _msgs = [];

  static MultiStreamController<List<ChatMessage>>? _controller;
  static final _msgsStream = Stream<List<ChatMessage>>.multi((controller) {
    _controller = controller;
    controller.add(_msgs);
  });

  @override
  Stream<List<ChatMessage>> messagesStream(String chatId) {
    return _msgsStream;
  }

  @override
  Future<ChatMessage> save(String text, ClientUser user, String chatId) async {
    final newMessage = ChatMessage(
      id: Random().nextDouble().toString(),
      text: text,
      createdAt: DateTime.now(),
      userId: user.id,
      userName: user.firstName + user.lastName,
      userImageUrl: user.imageUrl,
    );
    _msgs.add(newMessage);
    _controller?.add(_msgs.reversed.toList());
    return newMessage;
  }

  @override
  Future<Chat> createChat(
    String name,
    String description,
    List<String> members,
    File? image,
    List<String> adminIds,
  ) {
    // TODO: implement createChat
    throw UnimplementedError();
  }

  @override
  Stream<List<Chat>> getMembersChats(String userId) {
    // TODO: implement getMembersChats
    throw UnimplementedError();
  }

  @override
  // TODO: implement currentChat
  Chat? get currentChat => throw UnimplementedError();

  @override
  void updateCurrentChat(Chat newChat) {
    // TODO: implement updateCurrentChat
  }

  @override
  Future<void> addMemberToChat(String userId) {
    // TODO: implement addMemberToChat
    throw UnimplementedError();
  }

  @override
  // TODO: implement currentUsers
  List<ClientUser> get currentUsers => throw UnimplementedError();

  @override
  void updateCurrentUsers(List<ClientUser> newUsers) {
    // TODO: implement updateCurrentUsers
  }

  @override
  Future<void> updateChatInfo(Chat updatedChat) {
    // TODO: implement updateChatInfo
    throw UnimplementedError();
  }

  @override
  Future<void> removeChat() {
    // TODO: implement removeChat
    throw UnimplementedError();
  }

  @override
  Future<void> removeMemberFromChat(String userId, String? chatId) {
    // TODO: implement removeMemberFromChat
    throw UnimplementedError();
  }

  @override
  Future<void> makeUserAdmin(String userId) {
    // TODO: implement makeUserAdmin
    throw UnimplementedError();
  }

  @override
  Future<void> removeUserAdmin(String userId) {
    // TODO: implement removeUserAdmin
    throw UnimplementedError();
  }

  @override
  Future<void> loadCurrentChatMembersAndAdmins() {
    // TODO: implement loadCurrentChatMembersAndAdmins
    throw UnimplementedError();
  }

  @override
  Future<DateTime?> getUserJoinDate(String userId, String chatId) {
    // TODO: implement getUserJoinDate
    throw UnimplementedError();
  }

  @override
  void addListener(VoidCallback listener) {
    // TODO: implement addListener
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  // TODO: implement hasListeners
  bool get hasListeners => throw UnimplementedError();

  @override
  void notifyListeners() {
    // TODO: implement notifyListeners
  }

  @override
  void removeListener(VoidCallback listener) {
    // TODO: implement removeListener
  }

  @override
  void listenToCurrentChatMessages(
    void Function(List<ChatMessage> p1) onNewMessages,
  ) {
    // TODO: implement listenToCurrentChatMessages
  }
}
