import 'package:flutter/material.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

import '../../../core/models/product_ad.dart';
import '../../../core/models/store.dart';
import '../../../core/services/other/bottom_navigation_notifier.dart';

class MainPageSection extends StatelessWidget {
  MainPageSection({super.key});

  final store = AuthService().currentUser!.store!;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Image.asset(
              store.backgroundImageUrl ?? "assets/images/default_store.jpg",
              fit: BoxFit.cover,
              width: double.infinity,
              height: 180,
            ),
            Positioned(
              bottom: -50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondaryFixed,
                      width: 1,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage(
                      store.imageUrl ?? "assets/images/default_store.jpg",
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 60),

        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  store.name ?? "Sem Nome",
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.edit, size: 20),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Descrição",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                store.description ?? "Sem descrição disponível.",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Canais de venda",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Definir Canais de venda",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 10,
                children:
                    store.preferredDeliveryMethod?.map((method) {
                      IconData icon;
                      switch (method) {
                        case DeliveryMethod.COURIER:
                          icon = Icons.local_shipping;
                          break;
                        case DeliveryMethod.HOME_DELIVERY:
                          icon = Icons.home;
                          break;
                        case DeliveryMethod.PICKUP:
                          icon = Icons.store;
                          break;
                      }
                      return Chip(
                        avatar: Icon(
                          icon,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        label: Text(
                          method.toDisplayString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList() ??
                    [],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Anúncios publicados",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      Provider.of<BottomNavigationNotifier>(
                        context,
                        listen: false,
                      ).setIndex(2);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Novo anúncio"),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              store.productsAds!.isEmpty
                  ? const Text("Ainda não há anúncios publicados.")
                  : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: store.productsAds!.length,
                    itemBuilder: (context, index) {
                      final ad = store.productsAds![index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            ad.product.imageUrl.first,
                            width: 75,
                            height: 75,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              ad.product.name,
                              style: TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 5),
                            if (ad.highlight.isNotEmpty)
                              Tooltip(
                                message: ad.highlight,
                                showDuration: const Duration(seconds: 7),
                                triggerMode: TooltipTriggerMode.tap,
                                preferBelow: false,
                                child: Icon(
                                  Icons.info_outline,
                                ), // usar info_outline é mais visual
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Preço: ${ad.price}"),
                            Text("Categoria: ${ad.product.category}"),
                            // if (ad.highlight.isNotEmpty)
                            //   Text(
                            //     ad.highlight,
                            //     style: const TextStyle(
                            //       color: Colors.orange,
                            //       fontWeight: FontWeight.bold,
                            //     ),
                            //   ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {},
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Editar'),
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'remove',
                                  child: ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text('Remover'),
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'toggle_visibility',
                                  child: ListTile(
                                    leading: Icon(Icons.visibility),
                                    title: Text('Tornar público/privado'),
                                  ),
                                ),
                              ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => Divider(),
                  ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        // Center(
        //   child: ElevatedButton.icon(
        //     onPressed: () {},
        //     icon: const Icon(Icons.add),
        //     label: const Text("Adicionar um produto"),
        //   ),
        // ),
      ],
    );
  }
}
