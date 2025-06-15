import 'package:flutter/material.dart';
import 'package:harvestly/components/producer/store_page.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/pages/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:harvestly/core/services/auth/auth_notifier.dart';
import 'package:harvestly/core/models/search.dart';
import 'package:harvestly/core/services/other/bottom_navigation_notifier.dart';
import 'package:harvestly/utils/app_routes.dart';

List<SearchResultItem> getDynamicSearchItems(BuildContext context) {
  final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
  final user = authNotifier.currentUser;
  final navNotifier = Provider.of<BottomNavigationNotifier>(
    context,
    listen: false,
  );

  if (user == null) return [];
  final List<SearchResultItem> items = [];

  if (user.isProducer) {
    items.addAll([
      SearchResultItem(
        title: 'Gestão de Banca',
        section: 'Gestão',
        onTap: () => navNotifier.setIndex(4),
      ),
      SearchResultItem(
        title: 'Vendas',
        section: 'Gestão',
        onTap: () => navNotifier.setIndex(1),
      ),
    ]);

    for (var otherUser in authNotifier.allUsers) {
      if (!otherUser.isProducer) {
        items.add(
          SearchResultItem(
            title: '${otherUser.firstName} ${otherUser.lastName}',
            section: 'Clientes',
            onTap:
                () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.PROFILE_PAGE, arguments: otherUser),
          ),
        );
      }
    }
  } else {
    items.addAll([
      SearchResultItem(
        title: 'Explorar Produtos',
        section: 'Explorar',
        onTap: () => navNotifier.setIndex(2),
      ),
      SearchResultItem(
        title: 'Favoritos',
        section: 'Explorar',
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.FAVORITES_PAGE),
      ),
      SearchResultItem(
        title: 'Mapa',
        section: 'Explorar',
        onTap: () => navNotifier.setIndex(4),
      ),
      SearchResultItem(
        title: 'Encomendas',
        section: 'Geral',
        onTap: () => navNotifier.setIndex(1),
      ),
    ]);

    for (var otherUser in authNotifier.allUsers) {
      if (otherUser.isProducer) {
        items.add(
          SearchResultItem(
            title: otherUser.firstName + ' ' + otherUser.lastName,
            section: 'Produtores',
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => ProfilePage(otherUser as ProducerUser),
                  ),
                ),
          ),
        );

        if (otherUser is ProducerUser) {
          for (var store in otherUser.stores) {
            items.add(
              SearchResultItem(
                title: store.name!,
                section: 'Bancas',
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => StorePage(store: store),
                      ),
                    ),
              ),
            );
          }
        }
      }
    }
  }

  final uniqueItems = <String, SearchResultItem>{};
  for (var item in items) {
    uniqueItems[item.title.toLowerCase()] = item;
  }
  return uniqueItems.values.toList();
}
