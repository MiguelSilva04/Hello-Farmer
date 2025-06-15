import 'package:flutter/material.dart';
import 'package:harvestly/core/models/search.dart';
import 'app_routes.dart';

List<SearchResultItem> getStaticSearchItems(BuildContext context) => [
  SearchResultItem(
    title: 'Definições',
    section: 'Geral',
    onTap: () => Navigator.of(context).pushNamed(AppRoutes.SETTINGS_PAGE),
  ),
  SearchResultItem(
    title: 'Perfil',
    section: 'Geral',
    onTap: () => Navigator.of(context).pushNamed(AppRoutes.PROFILE_PAGE),
  ),
  SearchResultItem(
    title: 'Notificações',
    section: 'Geral',
    onTap: () => Navigator.of(context).pushNamed(AppRoutes.NOTIFICATION_PAGE),
  ),
];