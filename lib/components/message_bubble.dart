import 'dart:io';

import 'package:harvestly/components/bubble_message_special.dart';
import 'package:harvestly/core/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:harvestly/core/services/auth/auth_notifier.dart';
import 'package:provider/provider.dart';

class MessageBubble extends StatelessWidget {
  static const _defaultImage = 'assets/images/avatar.png';
  final ChatMessage message;
  final bool belongsToCurrentUser;
  final void Function(String) doShowAvatar;
  final bool itsTheSameUser;

  MessageBubble({
    required this.doShowAvatar,
    required this.message,
    required this.belongsToCurrentUser,
    required this.itsTheSameUser,
    super.key,
  });

  ImageProvider _getImageProvider(String imageUrl) {
    ImageProvider? provider;
    final uri = Uri.parse(imageUrl);

    if (uri.path.contains(_defaultImage)) {
      provider = const AssetImage(_defaultImage);
    } else if (uri.scheme.contains('http')) {
      provider = NetworkImage(uri.toString());
    } else {
      provider = FileImage(File(uri.toString()));
    }

    return provider;
  }

  @override
  Widget build(BuildContext context) {
    final user =
        Provider.of<AuthNotifier>(
          context,
          listen: false,
        ).allUsers.where((u) => u.id == message.userId).first;
    String hourSent = message.createdAt.toIso8601String().split('T')[1];
    hourSent = hourSent.split('.').first;
    hourSent = "${hourSent.split(":")[0]}:${hourSent.split(":")[1]}";
    return Container(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          BubbleSpecialThree(
            senderName: user.firstName + " " + user.lastName,
            avatarImage: _getImageProvider(message.userImageUrl),
            hourSent: hourSent,
            text: "${message.text}",
            color:
                belongsToCurrentUser
                    ? Theme.of(context).colorScheme.surface
                    : Color.fromRGBO(201, 215, 248, 1),
            isSender: belongsToCurrentUser,
            tail: true,
            textStyle: TextStyle(
              color: belongsToCurrentUser ? Colors.white : Colors.black,
              fontSize: 16,
            ),
            isSameUser: itsTheSameUser,
            showAvatar: doShowAvatar,
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }
}
