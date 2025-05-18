import 'package:flutter/material.dart';
import 'package:harvestly/components/producer/manageSection/breadCrumbNavigator.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'manageSection/mainPageSection.dart';
import 'manageSection/mainSectionManage.dart';
import 'manageSection/ordersSection.dart';

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
      "Gestão", // índice 0
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
      const Center(child: Text("Página Principal")),
      const Center(child: Text("Faturação")),
      const Center(child: Text("Compras abandonadas")),
      const Center(child: Text("Gestão de Stock")),
      const Center(child: Text("Gestão de Preços")),
      const Center(child: Text("Cabazes")),
      const Center(child: Text("Clientes")),
      const Center(child: Text("Análise de dados > Gestão de Stock")),
      const Center(child: Text("Análise de dados > Relatórios")),
      const Center(child: Text("Análise de dados > Por Canal de Venda")),
      const Center(child: Text("Análise de dados > Principais Produtores")),
      const Center(child: Text("Análise de dados > Visitas à Banca")),
      const Center(child: Text("Análise de dados > Finanças")),
      const Center(child: Text("Canais de Venda")),
      const Center(child: Text("Anúncios")),
      const Center(child: Text("Destaques de Anúncios")),
      const Center(child: Text("Finanças")),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
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
          Padding(
            padding: const EdgeInsets.all(10),
            child: sections[sectionIndex],
          ),
        ],
      ),
    );
  }
}
