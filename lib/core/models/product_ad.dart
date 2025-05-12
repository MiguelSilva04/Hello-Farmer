class ProductAd {
  static int _idCounter = 0;

  final String id;
  final String imageUrl;
  final String name;
  final String price;
  final String category;
  final String highlight;

  ProductAd({
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.category,
    required this.highlight,
  }) : id = (_idCounter++).toString();
}
