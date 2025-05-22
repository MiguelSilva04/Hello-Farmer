import 'package:flutter/material.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/models/order.dart';
import '../../../core/services/other/manage_section_notifier.dart';
import 'invoice_page.dart';

enum DateRangeOption {
  none('Escolher data'),
  week('Semana'),
  month('1 Mês'),
  threeMonths('3 Meses'),
  sixMonths('6 Meses'),
  year('1 Ano');

  final String label;
  const DateRangeOption(this.label);
}

class BillingSection extends StatefulWidget {
  const BillingSection({super.key});

  @override
  State<BillingSection> createState() => _BillingSectionState();
}

class _BillingSectionState extends State<BillingSection> {
  DateRangeOption _selectedRange = DateRangeOption.none;
  late ManageSectionNotifier provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<ManageSectionNotifier>(context, listen: false);
    _selectedRange = _getRangeFromDate(provider.billingFromDate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Atualiza o dropdown se billingFromDate mudar externamente
    final currentRange = _getRangeFromDate(provider.billingFromDate);
    if (_selectedRange != currentRange) {
      setState(() {
        _selectedRange = currentRange;
      });
    }
  }

  DateRangeOption _getRangeFromDate(DateTime? date) {
    if (date == null) return DateRangeOption.none;
    final now = DateTime.now();
    final createdAt = AuthService().currentUser!.store!.createdAt;
    if (date.isAtSameMomentAs(createdAt)) return DateRangeOption.none;
    if (date.isAtSameMomentAs(
      now
          .subtract(const Duration(days: 7))
          .copyWith(
            hour: 0,
            minute: 0,
            second: 0,
            millisecond: 0,
            microsecond: 0,
          ),
    )) {
      return DateRangeOption.week;
    }
    if (date.year == now.year &&
        date.month == now.month - 1 &&
        date.day == now.day) {
      return DateRangeOption.month;
    }
    if (date.year == now.year &&
        date.month == now.month - 3 &&
        date.day == now.day) {
      return DateRangeOption.threeMonths;
    }
    if (date.year == now.year &&
        date.month == now.month - 6 &&
        date.day == now.day) {
      return DateRangeOption.sixMonths;
    }
    if (date.year == now.year - 1 &&
        date.month == now.month &&
        date.day == now.day) {
      return DateRangeOption.year;
    }
    return DateRangeOption.none;
  }

  final List<Order> _orders = AuthService().currentUser!.store!.orders!;

  List<Order> get _filteredOrders {
    if (provider.billingFromDate ==
        AuthService().currentUser!.store!.createdAt) {
      return _orders
          .where((order) => order.state == OrderState.Entregue)
          .toList();
    }
    return _orders
        .where(
          (order) =>
              order.pickupDate.isAfter(provider.billingFromDate) &&
              order.state == OrderState.Entregue,
        )
        .toList();
  }

  double get _totalFaturacao {
    return _filteredOrders.fold(0, (sum, order) => sum + order.totalPrice);
  }

  Future<void> _selectFilterDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.billingFromDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != provider.billingFromDate) {
      provider.setBillingFromDate(picked);
      setState(() {
        _selectedRange = DateRangeOption.none;
      });
    }
  }

  void _onRangeSelected(DateRangeOption? option) {
    if (option == null) return;
    setState(() {
      _selectedRange = option;

      final now = DateTime.now();
      switch (option) {
        case DateRangeOption.week:
          provider.setBillingFromDate(now.subtract(const Duration(days: 7)));
          break;
        case DateRangeOption.month:
          provider.setBillingFromDate(
            DateTime(now.year, now.month - 1, now.day),
          );
          break;
        case DateRangeOption.threeMonths:
          provider.setBillingFromDate(
            DateTime(now.year, now.month - 3, now.day),
          );
          break;
        case DateRangeOption.sixMonths:
          provider.setBillingFromDate(
            DateTime(now.year, now.month - 6, now.day),
          );
          break;
        case DateRangeOption.year:
          provider.setBillingFromDate(
            DateTime(now.year - 1, now.month, now.day),
          );
          break;
        default:
          provider.setBillingFromDate(
            AuthService().currentUser!.store!.createdAt,
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_PT',
      symbol: '€',
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceDim,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: Theme.of(context).colorScheme.surface,
                  size: 30,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Total de Faturação:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  currencyFormatter.format(_totalFaturacao),
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.surface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Filtrar desde:', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 5),
                  ElevatedButton.icon(
                    onPressed: () => _selectFilterDate(context),
                    icon: Icon(
                      Icons.calendar_today,
                      size: 13,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    label: Text(
                      Provider.of<ManageSectionNotifier>(
                                context,
                                listen: false,
                              ).billingFromDate !=
                              AuthService().currentUser!.store!.createdAt
                          ? DateFormat.yMMMd().format(
                            Provider.of<ManageSectionNotifier>(
                              context,
                              listen: false,
                            ).billingFromDate,
                          )
                          : 'Escolher data',
                      style: TextStyle(fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
              DropdownButton<DateRangeOption>(
                value: _selectedRange,
                onChanged: _onRangeSelected,
                items:
                    DateRangeOption.values
                        .map(
                          (option) => DropdownMenuItem<DateRangeOption>(
                            value: option,
                            child: Text(option.label),
                          ),
                        )
                        .toList(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondaryFixed,
                  fontSize: 13,
                ),
                dropdownColor: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children:
                  _filteredOrders.map((order) {
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text('Encomenda ${order.id}'),
                        subtitle: Text(
                          'Data: ${DateFormat.yMMMd().format(order.pickupDate)}\nEstado: ${order.state.name}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        trailing: Text(
                          currencyFormatter.format(order.totalPrice),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.surface,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.secondary,
              iconColor: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: () {
              _filteredOrders.isNotEmpty
                  ? Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => InvoicePage(
                            orders: _filteredOrders,
                            total: _totalFaturacao,
                            fromDate:
                                Provider.of<ManageSectionNotifier>(
                                  context,
                                  listen: false,
                                ).billingFromDate,
                          ),
                    ),
                  )
                  : null;
            },
            icon: Padding(
              padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
              child: Icon(Icons.receipt, size: 30),
            ),
            label: Padding(
              padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
              child: Text("Gerar Fatura", style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }
}
