import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
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
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<List<Chat>>(
      stream: Provider.of<ChatService>(
        context,
        listen: false,
      ).streamUserChats(currentUser.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(context);
        }
        final chats = snapshot.data!;
        return RefreshIndicator(
          color: Theme.of(context).colorScheme.secondary,
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (ctx, index) {
              return _buildChatTile(context, chats[index]);
            },
          ),
        );
      },
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
                  trailing: IconButton(
                    icon: const Icon(Icons.message),
                    onPressed: () async {
                      final TextEditingController _messageController =
                          TextEditingController();

                      final result = await showDialog<String>(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            title: Text("Enviar mensagem"),
                            content: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: "Escreve a tua mensagem...",
                              ),
                              maxLines: null,
                              autofocus: true,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text("Fechar"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(
                                    ctx,
                                  ).pop(_messageController.text.trim());
                                },
                                child: const Text("Enviar"),
                              ),
                            ],
                          );
                        },
                      );

                      if (result != null && result.isNotEmpty) {
                        final chatService = Provider.of<ChatService>(
                          context,
                          listen: false,
                        );

                        final newChat = await chatService.createChat(
                          isProducer ? user.id : currentUser!.id,
                          isProducer ? currentUser!.id : user.id,
                        );

                        await chatService.save(
                          result,
                          currentUser!,
                          newChat.id,
                        );

                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed(AppRoutes.CHAT_PAGE);
                      }
                    },
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
    final AuthNotifier authNotifier = Provider.of(context, listen: false);
    final consumer =
        authNotifier.allUsers.where((u) => u.id == chat.consumerId).first;
    final producer =
        authNotifier.allUsers.where((u) => u.id == chat.producerId).first;

    final subtitleText =
        lastMessage == null
            ? 'Nenhuma mensagem'
            : (lastMessage.userId == currentUser?.id
                ? 'Eu: ${lastMessage.text}'
                : '${lastMessage.text}');

    final int unreadCount =
        chat.messages!
            .where((msg) => msg.userId != currentUser?.id && msg.seen == false)
            .length;

    final trailingWidget =
        lastMessage == null
            ? null
            : Column(
              mainAxisSize: MainAxisSize.min,
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
          backgroundImage:
              currentUser!.id == consumer.id
                  ? NetworkImage(producer.imageUrl)
                  : NetworkImage(consumer.imageUrl),
        ),
        title: Text(
          currentUser.id == consumer.id
              ? producer.firstName + " " + producer.lastName
              : consumer.firstName + " " + consumer.lastName,
        ),
        subtitle: Text(subtitleText),
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
