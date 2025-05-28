import 'package:flutter/material.dart';
import 'package:harvestly/utils/preferences_notifier.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isActivePIN = false;
  bool _permissions = false;
  bool _localization = false;
  bool _notifications = false;

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<PreferencesNotifier>(context, listen: false);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.language,
                      color: Theme.of(context).colorScheme.tertiaryFixed,
                    ),
                    const SizedBox(width: 8),
                    Text("Idioma", style: TextStyle(fontSize: 20)),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withAlpha(102),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButton<String>(
                    elevation: 2,
                    underline: SizedBox(),
                    iconEnabledColor:
                        Theme.of(context).colorScheme.tertiaryFixed,
                    iconDisabledColor:
                        Theme.of(context).colorScheme.tertiaryFixed,
                    dropdownColor: Theme.of(context).colorScheme.secondary,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiaryFixed,
                      fontSize: 20,
                    ),
                    value: "Português",
                    items: [
                      DropdownMenuItem(
                        value: "Português",
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Text("Português"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Inglês",
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Text("Inglês"),
                        ),
                      ),
                    ],
                    onChanged: (val) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.brightness_6,
                          color: Theme.of(context).colorScheme.tertiaryFixed,
                        ),
                        const SizedBox(width: 8),
                        Text("Tema do sistema", style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: notifier.themeMode == ThemeMode.light,
                          onChanged: (value) => notifier.toggleTheme(false),
                        ),
                        Text("Claro"),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: notifier.themeMode == ThemeMode.dark,
                          onChanged: (value) => notifier.toggleTheme(true),
                        ),
                        Text("Escuro"),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.fingerprint,
                      color: Theme.of(context).colorScheme.tertiaryFixed,
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Text(
                        "Autenticação por biometria ou PIN",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
                Switch(
                  inactiveThumbColor: Theme.of(context).colorScheme.secondary,
                  inactiveTrackColor: Theme.of(
                    context,
                  ).colorScheme.secondary.withAlpha(3),
                  activeColor: Theme.of(context).colorScheme.tertiaryFixed,
                  activeTrackColor: Theme.of(
                    context,
                  ).colorScheme.tertiaryFixed.withAlpha(153),
                  value: _isActivePIN,
                  onChanged:
                      (val) => setState(() {
                        _isActivePIN = !_isActivePIN;
                      }),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: Theme.of(context).colorScheme.tertiaryFixed,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Permissões da aplicação",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                Switch(
                  value: _permissions,
                  onChanged:
                      (val) => setState(() {
                        _permissions = !_permissions;
                      }),
                  inactiveThumbColor: Theme.of(context).colorScheme.secondary,
                  inactiveTrackColor: Theme.of(
                    context,
                  ).colorScheme.secondary.withAlpha(3),
                  activeColor: Theme.of(context).colorScheme.tertiaryFixed,
                  activeTrackColor: Theme.of(
                    context,
                  ).colorScheme.tertiaryFixed.withAlpha(153),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Theme.of(context).colorScheme.tertiaryFixed,
                    ),
                    const SizedBox(width: 8),
                    Text("Localização", style: TextStyle(fontSize: 18)),
                  ],
                ),
                Switch(
                  value: _localization,
                  onChanged:
                      (val) => setState(() {
                        _localization = !_localization;
                      }),
                  inactiveThumbColor: Theme.of(context).colorScheme.secondary,
                  inactiveTrackColor: Theme.of(
                    context,
                  ).colorScheme.secondary.withAlpha(3),
                  activeColor: Theme.of(context).colorScheme.tertiaryFixed,
                  activeTrackColor: Theme.of(
                    context,
                  ).colorScheme.tertiaryFixed.withAlpha(153),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications,
                      color: Theme.of(context).colorScheme.tertiaryFixed,
                    ),
                    const SizedBox(width: 8),
                    Text("Notificações", style: TextStyle(fontSize: 18)),
                  ],
                ),
                Switch(
                  value: _notifications,
                  onChanged:
                      (val) => setState(() {
                        _notifications = !_notifications;
                      }),
                  inactiveThumbColor: Theme.of(context).colorScheme.secondary,
                  inactiveTrackColor: Theme.of(
                    context,
                  ).colorScheme.secondary.withAlpha(3),
                  activeColor: Theme.of(context).colorScheme.tertiaryFixed,
                  activeTrackColor: Theme.of(
                    context,
                  ).colorScheme.tertiaryFixed.withAlpha(153),
                ),
              ],
            ),
            TextButton(
              onPressed:
                  () => showDialog(
                    context: context,
                    builder:
                        (ctx) =>
                            AlertDialog(content: Text(notifier.conditions)),
                  ),
              child: Text("Termos e condições"),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondaryFixed.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.change_circle_outlined),
                    const SizedBox(width: 10),
                    Text(
                      "Redifinir Definições",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
