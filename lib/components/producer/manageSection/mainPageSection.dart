import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:harvestly/core/services/other/manage_section_notifier.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/models/offer.dart';
import '../../../core/models/producer_user.dart';
import '../../../core/models/product.dart';
import '../../../core/models/product_ad.dart';
import '../../../core/models/store.dart';
import '../../../core/services/auth/auth_notifier.dart';
import '../../../core/services/auth/store_service.dart';
import '../../../core/services/other/bottom_navigation_notifier.dart';
import '../../../utils/categories.dart';
import '../../../utils/keywords.dart';
import '../../create_store.dart';

class MainPageSection extends StatefulWidget {
  MainPageSection({super.key});

  @override
  State<MainPageSection> createState() => _MainPageSectionState();
}

class _MainPageSectionState extends State<MainPageSection> {
  late Store store;
  late AuthNotifier authProvider;

  bool _isEditingAd = false;
  ProductAd? _currentAd;

  late TextEditingController nameController;
  late TextEditingController sloganController;
  late TextEditingController descriptionController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController municipalityController;
  LatLng? coordinates;

  File? profileImageFile;
  File? backgroundImageFile;

  bool _isLoading = false;
  bool _dataChanged = false;
  bool lowStock = false;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthNotifier>(context, listen: false);
    store =
        (authProvider.currentUser as ProducerUser).stores[authProvider
            .selectedStoreIndex!];

    nameController = TextEditingController(text: store.name ?? '');
    sloganController = TextEditingController(text: store.slogan ?? '');
    descriptionController = TextEditingController(
      text: store.description ?? '',
    );
    addressController = TextEditingController(text: store.address ?? '');
    cityController = TextEditingController(text: store.city ?? '');
    municipalityController = TextEditingController(
      text: store.municipality ?? '',
    );
    coordinates = store.coordinates;

