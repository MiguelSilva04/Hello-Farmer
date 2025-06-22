import 'package:flutter/material.dart';
import 'package:harvestly/core/models/search.dart';
import 'package:harvestly/utils/static_search_items.dart';
import 'package:harvestly/utils/dynamic_search_items.dart';

class SearchNotifier extends ChangeNotifier {
  List<SearchResultItem> _results = [];
  List<SearchResultItem> get results => _results;

  void search(String query, bool isProducer, BuildContext context) {
    if (query.trim().isEmpty) {
      _results = [];
      notifyListeners();
      return;
    }

    final staticSearchItems = getStaticSearchItems(context);
    final dynamicSearchItems = getDynamicSearchItems(context);

    final allItems = [...staticSearchItems, ...dynamicSearchItems];
    final queryNormalized = normalize(query);

    final filteredItems =
        allItems.where((item) {
          final titleNormalized = normalize(item.title);

          final matches = titleNormalized.contains(queryNormalized);

          final validForUser =
              !(item.isProducerOnly && !isProducer) &&
              !(item.isConsumerOnly && isProducer);

          return matches && validForUser;
        }).toList();

    _results = filteredItems;
    notifyListeners();
  }

  String normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]+'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void clear() {
    _results = [];
    notifyListeners();
  }
}
