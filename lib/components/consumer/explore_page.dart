import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          SearchBar(
            elevation: WidgetStateProperty.all(1),
            backgroundColor: WidgetStateProperty.all(
              Theme.of(context).colorScheme.surfaceContainerLow,
            ),
            leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
            ),
            hintStyle: WidgetStateProperty.all(
              TextStyle(
                color: Theme.of(context).colorScheme.inverseSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            textStyle: WidgetStateProperty.all(
              TextStyle(
                color: Theme.of(context).colorScheme.inverseSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            hintText: "Procurar produtos ou categorias",
          ),
        ],
      ),
    );
  }
}
