class Purchase {
  final String productName;
  final double quantity;
  final String unit;
  final double price;
  final String productImage;
  final String producerId;

  Purchase({
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.productImage,
    required this.producerId,
  });

  factory Purchase.fromMap(Map<String, dynamic> map) {
    return Purchase(
      productName: map['productName'] as String,
      quantity: double.tryParse(map['quantity'].toString()) ?? 0.0,
      unit: map['unit'] as String,
      price: double.tryParse(
              map['price'].toString().replaceAll("€", "").trim()) ??
          0.0,
      productImage: map['productImage'] as String,
      producerId: map['producerId'] as String,
    );
  }
}
