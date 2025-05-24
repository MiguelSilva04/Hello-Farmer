import 'package:harvestly/core/models/store.dart';

import 'basket.dart';
import 'order.dart';
import 'product.dart';
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
             preferredDeliveryMethods: [
               DeliveryMethod.COURIER,
               DeliveryMethod.HOME_DELIVERY,
             ],
             description:
                 "Centeio fresco, cultivado de forma sustentável, ideal para pães, farinhas e receitas saudáveis. Rico em fibras e nutrientes, direto do produtor para a sua mesa.",
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
             preferredDeliveryMethods: [DeliveryMethod.COURIER],
             description:
                 "Trigo de alta qualidade, cultivado de forma sustentável, ideal para panificação, massas e receitas saudáveis. Rico em nutrientes e sabor, direto do produtor para a sua mesa.",
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
             preferredDeliveryMethods: [DeliveryMethod.PICKUP],
             description:
                 "Alface Romana fresca, crocante e cheia de sabor, perfeita para saladas e sanduíches. Cultivada com práticas sustentáveis para garantir qualidade e frescura até à sua mesa.",
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
             preferredDeliveryMethods: [DeliveryMethod.HOME_DELIVERY],
             description:
                 "Cenouras baby frescas, crocantes e doces, ideais para snacks saudáveis, saladas e receitas variadas. Cultivadas com práticas sustentáveis para garantir qualidade e sabor direto do produtor.",
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
             preferredDeliveryMethods: [
               DeliveryMethod.COURIER,
               DeliveryMethod.HOME_DELIVERY,
               DeliveryMethod.PICKUP,
             ],
             description:
                 "Tomate Cherry fresco, doce e suculento, perfeito para saladas, snacks e pratos gourmet. Cultivado com práticas sustentáveis para garantir sabor e qualidade excepcionais.",
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
             preferredDeliveryMethods: [
               DeliveryMethod.COURIER,
               DeliveryMethod.HOME_DELIVERY,
             ],
             description:
                 "Ovos frescos de galinhas criadas ao ar livre, ricos em sabor e nutrientes. Ideais para pequenos-almoços, bolos e receitas saudáveis. Direto do produtor para a sua mesa.",
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
             deliveryDate: null,
             address: 'Rua do Pedido #1001',
             state: OrderState.Abandonada,
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
                 preferredDeliveryMethods: [
                   DeliveryMethod.COURIER,
                   DeliveryMethod.HOME_DELIVERY,
                 ],
                 description:
                     "Centeio fresco, cultivado de forma sustentável, ideal para pães, farinhas e receitas saudáveis. Rico em fibras e nutrientes, direto do produtor para a sua mesa.",
                 highlight: 'Este anuncio está destacado há mais de 3 dias!',
               ),
             ],
             totalPrice: 20.34,
             consumerId: "BABXdZ7vwKVFtpIjQQeri4mC71v2",
             producerId: "MkqAbSP1zbQZqTbFlyiUawKNslo1",
           ),
           Order(
             id: '0078',
             pickupDate: DateTime(2025, 4, 15),
             deliveryDate: DateTime(2025, 5, 19),
             address: 'Rua do Pedido #0078',
             state: OrderState.Pendente,
             productsAds: [
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
                 preferredDeliveryMethods: [DeliveryMethod.PICKUP],
                 description:
                     "Alface Romana fresca, crocante e cheia de sabor, perfeita para saladas e sanduíches. Cultivada com práticas sustentáveis para garantir qualidade e frescura até à sua mesa.",
                 highlight: 'Este anuncio está destacado há mais de 5 dias!',
               ),
             ],
             totalPrice: 25.12,
             consumerId: "YScblT6Hx2RswFie1JKZX5hgn5F2",
             producerId: "MkqAbSP1zbQZqTbFlyiUawKNslo1",
           ),
           Order(
             id: '0832',
             pickupDate: DateTime(2025, 4, 15),
             deliveryDate: null,
             address: 'Rua do Pedido #0832',
             state: OrderState.Abandonada,
             productsAds: [
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
                 preferredDeliveryMethods: [
                   DeliveryMethod.COURIER,
                   DeliveryMethod.HOME_DELIVERY,
                   DeliveryMethod.PICKUP,
                 ],
                 description:
                     "Tomate Cherry fresco, doce e suculento, perfeito para saladas, snacks e pratos gourmet. Cultivado com práticas sustentáveis para garantir sabor e qualidade excepcionais.",
                 highlight: 'Este anúncio não está em destaque!',
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
             productsAds: [
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
                 preferredDeliveryMethods: [DeliveryMethod.HOME_DELIVERY],
                 description:
                     "Cenouras baby frescas, crocantes e doces, ideais para snacks saudáveis, saladas e receitas variadas. Cultivadas com práticas sustentáveis para garantir qualidade e sabor direto do produtor.",
                 highlight: 'Este anuncio está destacado há 8 horas!',
               ),
             ],
             totalPrice: 17.36,
             consumerId: "BABXdZ7vwKVFtpIjQQeri4mC71v2",
             producerId: "MkqAbSP1zbQZqTbFlyiUawKNslo1",
           ),
           Order(
             id: '1938',
             pickupDate: DateTime(2025, 4, 1),
             deliveryDate: DateTime(2025, 4, 2),
             address: 'Rua do Pedido #1938',
             state: OrderState.Entregue,
             productsAds: [
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
                 preferredDeliveryMethods: [DeliveryMethod.PICKUP],
                 description:
                     "Alface Romana fresca, crocante e cheia de sabor, perfeita para saladas e sanduíches. Cultivada com práticas sustentáveis para garantir qualidade e frescura até à sua mesa.",
                 highlight: 'Este anuncio está destacado há mais de 5 dias!',
               ),
             ],
             totalPrice: 13.84,
             consumerId: "YScblT6Hx2RswFie1JKZX5hgn5F2",
             producerId: "MkqAbSP1zbQZqTbFlyiUawKNslo1",
           ),
           Order(
             id: '8809',
             pickupDate: DateTime(2025, 4, 1),
             deliveryDate: DateTime(2025, 4, 2),
             address: 'Rua do Pedido #8809',
             state: OrderState.Entregue,
             productsAds: [
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
                 preferredDeliveryMethods: [DeliveryMethod.HOME_DELIVERY],
                 description:
                     "Cenouras baby frescas, crocantes e doces, ideais para snacks saudáveis, saladas e receitas variadas. Cultivadas com práticas sustentáveis para garantir qualidade e sabor direto do produtor.",
                 highlight: 'Este anuncio está destacado há 8 horas!',
               ),
             ],
             totalPrice: 69.11,
             consumerId: "BABXdZ7vwKVFtpIjQQeri4mC71v2",
             producerId: "MkqAbSP1zbQZqTbFlyiUawKNslo1",
           ),
           Order(
             id: '1377',
             pickupDate: DateTime(2025, 5, 9),
             deliveryDate: null,
             address: 'Rua do Pedido #8809',
             state: OrderState.Abandonada,
             productsAds: [
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
                 preferredDeliveryMethods: [
                   DeliveryMethod.COURIER,
                   DeliveryMethod.HOME_DELIVERY,
                   DeliveryMethod.PICKUP,
                 ],
                 description:
                     "Tomate Cherry fresco, doce e suculento, perfeito para saladas, snacks e pratos gourmet. Cultivado com práticas sustentáveis para garantir sabor e qualidade excepcionais.",
                 highlight: 'Este anúncio não está em destaque!',
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
                 preferredDeliveryMethods: [DeliveryMethod.COURIER],
                 description:
                     "Trigo de alta qualidade, cultivado de forma sustentável, ideal para panificação, massas e receitas saudáveis. Rico em nutrientes e sabor, direto do produtor para a sua mesa.",
                 highlight: 'Este anúncio não está em destaque!',
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
                 preferredDeliveryMethods: [DeliveryMethod.HOME_DELIVERY],
                 description:
                     "Cenouras baby frescas, crocantes e doces, ideais para snacks saudáveis, saladas e receitas variadas. Cultivadas com práticas sustentáveis para garantir qualidade e sabor direto do produtor.",
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
                 preferredDeliveryMethods: [
                   DeliveryMethod.COURIER,
                   DeliveryMethod.HOME_DELIVERY,
                   DeliveryMethod.PICKUP,
                 ],
                 description:
                     "Tomate Cherry fresco, doce e suculento, perfeito para saladas, snacks e pratos gourmet. Cultivado com práticas sustentáveis para garantir sabor e qualidade excepcionais.",
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
                 preferredDeliveryMethods: [DeliveryMethod.PICKUP],
                 description:
                     "Alface Romana fresca, crocante e cheia de sabor, perfeita para saladas e sanduíches. Cultivada com práticas sustentáveis para garantir qualidade e frescura até à sua mesa.",
                 highlight: 'Este anuncio está destacado há mais de 5 dias!',
               ),
             ],
             totalPrice: 69.11,
             consumerId: "pxgE59JoVgaDHsxbOijA9VKMfKL2",
             producerId: "MkqAbSP1zbQZqTbFlyiUawKNslo1",
           ),
           Order(
             id: '1252',
             pickupDate: DateTime(2025, 5, 9),
             deliveryDate: DateTime(2025, 5, 10),
             address: 'Rua do Pedido #9809',
             state: OrderState.Enviada,
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
                 preferredDeliveryMethods: [
                   DeliveryMethod.COURIER,
                   DeliveryMethod.HOME_DELIVERY,
                 ],
                 description:
                     "Centeio fresco, cultivado de forma sustentável, ideal para pães, farinhas e receitas saudáveis. Rico em fibras e nutrientes, direto do produtor para a sua mesa.",
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
                 preferredDeliveryMethods: [DeliveryMethod.COURIER],
                 description:
                     "Trigo de alta qualidade, cultivado de forma sustentável, ideal para panificação, massas e receitas saudáveis. Rico em nutrientes e sabor, direto do produtor para a sua mesa.",
                 highlight: 'Este anúncio não está em destaque!',
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
                 preferredDeliveryMethods: [DeliveryMethod.HOME_DELIVERY],
                 description:
                     "Cenouras baby frescas, crocantes e doces, ideais para snacks saudáveis, saladas e receitas variadas. Cultivadas com práticas sustentáveis para garantir qualidade e sabor direto do produtor.",
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
                 preferredDeliveryMethods: [
                   DeliveryMethod.COURIER,
                   DeliveryMethod.HOME_DELIVERY,
                   DeliveryMethod.PICKUP,
                 ],
                 description:
                     "Tomate Cherry fresco, doce e suculento, perfeito para saladas, snacks e pratos gourmet. Cultivado com práticas sustentáveis para garantir sabor e qualidade excepcionais.",
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
                 preferredDeliveryMethods: [DeliveryMethod.PICKUP],
                 description:
                     "Alface Romana fresca, crocante e cheia de sabor, perfeita para saladas e sanduíches. Cultivada com práticas sustentáveis para garantir qualidade e frescura até à sua mesa.",
                 highlight: 'Este anuncio está destacado há mais de 5 dias!',
               ),
             ],
             totalPrice: 69.11,
             consumerId: "pxgE59JoVgaDHsxbOijA9VKMfKL2",
             producerId: "MkqAbSP1zbQZqTbFlyiUawKNslo1",
           ),
           //  Order(
           //    id: '2001',
           //    pickupDate: DateTime(2024, 6, 1),
           //    deliveryDate: null,
           //    address: 'Rua do Pedido #2001',
           //    state: OrderState.Abandonada,
           //    productsAds: [
           //      ProductAd(
           //        product: Product(
           //          name: 'Ovos',
           //          imageUrl: ['assets/images/mock_images/eggs.jpg'],
           //          category: 'Ovos',
           //          stock: 50,
           //          minAmount: 6,
           //          unit: Unit.UNIT,
           //          price: 2.0,
           //        ),
           //        preferredDeliveryMethods: [
           //          DeliveryMethod.COURIER,
           //          DeliveryMethod.HOME_DELIVERY,
           //        ],
           //        description:
           //            "Ovos frescos de galinhas criadas ao ar livre, ricos em sabor e nutrientes. Ideais para pequenos-almoços, bolos e receitas saudáveis. Direto do produtor para a sua mesa.",
           //        highlight: 'Este anuncio está destacado há 23 horas!',
           //      ),
           //    ],
           //    totalPrice: 12.0,
           //    consumerId: "vjjzySrSiIYy1c3QcduZhlKglNh2",
           //    producerId: "MkqAbSP1zbQZqTbFlyiUawKNslo1",
           //  ),
           Order(
             id: '2002',
             pickupDate: DateTime(2024, 6, 3),
             deliveryDate: DateTime(2024, 6, 4),
             address: 'Rua do Pedido #2002',
             state: OrderState.Enviada,
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
                 preferredDeliveryMethods: [
                   DeliveryMethod.COURIER,
                   DeliveryMethod.HOME_DELIVERY,
                 ],
                 description:
                     "Centeio fresco, cultivado de forma sustentável, ideal para pães, farinhas e receitas saudáveis. Rico em fibras e nutrientes, direto do produtor para a sua mesa.",
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
                 preferredDeliveryMethods: [DeliveryMethod.COURIER],
                 description:
                     "Trigo de alta qualidade, cultivado de forma sustentável, ideal para panificação, massas e receitas saudáveis. Rico em nutrientes e sabor, direto do produtor para a sua mesa.",
                 highlight: 'Este anúncio não está em destaque!',
               ),
             ],
             totalPrice: 26.0,
             consumerId: "YScblT6Hx2RswFie1JKZX5hgn5F2",
             producerId: "MkqAbSP1zbQZqTbFlyiUawKNslo1",
           ),
           Order(
             id: '2003',
             pickupDate: DateTime(2024, 6, 5),
             deliveryDate: DateTime(2024, 6, 7),
             address: 'Rua do Pedido #2003',
             state: OrderState.Enviada,
             productsAds: [
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
                 preferredDeliveryMethods: [DeliveryMethod.PICKUP],
                 description:
                     "Alface Romana fresca, crocante e cheia de sabor, perfeita para saladas e sanduíches. Cultivada com práticas sustentáveis para garantir qualidade e frescura até à sua mesa.",
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
                 preferredDeliveryMethods: [DeliveryMethod.HOME_DELIVERY],
                 description:
                     "Cenouras baby frescas, crocantes e doces, ideais para snacks saudáveis, saladas e receitas variadas. Cultivadas com práticas sustentáveis para garantir qualidade e sabor direto do produtor.",
                 highlight: 'Este anuncio está destacado há 8 horas!',
               ),
             ],
             totalPrice: 14.2,
             consumerId: "pxgE59JoVgaDHsxbOijA9VKMfKL2",
             producerId: "MkqAbSP1zbQZqTbFlyiUawKNslo1",
           ),
           Order(
             id: '2004',
             pickupDate: DateTime(2024, 6, 7),
             deliveryDate: DateTime(2024, 6, 8),
             address: 'Rua do Pedido #2004',
             state: OrderState.Enviada,
             productsAds: [
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
                 preferredDeliveryMethods: [
                   DeliveryMethod.COURIER,
                   DeliveryMethod.HOME_DELIVERY,
                   DeliveryMethod.PICKUP,
                 ],
                 description:
                     "Tomate Cherry fresco, doce e suculento, perfeito para saladas, snacks e pratos gourmet. Cultivado com práticas sustentáveis para garantir sabor e qualidade excepcionais.",
                 highlight: 'Este anúncio não está em destaque!',
               ),
             ],
             totalPrice: 87.5,
             consumerId: "BABXdZ7vwKVFtpIjQQeri4mC71v2",
             producerId: "MkqAbSP1zbQZqTbFlyiUawKNslo1",
           ),
           Order(
             id: '2005',
             pickupDate: DateTime(2024, 6, 10),
             deliveryDate: DateTime(2024, 6, 11),
             address: 'Rua do Pedido #2005',
             state: OrderState.Pendente,
             productsAds: [
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
                 preferredDeliveryMethods: [DeliveryMethod.COURIER],
                 description:
                     "Trigo de alta qualidade, cultivado de forma sustentável, ideal para panificação, massas e receitas saudáveis. Rico em nutrientes e sabor, direto do produtor para a sua mesa.",
                 highlight: 'Este anúncio não está em destaque!',
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
                 preferredDeliveryMethods: [DeliveryMethod.HOME_DELIVERY],
                 description:
                     "Cenouras baby frescas, crocantes e doces, ideais para snacks saudáveis, saladas e receitas variadas. Cultivadas com práticas sustentáveis para garantir qualidade e sabor direto do produtor.",
                 highlight: 'Este anuncio está destacado há 8 horas!',
               ),
             ],
             totalPrice: 15.3,
             consumerId: "cEK6hsmFrZO8N3G7AqltGVZtMYs2",
             producerId: "MkqAbSP1zbQZqTbFlyiUawKNslo1",
           ),
           Order(
             id: '2006',
             pickupDate: DateTime(2025, 5, 22),
             deliveryDate: DateTime(2025, 5, 23),
             address: 'Rua do Pedido #2006',
             state: OrderState.Entregue,
             productsAds: [
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
                 preferredDeliveryMethods: [DeliveryMethod.COURIER],
                 description:
                     "Trigo de alta qualidade, cultivado de forma sustentável, ideal para panificação, massas e receitas saudáveis. Rico em nutrientes e sabor, direto do produtor para a sua mesa.",
                 highlight: 'Este anúncio não está em destaque!',
               ),
             ],
             totalPrice: 5.10,
             consumerId: "cEK6hsmFrZO8N3G7AqltGVZtMYs2",
             producerId: "MkqAbSP1zbQZqTbFlyiUawKNslo1",
           ),
           Order(
             id: '2007',
             pickupDate: DateTime(2025, 5, 21),
             deliveryDate: DateTime(2025, 5, 22),
             address: 'Rua do Pedido #2007',
             state: OrderState.Entregue,
             productsAds: [
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
                 preferredDeliveryMethods: [DeliveryMethod.PICKUP],
                 description:
                     "Alface Romana fresca, crocante e cheia de sabor, perfeita para saladas e sanduíches. Cultivada com práticas sustentáveis para garantir qualidade e frescura até à sua mesa.",
                 highlight: 'Este anuncio está destacado há mais de 5 dias!',
               ),
             ],
             totalPrice: 7.99,
             consumerId: "BABXdZ7vwKVFtpIjQQeri4mC71v2",
             producerId: "MkqAbSP1zbQZqTbFlyiUawKNslo1",
           ),
           Order(
             id: '2008',
             pickupDate: DateTime(2025, 5, 18),
             deliveryDate: DateTime(2025, 5, 19),
             address: 'Rua do Pedido #2008',
             state: OrderState.Entregue,
             productsAds: [
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
                 preferredDeliveryMethods: [DeliveryMethod.PICKUP],
                 description:
                     "Alface Romana fresca, crocante e cheia de sabor, perfeita para saladas e sanduíches. Cultivada com práticas sustentáveis para garantir qualidade e frescura até à sua mesa.",
                 highlight: 'Este anuncio está destacado há mais de 5 dias!',
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
                 preferredDeliveryMethods: [DeliveryMethod.COURIER],
                 description:
                     "Trigo de alta qualidade, cultivado de forma sustentável, ideal para panificação, massas e receitas saudáveis. Rico em nutrientes e sabor, direto do produtor para a sua mesa.",
                 highlight: 'Este anúncio não está em destaque!',
               ),
             ],
             totalPrice: 9.99,
             consumerId: "BABXdZ7vwKVFtpIjQQeri4mC71v2",
             producerId: "MkqAbSP1zbQZqTbFlyiUawKNslo1",
           ),
           Order(
             id: '2009',
             pickupDate: DateTime(2025, 5, 15),
             deliveryDate: DateTime(2025, 5, 16),
             address: 'Rua do Pedido #2009',
             state: OrderState.Entregue,
             productsAds: [
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
                 preferredDeliveryMethods: [DeliveryMethod.PICKUP],
                 description:
                     "Alface Romana fresca, crocante e cheia de sabor, perfeita para saladas e sanduíches. Cultivada com práticas sustentáveis para garantir qualidade e frescura até à sua mesa.",
                 highlight: 'Este anuncio está destacado há mais de 5 dias!',
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
                 preferredDeliveryMethods: [DeliveryMethod.COURIER],
                 description:
                     "Trigo de alta qualidade, cultivado de forma sustentável, ideal para panificação, massas e receitas saudáveis. Rico em nutrientes e sabor, direto do produtor para a sua mesa.",
                 highlight: 'Este anúncio não está em destaque!',
               ),
             ],
             totalPrice: 9.99,
             consumerId: "BABXdZ7vwKVFtpIjQQeri4mC71v2",
             producerId: "MkqAbSP1zbQZqTbFlyiUawKNslo1",
           ),
         ],
         preferredDeliveryMethod: [
           DeliveryMethod.HOME_DELIVERY,
           DeliveryMethod.COURIER,
         ],
         baskets: [
           Basket(
             name: "Essenciais da Horta",
             deliveryDate: DeliveryDate.WEDNESDAY,
             price: 25.99,
             products: [
               Product(
                 name: 'Alface Romana',
                 imageUrl: ['assets/images/mock_images/alface_romana.jpg'],
                 category: 'Vegetais',
                 amount: 10,
                 unit: Unit.KG,
                 price: 8.99,
               ),
               Product(
                 name: 'Cenouras Baby',
                 imageUrl: ['assets/images/mock_images/baby_carrots.jpg'],
                 category: 'Vegetais',
                 amount: 10,
                 unit: Unit.KG,
                 price: 10.98,
               ),
               Product(
                 name: 'Tomate Cherry',
                 imageUrl: ['assets/images/mock_images/cherry_tomatoes.jpg'],
                 category: 'Vegetais',
                 amount: 10,
                 unit: Unit.KG,
                 price: 6,
               ),
             ],
           ),
           Basket(
             name: "Cereais da Terra",
             deliveryDate: DeliveryDate.FRIDAY,
             price: 15.4,
             products: [
               Product(
                 name: 'Centeio',
                 imageUrl: ['assets/images/mock_images/centeio.jpg'],
                 category: 'Cereais',
                 amount: 10,
                 unit: Unit.KG,
                 price: 7.8,
               ),
               Product(
                 name: 'Trigo',
                 imageUrl: ['assets/images/mock_images/trigo.jpg'],
                 category: 'Cereais',
                 amount: 10,
                 unit: Unit.KG,
                 price: 7.6,
               ),
             ],
           ),
           Basket(
             name: "Pequeno-Almoço Completo",
             deliveryDate: DeliveryDate.MONDAY,
             price: 10.5,
             products: [
               Product(
                 name: 'Ovos',
                 imageUrl: ['assets/images/mock_images/eggs.jpg'],
                 category: 'Ovos',
                 amount: 6,
                 unit: Unit.UNIT,
                 price: 2.0,
               ),
               Product(
                 name: 'Centeio',
                 imageUrl: ['assets/images/mock_images/centeio.jpg'],
                 category: 'Cereais',
                 amount: 5,
                 unit: Unit.KG,
                 price: 8.5,
               ),
               Product(
                 name: 'Centeio',
                 imageUrl: ['assets/images/mock_images/centeio.jpg'],
                 category: 'Cereais',
                 amount: 5,
                 unit: Unit.KG,
                 price: 13.5,
               ),
             ],
           ),
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
