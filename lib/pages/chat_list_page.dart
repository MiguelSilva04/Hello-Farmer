import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../components/sendMessageButton.dart';
import '../core/models/chat.dart';
import '../core/services/auth/auth_notifier.dart';
import '../core/services/auth/auth_service.dart';
import '../core/services/chat/chat_service.dart';
import '../utils/app_routes.dart';
import 'package:intl/intl.dart';

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser;
    if (currentUser == null) {
      print("Esta a acontecer isto");
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      backgroundColor: Theme.of(context).colorScheme.primary,
      color: Theme.of(context).colorScheme.secondary,
      onRefresh: () async {
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: StreamBuilder<List<Chat>>(
        stream: Provider.of<ChatService>(
          context,
          listen: false,
        ).streamAllChatsWithMessages(currentUser),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print("Esta a acontecer isto");
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(context);
          }

          List<Chat> chats = List<Chat>.from(snapshot.data!);
          chats.sort((a, b) {
            if (a.lastMessage == null && b.lastMessage == null) return 0;
            if (a.lastMessage == null) return 1;
            if (b.lastMessage == null) return -1;
            return b.lastMessage!.createdAt.compareTo(a.lastMessage!.createdAt);
          });

          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (ctx, index) {
              final chat = chats[index];
              return _buildChatTile(context, chat);
            },
          );
        },
      ),
    );
  }

  void _showStartChatModal(BuildContext context) {
    final currentUser = AuthService().currentUser;
    final isProducer = currentUser?.isProducer ?? false;

    final allUsers = Provider.of<AuthNotifier>(context, listen: false).allUsers;

    final filteredUsers =
        allUsers.where((user) {
          return user.id != currentUser?.id && (user.isProducer != isProducer);
        }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (_, scrollController) {
            if (filteredUsers.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Nenhum utilizador disponível."),
                ),
              );
            }

            return ListView.builder(
              controller: scrollController,
              itemCount: filteredUsers.length,
              itemBuilder: (_, index) {
                final user = filteredUsers[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      user.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(user.firstName + " " + user.lastName),
                  trailing: SendMessageButton(
                    otherUser: user,
                    isIconButton: true,
                  ),
                );
              },
            );
          },
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
            onPressed: () => _showStartChatModal(context),
            child: const Text(
              "Começa agora uma conversa!",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, Chat chat) {
    final currentUser = AuthService().currentUser;
    final lastMessage = chat.lastMessage;
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final consumer = authNotifier.allUsers.firstWhere(
      (u) => u.id == chat.consumerId,
    );
    final producer = authNotifier.allUsers.firstWhere(
      (u) => u.id == chat.producerId,
    );

    final subtitleText =
        lastMessage == null
            ? 'Nenhuma mensagem'
            : (lastMessage.userId == currentUser?.id
                ? 'Eu: ${lastMessage.text}'
                : '${lastMessage.text}');

    final int unreadCount = chat.unreadMessages ?? 0;

    final trailingWidget =
        lastMessage == null
            ? null
            : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(lastMessage.createdAt),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            );

    return Slidable(
      key: ValueKey(chat.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _confirmRemoveChat(context, chat),
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
          await Navigator.of(context).pushNamed(AppRoutes.CHAT_PAGE);
        },
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            currentUser!.id == consumer.id
                ? producer.imageUrl
                : consumer.imageUrl,
          ),
        ),
        title: Text(
          currentUser.id == consumer.id
              ? '${producer.firstName} ${producer.lastName}'
              : '${consumer.firstName} ${consumer.lastName}',
        ),
        subtitle: Text(subtitleText, overflow: TextOverflow.ellipsis),
        trailing: trailingWidget,
      ),
    );
  }

  Future<void> _confirmRemoveChat(BuildContext context, Chat chat) async {
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
      await Provider.of<ChatService>(context, listen: false).removeChat(chat);
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
}