    profileImageFile = null;
    backgroundImageFile = null;
  }

  Future<void> _pickImage(bool isProfile) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isProfile) {
          profileImageFile = File(picked.path);
        } else {
          backgroundImageFile = File(picked.path);
        }
        setState(() => _dataChanged = true);
        ;
      });
    }
  }

  Future<void> _submitChanges() async {
    setState(() => _isLoading = true);

    try {
      String? profileUrl;
      String? backgroundUrl;

      if (profileImageFile != null) {
        profileUrl = await Provider.of<StoreService>(
          context,
          listen: false,
        ).updateProfileImage(profileImageFile!, store.id);
      }

      if (backgroundImageFile != null) {
        backgroundUrl = await Provider.of<StoreService>(
          context,
          listen: false,
        ).updateBackgroundImage(backgroundImageFile!, store.id);
      }

      await Provider.of<StoreService>(context, listen: false).updateStoreData(
        name: nameController.text.trim(),
        slogan: sloganController.text.trim(),
        description: descriptionController.text.trim(),
        address: addressController.text.trim(),
        city: cityController.text.trim(),
        municipality: municipalityController.text.trim(),
        coordinates: coordinates,
        profileImageUrl: profileUrl,
        backgroundImageUrl: backgroundUrl,
        storeId: store.id,
      );

      await Provider.of<StoreService>(context, listen: false).loadStores();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alterações guardadas com sucesso')),
      );
      setState(() => _dataChanged = false);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao guardar alterações: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isEditingAd
        ? EditAdSection(
          storeId: store.id,
          ad: _currentAd!,
          onCancel: () => setState(() => _isEditingAd = false),
          onSave: (val) {},
          lowStock: lowStock,
        )
        : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 250,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    backgroundImageFile != null
                        ? Image.file(
                          backgroundImageFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 180,
                        )
                        : (store.backgroundImageUrl != null
                            ? Image.network(
                              store.backgroundImageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 180,
                            )
                            : Image.asset(
                              "assets/images/background_logo.png",
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 180,
                            )),

                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.photo,
                            size: 25,
                            color: Colors.black87,
                          ),
                        ),
                        onPressed: () => _pickImage(false),
                      ),
                    ),

                    Positioned(
                      top: 100,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.secondaryFixed,
                                  width: 1,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage:
                                    profileImageFile != null
                                        ? FileImage(profileImageFile!)
                                        : (store.imageUrl != null
                                            ? NetworkImage(store.imageUrl!)
                                            : AssetImage(
                                                  "assets/images/default_store.jpg",
                                                )
                                                as ImageProvider),
                              ),
                            ),

                            Positioned(
                              bottom: -20,
                              right: 0,
                              child: IconButton(
                                icon: Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 25,
                                    color: Colors.black87,
                                  ),
                                ),
                                onPressed: () => _pickImage(true),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Nome',
                            labelStyle: TextStyle(fontSize: 16),
                          ),
                          onChanged: (val) {
                            setState(() => setState(() => _dataChanged = true));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: sloganController,
                        decoration: InputDecoration(labelText: 'Slogan'),
                        maxLength: 40,
                        onChanged: (val) {
                          setState(() => _dataChanged = true);
                        },
                      ),
                    ),
                  ],
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
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Descrição'),
                      maxLines: 3,
                      onChanged: (val) {
                        setState(() => _dataChanged = true);
                        ;
                      },
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Localização",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "${municipalityController.text}, ${cityController.text}, ${addressController.text}",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton.icon(
                  icon: const Icon(Icons.map),
                  label: const Text("Selecionar Localização no Mapa"),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => MapPageProducer(
                              initialPosition: coordinates,
                              onLocationSelected: (position, placemark) {
                                setState(() {
                                  coordinates = position;
                                  addressController.text =
                                      placemark.street ?? '';
                                  cityController.text =
                                      placemark.locality ?? '';
                                  municipalityController.text =
                                      placemark.subAdministrativeArea ?? '';
                                  setState(() => _dataChanged = true);
                                  ;
                                });
                              },
                            ),
                      ),
                    );
                  },
                ),
              ),

              if (_dataChanged)
                (_isLoading)
                    ? Center(child: CircularProgressIndicator())
                    : Center(
                      child: ElevatedButton(
                        onPressed: _submitChanges,
                        child: Text("Guardar alterações"),
                      ),
                    ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: const Text(
                            "Canais de venda",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 160),
                          child: TextButton(
                            onPressed:
                                () => Provider.of<ManageSectionNotifier>(
                                  context,
                                  listen: false,
                                ).setIndex(13),
                            child: const Text(
                              "Definir Canais de venda",
                              style: TextStyle(fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 10,
                      children:
                          store.preferredDeliveryMethod.map((method) {
                            IconData icon = method.toIcon();
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
                          }).toList(),
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
                    Consumer<AuthNotifier>(
                      builder: (context, auth, _) {
                        final store =
                            (auth.currentUser as ProducerUser).stores[auth
                                .selectedStoreIndex!];
                        final ads = store.productsAds ?? [];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: const Text(
                                    "Anúncios publicados",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 150),
                                  child: TextButton.icon(
                                    onPressed: () {
                                      Provider.of<BottomNavigationNotifier>(
                                        context,
                                        listen: false,
                                      ).setIndex(2);
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text(
                                      "Novo anúncio",
                                      style: TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ads.isEmpty
                                ? const Text(
                                  "Ainda não há anúncios publicados.",
                                )
                                : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: ads.length,
                                  itemBuilder: (context, index) {
                                    final ad = ads[index];
                                    final stockLow =
                                        ad.stockChangedDate != null &&
                                        DateTime.now()
                                                .difference(
                                                  ad.stockChangedDate!,
                                                )
                                                .inDays >
                                            2;

                                    return ListTile(
                                      onTap: () {
                                        setState(() {
                                          _isEditingAd = true;
                                          _currentAd = ad;
                                          lowStock = stockLow;
                                        });
                                      },
                                      leading: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Opacity(
                                              opacity:
                                                  ad.visibility == false
                                                      ? 0.3
                                                      : 1.0,
                                              child: Image.network(
                                                ad.product.imageUrls.first,
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),

                                          if (ad.visibility == false)
                                            Positioned(
                                              top: 25,
                                              left: 25,
                                              child: Icon(
                                                Icons.visibility_off,
                                                size: 30,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surface
                                                    .withValues(alpha: 0.8),
                                              ),
                                            ),

                                          if (ad.highlightType ==
                                              HighlightType.HOME)
                                            Positioned(
                                              top: 0,
                                              left: 0,
                                              child: Badge(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .secondaryFixed,
                                                label: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
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
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .secondaryFixed,
                                                label: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
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
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                              triggerMode:
                                                  TooltipTriggerMode.tap,
                                              preferBelow: false,
                                              child: const Icon(
                                                Icons.info_outline,
                                              ),
                                            ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Preço: ${ad.price}€ p/ ${ad.product.unit.toDisplayString()}",
                                          ),
                                          Text(
                                            "Categoria: ${ad.product.category}",
                                          ),
                                        ],
                                      ),
                                      trailing:
                                          (stockLow)
                                              ? Tooltip(
                                                message:
                                                    "Stock estagnado há mais de 2 dias. Considere promover este anúncio.",
                                                child: Icon(
                                                  Icons.warning_amber_rounded,
                                                  color: Colors.red,
                                                ),
                                              )
                                              : null,
                                    );
                                  },
                                  separatorBuilder:
                                      (context, index) => const Divider(),
                                ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
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
  final String storeId;
  final ProductAd ad;
  final Function(ProductAd) onSave;
  final VoidCallback onCancel;
  final bool lowStock;

  const EditAdSection({
    super.key,
    required this.storeId,
    required this.ad,
    required this.onSave,
    required this.onCancel,
    required this.lowStock,
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
  HighlightType? highlightType;
  bool _isLoading = false;
  bool _isRemoving = false;
  DateTime? highlightDate;
  bool _dataChanged = false;
  bool _stockChanged = false;
  Set<String> _selectedKeywords = {};

  @override
  void initState() {
    super.initState();
    _selectedKeywords = widget.ad.keywords?.toSet() ?? {};
    highlightType = widget.ad.highlightType;
    highlightDate = widget.ad.highlightDate;
    nameController = TextEditingController(text: widget.ad.product.name);
    descController = TextEditingController(text: widget.ad.description);
    priceController = TextEditingController(
      text: widget.ad.product.price.toStringAsFixed(2),
    );
    category = widget.ad.product.category;
    unit = widget.ad.product.unit.toDisplayString();

    images = List.generate(6, (i) {
      if (i < widget.ad.product.imageUrls.length) {
        return imageProviderFromPath(widget.ad.product.imageUrls[i]);
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

    isSearch = widget.ad.highlightType == HighlightType.SEARCH;
    if (widget.ad.highlightType == null) isSearch = false;
    isVisible = widget.ad.visibility == true;
    print(widget.ad.updatedAt);
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
            setState(() => _dataChanged = true);
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

  Future<void> _save() async {
    setState(() => _isLoading = true);
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
    if (widget.ad.product.stock != newStock)
      setState(() => _stockChanged = true);
    widget.ad.description = descController.text;
    widget.ad.product.price = newPrice;
    widget.ad.product.name = nameController.text;
    widget.ad.product.category = category;
    widget.ad.visibility = isVisible;

    widget.ad.product.stock = newStock;
    widget.ad.product.minAmount = newMinQty;
    widget.ad.product.unit = unit == "Kg" ? Unit.KG : Unit.UNIT;
    widget.ad.highlightType = highlightType;
    widget.ad.highlightDate = highlightDate;

    widget.ad.product.imageUrls.clear();
    widget.ad.keywords = _selectedKeywords.toList();
    for (var image in images) {
      if (image != null) {
        if (image is FileImage) {
          widget.ad.product.imageUrls.add(image.file.path);
        } else if (image is NetworkImage) {
          widget.ad.product.imageUrls.add(image.url);
        } else if (image is AssetImage) {
          widget.ad.product.imageUrls.add(image.assetName);
        }
      }
    }

    widget.onSave(widget.ad);
    await Provider.of<StoreService>(
      context,
      listen: false,
    ).editProductAd(widget.ad, widget.storeId, _stockChanged);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Anúncio editado com sucesso')));
    setState(() => _isLoading = false);
  }

  Future<void> deleteAd(String storeId, String adId) async {
    await Provider.of<AuthNotifier>(
      context,
      listen: false,
    ).deleteProductAd(storeId, adId);
  }

  Future<void> sendOffer(String discount) async {
    await AuthService().sendOffer(discount, widget.ad.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Promoção de $discount aplicada!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void showPromotionDialog() {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_offer,
                  color: Theme.of(context).colorScheme.primary,
                  size: 40,
                ),
                SizedBox(height: 12),
                Text(
                  "Escolha o desconto para a promoção",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 3;
                        double minButtonWidth = 120;
                        if (constraints.maxWidth < 3 * minButtonWidth) {
                          crossAxisCount = (constraints.maxWidth ~/
                                  minButtonWidth)
                              .clamp(1, 3);
                        }
                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.2,
                          children:
                              DiscountValue.values.map((discount) {
                                return ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.secondary,
                                    foregroundColor: Colors.white,
                                    shape: StadiumBorder(),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 10,
                                    ),
                                  ),
                                  icon: Image.asset(
                                    discount.imagePath,
                                    width: 32,
                                    height: 32,
                                  ),
                                  label: Text(
                                    "${discount.toDisplayString()}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.tertiaryFixed,
                                    ),
                                  ),
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder:
                                          (ctx) => AlertDialog(
                                            title: Text("Confirmar promoção"),
                                            content: Text(
                                              "Tem a certeza que pretende aplicar a promoção de ${discount.toDisplayString()} neste anúncio?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.of(
                                                      ctx,
                                                    ).pop(false),
                                                child: Text("Cancelar"),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.of(
                                                      ctx,
                                                    ).pop(true),
                                                child: Text("Sim"),
                                              ),
                                            ],
                                          ),
                                    );
                                    if (confirmed == true) {
                                      Navigator.pop(context);
                                      await sendOffer(
                                        discount.toDisplayString(),
                                      );
                                    }
                                  },
                                );
                              }).toList(),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Voltar"),
                ),
              ],
            ),
          );
        },
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.lowStock)
              Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.10),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 32,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Stock estagnado há mais de 2 dias",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Quer publicar uma promoção para este anúncio?",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.white,
                        shape: StadiumBorder(),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                      ),
                      onPressed: showPromotionDialog,
                      icon: Icon(Icons.local_offer, size: 18),
                      label: Text(
                        "Promover",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
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
                        child: Image.network(
                          widget.ad.product.imageUrls.first,
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
                          "Preço: ${widget.ad.price}/${widget.ad.product.unit.toDisplayString()}",
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
                                    (_isRemoving)
                                        ? Center(
                                          child: CircularProgressIndicator(),
                                        )
                                        : TextButton(
                                          onPressed: () async {
                                            setState(() => _isRemoving = true);
                                            await deleteAd(
                                              widget.storeId,
                                              widget.ad.id,
                                            );
                                            setState(() => _isRemoving = false);
                                            Navigator.of(context).pop();
                                            widget.onCancel();
                                          },
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
                          onPressed:
                              () => setState(() {
                                _dataChanged = true;
                                isVisible = false;
                              }),
                          icon: Icon(Icons.visibility, color: Colors.blue),
                        )
                        : IconButton(
                          onPressed:
                              () => setState(() {
                                _dataChanged = true;
                                isVisible = true;
                              }),
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
              onChanged: (_) {
                _dataChanged = true;
              },
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: null,
              onChanged: (_) {
                _dataChanged = true;
              },
            ),
            DropdownButtonFormField<String>(
              value: category,
              items:
                  Categories.categories
                      .map(
                        (m) => DropdownMenuItem(
                          child: Text(m.name),
                          value: m.name,
                        ),
                      )
                      .toList(),
              onChanged:
                  (val) => setState(() {
                    _dataChanged = true;
                    category = val!;
                  }),
              decoration: InputDecoration(labelText: "Categoria"),
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiaryFixed,
              ),
              dropdownColor: Theme.of(context).colorScheme.secondary,
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Preço (€)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) {
                _dataChanged = true;
              },
            ),

            TextField(
              controller: stockController,
              decoration: InputDecoration(labelText: 'Stock ($unit)'),
              keyboardType: TextInputType.number,
              onChanged: (_) {
                setState(() {
                  _dataChanged = true;
                });
              },
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
                    onChanged:
                        (val) => setState(() {
                          _dataChanged = true;
                          unit = val!;
                        }),
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
                    onChanged:
                        (val) => setState(() {
                          _dataChanged = true;
                          unit = val!;
                        }),
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
              onChanged: (_) {
                _dataChanged = true;
              },
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
                                    value:
                                        highlightType == HighlightType.SEARCH,
                                    onChanged: (val) {
                                      setState(() {
                                        _dataChanged = true;
                                        highlightDate = DateTime.now();
                                        if (highlightType ==
                                            HighlightType.SEARCH) {
                                          highlightType = null;
                                        } else {
                                          highlightType = HighlightType.SEARCH;
                                        }
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
                                    value: highlightType == HighlightType.HOME,
                                    onChanged: (val) {
                                      setState(() {
                                        _dataChanged = true;
                                        highlightDate = DateTime.now();
                                        if (highlightType ==
                                            HighlightType.HOME) {
                                          highlightType = null;
                                        } else {
                                          highlightType = HighlightType.HOME;
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Com este destaque, o anúncio vai ser apresentado rotativamente na página inicial de consumidores...",
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

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  Keywords.keywords.map((keyword) {
                    final isSelected = _selectedKeywords.contains(keyword.name);
                    return FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            keyword.icon,
                            size: 18,
                            color:
                                isSelected
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(
                                      context,
                                    ).colorScheme.tertiaryFixed,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            keyword.name,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(
                                        context,
                                      ).colorScheme.tertiaryFixed,
                            ),
                          ),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _dataChanged = true;
                          if (selected) {
                            _selectedKeywords.add(keyword.name);
                          } else {
                            _selectedKeywords.remove(keyword.name);
                          }
                        });
                      },
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      selectedColor: Theme.of(context).colorScheme.surface,
                      checkmarkColor: Theme.of(context).colorScheme.secondary,
                    );
                  }).toList(),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text("Cancelar"),
                ),
                const SizedBox(width: 10),
                (_isLoading)
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        foregroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: _dataChanged ? _save : null,
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
