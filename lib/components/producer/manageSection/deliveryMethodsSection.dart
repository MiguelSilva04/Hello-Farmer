import 'package:flutter/material.dart';
import 'package:harvestly/core/models/store.dart';

import '../../../core/services/auth/auth_service.dart';

class DeliveryMethodsSection extends StatelessWidget {
  const DeliveryMethodsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final deliverOptions =
        AuthService().currentUser!.store!.preferredDeliveryMethod!;

    final List<Map<IconData, DeliveryMethod>> deliveryMethodsList = [
      {Icons.local_shipping: DeliveryMethod.COURIER},
      {Icons.home: DeliveryMethod.HOME_DELIVERY},
      {Icons.storefront: DeliveryMethod.PICKUP},
    ];

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Selecione os canais de venda que mais lhe são convenientes!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 5),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: deliveryMethodsList.length,
              itemBuilder: (ctx, index) {
                final entry = deliveryMethodsList[index];
                final icon = entry.keys.first;
                final method = entry.values.first;
                bool checked = deliverOptions.contains(method);
                return ListTile(
                  leading: Icon(
                    icon,
                    size: 35,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  title: Text(
                    method.toDisplayString(),
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.surface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: Transform.scale(
                    scale: 1.6,
                    child: Checkbox(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      activeColor: Theme.of(context).colorScheme.primary,
                      checkColor: Colors.white,
                      value: checked,
                      onChanged: (val) {
                        setState(() {
                          if (checked) {
                            deliverOptions.remove(method);
                          } else {
                            deliverOptions.add(method);
                          }
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
