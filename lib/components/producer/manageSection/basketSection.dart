import 'package:flutter/material.dart';
import 'package:harvestly/core/models/basket.dart';
import 'package:harvestly/core/models/product.dart';
import 'package:harvestly/core/models/product_ad.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:harvestly/core/services/other/manage_section_notifier.dart';
import 'package:provider/provider.dart';

import '../../../core/models/producer_user.dart';

class BasketSection extends StatefulWidget {
  const BasketSection({Key? key}) : super(key: key);

  @override
  State<BasketSection> createState() => _BasketSectionState();
}

class _BasketSectionState extends State<BasketSection> {
  @override
  Widget build(BuildContext context) {
    List<Basket> baskets =
        (AuthService().currentUser! as ProducerUser)
            .stores[Provider.of<ManageSectionNotifier>(
              context,
              listen: false,
            ).storeIndex]
            .baskets ??
        [];
    Basket? _editingBasket = null;

    // void startEdit(Basket basket) {
    //   setState(() {
    //     _editingBasket = basket;
    //   });
    // }

    void stopEdit() {
      setState(() {
        _editingBasket = null;
      });
    }

    void removeBasket(Basket basket) {
      setState(() {
        baskets.remove(basket);
        _editingBasket = null;
      });
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child:
            _editingBasket != null
                ? BasketEditAddPage(
                  isEditing: true,
                  basket: _editingBasket!,
                  onCancel: stopEdit,
                  onRemove: () => removeBasket(_editingBasket!),
                  onSave: (Basket updated) {
                    setState(() {
                      int idx = baskets.indexOf(_editingBasket!);
                      baskets[idx] = updated;
                      _editingBasket = null;
                    });
                  },
                )
                : ListView.builder(
                  itemCount: baskets.length + 1,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (index < baskets.length) {
                      final basket = baskets[index];
                      return BasketCard(
                        basket: basket,
                        onTap:
                            () => setState(() {
                              _editingBasket = basket;
                            }),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: AddBasketButton(),
                      );
                    }
                  },
                ),
      ),
    );
  }
}

class BasketCard extends StatelessWidget {
  final Basket basket;
  final VoidCallback? onTap;

