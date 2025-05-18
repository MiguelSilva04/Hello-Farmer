import 'package:flutter/material.dart';

class BreadcrumbNavigation extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const BreadcrumbNavigation({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(8),
      child: Row(
        children:
            items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: isLast ? null : item.onTap,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: isLast ? 16.5 : 14.5,
                          fontWeight:
                              isLast ? FontWeight.bold : FontWeight.normal,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  if (!isLast)
                    Text(
                      ' > ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                ],
              );
            }).toList(),
      ),
    );
  }
}

class BreadcrumbItem {
  final String label;
  final VoidCallback onTap;

  BreadcrumbItem({required this.label, required this.onTap});
}
