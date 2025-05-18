import 'package:flutter/material.dart';

import '../../../core/models/store.dart';

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
    productsAds: [], // Podes adicionar depois
    storeReviews: [], // Podes adicionar depois
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stack com imagem de fundo e imagem de perfil
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

        // Nome da quinta
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

        // Descrição
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

        // Canais de venda (mock fixo por agora)
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

        // Botão adicionar produto
        Center(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text("Adicionar um produto"),
          ),
        ),
      ],
    );
  }
}
