import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class BreadcrumbNavigation extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const BreadcrumbNavigation({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
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
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        child: AutoSizeText(
                          item.label,
                          maxLines: 1,
                          minFontSize: 14,
                          overflow: TextOverflow.ellipsis,
                          maxFontSize: isLast ? 22 : 20,
                          style: TextStyle(
                            decoration:
                                isLast ? TextDecoration.underline : null,
                            decorationColor:
                                Theme.of(context).colorScheme.secondary,
                            fontWeight:
                                isLast ? FontWeight.bold : FontWeight.normal,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
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
      ),
    );
  }
}

class BreadcrumbItem {
  final String label;
  final VoidCallback onTap;

  BreadcrumbItem({required this.label, required this.onTap});
}
