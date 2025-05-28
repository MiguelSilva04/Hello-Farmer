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
  String category;
  double? price;
  int? stock = 0;
  int? minAmount = 0;
  Unit unit;
  double? amount;

  Product({
    required this.name,
    required this.imageUrl,
    required this.category,
    this.stock,
    this.amount,
    required this.price,
    this.minAmount,
    required this.unit,
  }) : id = (_idCounter++).toString();

  int get totalStock => this.stock!;

  void addStock(int amount) {
    if (amount < 0) return;
    stock = stock! + amount;
  }

  bool removeStock(int amount) {
    if (amount < 0 || stock! < amount) return false;
    stock = stock! - amount;
    return true;
  }

  void changeMinAmount(int minAmount) => this.minAmount = minAmount;

  static Product fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] ?? '',
      imageUrl:
          json['imageUrl'] != null ? List<String>.from(json['imageUrl']) : [],
      category: json['category'] ?? '',
      minAmount: (json['minAmount'] ?? 0).toDouble(),
      unit:
          json['unit'] != null
              ? Unit.values.firstWhere(
                (u) => u.toString() == 'Unit.${json['unit']}',
                orElse: () => Unit.KG,
              )
              : Unit.KG,
      price: (json['price'] ?? 0).toDouble(),
      // Adicione outros campos conforme necessário
    );
  }
}
