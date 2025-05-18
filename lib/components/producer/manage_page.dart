import 'package:flutter/material.dart';
import 'package:harvestly/components/producer/manageSection/addsSection.dart';
import 'package:harvestly/components/producer/manageSection/analysisFinancesSection.dart';
import 'package:harvestly/components/producer/manageSection/analysisMainProducersSection.dart';
import 'package:harvestly/components/producer/manageSection/analysisManageStockSection.dart.dart';
import 'package:harvestly/components/producer/manageSection/analysisReportsSection.dart';
import 'package:harvestly/components/producer/manageSection/analysisSaleChannelSection.dart';
import 'package:harvestly/components/producer/manageSection/analysisStoreViewsSection.dart';
import 'package:harvestly/components/producer/manageSection/billingSection.dart';
import 'package:harvestly/components/producer/manageSection/breadCrumbNavigator.dart';
import 'package:harvestly/components/producer/manageSection/clientsSection.dart';
import 'package:harvestly/components/producer/manageSection/financesSection.dart';
import 'package:harvestly/components/producer/manageSection/giftsSection.dart';
import 'package:harvestly/components/producer/manageSection/highlightedAddsSection.dart';
import 'package:harvestly/components/producer/manageSection/managePricesSection.dart';
import 'package:harvestly/components/producer/manageSection/manageStockSection.dart';
import 'package:harvestly/components/producer/manageSection/ordersAbandonnedSection.dart';
import 'package:harvestly/components/producer/manageSection/saleChannelSection.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'manageSection/mainPageSection.dart';
import 'manageSection/mainSectionManage.dart';

class ManagePage extends StatefulWidget {
  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  final user = AuthService().currentUser;
  int sectionIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> sectionNames = [
      "Gestão",
      "Página Principal",
      "Faturação",
      "Compras abandonadas",
      "Gestão de Stock",
      "Gestão de Preços",
      "Cabazes",
      "Clientes",
      "Análise de dados > Gestão de Stock",
      "Análise de dados > Relatórios",
      "Análise de dados > Por Canal de Venda",
      "Análise de dados > Principais Produtores",
      "Análise de dados > Visitas à Banca",
      "Análise de dados > Finanças",
      "Canais de Venda",
      "Anúncios",
      "Destaques de Anúncios",
      "Finanças",
    ];

    final List<Widget> sections = [
      MainSectionPage(
        onClicks: {
          "mainPage": () => setState(() => sectionIndex = 1),
          "billingPage": () => setState(() => sectionIndex = 2),
          "ordersAbandoned": () => setState(() => sectionIndex = 3),
          "manageStock": () => setState(() => sectionIndex = 4),
          "managePrices": () => setState(() => sectionIndex = 5),
          "gifts": () => setState(() => sectionIndex = 6),
          "clients": () => setState(() => sectionIndex = 7),
          "analysisManageStock": () => setState(() => sectionIndex = 8),
          "analysisReports": () => setState(() => sectionIndex = 9),
          "analysisSaleChannel": () => setState(() => sectionIndex = 10),
          "analysisMainProducers": () => setState(() => sectionIndex = 11),
          "analysisStoreViews": () => setState(() => sectionIndex = 12),
          "analysisFinances": () => setState(() => sectionIndex = 13),
          "saleChannel": () => setState(() => sectionIndex = 14),
          "adds": () => setState(() => sectionIndex = 15),
          "highlightedAdds": () => setState(() => sectionIndex = 16),
          "finances": () => setState(() => sectionIndex = 17),
        },
      ),
      MainPageSection(),
      BillingSection(),
      OrdersAbandonedSection(),
      ManageStockSection(),
      ManagePricesSection(),
      GiftsSection(),
      ClientsSection(),
      AnalysisManageStockSection(),
      AnalysisReportsSection(),
      AnalysisSaleChannelSection(),
      AnalysisMainProducersSection(),
      AnalysisStoreViewsSection(),
      AnalysisFinancesSection(),
      SaleChannelSection(),
      AddsSection(),
      HighlightedAddsSection(),
      FinancesSection(),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            width: double.infinity,
            color: Theme.of(context).colorScheme.surface,
            child: BreadcrumbNavigation(
              items:
                  sectionIndex == 0
                      ? [
                        BreadcrumbItem(
                          label: sectionNames[0],
                          onTap: () => setState(() => sectionIndex = 0),
                        ),
                      ]
                      : [
                        BreadcrumbItem(
                          label: sectionNames[0],
                          onTap: () => setState(() => sectionIndex = 0),
                        ),
                        BreadcrumbItem(
                          label: sectionNames[sectionIndex],
                          onTap: () {}, // Página atual
                        ),
                      ],
            ),
          ),
          sections[sectionIndex],
        ],
      ),
    );
  }
}
