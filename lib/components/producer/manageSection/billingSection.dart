import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/order.dart';

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
  DateTime? _filterDate;
  DateRangeOption _selectedRange = DateRangeOption.none;

  final List<Order> _orders = [
    Order(
      id: '001',
      pickupDate: DateTime.now().subtract(const Duration(days: 2)),
      deliveryDate: DateTime.now().subtract(const Duration(days: 1)),
      address: 'Rua das Flores, 123',
      state: OrderState.Entregue,
      totalPrice: 29.90,
    ),
    Order(
      id: '002',
      pickupDate: DateTime.now(),
      deliveryDate: DateTime.now().add(const Duration(days: 2)),
      address: 'Av. Central, 456',
      state: OrderState.Entregue,
      totalPrice: 42.00,
    ),
    Order(
      id: '003',
      pickupDate: DateTime.now().subtract(const Duration(days: 5)),
      deliveryDate: DateTime.now().subtract(const Duration(days: 3)),
      address: 'Travessa do Sol, 789',
      state: OrderState.Entregue,
      totalPrice: 37.50,
    ),
    Order(
      id: '004',
      pickupDate: DateTime.now().subtract(const Duration(days: 15)),
      deliveryDate: DateTime.now().subtract(const Duration(days: 14)),
      address: 'Rio Tinto N23',
      state: OrderState.Entregue,
      totalPrice: 45.45,
    ),
    Order(
      id: '005',
      pickupDate: DateTime.now().subtract(const Duration(days: 35)),
      deliveryDate: DateTime.now().subtract(const Duration(days: 34)),
      address: 'Jurais do Compostal 74',
      state: OrderState.Entregue,
      totalPrice: 98.32,
    ),
  ];

  List<Order> get _filteredOrders {
    if (_filterDate == null) {
      return _orders
          .where((order) => order.state == OrderState.Entregue)
          .toList();
    }
    return _orders
        .where(
          (order) =>
              order.pickupDate.isAfter(_filterDate!) &&
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
      initialDate: _filterDate ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _filterDate) {
      setState(() {
        _filterDate = picked;
        _selectedRange = DateRangeOption.none;
      });
    }
  }

  void _onRangeSelected(DateRangeOption? option) {
    if (option == null) return;
    setState(() {
      _selectedRange = option;
      if (option == DateRangeOption.none) {
        _filterDate = null;
      } else {
        final now = DateTime.now();
        switch (option) {
          case DateRangeOption.week:
            _filterDate = now.subtract(const Duration(days: 7));
            break;
          case DateRangeOption.month:
            _filterDate = DateTime(now.year, now.month - 1, now.day);
            break;
          case DateRangeOption.threeMonths:
            _filterDate = DateTime(now.year, now.month - 3, now.day);
            break;
          case DateRangeOption.sixMonths:
            _filterDate = DateTime(now.year, now.month - 6, now.day);
            break;
          case DateRangeOption.year:
            _filterDate = DateTime(now.year - 1, now.month, now.day);
            break;
          default:
            _filterDate = null;
        }
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
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
            children: [
              const Text('Filtrar desde:', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 5),
              ElevatedButton.icon(
                onPressed: () => _selectFilterDate(context),
                icon: Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                label: Text(
                  _filterDate != null
                      ? DateFormat.yMMMd().format(_filterDate!)
                      : 'Escolher data',
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
                  fontSize: 16,
                ),
                dropdownColor: Theme.of(context).colorScheme.surface,
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
            onPressed: () {},
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
