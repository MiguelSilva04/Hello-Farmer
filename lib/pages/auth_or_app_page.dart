import 'package:harvestly/components/create_store.dart';
import 'package:harvestly/core/models/app_user.dart';
import 'package:harvestly/core/notification/chat_notification_service.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:harvestly/pages/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import '../core/models/store.dart';
import 'main_menu.dart';
import 'welcome_screen.dart';

class AuthOrAppPage extends StatelessWidget {
  const AuthOrAppPage({super.key});

  Future<void> init(BuildContext context) async {
    await Firebase.initializeApp();
    await Provider.of<ChatNotificationService>(context, listen: false).init();
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<AppUser?>(
      stream: authService.userChanges,
      builder: (ctx, userSnapshot) {
        if (userSnapshot.hasError) {
          return Center(child: Text('Erro a carregar utilizador'));
        }
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const LoadingPage();
        }

        final user = userSnapshot.data;

        if (user == null || !userSnapshot.hasData) return WelcomeScreen();

        if (user.isProducer) {
          authService.listenToMyStores();
          return StreamBuilder<List<Store>>(
            stream: authService.myStoresStream,
            builder: (ctx, storesSnapshot) {
                  if (storesSnapshot.connectionState == ConnectionState.waiting) {
                return const LoadingPage();
              }

              final stores = storesSnapshot.data ?? [];
              if (stores.isEmpty) {
                return CreateStore(isFirstTime: true);
              } else {
                return MainMenu();
              }
            },
          );
        } else {
          return MainMenu();
        }
      },
    );
  }
}
