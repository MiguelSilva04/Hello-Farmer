import 'package:flutter/material.dart';
import 'package:harvestly/core/models/basket.dart';
import 'package:harvestly/core/models/product.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';

class BasketSection extends StatelessWidget {
  final List<Basket> baskets = AuthService().currentUser!.store!.baskets!;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: ListView(
          children: [
            for (var basket in baskets) BasketCard(basket: basket),
            SizedBox(height: 20),
            AddBasketButton(),
          ],
        ),
      ),
    );
  }
}

class BasketCard extends StatelessWidget {
  final Basket basket;

  const BasketCard({required this.basket});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      child: Image.asset(
                        "assets/images/basketIllustration.png",
                        fit: BoxFit.fill,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            basket.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Text(
                          "Entregas: ${basket.deliveryDate.toDisplayString()}",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  "${basket.price.toStringAsFixed(2)}€",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(),
            Text("Contém:", style: TextStyle(fontWeight: FontWeight.w500)),
            ...basket.products.map(
              (p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 25,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        SizedBox(width: 8),
                        Text(p.name, style: TextStyle(fontSize: 15)),
                        SizedBox(width: 8),
                        Text(
                          "(${p.unit == Unit.UNIT ? p.amount!.toStringAsFixed(0) : p.amount!.toStringAsFixed(2)} ",
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          "${p.unit.toDisplayString()})",
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    Text(
                      "${p.price!.toStringAsFixed(2)}€",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddBasketButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.secondary,
          size: 25,
        ),
        label: Text('Adicionar Cabaz', style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.secondary,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
