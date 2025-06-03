import 'package:flutter/material.dart';

class CategoryIcon {
  final String name;
  final IconData icon;

  CategoryIcon(this.name, this.icon);
}

class Categories {
  static List<CategoryIcon> categories = [
    CategoryIcon("Frutas", Icons.apple),
    CategoryIcon("Legumes e Hortícolas", Icons.spa),
    CategoryIcon("Verduras e Folhosas", Icons.eco),
    CategoryIcon("Tubérculos e Raízes", Icons.grass),
    CategoryIcon("Ervas Aromáticas", Icons.local_florist),
    CategoryIcon("Cogumelos", Icons.rice_bowl),
    CategoryIcon("Grãos e Cereais", Icons.spa_outlined),
    CategoryIcon("Frutos Secos e Sementes", Icons.nature),
    CategoryIcon("Ovos", Icons.egg),
    CategoryIcon("Laticínios e Queijos", Icons.icecream),
    CategoryIcon("Carnes e Aves", Icons.set_meal),
    CategoryIcon("Peixe e Marisco", Icons.lunch_dining),
    CategoryIcon("Mel e Produtos Apícolas", Icons.bug_report),
    CategoryIcon("Pão e Pastelaria", Icons.bakery_dining),
    CategoryIcon("Conservas e Compotas", Icons.kitchen),
    CategoryIcon("Bebidas Artesanais", Icons.local_drink),
    CategoryIcon("Plantas e Mudas", Icons.park),
    CategoryIcon("Flores", Icons.local_florist),
  ];
}

