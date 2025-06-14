import 'package:flutter/material.dart';
import 'package:harvestly/core/models/order.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/models/producer_user.dart';
import '../../../core/services/auth/auth_notifier.dart';
import '../../../core/services/auth/auth_service.dart';

class AnalysisFinancesSection extends StatefulWidget {
  const AnalysisFinancesSection({super.key});

  @override
  State<AnalysisFinancesSection> createState() =>
      _AnalysisFinancesSectionState();
}

class _AnalysisFinancesSectionState extends State<AnalysisFinancesSection> {
  String filtroSelecionado = 'Semana';

  @override
  Widget build(BuildContext context) {
    final user = (AuthService().currentUser! as ProducerUser);
    final orders =
        user
            .stores[Provider.of<AuthNotifier>(
              context,
              listen: false,
            ).selectedStoreIndex]
            .orders;

    final now = DateTime.now();

    DateTime startDate;
    DateTime endDate;
    int diasIntervalo;

    if (filtroSelecionado == 'Semana') {
      // De 7 dias atrás até ontem
      endDate = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 1));
      startDate = endDate.subtract(const Duration(days: 6));
      diasIntervalo = 7;
    } else {
      // Mostrar todos os dias do mês atual
      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month + 1, 0); // último dia do mês atual
      diasIntervalo = endDate.day;
    }

    final ordersFiltrados =
        orders != null
            ? orders.where((order) {
              return 
                  !order.deliveryDate.isBefore(startDate) &&
                  !order.deliveryDate.isAfter(endDate);
            }).toList()
            : [];

    final receitasPorDia = List<double>.filled(diasIntervalo, 0.0);
    double totalReceitas = 0;

    for (var order in ordersFiltrados) {
      if (order.state == OrderState.Delivered) {
        final date = order.deliveryDate!;
        int index = date.difference(startDate).inDays;
        if (index >= 0 && index < receitasPorDia.length) {
          final valorOrder = order.totalPrice;
          receitasPorDia[index] += valorOrder;
          totalReceitas += valorOrder;
        }
      }
    }

    double despesasOperacionais = totalReceitas * 0.1;
    final lucroLiquido = totalReceitas - despesasOperacionais;
    final saldoDisponivel = lucroLiquido - 100;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text("Visualizar por:"),
              const SizedBox(width: 10),
              DropdownButton<String>(
                dropdownColor: Theme.of(context).colorScheme.secondary,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiaryFixed,
                ),
                value: filtroSelecionado,
                items: const [
                  DropdownMenuItem(value: 'Semana', child: Text('Semana')),
                  DropdownMenuItem(value: 'Mês', child: Text('Mês')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      filtroSelecionado = val;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMetric(
            "Receitas deste ${filtroSelecionado.toLowerCase()}",
            totalReceitas,
          ),
          const SizedBox(height: 8),
          _buildMetric("Despesas Operacionais", despesasOperacionais),
          const SizedBox(height: 8),
          _buildMetric("Lucro Líquido", lucroLiquido),
          const SizedBox(height: 16),
          _buildMetric("Saldo Disponível", saldoDisponivel),
          const SizedBox(height: 16),
          _buildBarChart(receitasPorDia, filtroSelecionado, startDate),
          const SizedBox(height: 16),
          _buildButton("Ver pagamentos recebidos"),
          _buildButton("Emitir fatura"),
          _buildButton("Transferir Saldo"),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, double value) {
    final formatted = NumberFormat.currency(
      locale: 'pt_PT',
      symbol: '€',
      decimalDigits: 2,
    ).format(value);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Text(
          formatted,
          style: TextStyle(
            color: Theme.of(context).colorScheme.surface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(
    List<double> valores,
    String filtroSelecionado,
    DateTime startDate,
  ) {
    List<String> labels;
    if (filtroSelecionado == 'Semana') {
      labels = [
        'Segunda',
        'Terça',
        'Quarta',
        'Quinta',
        'Sexta',
        'Sábado',
        'Domingo',
      ];
    } else {
      labels = List.generate(valores.length, (i) {
        final dia = startDate.add(Duration(days: i)).day;
        return dia.toString();
      });
    }

    final maxValor =
        valores.isNotEmpty ? valores.reduce((a, b) => a > b ? a : b) : 0.0;

    return SizedBox(
      height: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(valores.length, (i) {
          final heightFactor = maxValor > 0 ? valores[i] / maxValor : 0;
          return Expanded(
            child: Column(
              children: [
                if (filtroSelecionado == 'Semana')
                  Text(
                    "~${valores[i].toStringAsFixed(0)}€",
                    style: TextStyle(
                      fontSize: filtroSelecionado == 'Semana' ? 11 : 8,
                      fontWeight:
                          filtroSelecionado == 'Semana'
                              ? FontWeight.w700
                              : FontWeight.bold,
                    ),
                  ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: filtroSelecionado == 'Semana' ? 24 : 8,
                      height: (100 * heightFactor).toDouble(),
                      decoration: BoxDecoration(
                        color: const Color(0xFF428B6D),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: filtroSelecionado == 'Semana' ? 10 : 8,
                    fontWeight:
                        filtroSelecionado == 'Semana'
                            ? FontWeight.w700
                            : FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildButton(String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Theme.of(context).colorScheme.surface,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.tertiaryFixed,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
