import 'package:flutter/material.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:harvestly/core/services/other/preferences_notifier.dart';
import 'package:provider/provider.dart';

class BillingPage extends StatelessWidget {
  const BillingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser! as ProducerUser;
    final notifier = Provider.of<PreferencesNotifier>(context, listen: false);
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              final controller = TextEditingController(
                text: currentUser.billingAddress ?? "",
              );
              final result = await showDialog<String>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text("Editar Endereço de Faturação"),
                      content: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: "Novo endereço de faturação",
                        ),
                        autofocus: true,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text("Cancelar"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(controller.text.trim());
                          },
                          child: Text("Guardar"),
                        ),
                      ],
                    ),
              );
              if (result != null && result.isNotEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Endereço atualizado!')));
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Endereço de Faturação",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      currentUser.billingAddress ?? "",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.keyboard_arrow_right_rounded, size: 40),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    color: Theme.of(context).colorScheme.tertiaryFixed,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Envio de faturas por email",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              Switch(
                value: notifier.receiptsByEmail,
                onChanged: (val) => notifier.setReceiptsByEmail(val),
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
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mensagem nas faturas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: notifier.receiptMessage,
                decoration: InputDecoration(
                  hintText: "Frase Opcional",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (val) => notifier.setReceiptMessage(val),
              ),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              onPressed: () {
                // Salvar lógica aqui, por exemplo:
                notifier.setReceiptMessage(notifier.receiptMessage);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Mensagem guardada!')));
              },
              child: Text(
                "Guardar",
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