  const BasketCard({required this.basket, this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      child: Image.asset(
                        "assets/images/basketIllustration.png",
                        fit: BoxFit.fill,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            basket.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Text(
                          "Entregas: ${basket.deliveryDate.toDisplayString()}",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  "${basket.price.toStringAsFixed(2)}€",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(),
            Text("Contém:", style: TextStyle(fontWeight: FontWeight.w500)),
            ...basket.productsAmounts.map((p) {
              final productId = p.keys.first;
              final quantity = p.values.first;

              final storeIndex =
                  Provider.of<ManageSectionNotifier>(
                    context,
                    listen: false,
                  ).storeIndex;
              ProductAd? matchedProductAd;

              for (final user in AuthService().users) {
                if (user is ProducerUser && storeIndex < user.stores.length) {
                  final ads = user.stores[storeIndex].productsAds ?? [];
                  for (final ad in ads) {
                    if (ad.id == productId) {
                      matchedProductAd = ad;
                      break;
                    }
                  }
                }
                if (matchedProductAd != null) break;
              }

              if (matchedProductAd == null) {
                return Text("Produto não encontrado ($productId)");
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 25,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        SizedBox(width: 8),
                        Text(
                          matchedProductAd.product.name,
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "(${matchedProductAd.product.unit == Unit.UNIT ? quantity.toStringAsFixed(0) : quantity.toStringAsFixed(2)} ",
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          "${matchedProductAd.product.unit.toDisplayString()})",
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    Text(
                      "${matchedProductAd.product.price.toStringAsFixed(2)}€",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: cardContent);
    }
    return cardContent;
  }
}

class AddBasketButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              Basket emptyBasket = Basket(
                name: '',
                price: 0,
                deliveryDate: DeliveryDate.values.first,
                productsAmounts: [],
              );
              return Dialog(
                insetPadding: EdgeInsets.all(30),
                child: BasketEditAddPage(
                  isEditing: false,
                  basket: emptyBasket,
                  onCancel: () => Navigator.of(context).pop(),
                  onRemove: () => Navigator.of(context).pop(),
                  onSave: (Basket newBasket) {
                    Navigator.of(context).pop();
                  },
                ),
              );
            },
          );
        },
        icon: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.secondary,
          size: 25,
        ),
        label: Text('Adicionar Cabaz', style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.secondary,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class BasketEditAddPage extends StatefulWidget {
  final Basket basket;
  final VoidCallback onCancel;
  final VoidCallback onRemove;
  final ValueChanged<Basket> onSave;
  final bool isEditing;

  const BasketEditAddPage({
    required this.isEditing,
    required this.basket,
    required this.onCancel,
    required this.onRemove,
    required this.onSave,
    Key? key,
  }) : super(key: key);

  @override
  State<BasketEditAddPage> createState() => _BasketEditAddPageState();
}

class _BasketEditAddPageState extends State<BasketEditAddPage> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController amountController;
  late DeliveryDate selectedDeliveryDate;
  late List<Map<String, int>> editableProducts;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.basket.name);
    priceController = TextEditingController(
      text: widget.basket.price.toString(),
    );
    selectedDeliveryDate = widget.basket.deliveryDate;
    editableProducts = List<Map<String, int>>.from(
      widget.basket.productsAmounts,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void save() {
    final updated = widget.basket.copyWith(
      name: nameController.text,
      price: double.tryParse(priceController.text) ?? widget.basket.price,
      deliveryDate: selectedDeliveryDate,
      products: editableProducts,
    );
    widget.onSave(updated);
  }

  void addProduct(Map<String, int> product) {
    setState(() {
      editableProducts.add(product);
    });
  }

  void removeProduct(Product product) {
    setState(() {
      editableProducts.remove(product);
    });
  }

  Future<void> showAddProductDialog() async {
    Product? newProduct = await showDialog<Product>(
      context: context,
      builder: (context) {
        TextEditingController nameCtrl = TextEditingController();
        TextEditingController priceCtrl = TextEditingController();
        TextEditingController amountCtrl = TextEditingController();
        Unit selectedUnit = Unit.UNIT;
        return AlertDialog(
          title: Text('Adicionar Produto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: priceCtrl,
                decoration: InputDecoration(labelText: 'Preço (€)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: 'Quantidade'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              DropdownButton<Unit>(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiaryFixed,
                ),
                dropdownColor: Theme.of(context).colorScheme.secondary,
                value: selectedUnit,
                onChanged: (value) {
                  if (value != null) {
                    selectedUnit = value;
                  }
                },
                items:
                    Unit.values
                        .map(
                          (u) => DropdownMenuItem(
                            value: u,
                            child: Text(
                              u.toDisplayString(),
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.tertiaryFixed,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty &&
                    priceCtrl.text.isNotEmpty &&
                    amountCtrl.text.isNotEmpty) {
                  Navigator.pop(
                    context,
                    Product(
                      name: nameCtrl.text,
                      season: Season.ALL,
                      imageUrl: [],
                      category: '',
                      price: double.tryParse(priceCtrl.text) ?? 0,
                      unit: selectedUnit,
                    ),
                  );
                }
              },
              child: Text('Adicionar'),
            ),
          ],
        );
      },
    );
    if (newProduct != null) {
      addProduct({
        newProduct.id: double.tryParse(amountController.text)?.toInt() ?? 0,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Editar Cabaz",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nome"),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: priceController,
              decoration: InputDecoration(labelText: "Preço (€)"),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<DeliveryDate>(
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiaryFixed,
                fontSize: 16,
              ),
              dropdownColor: Theme.of(context).colorScheme.secondary,
              value: selectedDeliveryDate,
              decoration: InputDecoration(labelText: "Dia de Entrega"),
              onChanged: (DeliveryDate? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedDeliveryDate = newValue;
                  });
                }
              },
              items:
                  DeliveryDate.values
                      .map(
                        (d) => DropdownMenuItem(
                          value: d,
                          child: Text(d.toDisplayString()),
                        ),
                      )
                      .toList(),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Produtos do Cabaz",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
                GestureDetector(
                  onTap: showAddProductDialog,
                  child: Icon(
                    Icons.add_circle,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: editableProducts.length,
              itemBuilder: (context, index) {
                final p = editableProducts[index];
                final productId = p.keys.first;
                final quantity = p.values.first;
                ProductAd? matchedProductAd;

                for (final user in AuthService().users) {
                  if (user is ProducerUser) {
                    for (final ad
                        in (user)
                                .stores[Provider.of<ManageSectionNotifier>(
                                  context,
                                  listen: false,
                                ).storeIndex]
                                .productsAds ??
                            []) {
                      if (ad.product.id == productId) {
                        matchedProductAd = ad;
                        break;
                      }
                    }
                  }
                  if (matchedProductAd != null) break;
                }

                if (matchedProductAd == null) {
                  return Text("Produto não encontrado ($productId)");
                }
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(matchedProductAd.product.name),
                    subtitle: Text(
                      "${matchedProductAd.product.unit == Unit.UNIT ? quantity.toStringAsFixed(0) : quantity.toStringAsFixed(2)} ${matchedProductAd.product.unit.toDisplayString()} - ${matchedProductAd.product.price.toStringAsFixed(2)}€",
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeProduct(matchedProductAd!.product),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (!widget.isEditing)
                  InkWell(
                    onTap: widget.onCancel,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.arrow_back),
                    ),
                  ),
                if (widget.isEditing)
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.scrim,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                    ),
                    onPressed: widget.onCancel,
                    child: Text(
                      "Cancelar",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiaryFixed,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                SizedBox(width: 8),
                if (widget.isEditing)
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                    ),
                    onPressed: widget.onRemove,
                    child: Text(
                      "Remover",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                SizedBox(width: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                  onPressed: save,
                  child: Text(
                    "Guardar",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
