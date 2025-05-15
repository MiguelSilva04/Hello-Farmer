import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/auth/auth_service.dart';
import '../core/services/chat/chat_list_notifier.dart';
import '../utils/app_routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: const Text("Confirmar"),
                      content: const Text(
                        "Tem a certeza que pretende terminar a sessão?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text("Não"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text("Sim"),
                        ),
                      ],
                    ),
              );

              if (shouldLogout == true) {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  final chatNotifier = context.read<ChatListNotifier>();
                  chatNotifier.clearChats();
                  await AuthService().logout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.AUTH_OR_APP_PAGE,
                    (route) => false,
                  );
                });
              }
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Center(child: Text("Definições")),
    );
  }
}
