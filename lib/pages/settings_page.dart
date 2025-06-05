import 'package:flutter/material.dart';
import 'package:harvestly/components/settings/account_page.dart';
import 'package:harvestly/components/settings/billing_page.dart';
import 'package:harvestly/components/settings/notifications_page.dart';
import 'package:harvestly/components/settings/payment_page.dart';
import 'package:harvestly/core/services/other/settings_notifier.dart';
import 'package:provider/provider.dart';

import '../components/settings/main_page.dart';
import '../core/models/app_user.dart';
import '../core/services/auth/auth_service.dart';
import '../core/services/other/manage_section_notifier.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late int _selectedIndex;
  late SettingsNotifier provider;
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
    provider = Provider.of<SettingsNotifier>(context);
    _selectedIndex = provider.currentIndex;
    final user = AuthService().currentUser!;
    final pages = [
      {"Definições": getMain(context, user)},
      {"Geral": MainPage()},
      {"Métodos de pagamento": PaymentPage()},
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
              provider.setIndex(0);
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
      ),
      body: pages[_selectedIndex].entries.first.value,
    );
  }

  Widget getMain(BuildContext context, AppUser user) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const Divider(),
            _buildSettingsTile(
              icon: Icons.settings,
              title: "Geral",
              onTap: () => provider.setIndex(1),
            ),
            _buildSettingsTile(
              icon: Icons.credit_card,
              title: "Métodos de pagamento",
              onTap: () => provider.setIndex(2),
            ),
            if (user.isProducer!)
              _buildSettingsTile(
                icon: Icons.receipt,
                title: "Faturação",
                onTap: () => provider.setIndex(3),
              ),
            _buildSettingsTile(
              icon: Icons.notifications,
              title: "Notificações",
              onTap: () => provider.setIndex(4),
            ),
            _buildSettingsTile(
              icon: Icons.person,
              title: "Conta",
              onTap: () => provider.setIndex(5),
            ),
          ],
        ),
      ),
    );
  }
}
