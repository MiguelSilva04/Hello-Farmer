import 'package:flutter/material.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:harvestly/core/services/other/manage_section_notifier.dart';
import 'package:provider/provider.dart';

import '../../../core/models/order.dart';
import '../../../core/models/producer_user.dart';
import '../../../core/models/product.dart';
import '../../../core/models/store.dart';

class AnalysisDeliveryMethodSection extends StatelessWidget {
  AnalysisDeliveryMethodSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Order> orders =
        (AuthService().currentUser! as ProducerUser)
            .stores[Provider.of<ManageSectionNotifier>(
              context,
              listen: false,
            ).storeIndex]
            .orders ??
        [];
    List<Map<String, dynamic>> _calculateChannelData(List<Order> orders) {
      final currentStore =
          (AuthService().currentUser! as ProducerUser)
              .stores[Provider.of<ManageSectionNotifier>(
            context,
            listen: false,
          ).storeIndex];
      final List<Order> orders = currentStore.orders ?? [];
      final deliveryMethods = [
        {
          'method': DeliveryMethod.HOME_DELIVERY.toDisplayString(),
          'icon': Icons.home,
          'type': DeliveryMethod.HOME_DELIVERY,
        },
        {
          'method': DeliveryMethod.COURIER.toDisplayString(),
          'icon': Icons.local_shipping,
          'type': DeliveryMethod.COURIER,
        },
        {
          'method': DeliveryMethod.PICKUP.toDisplayString(),
          'icon': Icons.storefront,
          'type': DeliveryMethod.PICKUP,
        },
      ];

      final deliveredOrders = orders.where(
        (o) => o.state == OrderState.Delivered,
      );

      List<Map<String, dynamic>> result = [];
      double totalSalesAll = 0;
      Map<DeliveryMethod, double> salesPerMethod = {};
      Map<DeliveryMethod, int> unitsPerMethod = {};
      Map<DeliveryMethod, double> kgPerMethod = {};
      Map<DeliveryMethod, bool> selectedPerMethod = {};

      for (var method in DeliveryMethod.values) {
        salesPerMethod[method] = 0;
        unitsPerMethod[method] = 0;
        kgPerMethod[method] = 0;
        selectedPerMethod[method] = false;
      }

      for (var order in deliveredOrders) {
        for (var ad in order.productsAds) {
          final productAd =
              currentStore.productsAds!
                  .where((p) => p.id == ad.produtctAdId)
                  .first;
          for (var method in productAd.preferredDeliveryMethods) {
            selectedPerMethod[method] = true;
          }

          for (var method in productAd.preferredDeliveryMethods) {
            salesPerMethod[method] =
                (salesPerMethod[method] ?? 0) + order.totalPrice;
            if (productAd.product.unit == Unit.UNIT) {
              unitsPerMethod[method] = (unitsPerMethod[method] ?? 0) + 1;
              kgPerMethod[method] = (kgPerMethod[method] ?? 0) + 0;
            } else {
              unitsPerMethod[method] = (unitsPerMethod[method] ?? 0) + 1;
              kgPerMethod[method] = (kgPerMethod[method] ?? 0) + ad.qty;
            }
          }
        }
        totalSalesAll += order.totalPrice;
      }

      for (var method in deliveryMethods) {
        final type = method['type'] as DeliveryMethod;
        final totalSales = salesPerMethod[type] ?? 0;
        final unitsSold = unitsPerMethod[type] ?? 0;
        final kgSold = kgPerMethod[type] ?? 0;
        final selected = selectedPerMethod[type] ?? false;
        final percentage =
            totalSalesAll > 0 ? (totalSales / totalSalesAll) * 100 : 0.0;

        result.add({
          'method': method['method'],
          'icon': method['icon'],
          'totalSales': totalSales,
          'unitsSold': unitsSold,
          'kgSold': kgSold,
          'percentage': percentage,
          'selected': selected && totalSales > 0,
        });
      }

      return result;
    }

    final Color cardColor = Theme.of(context).colorScheme.surface;
    final Color textColor = Colors.white;
    final channelData = _calculateChannelData(orders);
    final totalSales = channelData.fold<double>(
      0,
      (sum, data) => sum + (data['totalSales'] as double),
    );
    final totalUnits = channelData.fold<int>(
      0,
      (sum, data) => sum + (data['unitsSold'] as int),
    );
    final totalKg = channelData.fold<double>(
      0,
      (sum, data) => sum + (data['kgSold'] as double),
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Total de Vendas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          '${totalSales.toStringAsFixed(2)}€',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        Text(
                          '$totalUnits Unidades',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          '${totalKg.toStringAsFixed(2)}kg',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ...channelData.map((data) {
              return Card(
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(data['icon'], color: Colors.white, size: 30),
                          SizedBox(width: 10),
                          Text(
                            data['method'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      if (data['selected'])
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Vendas totais:',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${data['totalSales'].toStringAsFixed(2)}€ ',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Percentagem das vendas:',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${data['percentage'].toStringAsFixed(2)}% ',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Unidades vendidas:',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${data['unitsSold']} ',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'KG vendidos:',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  ' ${data['kgSold'].toStringAsFixed(2)}kg',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      else
                        Text(
                          'Método não selecionado e sem vendas.',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
