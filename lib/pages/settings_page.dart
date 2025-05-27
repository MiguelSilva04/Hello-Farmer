import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/auth/auth_service.dart';
import '../core/services/chat/chat_list_notifier.dart';
import '../utils/app_routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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

    if (shouldLogout == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        context.read<ChatListNotifier>().clearChats();
        await AuthService().logout();
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.AUTH_OR_APP_PAGE, (route) => false);
      });
    }
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Icon(icon),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          trailing: const Icon(Icons.keyboard_arrow_right_rounded),
        ),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Definições"),
        actions: [
          IconButton(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              const Divider(),
              _buildSettingsTile(
                icon: Icons.settings,
                title: "Geral",
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.credit_card,
                title: "Métodos de pagamento",
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.cases_rounded,
                title: "Logística",
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.receipt,
                title: "Faturação",
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.notifications,
                title: "Notificações",
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.person,
                title: "Conta",
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
