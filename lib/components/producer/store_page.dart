import 'package:flutter/material.dart';


class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  bool showBanca = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    _buildTopButton("Banca", showBanca, () {
                      setState(() => showBanca = true);
                    }),
                    _buildTopButton("Avaliações", !showBanca, () {
                      setState(() => showBanca = false);
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: () { if (showBanca) {
                return _buildBancaSection();
              } else {
                return _buildAvaliacoesSection();}}(),
            ),
          ],
        ),
      
    );
  }

  Widget _buildTopButton(String text, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Theme.of(context).colorScheme.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBancaSection() {
  const mercados = [
    "Mercado Biológico de Lisboa",
    "Feira Rural de Torres Vedras",
    "Mercado Eco de Santarém"
  ];
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/producer/agro_insurance.jpg',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Quinta Sol Nascente",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Text("Produzimos com foco na sustentabilidade"),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                          ),
                          child: Text(
                            "Editar banca",
                            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Descrição
              const Text("Descrição", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text(
                "Bem-vindo à Quinta Sol Nascente 🙂 | Produzimos com foco na sustentabilidade e bem-estar | Agricultura regenerativa | Do campo diretamente para a sua mesa, com amor e responsabilidade 🌱",
              ),

              const SizedBox(height: 16),

              // Detalhes
              const Text("Detalhes", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(children: const [
                Icon(Icons.place, color: Colors.red, size: 18),
                SizedBox(width: 4),
                Text("Localização: Almeirim"),
              ]),
              Row(children: [
                Icon(Icons.home, color: Theme.of(context).colorScheme.primary, size: 18),
                SizedBox(width: 4),
                Text("Morada: -8.6235, 39.2081"),
              ]),

              const SizedBox(height: 16),

              // Mercados Habituais
              const Text("Mercados Habituais", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              for (var mercado in mercados)
                Row(
                  children: [
                    const Text("• "),
                    Expanded(child: Text(mercado)),
                  ],
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Anúncios Publicados
          AnuncioItem(
            id: '1',
            imageUrl: 'assets/images/producer/agro_insurance.jpg',
              name: 'Centeio',
              price: '13.5€/kg',
              category: 'Cereais',
              destaque: 'Este anúncio foi destacado por mais 3 dias!',
          ),
          SizedBox(height: 12),
        AnuncioItem(
            id: '2',
            imageUrl: 'assets/images/producer/agro_insurance.jpg',
            name: 'Trigo',
            price: '12.5€/kg',
            category: 'Cereais',
            destaque: 'Este anúncio não está em destaque!',
          ),
        ],
    ),
  );
}

  Widget _buildAvaliacoesSection() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text("Avaliações", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

class AnuncioItem extends StatelessWidget {
  final String id;
  final String imageUrl;
  final String name;
  final String price;
  final String category;
  final String destaque;

  const AnuncioItem({
    super.key,
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.category,
    required this.destaque,
  });

  void _onEdit(BuildContext context) {
    print('Editar: $id');
  }

  void _onDelete(BuildContext context) {
    print('Apagar: $id');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(price),
                Text(category),
                Text(destaque, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary)),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () => _onEdit(context),
                icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
              ),
              IconButton(
                onPressed: () => _onDelete(context),
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}