import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harvestly/core/models/order.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/models/product.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoicePageConsumer extends StatelessWidget {
  final Order order;
  final ProducerUser producer;

  const InvoicePageConsumer({
    Key? key,
    required this.order,
    required this.producer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subtotal = order.productsAds.fold<double>(0.0, (sum, item) {
      final ad = producer.store.productsAds!.firstWhere(
        (ad) => ad.id == item.produtctAdId,
      );
      final product = ad.product;
      return sum + (product.price * item.qty);
    });

    final iva = subtotal * 0.23;
    final total = subtotal + iva;

    final consumerName =
        AuthService().currentUser!.firstName +
        ' ' +
        AuthService().currentUser!.lastName;

    return Scaffold(
      appBar: AppBar(title: const Text("Fatura")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.black, fontSize: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Vendedor: ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    "${producer.firstName} ${producer.lastName}",
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    "Banca: ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    producer.store.name ?? 'N/A',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    "Encomenda Nº ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(order.id, style: const TextStyle(fontSize: 18)),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Cliente:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(consumerName, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "Data:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.pickupDate.toLocal().toString().split(' ')[0],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              Table(
                border: TableBorder.all(color: Colors.grey),
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(1.5),
                  2: FlexColumnWidth(2),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  const TableRow(
                    decoration: BoxDecoration(color: Colors.black12),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          "Descrição",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          "Qtd.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          "Custo/un.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...order.productsAds.map((item) {
                    final ad = producer.store.productsAds!.firstWhere(
                      (ad) => ad.id == item.produtctAdId,
                    );
                    final product = ad.product;

                    final unitLabel = product.unit.toDisplayString();
                    final isKg = product.unit == Unit.KG;
                    final qtyDisplay =
                        isKg
                            ? "${item.qty.toStringAsFixed(2)} $unitLabel"
                            : "${item.qty.toStringAsFixed(0)} $unitLabel";
                    final priceDisplay =
                        "${product.price.toStringAsFixed(2)} €";

                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            product.name,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            qtyDisplay,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            priceDisplay,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),

              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(flex: 3, child: SizedBox()),
                        const Expanded(flex: 1, child: SizedBox()),
                        Expanded(
                          flex: 4,
                          child: Text(
                            "Subtotal: ${subtotal.toStringAsFixed(2)} €",
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                            softWrap: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Expanded(flex: 3, child: SizedBox()),
                        const Expanded(flex: 1, child: SizedBox()),
                        Expanded(
                          flex: 4,
                          child: Text(
                            "IVA (23%): ${iva.toStringAsFixed(2)} €",
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                            softWrap: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Expanded(flex: 3, child: SizedBox()),
                        const Expanded(flex: 1, child: SizedBox()),
                        Expanded(
                          flex: 4,
                          child: Text(
                            "Total: ${total.toStringAsFixed(2)} €",
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                            softWrap: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              const Divider(thickness: 1.2),
              const SizedBox(height: 24),

              const Text(
                "Morada de Entrega:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(order.address, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    icon: Icon(
                      Icons.download,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    label: const Text("Descarregar"),
                    onPressed: () async {
                      final pdf = await generateInvoicePdf(
                        order,
                        producer,
                        consumerName,
                      );
                      await Printing.layoutPdf(
                        onLayout: (format) async => pdf.save(),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    icon: Icon(
                      Icons.share,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    label: const Text("Encaminhar"),
                    onPressed: () async {
                      final pdf = await generateInvoicePdf(
                        order,
                        producer,
                        consumerName,
                      );
                      await Printing.sharePdf(
                        bytes: await pdf.save(),
                        filename: 'fatura_${order.id}.pdf',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<pw.Document> generateInvoicePdf(
    Order order,
    ProducerUser producer,
    String consumerName,
  ) async {
    final pdf = pw.Document();

    final ttf = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Poppins-Regular.ttf'),
    );

    final subtotal = order.productsAds.fold<double>(0.0, (sum, item) {
      final ad = producer.store.productsAds!.firstWhere(
        (ad) => ad.id == item.produtctAdId,
      );
      final product = ad.product;
      return sum + (product.price * item.qty);
    });

    final iva = subtotal * 0.23;
    final total = subtotal + iva;

    pdf.addPage(
      pw.Page(
        build:
            (context) => pw.DefaultTextStyle(
              style: pw.TextStyle(font: ttf),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "Fatura",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    "Vendedor: ${producer.firstName} ${producer.lastName}",
                  ),
                  pw.Text("Banca: ${producer.store.name ?? 'N/A'}"),
                  pw.Text("Encomenda Nº: ${order.id}"),
                  pw.SizedBox(height: 16),
                  pw.Text("Cliente: $consumerName"),
                  pw.Text(
                    "Data: ${order.pickupDate.toLocal().toString().split(' ')[0]}",
                  ),
                  pw.SizedBox(height: 24),
                  pw.TableHelper.fromTextArray(
                    headers: ["Descrição", "Qtd.", "Custo/un."],
                    data:
                        order.productsAds.map((item) {
                          final ad = producer.store.productsAds!.firstWhere(
                            (ad) => ad.id == item.produtctAdId,
                          );
                          final product = ad.product;
                          final unitLabel = product.unit.toDisplayString();
                          final isKg = product.unit == Unit.KG;
                          final qtyDisplay =
                              isKg
                                  ? "${item.qty.toStringAsFixed(2)} $unitLabel"
                                  : "${item.qty.toStringAsFixed(0)} $unitLabel";
                          final priceDisplay =
                              "${product.price.toStringAsFixed(2)} €";
                          return [product.name, qtyDisplay, priceDisplay];
                        }).toList(),
                    cellStyle: pw.TextStyle(font: ttf),
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      font: ttf,
                    ),
                  ),
                  pw.SizedBox(height: 24),
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text("Subtotal: ${subtotal.toStringAsFixed(2)} €"),
                        pw.Text("IVA (23%): ${iva.toStringAsFixed(2)} €"),
                        pw.Text(
                          "Total: ${total.toStringAsFixed(2)} €",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            font: ttf,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 32),
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          "Endereço de Faturação:",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(producer.billingAddress ?? "Não definido."),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ),
    );

    return pdf;
  }
}
