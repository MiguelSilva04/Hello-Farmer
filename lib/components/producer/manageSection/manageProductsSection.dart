import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/product_ad.dart';
import '../../../core/services/other/manage_section_notifier.dart';

enum ManageViewMode { stock, prices }

class ManageProductsSection extends StatefulWidget {
  const ManageProductsSection({super.key});

  @override
  State<ManageProductsSection> createState() => _ManageProductsSectionState();
}

class _ManageProductsSectionState extends State<ManageProductsSection> {
  late ManageViewMode _mode;

  final List<ProductAd> _products = [
    ProductAd(
      product: Product(
        name: 'Tomate Cheryy',
        imageUrl: ['assets/images/mock_images/cherry_tomatoes.jpg'],
        category: 'Hortícolas',
        stock: 20,
        price: 2.5,
        minAmount: 5,
        unit: Unit.KG,
      ),
      highlight: '',
    ),
    ProductAd(
      product: Product(
        name: 'Alface Romana',
        imageUrl: ['assets/images/mock_images/alface_romana.jpg'],
        category: 'Hortícolas',
        stock: 10,
        price: 1.5,
        minAmount: 5,
        unit: Unit.KG,
      ),
      highlight: '',
    ),
    ProductAd(
      product: Product(
        name: 'Ovos',
        imageUrl: ['assets/images/mock_images/eggs.jpg'],
        category: 'Ovos',
        stock: 15,
        price: 1,
        minAmount: 6,
        unit: Unit.UNIT,
      ),
      highlight: '',
    ),
    ProductAd(
      product: Product(
        name: 'Trigo',
        imageUrl: ['assets/images/mock_images/trigo.jpg'],
        category: 'Cereais',
        stock: 30,
        price: 3.5,
        minAmount: 10,
        unit: Unit.KG,
      ),
      highlight: '',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final currentIndex =
        Provider.of<ManageSectionNotifier>(context, listen: false).currentIndex;
    if (currentIndex == 4) {
      _mode = ManageViewMode.stock;
    } else if (currentIndex == 5) {
      _mode = ManageViewMode.prices;
    } else {
      _mode = ManageViewMode.stock;
    }
  }

  void _onModeChanged(ManageViewMode? value) {
    if (value == null) return;
    setState(() => _mode = value);
    final notifier = Provider.of<ManageSectionNotifier>(context, listen: false);
    if (value == ManageViewMode.stock) {
      notifier.setIndex(4);
    } else if (value == ManageViewMode.prices) {
      notifier.setIndex(5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Visualizar:'),
            const SizedBox(width: 10),
            DropdownButton<ManageViewMode>(
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondaryFixed,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
              dropdownColor: Theme.of(context).colorScheme.secondary,
              value: _mode,
              items: const [
                DropdownMenuItem(
                  value: ManageViewMode.stock,
                  child: Text('Stock'),
                ),
                DropdownMenuItem(
                  value: ManageViewMode.prices,
                  child: Text('Preços'),
                ),
              ],
              onChanged: _onModeChanged,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: const Text(
              'Produtos:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(
          height: _products.length * MediaQuery.of(context).size.height * 0.1,
          child: ListView.builder(
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final productAd = _products[index];
              final product = productAd.product;

              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          productAd.product.imageUrl.first,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(product.name, style: TextStyle(fontSize: 20)),
                      subtitle:
                          _mode == ManageViewMode.stock
                              ? Text(
                                'Qtd: ${product.stock} ${product.unit.toDisplayString()}',
                                style: TextStyle(fontSize: 16),
                              )
                              : Text(
                                'Preço: ${product.price.toStringAsFixed(2)} €',
                                style: TextStyle(fontSize: 16),
                              ),
                      trailing: TextButton(
                        onPressed: () {
                          // Lógica de edição
                        },
                        child: const Text(
                          'Editar',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  Divider(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
