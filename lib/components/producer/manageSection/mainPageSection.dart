import 'dart:io';

import 'package:flutter/material.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:harvestly/core/services/other/manage_section_notifier.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/models/producer_user.dart';
import '../../../core/models/product.dart';
import '../../../core/models/product_ad.dart';
import '../../../core/models/store.dart';
import '../../../core/services/other/bottom_navigation_notifier.dart';

class MainPageSection extends StatefulWidget {
  MainPageSection({super.key});

  @override
  State<MainPageSection> createState() => _MainPageSectionState();
}

class _MainPageSectionState extends State<MainPageSection> {
  late Store store;

  bool _isEditingAd = false;
  ProductAd? _currentAd;

  @override
  void initState() {
    super.initState();
    store =
        (AuthService().currentUser! as ProducerUser)
            .stores[Provider.of<ManageSectionNotifier>(
          context,
          listen: false,
        ).storeIndex];
  }

  @override
  Widget build(BuildContext context) {
    return _isEditingAd
        ? EditAdSection(
          ad: _currentAd!,
          onCancel: () => setState(() => _isEditingAd = false),
          onSave: (val) {},
        )
        : SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    store.backgroundImageUrl ??
                        "assets/images/default_store.jpg",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
                  ),
                  Positioned(
                    bottom: -50,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.secondaryFixed,
                            width: 1,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage(
                            store.imageUrl ?? "assets/images/default_store.jpg",
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        store.name ?? "Sem Nome",
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.edit, size: 20),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Descrição",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      store.description ?? "Sem descrição disponível.",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Canais de venda",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed:
                              () => Provider.of<ManageSectionNotifier>(
                                context,
                                listen: false,
                              ).setIndex(13),
                          child: const Text(
                            "Definir Canais de venda",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 10,
                      children:
                          store.preferredDeliveryMethod?.map((method) {
                            IconData icon;
                            switch (method) {
                              case DeliveryMethod.COURIER:
                                icon = Icons.local_shipping;
                                break;
                              case DeliveryMethod.HOME_DELIVERY:
                                icon = Icons.home;
                                break;
                              case DeliveryMethod.PICKUP:
                                icon = Icons.store;
                                break;
                            }
                            return Chip(
                              avatar: Icon(
                                icon,
                                size: 16,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              label: Text(
                                method.toDisplayString(),
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList() ??
                          [],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Tooltip(
                      message:
                          "Os anúncios, se destacados, são classificados em:\n\nInicio: Para o topo da página de pesquisa \n- Com este destaque, o anúncio sobe de posição relativamente a anúncios semelhantes que não têm qualquer destaque\n\nPesquisa: Top de anúncios (destaque na página inicial) \n- Com este destaque, o anúncio vai ser apresentado rotativamente na página inicial de consumidores, antes mesmo de iniciarem a sua pesquisa, colocando também o embelema 'TOP' na foto do anúncio para que chame mais à atenção.",
                      textStyle: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                      showDuration: const Duration(seconds: 300),
                      triggerMode: TooltipTriggerMode.tap,
                      preferBelow: false,
                      child: Icon(Icons.info_outline),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Anúncios publicados",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () {
                                Provider.of<BottomNavigationNotifier>(
                                  context,
                                  listen: false,
                                ).setIndex(2);
                              },
                              icon: const Icon(Icons.add),
                              label: const Text("Novo anúncio"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        store.productsAds!.isEmpty
                            ? const Text("Ainda não há anúncios publicados.")
                            : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: store.productsAds!.length,
                              itemBuilder: (context, index) {
                                final ad = store.productsAds![index];
                                return ListTile(
                                  leading: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          ad.product.imageUrl.first,
                                          width: 75,
                                          height: 75,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      if (ad.highlightType ==
                                          HighlightType.HOME)
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          child: Badge(
                                            backgroundColor:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.secondaryFixed,
                                            label: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Icon(
                                                  Icons.star,
                                                  size: 10,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 3),
                                                Text(
                                                  "Inicio",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      if (ad.highlightType ==
                                          HighlightType.SEARCH)
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          child: Badge(
                                            backgroundColor:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.secondaryFixed,
                                            label: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Icon(
                                                  Icons.star,
                                                  size: 10,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 3),
                                                Text(
                                                  "Pesquisa",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  title: Row(
                                    children: [
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            ad.product.name,
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      if (ad.highlight.isNotEmpty)
                                        Tooltip(
                                          message: ad.highlight,
                                          showDuration: const Duration(
                                            seconds: 7,
                                          ),
                                          triggerMode: TooltipTriggerMode.tap,
                                          preferBelow: false,
                                          child: const Icon(Icons.info_outline),
                                        ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Preço: ${ad.price}"),
                                      Text("Categoria: ${ad.product.category}"),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isEditingAd = true;
                                        _currentAd = ad;
                                      });
                                    },
                                    icon: Icon(Icons.edit),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) => Divider(),
                            ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
  }
}

class EditAdSection extends StatefulWidget {
  final ProductAd ad;
  final Function(ProductAd) onSave;
  final VoidCallback onCancel;

  const EditAdSection({
    super.key,
    required this.ad,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<EditAdSection> createState() => _EditAdSectionState();
}

class _EditAdSectionState extends State<EditAdSection> {
  late TextEditingController nameController;
  late TextEditingController descController;
  late TextEditingController priceController;
  late String category;
  late List<ImageProvider?> images;
  late TextEditingController stockController;
  late TextEditingController minQtyController;
  late String unit;
  late bool isSearch;
  late bool isVisible;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.ad.product.name);
    descController = TextEditingController(text: widget.ad.description);
    priceController = TextEditingController(
      text: widget.ad.product.price?.toStringAsFixed(2),
    );
    category = widget.ad.product.category;
    unit = widget.ad.product.unit.toDisplayString();

    images = List.generate(6, (i) {
      if (i < widget.ad.product.imageUrl.length) {
        return imageProviderFromPath(widget.ad.product.imageUrl[i]);
      }
      return null;
    });

    stockController = TextEditingController(
      text: widget.ad.product.stock?.toString() ?? "0",
    );
    minQtyController = TextEditingController(
      text: widget.ad.product.minAmount?.toString() ?? "0",
    );
    unit = widget.ad.product.unit.toDisplayString();

    // Initialize isSearch based on the current ad's highlight type
    isSearch = widget.ad.highlightType == HighlightType.SEARCH;
    isVisible = widget.ad.visibility == AdVisibility.PUBLIC;
  }

  Widget imageBox(int index) {
    return GestureDetector(
      onTap: () {
        ImagePicker().pickImage(source: ImageSource.gallery).then((pickedFile) {
          if (pickedFile != null) {
            setState(() {
              images[index] = FileImage(File(pickedFile.path));
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${index + 1}ª imagem selecionada')),
            );
          }
        });
      },
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.grey[200],
        ),
        child:
            images[index] != null
                ? Image(
                  image: images[index]!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                )
                : Icon(Icons.add_a_photo, color: Colors.grey[600]),
      ),
    );
  }

  ImageProvider? imageProviderFromPath(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else if (path.startsWith('assets/')) {
      return AssetImage(path);
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return FileImage(file);
      } else {
        return AssetImage(path);
      }
    }
  }

  void _save() {
    double? newPrice = double.tryParse(priceController.text);
    if (newPrice == null || newPrice <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preço inválido.')));
      return;
    }

    int? newStock = int.tryParse(stockController.text);
    if (newStock == null || newStock < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Stock inválido.')));
      return;
    }

    int? newMinQty = int.tryParse(minQtyController.text);
    if (newMinQty == null || newMinQty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantidade mínima inválida.')),
      );
      return;
    }

    widget.ad.description = descController.text;
    widget.ad.product.price = newPrice;
    widget.ad.product.category = category;

    widget.ad.product.stock = newStock;
    widget.ad.product.minAmount = newMinQty;
    widget.ad.product.unit = unit == "Kg" ? Unit.KG : Unit.UNIT;

    widget.ad.product.imageUrl.clear();
    for (var image in images) {
      if (image != null) {
        if (image is FileImage) {
          widget.ad.product.imageUrl.add(image.file.path);
        } else if (image is NetworkImage) {
          widget.ad.product.imageUrl.add(image.url);
        } else if (image is AssetImage) {
          widget.ad.product.imageUrl.add(image.assetName);
        }
      }
    }

    // Atualiza o tipo de destaque conforme o valor de isSearch
    widget.ad.highlightType =
        isSearch ? HighlightType.SEARCH : HighlightType.HOME;

    widget.onSave(widget.ad);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.secondaryFixed,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          widget.ad.product.imageUrl.first,
                          width: 75,
                          height: 75,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (widget.ad.highlightType == HighlightType.HOME)
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Badge(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondaryFixed,
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.star, size: 10, color: Colors.white),
                                SizedBox(width: 3),
                                Text(
                                  "Inicio",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (widget.ad.highlightType == HighlightType.SEARCH)
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Badge(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondaryFixed,
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.star, size: 10, color: Colors.white),
                                SizedBox(width: 3),
                                Text(
                                  "Pesquisa",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.ad.product.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.ad.highlight.isNotEmpty)
                              Tooltip(
                                message: widget.ad.highlight,
                                showDuration: const Duration(seconds: 7),
                                triggerMode: TooltipTriggerMode.tap,
                                preferBelow: false,
                                child: const Icon(Icons.info_outline, size: 18),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Preço: ${widget.ad.price}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          "Categoria: ${widget.ad.product.category}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Editar Anúncio",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed:
                          () => showDialog(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  content: Text(
                                    "Tem a certeza que pretende eliminar este anúncio?",
                                  ),
                                  title: Text("Aviso"),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      child: Text("Não"),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      child: Text("Sim"),
                                    ),
                                  ],
                                ),
                          ),
                      icon: Icon(Icons.delete, color: Colors.red),
                    ),
                    const SizedBox(width: 15),
                    (isVisible)
                        ? IconButton(
                          onPressed: () => setState(() => isVisible = false),
                          icon: Icon(Icons.visibility, color: Colors.blue),
                        )
                        : IconButton(
                          onPressed: () => setState(() => isVisible = true),
                          icon: Icon(Icons.visibility_off, color: Colors.blue),
                        ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome Produto'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Preço (€)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),

            TextField(
              controller: stockController,
              decoration: InputDecoration(labelText: 'Stock ($unit)'),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 8),

            Text("Unidade de medida:"),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Kg", style: TextStyle(fontSize: 12)),
                    value: "Kg",
                    groupValue: unit,
                    onChanged: (val) => setState(() => unit = val!),
                    dense: true,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      "Unidade",
                      style: TextStyle(fontSize: 12),
                    ),
                    value: "Unidade(s)",
                    groupValue: unit,
                    onChanged: (val) => setState(() => unit = val!),
                    dense: true,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text("Quantidade mínima:", style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 5),
            TextField(
              controller: minQtyController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 12),

            Text("Imagens do produto:", style: const TextStyle(fontSize: 13)),
            Align(child: Wrap(children: List.generate(6, (i) => imageBox(i)))),

            const SizedBox(height: 20),

            Text(
              "Escolha a forma de destaque:",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.secondaryFixed,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Para o topo da página de pesquisa",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Checkbox(
                                    shape: const CircleBorder(),
                                    value: isSearch,
                                    onChanged: (val) {
                                      setState(() {
                                        isSearch = !isSearch;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Com este destaque, o anúncio sobe de posição relativamente a anúncio semelhantes que não têm qualquer destaque.",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.secondaryFixed,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Top de anúncios, destaque na página inicial",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Checkbox(
                                    shape: const CircleBorder(),
                                    value: !isSearch,
                                    onChanged: (val) {
                                      setState(() {
                                        isSearch = !isSearch;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Com este destaque, o anúncio vai ser apresentado rotativamente na página inicial de consumidores, antes mesmo de iniciarem a sua pesquisa, colocando também o embelema de 'TOP' na foto do anúncio de forma a apelar mais à atenção dos consumidores.",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text("Cancelar"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: _save,
                  child: const Text("Guardar"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
