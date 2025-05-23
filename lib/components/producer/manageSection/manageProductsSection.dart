import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/product.dart';
import '../../../core/models/product_ad.dart';
import '../../../core/services/auth/auth_service.dart';
import '../../../core/services/other/manage_section_notifier.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum ManageViewMode { stock, prices }

class ManageProductsSection extends StatefulWidget {
  const ManageProductsSection({super.key});

  @override
  State<ManageProductsSection> createState() => _ManageProductsSectionState();
}

class _ManageProductsSectionState extends State<ManageProductsSection> {
  late ManageViewMode _mode;

  final List<ProductAd> _products =
      AuthService().currentUser!.store!.productsAds!;

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
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            _mode == ManageViewMode.stock ? 'Qtd:' : 'Preço: ',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(width: 8),
                          StatefulBuilder(
                            builder: (context, setStateField) {
                              final TextEditingController _controller =
                                  TextEditingController(
                                    text:
                                        _mode == ManageViewMode.stock
                                            ? (product.stock ?? 0).toString()
                                            : (product.price ?? 0)
                                                .toStringAsFixed(1),
                                  );
                              return SizedBox(
                                width: (_mode == ManageViewMode.stock
                                        ? (product.stock ?? 0)
                                                .toString()
                                                .length *
                                            14.0
                                        : ((product.price ?? 0)
                                                .toStringAsFixed(1)
                                                .length *
                                            16.0))
                                    .clamp(50.0, 140.0),
                                child: TextFormField(
                                  controller: _controller,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: _mode != ManageViewMode.stock,
                                  ),
                                  decoration: InputDecoration(
                                    labelStyle: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    setStateField(() {
                                      if (_mode == ManageViewMode.stock) {
                                        product.stock = int.tryParse(val) ?? 0;
                                      } else {
                                        product.price =
                                            double.tryParse(val) ?? 0.0;
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 5),
                          (_mode == ManageViewMode.stock)
                              ? StatefulBuilder(
                                builder: (context, setStateUnit) {
                                  return DropdownButton<Unit>(
                                    dropdownColor:
                                        Theme.of(context).colorScheme.secondary,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondaryFixed,
                                    ),
                                    value: product.unit,
                                    onChanged: (val) {
                                      if (val != null) {
                                        setStateUnit(() {
                                          product.unit = val;
                                        });
                                      }
                                    },
                                    items: const [
                                      DropdownMenuItem(
                                        value: Unit.KG,
                                        child: Text("Kg"),
                                      ),
                                      DropdownMenuItem(
                                        value: Unit.UNIT,
                                        child: Text("Unidade(s)"),
                                      ),
                                    ],
                                  );
                                },
                              )
                              : Text("€"),
                        ],
                      ),
                      trailing: StatefulBuilder(
                        builder: (context, setStateTrailing) {
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_mode == ManageViewMode.stock) {
                                        if ((product.stock ?? 0) > 0)
                                          product.stock =
                                              (product.stock ?? 0) - 1;
                                      } else {
                                        product.price = double.parse(
                                          ((product.price ?? 0) - 0.1)
                                              .toStringAsFixed(1),
                                        );
                                      }
                                    });
                                  },
                                  child: Icon(
                                    FontAwesomeIcons.minus,
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_mode == ManageViewMode.stock) {
                                        product.stock =
                                            (product.stock ?? 0) + 1;
                                      } else {
                                        product.price = double.parse(
                                          ((product.price ?? 0) + 0.1)
                                              .toStringAsFixed(1),
                                        );
                                      }
                                    });
                                  },
                                  child: Icon(
                                    Icons.add,
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    size: 35,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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
