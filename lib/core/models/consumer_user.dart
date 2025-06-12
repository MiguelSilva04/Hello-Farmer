// import 'package:harvestly/core/models/product_ad.dart';
import 'package:harvestly/core/models/shopping_cart.dart';

import 'app_user.dart';
import 'offer.dart';

class ConsumerUser extends AppUser {
  List<Offer>? offers;
  ShoppingCart shoppingCart = ShoppingCart();
  List<String>? favouritesProductsIds;

  ConsumerUser({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.isProducer,
    required super.phone,
    required super.imageUrl,
    super.recoveryEmail,
    super.dateOfBirth,
    this.offers,
  });
  // }) : favouritesProductsIds = ["idCenteio", "idTrigo"],
  //      offers = [
  //        Offer(
  //          id: 'offer1',
  //          discountValue: DiscountValue.TEN,
  //          productAdId: "idCenteio",
  //          startDate: DateTime.now().subtract(Duration(days: 2)),
  //          endDate: DateTime.now().add(Duration(days: 5)),
  //        ),
  //        Offer(
  //          id: 'offer2',
  //          discountValue: DiscountValue.FIFTY,
  //          productAdId: "idTrigo",
  //          startDate: DateTime.now().subtract(Duration(days: 1)),
  //          endDate: DateTime.now().add(Duration(days: 10)),
  //        ),
  //        Offer(
  //          id: 'offer3',
  //          discountValue: DiscountValue.TWENTY_FIVE,
  //          productAdId: "idCenourasBaby",
  //          startDate: DateTime.now().subtract(Duration(days: 3)),
  //          endDate: DateTime.now().add(Duration(days: 7)),
  //        ),
  //        Offer(
  //          id: 'offer4',
  //          discountValue: DiscountValue.FIVE,
  //          productAdId: "idAlfaceRomana",
  //          startDate: DateTime.now().subtract(Duration(days: 4)),
  //          endDate: DateTime.now().add(Duration(days: 8)),
  //        ),
  //        Offer(
  //          id: 'offer5',
  //          discountValue: DiscountValue.NINETY,
  //          productAdId: "idOvos",
  //          startDate: DateTime.now().subtract(Duration(days: 5)),
  //          endDate: DateTime.now().add(Duration(days: 12)),
  //        ),
  //        Offer(
  //          id: 'offer6',
  //          discountValue: DiscountValue.TEN,
  //          productAdId: "idCenteio",
  //          startDate: DateTime.now().subtract(Duration(days: 6)),
  //          endDate: DateTime.now().add(Duration(days: 15)),
  //        ),
  //        Offer(
  //          id: 'offer7',
  //          discountValue: DiscountValue.TWENTY_FIVE,
  //          productAdId: "idTomateCherry",
  //          startDate: DateTime.now().subtract(Duration(days: 7)),
  //          endDate: DateTime.now().add(Duration(days: 9)),
  //        ),
  //        Offer(
  //          id: 'offer8',
  //          discountValue: DiscountValue.FIFTY,
  //          productAdId: "idOvos",
  //          startDate: DateTime.now().subtract(Duration(days: 8)),
  //          endDate: DateTime.now().add(Duration(days: 11)),
  //        ),
  //        Offer(
  //          id: 'offer9',
  //          discountValue: DiscountValue.FIVE,
  //          productAdId: "idAlfaceRomana",
  //          startDate: DateTime.now().subtract(Duration(days: 9)),
  //          endDate: DateTime.now().add(Duration(days: 13)),
  //        ),
  //        Offer(
  //          id: 'offer10',
  //          discountValue: DiscountValue.SEVENTY_FIVE,
  //          productAdId: "idTrigo",
  //          startDate: DateTime.now().subtract(Duration(days: 10)),
  //          endDate: DateTime.now().add(Duration(days: 14)),
  //        ),
  //      ];

  factory ConsumerUser.fromMap(Map<String, dynamic> map) {
    return ConsumerUser(
      id: map['id'] as String,
      email: map['email'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      isProducer: map['isProducer'] as bool,
      phone: map['phone'] as String,
      imageUrl: map['imageUrl'] as String,
      recoveryEmail: map['recoveryEmail'] as String?,
      dateOfBirth: map['dateOfBirth'] as String?,
    );
  }

  factory ConsumerUser.fromJson(Map<String, dynamic> json) {
    return ConsumerUser.fromMap(json);
  }
}
