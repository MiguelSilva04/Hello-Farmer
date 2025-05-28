import 'package:flutter/material.dart';

import '../../core/models/app_user.dart';
import '../../core/models/order.dart';
import '../../core/models/product_ad.dart';

class OrderDetailsPage extends StatelessWidget {
  final Order order;
  final ads;
  final AppUser producer;

  const OrderDetailsPage({
    super.key,
    required this.order,
    required this.ads,
    required this.producer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes'),
        backgroundColor: const Color.fromRGBO(59, 126, 98, 1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(

              ads.first.product.imageUrl.first,
              //order['imagePath']!,
              height: 180),
            const SizedBox(height: 20),
            Text(
              'Encomenda #${order.id}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Produtor: ${producer.firstName} ${producer.lastName}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Valor: ${order.totalPrice}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(order.state.toString(), style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              order.deliveryDate != null
                  ? "${order.deliveryDate!.day}/${order.deliveryDate!.month}/${order.deliveryDate!.year}"
                  : "Sem entrega",
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
