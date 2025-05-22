import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/models/order.dart';
import '../../../core/services/auth/auth_service.dart';

class InvoicePage extends StatelessWidget {
  final List<Order> orders;
  final double total;
  final DateTime? fromDate;

  const InvoicePage({
    super.key,
    required this.orders,
    required this.total,
    this.fromDate,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey previewContainer = GlobalKey();
    final store = AuthService().currentUser!.store!;
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_PT',
      symbol: '€',
    );

    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: RepaintBoundary(
                key: previewContainer,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello Farmer",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Text("Data: ${DateFormat.yMMMMd('pt_PT').format(DateTime.now())}"),
                    const Divider(),
                    const SizedBox(height: 40),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          store.name!,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          store.location!,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          store.address!,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (fromDate != null)
                      Row(
                        children: [
                          Text(
                            "Obtido desde: ",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "${DateFormat.yMMMd('pt_PT').format(fromDate!)}",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              "Encomendas",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Total",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: ListView.separated(
                        itemCount: orders.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (_, index) {
                          final order = orders[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Encomenda #${order.id}",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        "Data: ${DateFormat.yMMMd('pt_PT').format(order.pickupDate)}",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      currencyFormatter.format(
                                        order.totalPrice,
                                      ),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Total de Faturação:",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "${currencyFormatter.format(total)}",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () async {
                    RenderRepaintBoundary boundary =
                        previewContainer.currentContext!.findRenderObject()
                            as RenderRepaintBoundary;
                    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
                    ByteData? byteData = await image.toByteData(
                      format: ui.ImageByteFormat.png,
                    );
                    Uint8List imageBytes = byteData!.buffer.asUint8List();

                    final pdf = pw.Document();
                    final imageProvider = pw.MemoryImage(imageBytes);

                    pdf.addPage(
                      pw.Page(
                        pageFormat: PdfPageFormat.a4,
                        build: (pw.Context context) {
                          return pw.Center(child: pw.Image(imageProvider));
                        },
                      ),
                    );

                    await Printing.layoutPdf(
                      onLayout: (PdfPageFormat format) async => pdf.save(),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          "Descarregar",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(Icons.download_rounded, size: 35),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    RenderRepaintBoundary boundary =
                        previewContainer.currentContext!.findRenderObject()
                            as RenderRepaintBoundary;
                    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
                    ByteData? byteData = await image.toByteData(
                      format: ui.ImageByteFormat.png,
                    );
                    Uint8List imageBytes = byteData!.buffer.asUint8List();

                    final pdf = pw.Document();
                    final imageProvider = pw.MemoryImage(imageBytes);

                    pdf.addPage(
                      pw.Page(
                        build: (pw.Context context) {
                          return pw.Center(child: pw.Image(imageProvider));
                        },
                      ),
                    );

                    await Printing.sharePdf(
                      bytes: await pdf.save(),
                      filename:
                          'fatura_${store.name}_${fromDate != null ? DateFormat('yyyy_MM_dd').format(fromDate!) : ''}.pdf',
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          "Encaminhar",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(Icons.share_outlined, size: 35),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
