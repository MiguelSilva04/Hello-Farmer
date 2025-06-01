enum DiscountValue { FIVE, TEN, TWENTY_FIVE, FIFTY, SEVENTY_FIVE, NINETY }

extension DiscountValueExtension on DiscountValue {
  String toDisplayString() {
    switch (this) {
      case DiscountValue.FIVE:
        return "5%";
      case DiscountValue.TEN:
        return "10%";
      case DiscountValue.TWENTY_FIVE:
        return "25%";
      case DiscountValue.FIFTY:
        return "50%";
      case DiscountValue.SEVENTY_FIVE:
        return "75%";
      case DiscountValue.NINETY:
        return "90%";
    }
  }

  String get imagePath {
    switch (this) {
      case DiscountValue.FIVE:
        return "assets/images/discounts_images/5%PT.png";
      case DiscountValue.TEN:
        return "assets/images/discounts_images/10%PT.png";
      case DiscountValue.TWENTY_FIVE:
        return "assets/images/discounts_images/25%PT.png";
      case DiscountValue.FIFTY:
        return "assets/images/discounts_images/50%PT.png";
      case DiscountValue.SEVENTY_FIVE:
        return "assets/images/discounts_images/75%PT.png";
      case DiscountValue.NINETY:
        return "assets/images/discounts_images/90%PT.png";
    }
  }
}

class Offer {
  String id;
  DiscountValue discountValue;
  String productAdId;
  DateTime startDate;
  DateTime endDate;

  Offer({
    required this.id,
    required this.discountValue,
    required this.productAdId,
    required this.startDate,
    required this.endDate,
  });
}
