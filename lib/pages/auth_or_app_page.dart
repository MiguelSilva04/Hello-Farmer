import 'package:harvestly/core/models/app_user.dart';
import 'package:harvestly/core/notification/chat_notification_service.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:harvestly/pages/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'main_menu.dart';
import 'welcome_screen.dart';

class AuthOrAppPage extends StatelessWidget {
  const AuthOrAppPage({super.key});

  Future<void> init(BuildContext context) async {
    await Firebase.initializeApp();
    await Provider.of<ChatNotificationService>(context, listen: false).init();

    // final authService = Provider.of<AuthFirebaseService>(
    //   context,
    //   listen: false,
    // );
    // authService.listenToUserChanges();

    // final user = await authService.getCurrentUser();
    // if (user != null) {
    //   authService.setCurrentUser(user);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: init(context),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingPage();
        } else {
          return StreamBuilder<AppUser?>(
            stream: AuthService().userChanges,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingPage();
              } else {
                return snapshot.hasData ? const MainMenu() : WelcomeScreen();
              }
            },
          );
        }
      },
    );
  }
}
