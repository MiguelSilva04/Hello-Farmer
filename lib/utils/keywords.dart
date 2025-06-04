import 'package:flutter/material.dart';

class KeywordIcon {
  final String name;
  final IconData icon;

  KeywordIcon(this.name, this.icon);
}

class Keywords {
  static List<KeywordIcon> keywords = [
    KeywordIcon("Biológico", Icons.eco),
    KeywordIcon("Artesanal", Icons.handyman),
    KeywordIcon("Sem Glúten", Icons.no_food),
    KeywordIcon("Sem Lactose", Icons.local_cafe),
    KeywordIcon("Vegan", Icons.spa),
    KeywordIcon("Vegetariano", Icons.grass),
    KeywordIcon("Fair Trade", Icons.volunteer_activism),
    KeywordIcon("Natural", Icons.nature),
  ];
}
