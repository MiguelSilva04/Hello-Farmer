import 'package:flutter/material.dart';
import 'package:harvestly/core/models/search.dart';

class GlobalSearchResults extends StatelessWidget {
  final List<SearchResultItem> filteredItems;
  final String query;

  const GlobalSearchResults({
    super.key,
    required this.filteredItems,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Digite algo para pesquisar.',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (filteredItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Sem resultados.',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final sections = filteredItems.map((e) => e.section).toSet().toList();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sections.length,
      separatorBuilder: (_, __) => const Divider(height: 32),
      itemBuilder: (context, sectionIndex) {
        final section = sections[sectionIndex];
        final itemsInSection =
            filteredItems.where((item) => item.section == section).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8,
              ),
              child: Text(
                section,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ...itemsInSection.map(
              (item) => ListTile(
                title: Text(item.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: item.onTap,
              ),
            ),
          ],
        );
      },
    );
  }
}
