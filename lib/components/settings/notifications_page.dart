import 'package:flutter/material.dart';
import 'package:harvestly/core/services/other/preferences_notifier.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<PreferencesNotifier>(context, listen: false);
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: Theme.of(context).colorScheme.tertiaryFixed,
                  ),
                  const SizedBox(width: 15),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Notificações push",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "Mostrar as notificações no ecrã bloqueado",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Switch(
                value: notifier.pushNotifications,
                onChanged: (val) => notifier.setPushNotifications(val),
                inactiveThumbColor: Theme.of(context).colorScheme.secondary,
                inactiveTrackColor: Theme.of(
                  context,
                ).colorScheme.secondary.withAlpha(3),
                activeColor: Theme.of(context).colorScheme.secondary,
                activeTrackColor: Theme.of(context).colorScheme.surface,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    color: Theme.of(context).colorScheme.tertiaryFixed,
                  ),
                  const SizedBox(width: 15),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Notificações por e-mail",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "Receber notificações na sua caixa de entrada",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Switch(
                value: notifier.emailNotifications,
                onChanged: (val) => notifier.setEmailNotifications(val),
                inactiveThumbColor: Theme.of(context).colorScheme.secondary,
                inactiveTrackColor: Theme.of(
                  context,
                ).colorScheme.secondary.withAlpha(3),
                activeColor: Theme.of(context).colorScheme.secondary,
                activeTrackColor: Theme.of(context).colorScheme.surface,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.recommend_outlined,
                    color: Theme.of(context).colorScheme.tertiaryFixed,
                  ),
                  const SizedBox(width: 15),
                  Text(
                    "Recomendações",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Switch(
                value: notifier.recomendations,
                onChanged: (val) => notifier.setRecomendations(val),
                inactiveThumbColor: Theme.of(context).colorScheme.secondary,
                inactiveTrackColor: Theme.of(
                  context,
                ).colorScheme.secondary.withAlpha(3),
                activeColor: Theme.of(context).colorScheme.secondary,
                activeTrackColor: Theme.of(context).colorScheme.surface,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.update_outlined,
                    color: Theme.of(context).colorScheme.tertiaryFixed,
                  ),
                  const SizedBox(width: 15),
                  Text(
                    "Atualizações de produtos",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Switch(
                value: notifier.productsUpdates,
                onChanged: (val) => notifier.setProductsUpdates(val),
                inactiveThumbColor: Theme.of(context).colorScheme.secondary,
                inactiveTrackColor: Theme.of(
                  context,
                ).colorScheme.secondary.withAlpha(3),
                activeColor: Theme.of(context).colorScheme.secondary,
                activeTrackColor: Theme.of(context).colorScheme.surface,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
