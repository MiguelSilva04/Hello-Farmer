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

  int toValue() {
    switch (this) {
      case DiscountValue.FIVE:
        return 5;
      case DiscountValue.TEN:
        return 10;
      case DiscountValue.TWENTY_FIVE:
        return 25;
      case DiscountValue.FIFTY:
        return 50;
      case DiscountValue.SEVENTY_FIVE:
        return 75;
      case DiscountValue.NINETY:
        return 90;
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

  static DiscountValue fromString(String value) {
    switch (value) {
      case "5%":
        return DiscountValue.FIVE;
      case "10%":
        return DiscountValue.TEN;
      case "25%":
        return DiscountValue.TWENTY_FIVE;
      case "50%":
        return DiscountValue.FIFTY;
      case "75%":
        return DiscountValue.SEVENTY_FIVE;
      case "90%":
        return DiscountValue.NINETY;
      default:
        throw ArgumentError('Unknown discount value: $value');
    }
  }

  String toJson() {
    return toDisplayString();
  }
}

class Offer {
  String id;
  DiscountValue discountValue;
  String productAdId;
  DateTime startDate;
  DateTime endDate;
  String discountCode;

  Offer({
    required this.id,
    required this.discountValue,
    required this.productAdId,
    required this.startDate,
    required this.endDate,
    required this.discountCode,
  });

  int get value {
    switch (discountValue) {
      case DiscountValue.FIVE:
        return 5;
      case DiscountValue.TEN:
        return 10;
      case DiscountValue.TWENTY_FIVE:
        return 25;
      case DiscountValue.FIFTY:
        return 50;
      case DiscountValue.SEVENTY_FIVE:
        return 75;
      case DiscountValue.NINETY:
        return 90;
    }
  }

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] as String,
      discountValue: DiscountValueExtension.fromString(json['discountValue'] as String),
      productAdId: json['productAdId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      discountCode: json['discountCode'] as String,
    );
  }
}
