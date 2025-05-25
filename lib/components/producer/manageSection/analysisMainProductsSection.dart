import 'package:flutter/material.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../core/models/product.dart';

// Define the ProductStats class
class ProductStats {
  final String name;
  final String image;
  int totalSales;
  double totalKg;
  double totalUnits;
  double totalAmountInSales;

  ProductStats({
    required this.name,
    required this.image,
    this.totalSales = 0,
    this.totalUnits = 0.0,
    this.totalKg = 0.0,
    this.totalAmountInSales = 0.0,
  });
}

// Widget for displaying a product on the podium
class _PodiumProduct extends StatelessWidget {
  final ProductStats product;
  final double percent;
  final int place;

  const _PodiumProduct({
    Key? key,
    required this.product,
    required this.percent,
    required this.place,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${product.totalAmountInSales.toStringAsFixed(2)}€',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        CircularPercentIndicator(
          radius: place == 1 ? 48 : 40,
          lineWidth: 8,
          percent: percent.clamp(0.0, 1.0),
          center: CircleAvatar(
            backgroundImage: AssetImage(product.image),
            radius: place == 1 ? 32 : 26,
          ),
          progressColor:
              place == 1
                  ? Colors.amber[900]
                  : place == 2
                  ? Colors.grey
                  : Colors.brown,
          backgroundColor: Colors.grey.shade200,
          animation: true,
        ),
        const SizedBox(height: 8),
        Text(
          product.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: place == 1 ? 16 : 14,
          ),
        ),
        Text(
          '${product.totalSales} vendas',
          style: TextStyle(color: Colors.grey[700], fontSize: 12),
        ),
        Text(
          '${product.totalKg.toStringAsFixed(2)} kg',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        SizedBox(height: (place == 1) ? 14 : 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color:
                place == 1
                    ? Colors.amber[900]
                    : place == 2
                    ? Colors.grey
                    : Colors.brown,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$placeº',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// Widget for displaying a product card in the grid
class _ProductCard extends StatelessWidget {
  final ProductStats product;
  final double percent;

  const _ProductCard({Key? key, required this.product, required this.percent})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${product.totalAmountInSales.toStringAsFixed(2)}€',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          CircularPercentIndicator(
            radius: 32,
            lineWidth: 6,
            percent: percent.clamp(0.0, 1.0),
            center: CircleAvatar(
              backgroundImage: AssetImage(product.image),
              radius: 100,
            ),
            progressColor: Colors.green,
            backgroundColor: Colors.grey.shade200,
            animation: true,
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          Text(
            '${product.totalSales} vendas',
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
          Text(
            '${product.totalKg.toStringAsFixed(1)} kg',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class AnalysisMainProductsSection extends StatelessWidget {
  const AnalysisMainProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    List<ProductStats> calculateProductStats() {
      final orders = AuthService().currentUser!.store!.orders!;
      final Map<String, ProductStats> statsMap = {};

      for (final order in orders) {
        for (final ad in order.productsAds) {
          final product = ad.product;
          final name = product.name;
          final image = product.imageUrl.first;
          final unit = product.unit;
          final amount = product.amount ?? 0.0;
          final price = ad.product.price ?? 0.0;

          statsMap.putIfAbsent(
            name,
            () => ProductStats(name: name, image: image),
          );
          final stats = statsMap[name]!;

          stats.totalSales += 1;
          stats.totalAmountInSales += price;

          if (unit == Unit.KG) {
            stats.totalKg += amount;
          } else if (unit == Unit.UNIT) {
            stats.totalUnits += amount;
          }
        }
      }

      return statsMap.values.toList();
    }

    final stats = calculateProductStats();
    stats.sort((a, b) => b.totalSales.compareTo(a.totalSales));
    final totalSales = stats.fold<int>(0, (sum, s) => sum + s.totalSales);

    // Separar top 3 e o resto
    final top3 = stats.take(3).toList();
    final rest = stats.length > 3 ? stats.sublist(3) : [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estatísticas dos produtos mais vendidos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24),
          if (top3.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 2º lugar
                if (top3.length > 1)
                  _PodiumProduct(
                    product: top3[1],
                    percent:
                        totalSales > 0 ? top3[1].totalSales / totalSales : 0.0,
                    place: 2,
                  ),
                const SizedBox(width: 20),
                _PodiumProduct(
                  product: top3[0],
                  percent:
                      totalSales > 0 ? top3[0].totalSales / totalSales : 0.0,
                  place: 1,
                ),
                const SizedBox(width: 20),
                if (top3.length > 2)
                  _PodiumProduct(
                    product: top3[2],
                    percent:
                        totalSales > 0 ? top3[2].totalSales / totalSales : 0.0,
                    place: 3,
                  ),
              ],
            ),
          const SizedBox(height: 32),
          if (rest.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Outros produtos',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rest.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final product = rest[index];
                    final percent =
                        totalSales > 0 ? product.totalSales / totalSales : 0.0;
                    return _ProductCard(product: product, percent: percent);
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}
