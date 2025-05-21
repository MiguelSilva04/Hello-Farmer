import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/product_ad.dart';
import '../../../core/models/store.dart';
import '../../../core/services/other/bottom_navigation_notifier.dart';

class MainPageSection extends StatelessWidget {
  MainPageSection({super.key});

  final store = Store(
    backgroundImageUrl: "assets/images/mock_images/quinta.jpg",
    imageUrl: "assets/images/mock_images/quinta.jpg",
    name: "Quinta da Soeira",
    subName: "Vale Verde",
    description:
        "Na Quinta do Vale Verde, cultivamos com paixão e respeito pela natureza. Todos os nossos produtos são 100% biológicos.",
    location: "Braga",
    address: "Rua da Agricultura, 123",
    preferredMarkets: ["Feira de Guimarães", "Mercado de Braga"],
    productsAds: [
      ProductAd(
        name: "Ovos Biológico",
        imageUrl: "assets/images/mock_images/eggs.jpg",
        price: "2,50€/unidade",
        category: "Ovos",
        highlight: "Colheita biológica!",
      ),
      ProductAd(
        name: "Centeio",
        imageUrl: "assets/images/mock_images/centeio.jpg",
        price: "3,00€/kg",
        category: "Ervas",
        highlight: "Colheita fresca!",
      ),
      ProductAd(
        name: "Cenouras baby",
        imageUrl: "assets/images/mock_images/baby_carrots.jpg",
        price: "1,20€/unidade",
        category: "Legumes",
        highlight: "Promoção da semana",
      ),
    ],
    storeReviews: [],
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Image.asset(
              store.imageUrl ?? "assets/images/default_store.jpg",
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
                      "assets/images/mock_images/trigo.jpg",
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
                    child: const Text("Definir Canais de venda"),
                  ),
                ],
              ),
              Wrap(
                spacing: 10,
                children: [
                  Chip(
                    avatar: Icon(
                      Icons.local_shipping,
                      size: 18,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    label: Text(
                      "Transportadora",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  Chip(
                    avatar: Icon(
                      Icons.home,
                      size: 18,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    label: Text(
                      "Entrega ao domicílio",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
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
                  : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: store.productsAds!.length,
                    itemBuilder: (context, index) {
                      final ad = store.productsAds![index];
                      return Card(
                        color: Theme.of(context).colorScheme.secondary,
                        // margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              ad.imageUrl,
                              width: 75,
                              height: 75,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(ad.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Preço: ${ad.price}"),
                              Text("Categoria: ${ad.category}"),
                              if (ad.highlight.isNotEmpty)
                                Text(
                                  ad.highlight,
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              // Implementar ações: editar, remover, tornar público/privado
                            },
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
                        ),
                      );
                    },
                  ),
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
