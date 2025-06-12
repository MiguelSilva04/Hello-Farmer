// Modelo de dados para notificação
import 'package:flutter/material.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';

import '../core/models/notification.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final notifications = AuthService().currentUser!.notifications;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body:
          (notifications != null)
              ? ListView.builder(
                itemCount: notifications!.length,
                itemBuilder: (context, index) {
                  final notification = notifications![index];
                  return Dismissible(
                    key: Key(notification.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      setState(() {
                        notifications!.removeAt(index);
                      });
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: notification.type.color,
                        child: Icon(
                          notification.type.icon,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(notification.title),
                      subtitle: Text(notification.description),
                      trailing: Text(
                        '${notification.dateTime.day}/${notification.dateTime.month} ${notification.dateTime.hour}:${notification.dateTime.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  );
                },
              )
              : Center(child: Text("Sem notificações")),
    );
  }
}
