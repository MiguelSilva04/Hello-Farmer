import 'dart:async';

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

  @override
  void initState() {
    super.initState();
    authNotifier = Provider.of(context, listen: false);
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
                  ? producer.imageUrl ?? ''
                  : consumer.imageUrl ?? '',
            ),
            child:
                (consumer.imageUrl == null && producer.imageUrl == null)
                    ? const Icon(Icons.group)
                    : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context, listen: false);
    final currentChatId = chatService.currentChat!.id;

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('chats')
              .doc(currentChatId)
              .snapshots(),
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
            title: Text(
              (authNotifier.currentUser!.id == consumer.id)
                  ? '${producer.firstName} ${producer.lastName}'
                  : '${consumer.firstName} ${consumer.lastName}',
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
