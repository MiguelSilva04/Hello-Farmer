import 'package:flutter/material.dart';

class CategoryIcon {
  final String name;
  final IconData icon;

  CategoryIcon(this.name, this.icon);
}

class Categories {
  static List<CategoryIcon> categories = [
    CategoryIcon("Frutas", Icons.apple),
    CategoryIcon("Hortícolas", Icons.spa),
    CategoryIcon("Folhosas", Icons.eco),
    CategoryIcon("Tubérculos", Icons.grass),
    CategoryIcon("Ervas Aromáticas", Icons.local_florist),
    CategoryIcon("Cogumelos", Icons.rice_bowl),
    CategoryIcon("Cereais", Icons.spa_outlined),
    CategoryIcon("Frutos Secos", Icons.nature),
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

