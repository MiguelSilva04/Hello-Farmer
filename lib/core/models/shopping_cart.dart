

class ShoppingCart {
  List<Map<String, int>>? productsQty;
  int totalPrice;

  ShoppingCart()
    : totalPrice = 0,
      productsQty = [
        {"idTrigo": 20},
        {"idCenteio": 15},
        {"idOvos": 6},
      ];
}
