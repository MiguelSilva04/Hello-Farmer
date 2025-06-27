import 'package:flutter/material.dart';
import 'package:harvestly/core/services/auth/auth_notifier.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:harvestly/core/services/auth/notification_notifier.dart';
import 'package:harvestly/core/services/auth/store_service.dart';
import 'package:harvestly/core/services/other/bottom_navigation_notifier.dart';
import 'package:provider/provider.dart';
import '../../core/models/producer_user.dart';
import '../../core/services/chat/chat_list_notifier.dart';
import '../../utils/app_routes.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
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

    if (shouldLogout != true) return;

    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final user = authNotifier.currentUser;

    if (user != null) {
      final notificationNotifier = Provider.of<NotificationNotifier>(
        context,
        listen: false,
      );

      await notificationNotifier.removeToken(
        id:
            user.isProducer
                ? (user as ProducerUser)
                    .stores[authNotifier.selectedStoreIndex!]
                    .id
                : user.id,
        isProducer: user.isProducer,
      );

      Provider.of<BottomNavigationNotifier>(context, listen: false).setIndex(0);

      await notificationNotifier.logoutCleanup(
        userId: user.id,
        isProducer: user.isProducer,
      );

      await Provider.of<StoreService>(context, listen: false).clearStores();
      context.read<ChatListNotifier>().clearChats();
      authNotifier.setSelectedStoreIndex(0);

      await AuthService().logout();
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.WELCOME_SCREEN, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser!;
    void _showAlert(String title, String message, bool isEditingEmail) {
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () async {
                    (isEditingEmail)
                        ? await AuthService().updateSingleUserField(
                          email: currentUser.recoveryEmail,
                        )
                        : await AuthService().recoverPassword(
                          currentUser.email,
                        );
                    ;
                    Navigator.of(ctx).pushNamedAndRemoveUntil(
                      AppRoutes.WELCOME_SCREEN,
                      (Route<dynamic> route) => false,
                    );
                    AuthService().logout();
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nome",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
              Text(
                "${currentUser.firstName} ${currentUser.lastName}",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
            ],
          ),
          const Divider(),
          InkWell(
            onTap: () async {
              _showAlert(
                "Verificação necessária",
                "Um e-mail de confirmação irá ser enviado para ${currentUser.recoveryEmail}. A sua sessão irá depois disso expirar.",
                true,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Email",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                ),
                Text(
                  "${currentUser.email}",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                ),
              ],
            ),
          ),

          const Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Número de contribuinte",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
              Text(
                "${currentUser.taxpayerNumber ?? ""}",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
            ],
          ),
          const Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cidade",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
              Text(
                "${currentUser.city}",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
            ],
          ),
          Center(
            child: TextButton(
              onPressed: () {
                _showAlert(
                  "Verificação necessária",
                  "Um e-mail de recuperação de palavra-passe irá ser enviado para o seu email, ${currentUser.email}. A sua sessão irá expirar depois disso.",
                  false,
                );
              },
              child: Text(
                "Mudar palavra-passe",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor:
                    Theme.of(context).colorScheme.onSecondaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(width: 0.5),
                ),
                elevation: 0,
              ),
              onPressed: () => _confirmLogout(context),
              child: Text(
                "Terminar Sessão",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
