import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/order.dart';
import '../../../core/models/producer_user.dart';
import '../../../core/models/product.dart';
import '../../../core/services/auth/auth_notifier.dart';
import '../../../core/services/auth/auth_service.dart';

class AnalysisReportsSection extends StatelessWidget {
  const AnalysisReportsSection({super.key});

  @override
  Widget build(BuildContext context) {
    double calcularDiasRestantesDeStock({
      required List<Product> products,
      required List<Order> orders,
      required int numDias,
    }) {
      if (products.length == 0) return 0.0;
      // Soma o stock total de todos os produtos
      final double stockTotal = products.fold(
        0.0,
        (soma, produto) => soma + produto.stock!,
      );

      // Soma a quantidade total vendida em todos os pedidos
      double totalVendido = 0.0;
      for (var order in orders) {
        for (var produtoAd in order.ordersItems) {
          totalVendido += produtoAd.qty;
        }
      }

      // Calcula a média de vendas por dia
      final double mediaVendasPorDia = totalVendido / numDias;

      // Evita divisão por zero
      if (mediaVendasPorDia == 0) return double.infinity;
      // Calcula dias restantes de stock
      final double diasRestantes = stockTotal / mediaVendasPorDia;

      return diasRestantes;
    }

    final curUserStore =
        (AuthService().currentUser! as ProducerUser)
            .stores[Provider.of<AuthNotifier>(
          context,
          listen: false,
        ).selectedStoreIndex!];
    final orders = curUserStore.orders ?? [];
    final productAds = curUserStore.productsAds!;
    final todosProdutos = <Product>[];
    final nomesProdutos = <String>{};

    for (var ad in productAds) {
      if (!nomesProdutos.contains(ad.product.name)) {
        nomesProdutos.add(ad.product.name);
        todosProdutos.add(ad.product);
      }
    }
    final today = DateTime.now();
    final buyersToday =
        orders
            .where((order) {
              final date = order.deliveryDate;
              return date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
            })
            .map((order) => order.consumerId)
            .toSet()
            .length;

    final dias = calcularDiasRestantesDeStock(
      products: todosProdutos,
      orders: orders,
      numDias: 30,
    );

    int getWeekNumber(DateTime date) {
      final firstDayOfYear = DateTime(date.year, 1, 1);
      final daysOffset = firstDayOfYear.weekday - 1;
      final firstMonday = firstDayOfYear.subtract(Duration(days: daysOffset));
      final diff = date.difference(firstMonday).inDays;
      return (diff / 7).ceil() + 1;
    }

    double calcularPercentagemVendasSemana(List<Order> orders) {
      if (orders.isEmpty) return 0.0;
      final now = DateTime.now();
      final currentWeek = getWeekNumber(now);
      final currentYear = now.year;

      int vendasSemana = 0;
      int vendasTotal = 0;

      for (var order in orders) {
        final date = order.deliveryDate;
        vendasTotal++;
        if (date.year == currentYear && getWeekNumber(date) == currentWeek) {
          vendasSemana++;
        }
      }

      if (vendasTotal == 0) return 0.0;
      return (vendasSemana / vendasTotal) * 100;
    }

    final percentagemSemana = calcularPercentagemVendasSemana(orders);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Relatórios e Inventário',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text('Visualiza e gere os teus dados num só lugar'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildMetricCard(
                  percentagemSemana > 0
                      ? "+${percentagemSemana.toStringAsFixed(2)}%"
                      : "-${percentagemSemana.toStringAsFixed(2)}%",
                  'esta semana',
                  Icons.shopping_cart,
                  context,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  dias.toStringAsFixed(0),
                  'dias restantes',
                  Icons.calendar_today,
                  context,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  buyersToday.toString(),
                  'pessoas hoje',
                  Icons.group,
                  context,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.inventory, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: const [
                    Text(
                      'Inventário',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('acompanha os teus movimentos'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          _buildInventoryTable(context),
          const SizedBox(height: 24),
          Row(
            children: const [
              Icon(Icons.analytics, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Gerar Relatórios',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.surface,
                      width: 1,
                    ),
                  ),
                  onPressed: () {},
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Gerar Semanal',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.surface,
                      width: 1,
                    ),
                  ),
                  onPressed: () {},
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('Gerar Mensal', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: Theme.of(context).colorScheme.surface,
                width: 1,
              ),
            ),
            onPressed: () {},
            child: Align(
              alignment: Alignment.center,
              child: Text('Gerar Costumizado', style: TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {},
            icon: Icon(Icons.calendar_today),
            label: Text('Selecionar datas'),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(
              width: 56,
              height: 56,
              child: FloatingActionButton(
                shape: const CircleBorder(),
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.secondary,
                onPressed: () {},
                child: Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String value,
    String label,
    IconData icon,
    BuildContext context,
  ) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.green[800]),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildInventoryTable(BuildContext context) {
    final productAds =
        (AuthService().currentUser! as ProducerUser)
            .stores[Provider.of<AuthNotifier>(
              context,
              listen: false,
            ).selectedStoreIndex!]
            .productsAds!;
    final orders =
        (AuthService().currentUser! as ProducerUser)
            .stores[Provider.of<AuthNotifier>(
              context,
              listen: false,
            ).selectedStoreIndex!]
            .orders ??
        [];

    final uniqueProducts = <String, Product>{};
    for (var ad in productAds) {
      final product = ad.product;
      uniqueProducts[product.name] = product;
    }

    List<Map<String, String>> productStats = [];
    for (var entry in uniqueProducts.entries) {
      final productName = entry.key;
      final product = entry.value;

      int totalOrders = 0;
      int deliveredOrders = 0;
      DateTime? lastOrderDate;

      for (var order in orders) {
        final hasProduct = order.ordersItems.any((p) {
          final matchingAds = (AuthService().currentUser! as ProducerUser)
              .stores[Provider.of<AuthNotifier>(
                context,
                listen: false,
              ).selectedStoreIndex!]
              .productsAds!
              .where((pr) => pr.id == p.productAdId);

          if (matchingAds.isEmpty) return false;

          final finalProductAd = matchingAds.first;

          return finalProductAd.product.name == productName;
        });

        if (hasProduct) {
          totalOrders++;
          if (order.state == OrderState.Delivered) {
            deliveredOrders++;
          }
          final orderDate = order.deliveryDate;
          if (lastOrderDate == null || orderDate.isAfter(lastOrderDate)) {
            lastOrderDate = orderDate;
          }
        }
      }

      String rate =
          totalOrders > 0
              ? '${((deliveredOrders / totalOrders) * 100).round()}%'
              : '0%';

      String days = '--';
      if (lastOrderDate != null) {
        final diff = DateTime.now().difference(lastOrderDate).inDays;
        days = diff == 1 ? '1 dia' : '$diff dias';
      }

      productStats.add({'name': product.name, 'rate': rate, 'days': days});
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1.5),
      },
      border: TableBorder.all(color: Colors.black12),
      children: [
        TableRow(
          children: const [
            Padding(
              padding: EdgeInsets.all(4),
              child: Text(
                'Produto',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4),
              child: Text(
                'Taxa de venda',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4),
              child: Text(
                'Dias desde última venda',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        for (var stat in productStats)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(stat['name']!),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(stat['rate']!),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${stat['days']! == "355 dias" ? " " : stat['days']!}",
                ),
              ),
            ],
          ),
      ],
    );
  }
}
