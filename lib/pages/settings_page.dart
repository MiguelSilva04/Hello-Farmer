import 'package:flutter/material.dart';
import 'package:harvestly/components/settings/account_page.dart';
import 'package:harvestly/components/settings/billing_page.dart';
import 'package:harvestly/components/settings/logistics_page.dart';
import 'package:harvestly/components/settings/notifications_page.dart';
import 'package:harvestly/components/settings/payment_page.dart';
import 'package:provider/provider.dart';

import '../components/settings/main_page.dart';
import '../core/services/auth/auth_service.dart';
import '../core/services/chat/chat_list_notifier.dart';
import '../utils/app_routes.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 0;

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
    final pages = [
      {"Definições": getMain(context)},
      {"Geral": MainPage()},
      {"Métodos de pagamento": PaymentPage()},
      {"Logística": LogisticsPage()},
      {"Faturação": BillingPage()},
      {"Notificações": NotificationsPage()},
      {"Conta": AccountPage()},
    ];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_selectedIndex == 0) {
              Navigator.of(context).pop();
            } else {
              setState(() {
                _selectedIndex = 0;
              });
            }
          },
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            pages[_selectedIndex].entries.first.key,
            style: const TextStyle(fontSize: 40),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: pages[_selectedIndex].entries.first.value,
    );
  }

  Widget getMain(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const Divider(),
            _buildSettingsTile(
              icon: Icons.settings,
              title: "Geral",
              onTap: () => setState(() => _selectedIndex = 1),
            ),
            _buildSettingsTile(
              icon: Icons.credit_card,
              title: "Métodos de pagamento",
              onTap: () => setState(() => _selectedIndex = 2),
            ),
            _buildSettingsTile(
              icon: Icons.cases_rounded,
              title: "Logística",
              onTap: () => setState(() => _selectedIndex = 3),
            ),
            _buildSettingsTile(
              icon: Icons.receipt,
              title: "Faturação",
              onTap: () => setState(() => _selectedIndex = 4),
            ),
            _buildSettingsTile(
              icon: Icons.notifications,
              title: "Notificações",
              onTap: () => setState(() => _selectedIndex = 5),
            ),
            _buildSettingsTile(
              icon: Icons.person,
              title: "Conta",
              onTap: () => setState(() => _selectedIndex = 6),
            ),
          ],
        ),
      ),
    );
  }
}
