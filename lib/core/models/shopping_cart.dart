class ProductRegist {
  String productAdId;
  int quantity;
  ProductRegist({required this.productAdId, required this.quantity});
}

class ShoppingCart {
  List<ProductRegist>? productsQty;
  int? totalPrice;

  ShoppingCart({this.productsQty, this.totalPrice});
}
