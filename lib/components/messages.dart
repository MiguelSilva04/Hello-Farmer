import 'dart:io';
import 'package:harvestly/components/custom_chip.dart';
import 'package:harvestly/components/message_bubble.dart';
import 'package:harvestly/core/models/chat_message.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:harvestly/core/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/models/chat.dart';
import 'package:collection/collection.dart';

class Messages extends StatefulWidget {
  final String chatId;

  const Messages(this.chatId, {super.key});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  bool _isShowingAvatar = false;
  String? _curImageUrl;
  Chat? chat;
  Map<String, DateTime> userEntryDates = {};
  ChatService? provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<ChatService>(context, listen: false);
    _loadUserEntryDates();
  }

  Future<void> _loadUserEntryDates() async {
    chat = provider!.currentChat;
    if (chat != null) {
      for (var memberId in chat!.membersIds) {
        final joinedDate = await provider!.getUserJoinDate(memberId, chat!.id!);
        if (joinedDate != null) {
          userEntryDates[memberId] = joinedDate;
        }
      }
      setState(() {});
    }
  }

  bool compareDatesDays(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  String dateChipText(DateTime date) {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final yesterday = DateFormat(
      'yyyy-MM-dd',
    ).format(now.subtract(const Duration(days: 1)));
    final messageDate = DateFormat('yyyy-MM-dd').format(date);

    if (today == messageDate) return 'Hoje';
    if (yesterday == messageDate) return 'Ontem';
    return DateFormat("d 'de' MMMM 'de' y", "pt_PT").format(date);
  }

  bool isSameUser(ChatMessage currentMessage, ChatMessage? previousMessage) {
    return previousMessage != null &&
        currentMessage.userId == previousMessage.userId &&
        currentMessage.createdAt.day == previousMessage.createdAt.day;
  }

  void _switchAvatarShowing(String imageUrl) {
    setState(() {
      _curImageUrl = imageUrl;
      _isShowingAvatar = !_isShowingAvatar;
    });
  }

  void _hideAvatar() => setState(() => _isShowingAvatar = false);

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);
    final currentUser = AuthService().currentUser;
    final chatUsers = chatService.currentUsers ?? [];

    return StreamBuilder<List<ChatMessage>>(
      stream: chatService.messagesStream(widget.chatId),
      builder: (ctx, snapshot) {
        final messages = snapshot.data ?? [];
        final List<MapEntry<DateTime, Widget>> timelineEntries = [];
        final isCurrentUserCreator =
            chat?.createdAt == userEntryDates[currentUser?.id];

        if (chat != null) {
          timelineEntries.add(
            MapEntry(chat!.createdAt!, _buildGroupInfoCard()),
          );

          final chipText =
              isCurrentUserCreator ? 'Criaste este grupo' : 'Entraste no grupo';
          timelineEntries.add(
            MapEntry(
              userEntryDates[currentUser?.id] ?? chat!.createdAt!,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: CustomChip(text: chipText),
              ),
            ),
          );
        }

        // Carregar os userEntryDates dinamicamente
        if (chat != null && userEntryDates.isEmpty) {
          for (var memberId in chat!.membersIds) {
            provider!.getUserJoinDate(memberId, chat!.id!).then((joinedDate) {
              if (joinedDate != null) {
                setState(() {
                  userEntryDates[memberId] = joinedDate;
                });
              }
            });
          }
        }

        for (var entry in userEntryDates.entries) {
          final user = chatUsers.firstWhereOrNull((u) => u.id == entry.key);
          if (user != null && user.id != currentUser!.id) {
            timelineEntries.add(
              MapEntry(
                entry.value,
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: CustomChip(text: '${user.firstName} entrou no grupo'),
                ),
              ),
            );
          }
        }

        for (int i = messages.length - 1; i >= 0; i--) {
          final currentMessage = messages[i];
          final nextMessage = i + 1 < messages.length ? messages[i + 1] : null;

          final createdAt = currentMessage.createdAt;

          final isNewDay =
              nextMessage == null ||
              !compareDatesDays(createdAt, nextMessage.createdAt);

          if (isNewDay) {
            timelineEntries.add(
              MapEntry(
                createdAt.subtract(const Duration(milliseconds: 1)),
                CustomChip(text: dateChipText(createdAt)),
              ),
            );
          }

          timelineEntries.add(
            MapEntry(
              createdAt,
              MessageBubble(
                key: ValueKey(currentMessage.id),
                message: currentMessage,
                belongsToCurrentUser: currentUser?.id == currentMessage.userId,
                itsTheSameUser: isSameUser(currentMessage, nextMessage),
                doShowAvatar: _switchAvatarShowing,
              ),
            ),
          );
        }

        // Ordenar por data
        timelineEntries.sort((a, b) => a.key.compareTo(b.key));

        // Construir a lista de widgets ordenados
        final widgetsToDisplay = timelineEntries.map((e) => e.value).toList();

        return Stack(
          children: [
            Opacity(
              opacity: _isShowingAvatar ? 0.2 : 1,
              child: InkWell(
                onTap: _isShowingAvatar ? _hideAvatar : null,
                child: ListView(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: widgetsToDisplay.reversed.toList(),
                ),
              ),
            ),
            if (_isShowingAvatar) Center(child: _showUserImage()),
          ],
        );
      },
    );
  }

  Widget _showUserImage() {
    final uri = Uri.parse(_curImageUrl!);
    final imageProvider =
        uri.scheme.contains('http')
            ? NetworkImage(uri.toString())
            : FileImage(File(uri.toString())) as ImageProvider;
    return CircleAvatar(backgroundImage: imageProvider, radius: 150);
  }

  Widget _buildGroupInfoCard() {
    if (chat == null) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            SizedBox(height: 10),
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(chat!.imageUrl!),
            ),
            SizedBox(height: 10),
            Text(
              chat!.name!,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                chat!.description ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
