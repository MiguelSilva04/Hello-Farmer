import 'dart:async';
import 'package:flutter/material.dart';
import '../../../encryption/encryption_service.dart';
import '../../models/chat.dart';
import '../../models/chat_message.dart';
import '../auth/auth_service.dart';
import 'chat_service.dart';

class ChatListNotifier with ChangeNotifier {
  static final ChatListNotifier instance = ChatListNotifier();
  final ChatService _chatService = ChatService();
  List<Chat> _chats = [];
  bool _isLoading = false;
  String _searchQuery = '';
  StreamSubscription<List<Chat>>? _chatSubscription;

  List<Chat> get chats => _filteredChats();
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  ChatListNotifier() {
    listenToChats();
  }

  Future<void> listenToChats() async {
    _isLoading = true;
    notifyListeners();

    final userId = AuthService().currentUser?.id;
    if (userId == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    await _chatSubscription?.cancel();

    _chatSubscription = _chatService.getMembersChats(userId).listen((
      chatList,
    ) async {
      _isLoading = true;
      notifyListeners();

      try {
        final updatedChats = await _fetchLastMessagesForChats(chatList);
        _chats = updatedChats;
        _sortChats();
      } catch (e) {
        print('Error fetching last messages: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<List<Chat>> _fetchLastMessagesForChats(List<Chat> chatList) async {
    return await Future.wait(
      chatList.map((chat) async {
        final lastMessage = await getLastMessage(chat.id);
        chat.lastMessage = lastMessage;
        return chat;
      }).toList(),
    );
  }

  void updateLastMessage(String chatId, ChatMessage lastMessage) {
    final chatIndex = _chats.indexWhere((chat) => chat.id == chatId);
    if (chatIndex != -1) {
      lastMessage.text = EncryptionService.decryptMessage(lastMessage.text);

      _chats[chatIndex].lastMessage = lastMessage;
      _sortChats();
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  Future<void> removeChat(Chat? chat) async {
    await _chatService.removeChat(chat);
  }

  Future<ChatMessage?> getLastMessage(String chatId) async {
    try {
      final messages = await _chatService.messagesStream(chatId).first;
      if (messages.isEmpty) return null;
      messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return messages.first;
    } catch (e) {
      print('Error getting last message: $e');
      return null;
    }
  }

  void addChat(Chat chat) {
    _chats.add(chat);
    _sortChats();
    notifyListeners();
  }

  void _sortChats() {
    _chats.sort((a, b) {
      final aDate = a.lastMessage?.createdAt ?? a.createdAt!;
      final bDate = b.lastMessage?.createdAt ?? b.createdAt!;
      return bDate.compareTo(aDate);
    });
  }

  List<Chat> _filteredChats() {
    if (_searchQuery.isEmpty) {
      return _chats;
    } else {
      return _chats.where((chat) {
        final chatName = chat.name?.toLowerCase() ?? '';
        return chatName.contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  void clearChats() {
    _chatSubscription?.cancel();
    _chatSubscription = null;
    _chats.clear();
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    super.dispose();
  }
}
