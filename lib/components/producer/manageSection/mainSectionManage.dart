import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MainSectionPage extends StatelessWidget {
  final Map<String, VoidCallback> onClicks;

  const MainSectionPage({super.key, required this.onClicks});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.onInverseSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/next_steps.png",
                    height: 80,
                  ).animate().fade(duration: 800.ms).scale(),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          "Próximos passos",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          "Siga estas etapas para começar a vender: \n• Adicionar um produto\n• Configurar os canais de venda\n• Destacar o seu anúncio",
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().slide(duration: 500.ms),
          const SizedBox(height: 10),

          // Página Principal
          SettingsTileGroup(
            icon: Icons.home,
            title: "Página Principal",
            onTap: onClicks["mainPage"],
          ),

          // Encomendas
          SettingsTileGroup(
            icon: Icons.shopping_cart,
            title: "Encomendas",
            onTap: () {}, // opcional
            subOptions: [
              SettingsSubOption(
                title: "Faturação",
                onTap: onClicks["billingPage"]!,
              ),
              SettingsSubOption(
                title: "Compras abandonadas",
                onTap: onClicks["ordersAbandoned"]!,
              ),
            ],
          ),

          // Produtos
          SettingsTileGroup(
            icon: Icons.inventory,
            title: "Produtos",
            subOptions: [
              SettingsSubOption(
                title: "Gestão de Stock",
                onTap: onClicks["manageStock"]!,
              ),
              SettingsSubOption(
                title: "Gestão de Preços",
                onTap: onClicks["managePrices"]!,
              ),
              SettingsSubOption(title: "Cabazes", onTap: onClicks["baskets"]!),
            ],
          ),

          // Clientes
          SettingsTileGroup(
            icon: Icons.people,
            title: "Clientes",
            onTap: onClicks["clients"],
          ),

          // Análise de Dados
          SettingsTileGroup(
            icon: Icons.analytics,
            title: "Análise de Dados",
            subOptions: [
              SettingsSubOption(
                title: "Relatórios",
                onTap: onClicks["analysisReports"]!,
              ),
              SettingsSubOption(
                title: "Por canal de venda",
                onTap: onClicks["analysisDeliveryMethod"]!,
              ),
              SettingsSubOption(
                title: "Principais produtos",
                onTap: onClicks["analysisMainProducts"]!,
              ),
              SettingsSubOption(
                title: "Visitas à banca",
                onTap: onClicks["analysisStoreViews"]!,
              ),
              SettingsSubOption(
                title: "Finanças",
                onTap: onClicks["analysisFinances"]!,
              ),
            ],
          ),

          // Restantes opções
          SettingsTileGroup(
            icon: Icons.storefront,
            title: "Canais de Venda",
            onTap: onClicks["deliveryMethod"],
          ),
          SettingsTileGroup(
            icon: Icons.campaign,
            title: "Anúncios",
            onTap: onClicks["adds"],
          ),
          SettingsTileGroup(
            icon: Icons.star,
            title: "Destaques de Anúncios",
            onTap: onClicks["highlightedAdds"],
          ),
          SettingsTileGroup(
            icon: Icons.attach_money,
            title: "Finanças",
            onTap: onClicks["finances"],
          ),
        ],
      ),
    );
  }
}

class SettingsTileGroup extends StatefulWidget {
  final IconData icon;
  final String title;
  final List<SettingsSubOption>? subOptions;
  final VoidCallback? onTap;

  const SettingsTileGroup({
    super.key,
    required this.icon,
    required this.title,
    this.subOptions,
    this.onTap,
  });

  @override
  State<SettingsTileGroup> createState() => _SettingsTileGroupState();
}

class _SettingsTileGroupState extends State<SettingsTileGroup> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.inversePrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(widget.icon, size: 50, color: color),
          title: Text(
            widget.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22,
              color: color,
            ),
          ),
          trailing:
              widget.subOptions != null
                  ? Icon(
                    _isExpanded
                        ? Icons.expand_less
                        : Icons.keyboard_arrow_down_rounded,
                    size: 35,
                    color: color,
                  )
                  : Icon(Icons.arrow_forward_ios, color: color),
          onTap: () {
            if (widget.subOptions != null) {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            } else {
              widget.onTap?.call();
            }
          },
        ),
        if (widget.subOptions != null)
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isExpanded ? (widget.subOptions!.length * 60.0) : 0,
              curve: Curves.fastOutSlowIn,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children:
                      widget.subOptions!
                          .map(
                            (sub) => ListTile(
                              title: Text(
                                sub.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: color,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: color,
                              ),
                              onTap: sub.onTap,
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
          ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class SettingsSubOption {
  final String title;
  final VoidCallback onTap;

  SettingsSubOption({required this.title, required this.onTap});
}
