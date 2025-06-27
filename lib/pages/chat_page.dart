import 'package:firebase_database/firebase_database.dart';
import 'package:harvestly/components/messages.dart';
import 'package:harvestly/components/new_message.dart';
import 'package:harvestly/core/models/app_user.dart';
import 'package:harvestly/core/models/chat.dart';
import 'package:harvestly/core/services/auth/auth_notifier.dart';
import 'package:harvestly/core/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late AuthNotifier authNotifier;
  late String currentChatId;
  late ChatService chatService;

  @override
  void initState() {
    super.initState();
    chatService = Provider.of<ChatService>(context, listen: false);
    authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    currentChatId = chatService.currentChat!.id;
    chatService.listenAndMarkMessagesAsSeen(authNotifier.currentUser!.id);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getLeadingAppBarWidget(
    BuildContext context,
    AppUser consumer,
    AppUser producer,
  ) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      borderRadius: BorderRadius.circular(100),
      child: Row(
        children: [
          const Icon(Icons.arrow_back),
          const SizedBox(width: 5),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            backgroundImage: NetworkImage(
              (authNotifier.currentUser!.id == consumer.id)
                  ? producer.imageUrl
                  : consumer.imageUrl,
            ),
          ),
        ],
      ),
    );
  }

  Future<String> getUserOnlineStatus(String userId) async {
    print(userId);
    final ref = FirebaseDatabase.instance.ref("userStatus/$userId");
    final snapshot = await ref.get();
    print(snapshot);

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>?;

      final isOnline = data?['isOnline'] as bool? ?? false;
      if (isOnline) {
        return "Online";
      } else {
        final lastSeenMillis = data?['lastSeen'] as int?;
        if (lastSeenMillis != null) {
          final lastSeen = DateTime.fromMillisecondsSinceEpoch(lastSeenMillis);
          final now = DateTime.now();
          final difference = now.difference(lastSeen);

          if (difference.inSeconds < 60) {
            return "Online há poucos segundos";
          } else if (difference.inMinutes < 60) {
            return "Online há ${difference.inMinutes} min";
          } else if (difference.inHours < 24) {
            return "Online há ${difference.inHours} h";
          } else {
            return "Online há ${difference.inDays} d";
          }
        }
      }
    }
    return "Offline";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: chatService.messagesChat(),
      builder: (context, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!chatSnapshot.hasData || !chatSnapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Chat não encontrado.')),
          );
        }

        final chatData = chatSnapshot.data!;
        final chat = Chat.fromDocument(chatData);

        final consumer = authNotifier.allUsers.firstWhereOrNull(
          (u) => u.id == chat.consumerId,
        );
        final producer = authNotifier.allUsers.firstWhereOrNull(
          (u) => u.id == chat.producerId,
        );

        return Scaffold(
          appBar: AppBar(
            leadingWidth: 70,
            leading: getLeadingAppBarWidget(context, consumer!, producer!),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (authNotifier.currentUser!.id == consumer.id)
                      ? '${producer.firstName} ${producer.lastName}'
                      : '${consumer.firstName} ${consumer.lastName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FutureBuilder<String>(
                  future: getUserOnlineStatus(
                    (authNotifier.currentUser!.id == consumer.id)
                        ? producer.id
                        : consumer.id,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text(
                        "A carregar...",
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      );
                    }
                    final isOnline = snapshot.data == "Online";
                    return Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: isOnline ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          snapshot.data ?? "Offline",
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            centerTitle: false,
            titleSpacing: 5,
            titleTextStyle: const TextStyle(fontSize: 22),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(child: Messages(currentChatId)),
                NewMessage(currentChatId),
              ],
            ),
          ),
        );
      },
    );
  }
}
