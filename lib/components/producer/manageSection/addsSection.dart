import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/product.dart';
import '../../../core/models/product_ad.dart';
import '../../../core/services/auth/auth_service.dart';
import '../../../core/services/other/manage_section_notifier.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../components/producer/sell_page.dart';
import 'package:image_picker/image_picker.dart';

class AddsSection extends StatefulWidget {
  const AddsSection({super.key});

  @override
  State<AddsSection> createState() => _AddsSectionState();
}

class _AddsSectionState extends State<AddsSection> {
  final List<ProductAd> adds = AuthService().currentUser!.store!.productsAds!;
  bool isEditing = false;
  ProductAd? selectedAd;

  void _editAd(ProductAd ad) {
    setState(() {
      isEditing = true;
      selectedAd = ad;
    });
    
}

  void _highlightAd(ProductAd ad) {
    String? selectedHighlight = ad.highlight;
    showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Escolha o tipo de destaque:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              RadioListTile<String>(
                title: const Text("Destaque para o topo da página de pesquisa"),
                value: "Destaque: topo da pesquisa",
                groupValue: selectedHighlight,
                onChanged: (val) => setState(() => selectedHighlight = val),
              ),
              RadioListTile<String>(
                title: const Text("Destaque na top de anúncios (Página Inicial)"),
                value: "Destaque: página inicial",
                groupValue: selectedHighlight,
                onChanged: (val) => setState(() => selectedHighlight = val),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedHighlight != null) {
                setState(() {
                  ad.highlight = selectedHighlight!;
                });
              }
              Navigator.of(context).pop();
            },
            child: const Text('Confirmar'),
          ),
        ],
      );
    },
  );
}

  void _deleteAd(ProductAd ad) {
    setState(() {
      adds.remove(ad);
    });
  }

  Widget buildImageFromPath(String? path, {
  double? width,
  double? height,
  BoxFit? fit,
  Widget? placeholder,
}) {
  if (path == null || path.isEmpty) {
    return placeholder ??
        Container(
          color: Colors.grey[300],
          child: const Icon(Icons.image, size: 40),
        );
  }

  if (path.startsWith('http')) {
    return Image.network(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) =>
          placeholder ??
          Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 40),
          ),
    );
  }

  if (path.startsWith('assets/')) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) =>
          placeholder ??
          Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 40),
          ),
    );
  }
  final file = File(path);
  if (file.existsSync()) {
    return Image.file(
      file,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) =>
          placeholder ??
          Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 40),
          ),
    );
  } else {
    return placeholder ??
        Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 40),
        );
  }
}

  @override
Widget build(BuildContext context) {
  if (isEditing && selectedAd != null) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: EditAdSection(
        ad: selectedAd!,
        onSave: (updatedAd) {
          final index = adds.indexWhere((a) => a.id == updatedAd.id);
          setState(() {
            adds[index] = updatedAd;
            isEditing = false;
            selectedAd = null;
          });
        },
        onCancel: () {
          setState(() {
            isEditing = false;
            selectedAd = null;
          });
        },
      ),
    );
  }

  return SingleChildScrollView(
    child: Column(
      children: adds.map(_buildAdCard).toList(),
    ),
  );
}


  Widget _buildAdCard(ProductAd ad) {
    final product = ad.product;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: buildImageFromPath(
  ad.product.imageUrl.isNotEmpty ? ad.product.imageUrl.first : null,
  width: 70,
  height: 70,
  fit: BoxFit.cover,
  placeholder: Container(
    width: 70,
    height: 70,
    color: Colors.grey[300],
    child: const Icon(Icons.image, size: 40),
  ),
),
            ),
            const SizedBox(width: 12),
            // detalhes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  if(ad.highlight.isNotEmpty && ad.highlight != "Este anúncio não está em destaque!")
                    Row(
                      children: [
                        const Icon(FontAwesomeIcons.solidStar, color: Colors.amber, size: 12),
                        const SizedBox(width: 4),
                        Flexible(child: Text(ad.highlight, style: const TextStyle(color: Colors.amber, fontSize: 12))),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Text("${ad.product.price} €/${ad.product.unit.toDisplayString()}"),
                  Text(product.category, style: TextStyle(fontSize: 12, color: const Color.fromARGB(255, 107, 107, 107))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _actionButton('Editar', () => _editAd(ad)),
                      const SizedBox(width: 6),
                      _actionButton('Destacar', () => _highlightAd(ad)),
                      const SizedBox(width: 6),
                      _actionButton('Apagar', () => _deleteAd(ad)),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, VoidCallback onPressed) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)), 
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
  late TextEditingController descController;
  late TextEditingController priceController;
  late String category;
  late List<ImageProvider?> images;
  late TextEditingController stockController;
  late TextEditingController minQtyController;
  late String unit;

  @override
  void initState() {
    super.initState();
    descController = TextEditingController(text: widget.ad.description);
    priceController = TextEditingController(text: widget.ad.product.price?.toStringAsFixed(2));
    category = widget.ad.product.category;
    unit = widget.ad.product.unit.toDisplayString();
    
    images = List.generate(6, (i) {
  if (i < widget.ad.product.imageUrl.length) {
    return imageProviderFromPath(widget.ad.product.imageUrl[i]);
  }
  return null;
});

    stockController = TextEditingController(text: widget.ad.product.stock?.toString() ?? "0");
    minQtyController = TextEditingController(text: widget.ad.product.minAmount?.toString() ?? "0");
    unit = widget.ad.product.unit.toDisplayString();


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
      child: images[index] != null
          ? Image(image: images[index]!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),)
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preço inválido.')),
    );
    return;
  }

  int? newStock = int.tryParse(stockController.text);
  if (newStock == null || newStock < 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stock inválido.')),
    );
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

  widget.onSave(widget.ad);
}

  @override
  Widget build(BuildContext context) {
    return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text("Editar Anúncio", style: Theme.of(context).textTheme.headlineSmall),
    TextField(controller: descController, decoration: const InputDecoration(labelText: 'Descrição')),
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
            title: const Text("Unidade", style: TextStyle(fontSize: 12)),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: TextInputType.number,
    ),

    const SizedBox(height: 12),

    Wrap(
      children: List.generate(6, (i) => imageBox(i)),
    ),

    const SizedBox(height: 20),

    Row(
      children: [
        ElevatedButton(onPressed: _save, child: const Text("Guardar")),
        const SizedBox(width: 10),
        OutlinedButton(onPressed: widget.onCancel, child: const Text("Cancelar")),
      ],
    )
  ],
);
  }
}