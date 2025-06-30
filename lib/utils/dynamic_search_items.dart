import 'package:flutter/material.dart';
import 'package:harvestly/components/consumer/offers_page.dart';
import 'package:harvestly/components/consumer/shopping_cart_page.dart';
import 'package:harvestly/components/producer/store_page.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/services/other/manage_section_notifier.dart';
import 'package:harvestly/pages/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:harvestly/core/services/auth/auth_notifier.dart';
import 'package:harvestly/core/models/search.dart';
import 'package:harvestly/core/services/other/bottom_navigation_notifier.dart';
import 'package:harvestly/utils/app_routes.dart';

import '../core/services/other/settings_notifier.dart';

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
        title: 'Pagina principal',
        section: 'Gestão',
        onTap: () => navNotifier.setIndex(0),
      ),
      SearchResultItem(
        title: 'Ver Vendas',
        section: 'Gestão',
        onTap: () => navNotifier.setIndex(1),
      ),
      SearchResultItem(
        title: 'Publicar Anuncio',
        section: 'Gestão',
        onTap: () => navNotifier.setIndex(2),
      ),
      SearchResultItem(
        title: 'Mensagens',
        section: 'Gestão',
        onTap: () => navNotifier.setIndex(3),
      ),
      SearchResultItem(
        title: 'Mudar email',
        section: 'Gestão',
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.SETTINGS_PAGE);
          Provider.of<SettingsNotifier>(context, listen: false).setIndex(5);
        },
      ),
      SearchResultItem(
        title: 'Mudar password',
        section: 'Gestão',
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.SETTINGS_PAGE);
          Provider.of<SettingsNotifier>(context, listen: false).setIndex(5);
        },
      ),
      SearchResultItem(
        title: 'Terminar Sessão',
        section: 'Gestão',
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.SETTINGS_PAGE);
          Provider.of<SettingsNotifier>(context, listen: false).setIndex(5);
        },
      ),
      SearchResultItem(
        title: 'Dados de pagamento',
        section: 'Gestão',
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.SETTINGS_PAGE);
          Provider.of<SettingsNotifier>(context, listen: false).setIndex(2);
        },
      ),
      SearchResultItem(
        title: 'Editar Banca',
        section: 'Gestão',
        onTap: () {
          navNotifier.setIndex(4);
          Provider.of<ManageSectionNotifier>(
            context,
            listen: false,
          ).setIndex(1);
        },
      ),
      SearchResultItem(
        title: 'Faturação',
        section: 'Gestão',
        onTap: () {
          navNotifier.setIndex(4);
          Provider.of<ManageSectionNotifier>(
            context,
            listen: false,
          ).setIndex(2);
        },
      ),
      SearchResultItem(
        title: 'Ver Encomendas Abandonadas',
        section: 'Gestão',
        onTap: () {
          navNotifier.setIndex(4);
          Provider.of<ManageSectionNotifier>(
            context,
            listen: false,
          ).setIndex(3);
        },
      ),
      SearchResultItem(
        title: 'Gerir Stock',
        section: 'Gestão',
        onTap: () {
          navNotifier.setIndex(4);
          Provider.of<ManageSectionNotifier>(
            context,
            listen: false,
          ).setIndex(4);
        },
      ),
      SearchResultItem(
        title: 'Gerir Preços',
        section: 'Gestão',
        onTap: () {
          navNotifier.setIndex(4);
          Provider.of<ManageSectionNotifier>(
            context,
            listen: false,
          ).setIndex(5);
        },
      ),
      SearchResultItem(
        title: 'Gerir Cabazes',
        section: 'Gestão',
        onTap: () {
          navNotifier.setIndex(4);
          Provider.of<ManageSectionNotifier>(
            context,
            listen: false,
          ).setIndex(6);
        },
      ),
      SearchResultItem(
        title: 'Consultar Clientes',
        section: 'Gestão',
        onTap: () {
          navNotifier.setIndex(4);
          Provider.of<ManageSectionNotifier>(
            context,
            listen: false,
          ).setIndex(7);
        },
      ),
      SearchResultItem(
        title: 'Relatórios de Vendas',
        section: 'Gestão',
        onTap: () {
          navNotifier.setIndex(4);
          Provider.of<ManageSectionNotifier>(
            context,
            listen: false,
          ).setIndex(8);
        },
      ),
      SearchResultItem(
        title: 'Vendas por Canal',
        section: 'Gestão',
        onTap: () {
          navNotifier.setIndex(4);
          Provider.of<ManageSectionNotifier>(
            context,
            listen: false,
          ).setIndex(9);
        },
      ),
      SearchResultItem(
        title: 'Principais Produtos',
        section: 'Gestão',
        onTap: () {
          navNotifier.setIndex(4);
          Provider.of<ManageSectionNotifier>(
            context,
            listen: false,
          ).setIndex(10);
        },
      ),
      SearchResultItem(
        title: 'Consultas visitas à banca',
        section: 'Gestão',
        onTap: () {
          navNotifier.setIndex(4);
          Provider.of<ManageSectionNotifier>(
            context,
            listen: false,
          ).setIndex(11);
        },
      ),
      SearchResultItem(
        title: 'Finanças',
        section: 'Gestão',
        onTap: () {
          navNotifier.setIndex(4);
          Provider.of<ManageSectionNotifier>(
            context,
            listen: false,
          ).setIndex(12);
        },
      ),
      SearchResultItem(
        title: 'Gerir Canais de Venda',
        section: 'Gestão',
        onTap: () {
          navNotifier.setIndex(4);
          Provider.of<ManageSectionNotifier>(
            context,
            listen: false,
          ).setIndex(13);
        },
      ),
      SearchResultItem(
        title: 'Ver Banca atual',
        section: 'Geral',
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.STORE_PAGE),
      ),
    ]);

    for (var otherUser in authNotifier.allUsers) {
      if (!otherUser.isProducer) {
        items.add(
          SearchResultItem(
            title: '${otherUser.firstName} ${otherUser.lastName}',
            section: 'Clientes',
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => ProfilePage(otherUser)),
                ),
          ),
        );
      }
    }
  } else {
    items.addAll([
      SearchResultItem(
        title: 'Pagina principal',
        section: 'Gestão',
        onTap: () => navNotifier.setIndex(0),
      ),
      SearchResultItem(
        title: 'Mensagens',
        section: 'Geral',
        onTap: () => navNotifier.setIndex(3),
      ),
      SearchResultItem(
        title: 'Mudar email',
        section: 'Gestão',
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.SETTINGS_PAGE);
          Provider.of<SettingsNotifier>(context, listen: false).setIndex(5);
        },
      ),
      SearchResultItem(
        title: 'Mudar password',
        section: 'Gestão',
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.SETTINGS_PAGE);
          Provider.of<SettingsNotifier>(context, listen: false).setIndex(5);
        },
      ),
      SearchResultItem(
        title: 'Terminar Sessão',
        section: 'Gestão',
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.SETTINGS_PAGE);
          Provider.of<SettingsNotifier>(context, listen: false).setIndex(5);
        },
      ),
      SearchResultItem(
        title: 'Dados de pagamento',
        section: 'Gestão',
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.SETTINGS_PAGE);
          Provider.of<SettingsNotifier>(context, listen: false).setIndex(2);
        },
      ),
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
      SearchResultItem(
        title: 'Carrinho',
        section: 'Geral',
        onTap:
            () => Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => const ShoppingCartPage()),
            ),
      ),
      SearchResultItem(
        title: 'Ofertas',
        section: 'Geral',
        onTap:
            () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (ctx) => const OffersPage())),
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
