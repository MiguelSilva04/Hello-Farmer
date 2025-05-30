import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';

import '../../../core/models/order.dart';
import '../../../core/models/producer_user.dart';

enum DateFilter {
  TODAY,
  LAST_WEEK,
  LAST_MONTH,
  LAST_3MONTHS,
  LAST_6MONTHS,
  YEAR,
  ALL,
}

extension DateFilterExtension on DateFilter {
  String toDisplayString() {
    switch (this) {
      case DateFilter.TODAY:
        return 'Hoje';
      case DateFilter.LAST_WEEK:
        return 'Última Semana';
      case DateFilter.LAST_MONTH:
        return 'Este Mês';
      case DateFilter.LAST_3MONTHS:
        return 'Últimos 3 Meses';
      case DateFilter.LAST_6MONTHS:
        return 'Últimos 6 Meses';
      case DateFilter.YEAR:
        return 'Este Ano';
      case DateFilter.ALL:
        return 'Todo o Período';
    }
  }
}

class AnalysisStoreViewsSection extends StatefulWidget {
  const AnalysisStoreViewsSection({Key? key}) : super(key: key);

  @override
  State<AnalysisStoreViewsSection> createState() =>
      _AnalysisStoreViewsSectionState();
}

class _AnalysisStoreViewsSectionState extends State<AnalysisStoreViewsSection> {
  DateFilter _selectedPeriod = DateFilter.LAST_WEEK;

  final List<DateFilter> availablePeriods = DateFilter.values;

  @override
  Widget build(BuildContext context) {
    final currentStore = (AuthService().currentUser! as ProducerUser).store;

    if (currentStore == null) {
      return const Center(
        child: Text('Não foi possível carregar os dados da loja.'),
      );
    }

    final filteredViews = _filterViewsByPeriod(
      currentStore.viewsByUserDateTime ?? [],
      _selectedPeriod,
    );

    final int totalViews = filteredViews.length;
    final uniqueVisitors =
        filteredViews.map((e) => e.values.first).toSet().length;

    final filteredOrders =
        (currentStore.orders ?? []).where((o) {
          if (o.state != OrderState.Entregue) return false;
          if (o.deliveryDate == null) return false;
          final deliveredAt = o.deliveryDate!;
          final now = DateTime.now();
          DateTime startDate;
          DateTime endDate = DateTime(
            now.year,
            now.month,
            now.day,
            23,
            59,
            59,
            999,
          );
          switch (_selectedPeriod) {
            case DateFilter.TODAY:
              startDate = DateTime(now.year, now.month, now.day);
              break;
            case DateFilter.LAST_WEEK:
              startDate = DateTime(
                now.year,
                now.month,
                now.day,
              ).subtract(const Duration(days: 6));
              break;
            case DateFilter.LAST_MONTH:
              startDate = DateTime(now.year, now.month, 1);
              endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
              break;
            case DateFilter.LAST_3MONTHS:
              startDate = DateTime(now.year, now.month - 2, 1);
              break;
            case DateFilter.LAST_6MONTHS:
              startDate = DateTime(now.year, now.month - 5, 1);
              break;
            case DateFilter.YEAR:
              startDate = DateTime(now.year, 1, 1);
              endDate = DateTime(now.year, 12, 31, 23, 59, 59, 999);
              break;
            case DateFilter.ALL:
            default:
              startDate = DateTime(2000, 1, 1);
              break;
          }
          final normalizedDeliveredAt = DateTime(
            deliveredAt.year,
            deliveredAt.month,
            deliveredAt.day,
          );
          final normalizedStartDate = DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
          );
          return (normalizedDeliveredAt.isAtSameMomentAs(normalizedStartDate) ||
                  normalizedDeliveredAt.isAfter(normalizedStartDate)) &&
              (deliveredAt.isAtSameMomentAs(endDate) ||
                  deliveredAt.isBefore(endDate));
        }).toList();

    final int totalSales = filteredOrders.length;

    final double conversionRate =
        totalViews == 0 ? 0 : (totalSales / totalViews) * 100;

