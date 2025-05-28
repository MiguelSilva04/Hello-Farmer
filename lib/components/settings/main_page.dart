import 'package:flutter/material.dart';
import 'package:harvestly/core/services/other/preferences_notifier.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isOnContractMode = false;

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<PreferencesNotifier>(context, listen: false);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          if (_isOnContractMode)
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(notifier.conditions),
                    TextButton(
                      onPressed:
                          () => setState(() => _isOnContractMode = false),
                      child: Text("Fechar"),
                    ),
                  ],
                ),
              ),
            ),
          Opacity(
            opacity: _isOnContractMode ? 0 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                              color:
                                  Theme.of(context).colorScheme.tertiaryFixed,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Tema do sistema",
                              style: TextStyle(fontSize: 20),
                            ),
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
                      inactiveThumbColor:
                          Theme.of(context).colorScheme.secondary,
                      inactiveTrackColor: Theme.of(
                        context,
                      ).colorScheme.secondary.withAlpha(3),
                      activeColor: Theme.of(context).colorScheme.secondary,
                      activeTrackColor: Theme.of(context).colorScheme.surface,
                      value: notifier.isActivePin,
                      onChanged: (val) => notifier.setActivePin(val),
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
                      value: notifier.permissions,
                      onChanged: (val) => notifier.setPermissions(val),
                      inactiveThumbColor:
                          Theme.of(context).colorScheme.secondary,
                      inactiveTrackColor: Theme.of(
                        context,
                      ).colorScheme.secondary.withAlpha(3),
                      activeColor: Theme.of(context).colorScheme.secondary,
                      activeTrackColor: Theme.of(context).colorScheme.surface,
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
                      value: notifier.localization,
                      onChanged: (val) => notifier.setLocalization(val),
                      inactiveThumbColor:
                          Theme.of(context).colorScheme.secondary,
                      inactiveTrackColor: Theme.of(
                        context,
                      ).colorScheme.secondary.withAlpha(3),
                      activeColor: Theme.of(context).colorScheme.secondary,
                      activeTrackColor: Theme.of(context).colorScheme.surface,
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
                      value: notifier.notifications,
                      onChanged: (val) => notifier.setNotifications(val),
                      inactiveThumbColor:
                          Theme.of(context).colorScheme.secondary,
                      inactiveTrackColor: Theme.of(
                        context,
                      ).colorScheme.secondary.withAlpha(3),
                      activeColor: Theme.of(context).colorScheme.secondary,
                      activeTrackColor: Theme.of(context).colorScheme.surface,
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
                          Icons.inventory_2,
                          color: Theme.of(context).colorScheme.tertiaryFixed,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Gestão de Inventário",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    Switch(
                      value: notifier.inventoryManagement,
                      onChanged: (val) => notifier.setInventoryManagement(val),
                      inactiveThumbColor:
                          Theme.of(context).colorScheme.secondary,
                      inactiveTrackColor: Theme.of(
                        context,
                      ).colorScheme.secondary.withAlpha(3),
                      activeColor: Theme.of(context).colorScheme.secondary,
                      activeTrackColor: Theme.of(context).colorScheme.surface,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final selected = await showDialog<ReturnPolicy>(
                      context: context,
                      builder: (context) {
                        return SimpleDialog(
                          title: Text(
                            "Selecione a política de devoluções",
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.tertiaryFixed,
                              fontSize: 24,
                            ),
                          ),
                          children: [
                            SimpleDialogOption(
                              onPressed:
                                  () =>
                                      Navigator.pop(context, ReturnPolicy.NONE),
                              child: Text('Sem devolução'),
                            ),
                            SimpleDialogOption(
                              onPressed:
                                  () => Navigator.pop(
                                    context,
                                    ReturnPolicy.THREE_DAYS,
                                  ),
                              child: Text('3 dias após a entrega'),
                            ),
                            SimpleDialogOption(
                              onPressed:
                                  () =>
                                      Navigator.pop(context, ReturnPolicy.WEEK),
                              child: Text('1 semana após a entrega'),
                            ),
                            SimpleDialogOption(
                              onPressed:
                                  () => Navigator.pop(
                                    context,
                                    ReturnPolicy.MONTH,
                                  ),
                              child: Text('1 mês após a entrega'),
                            ),
                          ],
                        );
                      },
                    );
                    if (selected != null) {
                      notifier.setReturnPolicy(selected);
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Política de devoluções",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            notifier.returnPolicy.toDisplayString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _isOnContractMode = true),
                    child: Text("Termos e condições"),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondaryFixed.withAlpha(30),
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondaryContainer,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {},
                    icon: Icon(
                      Icons.change_circle_outlined,
                      color: Theme.of(context).colorScheme.tertiaryFixed,
                      size: 30,
                    ),
                    label: Text(
                      "Redefinir Definições",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
