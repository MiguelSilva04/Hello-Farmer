import 'package:flutter/material.dart';
import 'package:harvestly/core/services/auth/auth_notifier.dart';
import 'package:provider/provider.dart';

import '../core/models/app_user.dart';
import '../core/models/store.dart';
import '../core/services/auth/notification_notifier.dart';
import '../core/services/chat/chat_list_notifier.dart';
import '../core/services/chat/chat_service.dart';
import '../utils/app_routes.dart';

class SendMessageButton extends StatelessWidget {
  final AppUser otherUser;
  final Store? store;
  final bool isIconButton;

  const SendMessageButton({
    super.key,
    required this.otherUser,
    required this.isIconButton,
    this.store,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser =
        Provider.of<AuthNotifier>(context, listen: false).currentUser!;
    final chatService = Provider.of<ChatService>(context, listen: false);
    final notificationNotifier = Provider.of<NotificationNotifier>(
      context,
      listen: false,
    );
    bool verifyIfAlreadyExistsConversation(
      String currentUserId,
      String otherUserId,
    ) {
      final chatList =
          Provider.of<ChatListNotifier>(context, listen: false).chats;

      return chatList.any(
        (chat) =>
            (chat.consumerId == currentUserId &&
                chat.producerId == otherUserId) ||
            (chat.producerId == currentUserId &&
                chat.consumerId == otherUserId),
      );
    }

    final alreadyExists = verifyIfAlreadyExistsConversation(
      currentUser.id,
      otherUser.id,
    );

    if (isIconButton) {
      return IconButton(
        onPressed: () async {
          if (alreadyExists) {
            final chatList =
                Provider.of<ChatListNotifier>(context, listen: false).chats;
            final existingChat = chatList.firstWhere(
              (chat) =>
                  (chat.consumerId == currentUser.id &&
                      chat.producerId == otherUser.id) ||
                  (chat.producerId == currentUser.id &&
                      chat.consumerId == otherUser.id),
            );
            chatService.updateCurrentChat(existingChat);
            Navigator.of(context).pushNamed(AppRoutes.CHAT_PAGE);
            return;
          }

          final _messageController = TextEditingController();
          final result = await showDialog<String>(
            context: context,
            builder:
                (ctx) => AlertDialog(
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
                      onPressed:
                          () => Navigator.of(
                            ctx,
                          ).pop(_messageController.text.trim()),
                      child: const Text("Enviar"),
                    ),
                  ],
                ),
          );

          await submit(
            result,
            chatService,
            currentUser,
            notificationNotifier,
            context,
          );
        },
        icon: Icon(Icons.message),
        tooltip: alreadyExists ? "Ver Conversa" : "Enviar mensagem",
      );
    } else {
      return ElevatedButton.icon(
        onPressed: () async {
          if (alreadyExists) {
            final chatList =
                Provider.of<ChatListNotifier>(context, listen: false).chats;
            final existingChat = chatList.firstWhere(
              (chat) =>
                  (chat.consumerId == currentUser.id &&
                      chat.producerId == otherUser.id) ||
                  (chat.producerId == currentUser.id &&
                      chat.consumerId == otherUser.id),
            );
            chatService.updateCurrentChat(existingChat);
            Navigator.of(context).pushNamed(AppRoutes.CHAT_PAGE);
            return;
          }

          final _messageController = TextEditingController();
          final result = await showDialog<String>(
            context: context,
            builder:
                (ctx) => AlertDialog(
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
                      onPressed:
                          () => Navigator.of(
                            ctx,
                          ).pop(_messageController.text.trim()),
                      child: const Text("Enviar"),
                    ),
                  ],
                ),
          );

          await submit(
            result,
            chatService,
            currentUser,
            notificationNotifier,
            context,
          );
        },
        icon: Icon(
          Icons.message,
          color: Theme.of(context).colorScheme.secondary,
        ),
        label: Text(alreadyExists ? "Ver Conversa" : 'Enviar mensagem'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.secondary,
          backgroundColor: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      );
    }
  }

  Future<void> submit(
    String? result,
    ChatService chatService,
    AppUser currentUser,
    NotificationNotifier notificationNotifier,
    BuildContext context,
  ) async {
    if (result != null && result.isNotEmpty) {
      final newChat = await chatService.createChat(
        currentUser.isProducer ? otherUser.id : currentUser.id,
        currentUser.isProducer ? currentUser.id : otherUser.id,
      );
      final id = (store != null) ? store!.id : otherUser.id;
      await chatService.save(result, currentUser, newChat.id);
      await notificationNotifier
          .addNewMessageNotification(
            id,
            currentUser.id,
            isProducer: store != null,
          );

      Provider.of<ChatListNotifier>(context, listen: false).addChat(newChat);

      chatService.updateCurrentChat(newChat);

      Navigator.of(context).pushNamed(AppRoutes.CHAT_PAGE);
    }
  }
}
