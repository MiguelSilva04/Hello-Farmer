import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../core/models/chat.dart';
import '../core/models/app_user.dart';
import '../core/services/chat/chat_list_notifier.dart';
import '../utils/app_routes.dart';
import 'package:intl/intl.dart';
import '../core/services/auth/auth_service.dart';
import '../core/services/chat/chat_service.dart';

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatListNotifier>(
      builder: (ctx, notifier, _) {
        return RefreshIndicator(
          onRefresh: () async {
            notifier.listenToChats();
          },
          child:
              notifier.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : notifier.chats.isEmpty
                  ? _buildEmptyState(context)
                  : AnimatedList(
                    initialItemCount: notifier.chats.length,
                    itemBuilder: (ctx, index, animation) {
                      final isLastItem = index == notifier.chats.length - 1;
                      return Column(
                        children: [
                          _buildChatTile(
                            context,
                            notifier,
                            notifier.chats[index],
                            animation,
                          ),
                          if (!isLastItem) const Divider(),
                        ],
                      );
                    },
                  ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Ainda não entraste em contacto com ninguém?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed:
                () => Navigator.of(context).pushNamed(AppRoutes.NEW_CHAT_PAGE),
            child: const Text(
              "Começa agora uma conversa!",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(
    BuildContext context,
    ChatListNotifier notifier,
    Chat chat,
    Animation<double> animation,
  ) {
    final currentUser = AuthService().currentUser;
    final lastMessage = chat.lastMessage;

    final subtitleText =
        lastMessage == null
            ? 'Nenhuma mensagem'
            : (lastMessage.userId == currentUser?.id
                ? 'Eu: ${lastMessage.text}'
                : '${lastMessage.userName}: ${lastMessage.text}');

    final trailingWidget =
        lastMessage == null
            ? null
            : Text(
              _formatTime(lastMessage.createdAt),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            );

    return FadeTransition(
      opacity: animation,
      child: Slidable(
        key: ValueKey(chat.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _confirmRemoveChat(context, notifier, chat),
              backgroundColor: const Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Remover',
            ),
          ],
        ),
        child: ListTile(
          onTap: () async {
            Provider.of<ChatService>(
              context,
              listen: false,
            ).updateCurrentChat(chat);
            Provider.of<ChatService>(
              context,
              listen: false,
            ).updateCurrentUsers(_getListAppUsers(chat));
            await Navigator.of(context).pushNamed(AppRoutes.CHAT_PAGE);
          },
          leading: CircleAvatar(
            backgroundImage:
                chat.imageUrl != null ? NetworkImage(chat.imageUrl!) : null,
            child: chat.imageUrl == null ? const Icon(Icons.chat) : null,
          ),
          title: Text(chat.name ?? ''),
          subtitle: Text(subtitleText),
          trailing: trailingWidget,
        ),
      ),
    );
  }

  Future<void> _confirmRemoveChat(
    BuildContext context,
    ChatListNotifier notifier,
    Chat chat,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Aviso"),
            content: const Text(
              "Ao remover esta conversa deixarás de fazer parte dela. Tens a certeza?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Não"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Sim"),
              ),
            ],
          ),
    );

    if (confirm ?? false) {
      await notifier.removeChat(chat);
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inMinutes < 1) return 'Agora';
    if (difference.inHours < 1) return '${difference.inMinutes}m';
    if (difference.inDays < 1) return '${difference.inHours}h';
    if (difference.inDays == 1 ||
        (difference.inDays == 0 && now.day != time.day)) {
      return 'Ontem';
    }
    return DateFormat("d MMM y", "pt_PT").format(time);
  }

  List<AppUser> _getListAppUsers(Chat chat) {
    return AuthService().users
        .where((u) => chat.membersIds.contains(u.id))
        .toList();
  }
}
