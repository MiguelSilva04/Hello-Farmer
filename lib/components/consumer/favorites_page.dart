import 'package:flutter/material.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'product_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  // Lista de favoritos fictícia, futuramente substituir por favoritos reais (possivelmente um list de productads chamada favorites)
  List<Map<String, String>> favorites = [
    {
      'product': 'Batata',
      'seller': 'Banca Zé das Couve',
      'imagePath': 'assets/images/mock_images/batata.jpg',
    },
    {
      'product': 'Cenoura',
      'seller': 'Banca Joel Loures',
      'imagePath': 'assets/images/mock_images/cenoura.jpg',
    },
    {
      'product': 'Tomate',
      'seller': 'Banca António Silva',
      'imagePath': 'assets/images/mock_images/tomate.jpg',
    },
  ];

  final currentUser = AuthService().currentUser!;

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  void removeItem(int index) {
    final removedItem = favorites[index];

    _listKey.currentState?.removeItem(index, (context, animation) {
      return SizeTransition(
        sizeFactor: animation,
        axis: Axis.vertical,
        child: FadeTransition(
          opacity: animation,
          child: buildListItem(context, removedItem, index, animate: false),
        ),
      );
    }, duration: const Duration(milliseconds: 300));

    setState(() {
      favorites.removeAt(index);
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removedItem['product']} removido dos favoritos'),
      ),
    );
  }

  Widget buildListItem(
    BuildContext context,
    Map<String, String> item,
    int index, {
    bool animate = true,
  }) {
    return Column(
      key: ValueKey(item['product']),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ProductDetailPage(
                        product: item['product']!,
                        seller: item['seller']!,
                        imagePath: item['imagePath']!,
                      ),
                ),
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagem
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    item['imagePath']!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),

                // Título e vendedor
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['product']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['seller']!,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Botão favorito animado
                FavoriteButton(onPressed: () => removeItem(index)),
              ],
            ),
          ),
        ),

        if (index < favorites.length - 1)
          const Divider(height: 1, thickness: 0.5, color: Colors.grey),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos'), centerTitle: true),
      body: AnimatedList(
        key: _listKey,
        padding: const EdgeInsets.all(12),
        initialItemCount: favorites.length,
        itemBuilder: (context, index, animation) {
          return SizeTransition(
            sizeFactor: animation,
            child: buildListItem(context, favorites[index], index),
          );
        },
      ),
    );
  }
}

class FavoriteButton extends StatefulWidget {
  final VoidCallback onPressed;

  const FavoriteButton({super.key, required this.onPressed});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    await _controller.forward();
    _controller.reset();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        icon: const Icon(
          Icons.favorite,
          color: Color.fromRGBO(76, 153, 120, 1),
        ),
        onPressed: _handleTap,
      ),
    );
  }
}
