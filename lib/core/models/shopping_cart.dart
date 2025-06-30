class ProductRegist {
  String productAdId;
  double quantity;
  int? promotion = 0;
  ProductRegist({required this.productAdId, required this.quantity, this.promotion});
}

class ShoppingCart {
  List<ProductRegist>? productsQty;
  double? totalPrice;

  ShoppingCart({this.productsQty, this.totalPrice});
}
