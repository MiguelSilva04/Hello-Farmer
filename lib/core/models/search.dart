import 'package:flutter/material.dart';

class SearchResultItem {
  final String title;
  final String section;
  final VoidCallback onTap;
  final bool isProducerOnly;
  final bool isConsumerOnly;

  SearchResultItem({
    required this.title,
    required this.section,
    required this.onTap,
    this.isProducerOnly = false,
    this.isConsumerOnly = false,
  });
}