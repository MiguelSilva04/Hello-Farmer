enum DiscountValue { TEN, TWENTY_FIVE, FIFTY, SEVENTY_FIVE }

extension DiscountValueExtension on DiscountValue {
  String toDisplayString() {
    switch (this) {
      case DiscountValue.TEN:
      return "10%";
      case DiscountValue.TWENTY_FIVE:
      return "25%";
      case DiscountValue.FIFTY:
      return "50%";
      case DiscountValue.SEVENTY_FIVE:
      return "75%";
    }
  }
}

class Offer {
  String id;
  DiscountValue discountValue;
  int productAdId;
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
