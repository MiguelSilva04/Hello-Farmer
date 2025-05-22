import 'package:harvestly/core/models/store.dart';

import 'order.dart';
import 'product_ad.dart';
import 'store_review.dart';

class ClientUser {
  final String id;
  String firstName;
  String lastName;
  String email;
  String gender;
  String phone;
  String recoveryEmail;
  String dateOfBirth;
  String imageUrl;
  String? backgroundUrl;
  String? nickname;
  String? aboutMe;
  String? status;
  String? iconStatus;
  String? customStatus;
  String? customIconStatus;
  List<String>? friendsIds;
  bool? isProducer;
  Store? store;

  ClientUser({
    required this.gender,
    required this.phone,
    required this.recoveryEmail,
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.imageUrl,
    required this.dateOfBirth,
    required this.isProducer,
    this.backgroundUrl,
    this.nickname,
    this.aboutMe,
    this.status,
    this.iconStatus,
    this.customStatus,
    this.customIconStatus,
    this.friendsIds,
  }) : store = Store(
         createdAt: DateTime(2025, 1, 1),
         name: "Quinta Sol Nascente",
         subName: "Produzimos com foco na sustentabilidade",
         description:
             "Bem-vindo à Quinta Sol Nascente 🙂 | Produzimos com foco na sustentabilidade e bem-estar | Agricultura regenerativa | Do campo diretamente para a sua mesa, com amor e responsabilidade 🌱",
         location: "Almeirim",
         address: "-8.6235, 39.2081",
         preferredMarkets: [
           "Mercado Biológico de Lisboa",
           "Feira Rural de Torres Vedras",
           "Mercado Eco de Santarém",
         ],
         imageUrl: 'assets/images/mock_images/trigo.jpg',
         backgroundImageUrl: 'assets/images/mock_images/quinta.jpg',
         productsAds: [
           ProductAd(
             product: Product(
               name: 'Centeio',
               imageUrl: ['assets/images/mock_images/centeio.jpg'],
               category: 'Cereais',
               stock: 10,
               minAmount: 5,
               unit: Unit.KG,
               price: 13.5,
             ),
             highlight: 'Este anuncio está destacado há mais de 3 dias!',
           ),
           ProductAd(
             product: Product(
               name: 'Trigo',
               imageUrl: ['assets/images/mock_images/trigo.jpg'],
               category: 'Cereais',
               stock: 20,
               minAmount: 10,
               unit: Unit.KG,
               price: 12.5,
             ),
             highlight: 'Este anúncio não está em destaque!',
           ),
           ProductAd(
             product: Product(
               name: 'Alface Romana',
               imageUrl: ['assets/images/mock_images/alface_romana.jpg'],
               category: 'Vegetais',
               stock: 30,
               minAmount: 1,
               unit: Unit.UNIT,
               price: 1.2,
             ),
             highlight: 'Este anuncio está destacado há mais de 5 dias!',
           ),
           ProductAd(
             product: Product(
               name: 'Cenouras Baby',
               imageUrl: ['assets/images/mock_images/baby_carrots.jpg'],
               category: 'Vegetais',
               stock: 25,
               minAmount: 5,
               unit: Unit.KG,
               price: 2.8,
             ),
             highlight: 'Este anuncio está destacado há 8 horas!',
           ),
           ProductAd(
             product: Product(
               name: 'Tomate Cherry',
               imageUrl: ['assets/images/mock_images/cherry_tomatoes.jpg'],
               category: 'Vegetais',
               stock: 15,
               minAmount: 25,
               unit: Unit.KG,
               price: 3.5,
             ),
             highlight: 'Este anúncio não está em destaque!',
           ),
           ProductAd(
             product: Product(
               name: 'Ovos',
               imageUrl: ['assets/images/mock_images/eggs.jpg'],
               category: 'Ovos',
               stock: 50,
               minAmount: 6,
               unit: Unit.UNIT,
               price: 2.0,
             ),
             highlight: 'Este anuncio está destacado há 23 horas!',
           ),
         ],
         storeReviews: [
           StoreReview(
             rating: 4.3,
             description:
                 "Entrega em mãos impecável, correu tudo bem e rápido!",
             dateTime: DateTime(2025, 4, 1, 11, 45),
             reviewerId: "vjjzySrSiIYy1c3QcduZhlKglNh2",
           ),
           StoreReview(
             rating: 4.5,
             description: "Chegou tudo em condições e com ótima qualidade!",
             dateTime: DateTime(2025, 5, 6, 09, 05),
             reviewerId: "YScblT6Hx2RswFie1JKZX5hgn5F2",
           ),
           StoreReview(
             rating: 3.6,
             description:
                 "Em excelente condição podia ter sido é um pouco mais rápido...",
             dateTime: DateTime(2025, 2, 26, 19, 13),
             reviewerId: "pxgE59JoVgaDHsxbOijA9VKMfKL2",
           ),
           StoreReview(
             rating: 4.1,
             description:
                 "Entrega no ponto de encontro e produto tudo impecável.",
             dateTime: DateTime(2025, 5, 12, 12, 00),
             reviewerId: "BABXdZ7vwKVFtpIjQQeri4mC71v2",
           ),
           StoreReview(
             rating: 4.9,
             description: "Adorei as cenouras que comprei, é para repetir!!",
             dateTime: DateTime(2025, 5, 12, 12, 08, 01),
             reviewerId: "IyxNeUyr6QNA3lwSALZBHsV75ap2",
           ),
           StoreReview(
             rating: 4.8,
             description: "Comprei beterrabas e eram incriveis, adorei!",
             dateTime: DateTime(2025, 5, 8, 08, 10),
             reviewerId: "pxgE59JoVgaDHsxbOijA9VKMfKL2",
           ),
         ],
         orders: [
           Order(
             id: '1001',
             pickupDate: DateTime(2025, 5, 18),
             deliveryDate: DateTime(2025, 5, 19),
             address: 'Rua do Pedido #1001',
             state: OrderState.Entregue,
             products: [
               Product(
                 name: 'Trigo',
                 imageUrl: ['assets/images/mock_images/trigo.jpg'],
                 category: 'Cereais',
                 minAmount: 10,
                 unit: Unit.KG,
                 price: 12.5,
               ),
             ],
             totalPrice: 20.34,
             consumerId: "BABXdZ7vwKVFtpIjQQeri4mC71v2",
             producerId: "IyxNeUyr6QNA3lwSALZBHsV75ap2",
           ),
           Order(
             id: '0078',
             pickupDate: DateTime(2025, 4, 15),
             deliveryDate: DateTime(2025, 5, 19),
             address: 'Rua do Pedido #0078',
             state: OrderState.Pendente,
             products: [
               Product(
                 name: 'Alface Romana',
                 imageUrl: ['assets/images/mock_images/alface_romana.jpg'],
                 category: 'Vegetais',
                 minAmount: 1,
                 unit: Unit.UNIT,
                 price: 1.2,
               ),
             ],
             totalPrice: 25.12,
             consumerId: "YScblT6Hx2RswFie1JKZX5hgn5F2",
             producerId: "aO7wPBBHgTY1fc9QCqXtrR5Fc8I2",
           ),
           Order(
             id: '0832',
             pickupDate: DateTime(2025, 4, 15),
             deliveryDate: null,
             address: 'Rua do Pedido #0832',
             state: OrderState.Abandonada,
             products: [
               Product(
                 name: 'Tomate Cherry',
                 imageUrl: ['assets/images/mock_images/cherry_tomatoes.jpg'],
                 category: 'Vegetais',
                 minAmount: 25,
                 unit: Unit.KG,
                 price: 3.5,
               ),
             ],
             totalPrice: 30.59,
             consumerId: "cEK6hsmFrZO8N3G7AqltGVZtMYs2",
             producerId: "MkqAbSP1zbQZqTbFlyiUawKNslo1",
           ),
           Order(
             id: '3627',
             pickupDate: DateTime(2025, 4, 29),
             deliveryDate: DateTime(2025, 5, 4),
             address: 'Rua do Pedido #3627',
             state: OrderState.Pendente,
             products: [
               Product(
                 name: 'Cenouras Baby',
                 imageUrl: ['assets/images/mock_images/baby_carrots.jpg'],
                 category: 'Vegetais',
                 minAmount: 5,
                 unit: Unit.KG,
                 price: 2.8,
               ),
             ],
             totalPrice: 17.36,
             consumerId: "BABXdZ7vwKVFtpIjQQeri4mC71v2",
             producerId: "aO7wPBBHgTY1fc9QCqXtrR5Fc8I2",
           ),
           Order(
             id: '1938',
             pickupDate: DateTime(2025, 4, 1),
             deliveryDate: DateTime(2025, 4, 2),
             address: 'Rua do Pedido #1938',
             state: OrderState.Entregue,
             products: [
               Product(
                 name: 'Alface Romana',
                 imageUrl: ['assets/images/mock_images/alface_romana.jpg'],
                 category: 'Vegetais',
                 minAmount: 1,
                 unit: Unit.UNIT,
                 price: 1.2,
               ),
             ],
             totalPrice: 13.84,
             consumerId: "YScblT6Hx2RswFie1JKZX5hgn5F2",
             producerId: "vjjzySrSiIYy1c3QcduZhlKglNh2",
           ),
           Order(
             id: '8809',
             pickupDate: DateTime(2025, 4, 1),
             deliveryDate: DateTime(2025, 4, 2),
             address: 'Rua do Pedido #8809',
             state: OrderState.Entregue,
             products: [
               Product(
                 name: 'Cenouras Baby',
                 imageUrl: ['assets/images/mock_images/baby_carrots.jpg'],
                 category: 'Vegetais',
                 minAmount: 5,
                 unit: Unit.KG,
                 price: 2.8,
               ),
             ],
             totalPrice: 69.11,
             consumerId: "BABXdZ7vwKVFtpIjQQeri4mC71v2",
             producerId: "10oLrK8p1YPcGVYLHLEpPfiXJeF2",
           ),
           Order(
             id: '1377',
             pickupDate: DateTime(2025, 5, 9),
             deliveryDate: null,
             address: 'Rua do Pedido #8809',
             state: OrderState.Abandonada,
             products: [
               Product(
                 name: 'Centeio',
                 imageUrl: ['assets/images/mock_images/centeio.jpg'],
                 category: 'Cereais',
                 minAmount: 5,
                 unit: Unit.KG,
                 price: 13.5,
               ),
               Product(
                 name: 'Trigo',
                 imageUrl: ['assets/images/mock_images/trigo.jpg'],
                 category: 'Cereais',
                 minAmount: 10,
                 unit: Unit.KG,
                 price: 12.5,
               ),
               Product(
                 name: 'Cenouras Baby',
                 imageUrl: ['assets/images/mock_images/baby_carrots.jpg'],
                 category: 'Vegetais',
                 minAmount: 5,
                 unit: Unit.KG,
                 price: 2.8,
               ),
               Product(
                 name: 'Tomate Cherry',
                 imageUrl: ['assets/images/mock_images/cherry_tomatoes.jpg'],
                 category: 'Vegetais',
                 minAmount: 25,
                 unit: Unit.KG,
                 price: 3.5,
               ),
               Product(
                 name: 'Alface Romana',
                 imageUrl: ['assets/images/mock_images/alface_romana.jpg'],
                 category: 'Vegetais',
                 minAmount: 1,
                 unit: Unit.UNIT,
                 price: 1.2,
               ),
             ],
             totalPrice: 69.11,
             consumerId: "pxgE59JoVgaDHsxbOijA9VKMfKL2",
             producerId: "MkqAbSP1zbQZqTbFlyiUawKNslo1",
           ),
         ],
         preferredDeliveryMethod: [
           DeliveryMethod.HOME_DELIVERY,
           DeliveryMethod.COURIER,
         ],
       );

  factory ClientUser.fromMap(Map<String, dynamic> map) {
    return ClientUser(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      gender: map['gender'] ?? '',
      phone: map['phone'] ?? '',
      recoveryEmail: map['recoverEmail'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isProducer: map['isProducer'] ?? '',
    );
  }
}
