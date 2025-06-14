class ProductRegist {
  String productAdId;
  double quantity;
  ProductRegist({required this.productAdId, required this.quantity});
}

class ShoppingCart {
  List<ProductRegist>? productsQty;
  double? totalPrice;

  ShoppingCart({this.productsQty, this.totalPrice});
}