    final products =
        currentStore.productsAds
            ?.where((p) => p.product.imageUrl.isNotEmpty)
            .toList();
    products?.sort(
      (a, b) => (b.viewsByUserDateTime?.length ?? 0).compareTo(
        a.viewsByUserDateTime?.length ?? 0,
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
            children: [
              _buildMetricCard(
                'Visitas à Banca',
                totalViews.toString(),
                Icons.visibility,
              ),
              _buildMetricCard(
                'Visitantes Únicos',
                uniqueVisitors.toString(),
                Icons.people_alt,
              ),
              _buildMetricCard(
                'Taxa de Conversão',
                '${conversionRate.toStringAsFixed(1)}%',
                Icons.show_chart,
              ),
              _buildMetricCard(
                'Vendas Totais',
                totalSales.toString(),
                Icons.shopping_basket,
              ),
            ],
          ),
          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerRight,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<DateFilter>(
                dropdownColor: Theme.of(context).colorScheme.secondary,
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.tertiaryFixed,
                ),
                value: _selectedPeriod,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.surface,
                ),
                items:
                    availablePeriods
                        .map(
                          (period) => DropdownMenuItem(
                            value: period,
                            child: Text(period.toDisplayString()),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPeriod = value;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Visitas por Período',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 250,

                child: _buildLineChart(filteredViews, totalViews),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Produtos Mais Vistos',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                (products == null || products.isEmpty)
                    ? Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'Nenhum produto encontrado ou visualizado.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondaryFixed,
                          ),
                        ),
                      ),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage: AssetImage(
                                  product.product.imageUrl.first,
                                ),
                              ),
                              title: Text(
                                product.product.name,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              trailing: Text(
                                '${product.viewsByUserDateTime?.length ?? 0} visitas',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                              ),
                              onTap: () {
                                print(
                                  'Produto mais visto clicado: ${product.product.name}',
                                );
                              },
                            ),
                            if (index < products.length - 1)
                              const Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                              ),
                          ],
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.surface),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.tertiaryFixed,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondaryFixed,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _filterViewsByPeriod(List<dynamic> views, DateFilter period) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    switch (period) {
      case DateFilter.TODAY:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case DateFilter.LAST_WEEK:
        startDate = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 6));
        break;
      case DateFilter.LAST_MONTH:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
        break;
      case DateFilter.LAST_3MONTHS:
        startDate = DateTime(now.year, now.month - 2, 1);
        break;
      case DateFilter.LAST_6MONTHS:
        startDate = DateTime(now.year, now.month - 5, 1);
        break;
      case DateFilter.YEAR:
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, 12, 31, 23, 59, 59, 999);
        break;
      case DateFilter.ALL:
      default:
        startDate = DateTime(2000, 1, 1);
        break;
    }

    return views.where((view) {
      final viewDateTime = view.keys.first as DateTime;
      return !viewDateTime.isBefore(startDate) &&
          !viewDateTime.isAfter(endDate);
    }).toList();
  }

  Map<DateTime, int> _groupViewsByDay(List<dynamic> views) {
    final Map<DateTime, int> grouped = {};
    for (var view in views) {
      final date = view.keys.first as DateTime;
      final day = DateTime(date.year, date.month, date.day);
      grouped[day] = (grouped[day] ?? 0) + 1;
    }
    return grouped;
  }

  Widget _buildLineChart(List<dynamic> viewsByUserDateTime, int totalViews) {
    final groupedViews = _groupViewsByDay(viewsByUserDateTime);

    final sortedDates = groupedViews.keys.toList()..sort();

    List<DateTime> allDates = [];
    if (sortedDates.isNotEmpty) {
      DateTime start = sortedDates.first;
      DateTime end = sortedDates.last;
      for (
        DateTime d = start;
        !d.isAfter(end);
        d = d.add(const Duration(days: 1))
      ) {
        allDates.add(d);
      }
    }

    List<DateTime> xLabels = [];
    Map<int, int> groupedByHour = {};
    List<FlSpot> spots = [];

    bool showBottomTitles =
        _selectedPeriod.toDisplayString() == 'Hoje'
            ? allDates.length <= 24
            : allDates.length <= 7;

    if (_selectedPeriod.toDisplayString() == 'Hoje') {
      for (var view in viewsByUserDateTime) {
        final date = view.keys.first as DateTime;
        final hour = date.hour;
        groupedByHour[hour] = (groupedByHour[hour] ?? 0) + 1;
      }
      xLabels = List.generate(
        24,
        (i) => DateTime.now().copyWith(
          hour: i,
          minute: 0,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        ),
      );
      for (int i = 0; i < 24; i++) {
        spots.add(FlSpot(i.toDouble(), groupedByHour[i]?.toDouble() ?? 0));
      }
    } else {
      xLabels = allDates;
      for (int i = 0; i < allDates.length; i++) {
        final date = allDates[i];
        final count = groupedViews[date] ?? 0;
        spots.add(FlSpot(i.toDouble(), count.toDouble()));
      }
    }

    double maxY =
        spots.isNotEmpty
            ? spots.map((e) => e.y).reduce((a, b) => a > b ? a : b)
            : 5;
    if (maxY < 5) {
      maxY = 5;
    } else {
      maxY += 1;
    }

    final hasData = spots.any((spot) => spot.y > 0);

    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine:
                      (value) => FlLine(
                        color: Theme.of(context).colorScheme.secondaryFixed,
                        strokeWidth: 1,
                      ),
                  getDrawingVerticalLine:
                      (value) => FlLine(
                        color: Theme.of(context).colorScheme.secondaryFixed,
                        strokeWidth: 1,
                      ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: Text("Visitas"),
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      },
                      reservedSize: 35,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: Text(
                      _selectedPeriod.toDisplayString() == 'Hoje'
                          ? "Horas do Dia"
                          : _selectedPeriod.toDisplayString() == 'Última Semana'
                          ? "Dias Da Semana"
                          : "Dias",
                    ),
                    sideTitles: SideTitles(
                      showTitles: showBottomTitles,
                      getTitlesWidget: (value, meta) {
                        int index = value.round();
                        if (!showBottomTitles ||
                            index < 0 ||
                            index >= xLabels.length) {
                          return const SizedBox.shrink();
                        }
                        if (_selectedPeriod.toDisplayString() == 'Hoje') {
                          // Exibe apenas algumas horas para não poluir
                          if (index % 2 != 0 && xLabels.length > 12)
                            return const SizedBox.shrink();
                          final hour = xLabels[index].hour;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${hour.toString().padLeft(2, '0')}h',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          );
                        } else {
                          final date = xLabels[index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${date.day}/${date.month}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          );
                        }
                      },
                      interval: 1,
                      reservedSize: 20,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondaryFixed,
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!hasData)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                'Nenhum dado disponível para o período selecionado.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondaryFixed,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
