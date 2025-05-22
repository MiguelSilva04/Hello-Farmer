enum Unit { KG, UNIT }

extension UnitExtension on Unit {
  String toDisplayString() {
    switch (this) {
      case Unit.KG:
        return "Kg";
      case Unit.UNIT:
        return "Unidade(s)";
    }
  }
}

class Product {
  static int _idCounter = 0;
  final String id;
  final String name;
  final List<String> imageUrl;
  final String category;
  final double price;
  int stock = 0;
  int minAmount = 0;
  Unit unit;

  Product({
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.stock,
    required this.price,
    required this.minAmount,
    required this.unit,
  }) : id = (_idCounter++).toString();

  int get totalStock => this.stock;

  void addStock(int amount) {
    if (amount < 0) return;
    stock = stock + amount;
  }

  bool removeStock(int amount) {
    if (amount < 0 || stock < amount) return false;
    stock = stock - amount;
    return true;
  }

  void changeMinAmount(int minAmount) => this.minAmount = minAmount;
}

class ProductAd {
  static int _idCounter = 0;

  final String id;
  final Product product;
  String price;
  final String highlight;

  ProductAd({
    required this.product,
    String? price,
    required this.highlight,
  }) : price =
           price ??
           "${product.price.toStringAsFixed(2)}€/${product.unit.toDisplayString()}",
       id = (_idCounter++).toString();
}
