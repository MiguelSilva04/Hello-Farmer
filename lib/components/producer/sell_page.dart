import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:harvestly/core/services/auth/auth_notifier.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:harvestly/core/services/other/bottom_navigation_notifier.dart';
import 'package:harvestly/core/services/other/manage_section_notifier.dart';
import 'package:harvestly/utils/categories.dart';
import 'package:harvestly/utils/keywords.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../../core/models/producer_user.dart';
import '../../core/models/store.dart';

class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  State<SellPage> createState() => SellPageState();
}

class SellPageState extends State<SellPage> {
  final _formKey = GlobalKey<FormState>();
  String? title;
  String? category;
  String? description;
  List<String> deliveryOptions = [];
  String? unit = 'Kg';
  String? qty;
  String? price;
  String? stock;
  String? name;
  String? phone;
  List<ImageProvider?> images = List.generate(
    6,
    (index) => null,
    growable: true,
  );
  bool _isSubmitted = false;
  bool _isPreviewing = false;
  bool? _highlighted = false;
  String? _highlightOption;
  Set<String> _selectedKeywords = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    deliveryOptions =
        (AuthService().currentUser! as ProducerUser)
            .stores[Provider.of<AuthNotifier>(
              context,
              listen: false,
            ).selectedStoreIndex]
            .preferredDeliveryMethod
            .map((p) => p.toDisplayString())
            .toList();
  }

  void toggleDelivery(String option, bool selected) {
    setState(() {
      if (selected) {
        deliveryOptions.add(option);
      } else {
        deliveryOptions.remove(option);
      }
    });
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
    });

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios.'),
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    if (images.every((image) => image == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, adicione pelo menos uma imagem.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    if (category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecione uma categoria.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    if (deliveryOptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, selecione pelo menos uma opção de entrega.',
          ),
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    _formKey.currentState!.save();

    try {
      final selectedStore =
          (AuthService().currentUser as ProducerUser)
              .stores[Provider.of<AuthNotifier>(
            context,
            listen: false,
          ).selectedStoreIndex];

      List<File> imageFiles =
          images.whereType<FileImage>().map((image) => image.file).toList();

      await Provider.of<AuthNotifier>(context, listen: false).publishAd(
        title!,
        description!,
        imageFiles,
        category!,
        double.parse(qty!),
        unit!,
        double.parse(price!),
        int.parse(stock!),
        selectedStore.id,
        _selectedKeywords.toList(),
        _highlightOption,
      );
    } catch (e) {
      print('Erro ao publicar anúncio: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao publicar anúncio.')));
    } finally {
      setState(() {
        _isLoading = false;
        _isSubmitted = true;
      });
    }
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
      child: DashedBorderContainer(
        key: ValueKey(index),
        child:
            images[index] != null
                ? Image(image: images[index]!, fit: BoxFit.cover)
                : Icon(Icons.add_a_photo, color: Colors.grey[600]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isSubmitted
        ? getSubmittedScreen(context)
        : _isPreviewing
        ? getPreviewingScreen(context)
        : getMainScreen(context);
  }

  Widget getPreviewingScreen(BuildContext context) {
    final pageController = PageController();
    return SingleChildScrollView(
      child: Column(
        children: [
          StatefulBuilder(
            builder: (context, setState) {
              int currentPage =
                  pageController.hasClients
                      ? pageController.page?.round() ?? 0
                      : 0;
              final activeImages =
                  images.where((image) => image != null).toList();
              return Container(
                child: Center(
                  child: SizedBox(
                    height: 300,
                    child: Container(
                      width: double.infinity,
                      child: Column(
                        children: [
                          Expanded(
                            child: PageView.builder(
                              controller: pageController,
                              itemCount: activeImages.length,
                              onPageChanged: (index) {
                                setState(() {
                                  currentPage = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: activeImages[index]!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              activeImages.length,
                              (index) => Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withAlpha(
                                    index == currentPage ? 255 : 102,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(
                        AuthService().currentUser!.imageUrl,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      name ??
                          AuthService().currentUser!.firstName +
                              " " +
                              AuthService().currentUser!.lastName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Text(
                      title ?? "Sem titulo",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (_highlighted!)
                      Chip(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        label: Text(
                          _highlightOption == "topo_pesquisa" ? "TOPO" : "TOP",
                        ),
                      ),
                  ],
                ),

                Text(
                  '${price ?? "PREÇO"}€/${unit ?? "unidade"}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.inverseSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),

                if (_selectedKeywords.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        Keywords.keywords
                            .where(
                              (keyword) =>
                                  _selectedKeywords.contains(keyword.name),
                            )
                            .map(
                              (keyword) => Chip(
                                avatar: Icon(
                                  keyword.icon,
                                  size: 18,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                label: Text(
                                  keyword.name,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],

                const SizedBox(height: 12),
                Text(
                  description ?? 'SEM DESCRIÇÃO',
                  style: TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 12),

                Text(
                  'Opções de entrega:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onTertiaryFixed,
                  ),
                ),
                const SizedBox(height: 4),
                deliveryOptions.isEmpty
                    ? Text("Sem opções de entrega selecionadas")
                    : Column(
                      children:
                          deliveryOptions
                              .map(
                                (deliveryOption) => Row(
                                  children: [
                                    Icon(
                                      Icons.check,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onTertiaryFixed,
                                      size: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Text(deliveryOption),
                                  ],
                                ),
                              )
                              .toList(),
                    ),

                const SizedBox(height: 12),

                Text(
                  'Quantidade mínima: ${qty ?? "XX"} unidades',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiaryFixed,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap:
                    () => setState(() {
                      _isPreviewing = false;
                    }),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Voltar",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap:
                    () => setState(() {
                      _submit();
                      _isPreviewing = false;
                    }),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Publicar",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget customTextFormField({
    required BuildContext context,
    required String label,
    String? initialValue,
    int? maxLength,
    int? maxLines,
    TextInputType? keyboardType,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
    bool? enabled,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondaryFixed,
            width: 1,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      enabled: enabled,
      initialValue: initialValue,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
    );
  }

  Container getMainScreen(BuildContext context) {
    final selectedStoreIndex =
        Provider.of<AuthNotifier>(context, listen: false).selectedStoreIndex;
    final user = AuthService().currentUser! as ProducerUser;

    if (user.stores.isEmpty || selectedStoreIndex >= user.stores.length) {
      return Container();
    }

    final preferredMethods =
        (AuthService().currentUser! as ProducerUser).stores.length >
                selectedStoreIndex
            ? (AuthService().currentUser! as ProducerUser)
                .stores[selectedStoreIndex]
                .preferredDeliveryMethod
            : [];
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Públicar anúncio...",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.tertiaryFixed,
                  ),
                ),
                Text(
                  "Quanto mais detalhado melhor!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.tertiaryFixed,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Todos os campos são obrigatórios*",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onTertiaryFixedVariant,
                  ),
                ),
                customTextFormField(
                  context: context,
                  label: "Título do anúncio",
                  initialValue: title,
                  onChanged: (val) => title = val,
                  maxLength: 20,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "O título não pode estar vazio.";
                    }
                    if (val.length < 5) {
                      return "O título deve ter pelo menos 5 caracteres.";
                    }
                    return null;
                  },
                ),
                customTextFormField(
                  context: context,
                  initialValue: description,
                  label: "Descrição",
                  maxLines: 4,
                  maxLength: 1000,
                  onChanged: (val) => description = val,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "A descrição não pode estar vazia.";
                    }
                    if (val.length < 20) {
                      return "A descrição deve ter pelo menos 20 caracteres.";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16),
                Text(
                  "Selecione:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "A primeira imagem é a principal do anúncio, arrasta e larga as imagens para mudar as posições das mesmas",
                ),
                const SizedBox(height: 5),
                ReorderableGridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  physics: NeverScrollableScrollPhysics(),
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      print('Reordering from $oldIndex to $newIndex');
                      if (newIndex > oldIndex) newIndex--;
                      final image = images.removeAt(oldIndex);
                      images.insert(newIndex, image);
                      print('Updated images list: $images');
                    });
                  },
                  children: List.generate(
                    6,
                    (index) => KeyedSubtree(
                      key: ValueKey(index),
                      child: imageBox(index),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Categoria:",
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                  onChanged: (val) => setState(() => category = val),
                  decoration: InputDecoration(
                    labelText: "Selecione uma categoria",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondaryFixed,
                        width: 1,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.tertiaryFixed,
                  ),
                  dropdownColor: Theme.of(context).colorScheme.secondary,
                ),

                SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      "Opções de entrega:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<BottomNavigationNotifier>(
                          context,
                          listen: false,
                        ).setIndex(4);
                        Provider.of<ManageSectionNotifier>(
                          context,
                          listen: false,
                        ).setIndex(13);
                      },
                      child: Text(
                        "alterar opções",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                ...DeliveryMethod.values.map(
                  (method) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(method.toDisplayString()),
                      Checkbox(
                        value: preferredMethods.contains(method),
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Detalhes da venda:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Text(
                            "Quantidade mínima:",
                            style: TextStyle(fontSize: 13),
                          ),
                          SizedBox(height: 5),
                          TextFormField(
                            initialValue: qty,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.surface,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.surface,
                                  width: 2.5,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (val) => qty = val,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return "A quantidade mínima não pode estar vazia.";
                              }
                              if (int.tryParse(val) == null ||
                                  int.parse(val) <= 0) {
                                return "Insira um número válido maior que zero.";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 10),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Unidade de medida:"),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    "Kg",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  value: "Kg",
                                  groupValue: unit,
                                  onChanged:
                                      (val) => setState(() => unit = val),
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    "Unidade",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  value: "Unidade",
                                  groupValue: unit,
                                  onChanged:
                                      (val) => setState(() => unit = val),
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: customTextFormField(
                        context: context,
                        label: "Preço p/ ${unit} (€)",
                        initialValue: price,
                        onChanged: (val) => price = val,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "O preço não pode estar vazio.";
                          }
                          if (double.tryParse(val) == null ||
                              double.parse(val) <= 0) {
                            return "Insira um preço válido maior que zero.";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Flexible(
                      flex: 2,
                      child: customTextFormField(
                        context: context,
                        label: "Stock (${unit})",
                        initialValue: stock,
                        onChanged: (val) => stock = val,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "O stock não pode estar vazio.";
                          }
                          if (double.tryParse(val) == null ||
                              double.parse(val) <= 0) {
                            return "Insira um stock válido maior que zero.";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),
                Text(
                  "Os seus detalhes:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Nome",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondaryFixed,
                        width: 1,
                      ),
                    ),
                  ),
                  enabled: false,
                  initialValue:
                      AuthService().currentUser!.firstName +
                      " " +
                      AuthService().currentUser!.lastName,
                  onChanged: (val) => name = val,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "O nome não pode estar vazio.";
                    }
                    if (val.length < 3) {
                      return "O nome deve ter pelo menos 3 caracteres.";
                    }
                    return null;
                  },
                ),

                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Número de telefone",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondaryFixed,
                        width: 1,
                      ),
                    ),
                  ),
                  enabled: false,
                  initialValue: AuthService().currentUser!.phone,
                  keyboardType: TextInputType.phone,
                  onChanged: (val) => phone = val,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "O número de telefone não pode estar vazio.";
                    }
                    if (val.length < 9) {
                      return "O número de telefone deve ter pelo menos 9 dígitos.";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),
                Text(
                  "Localização:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                customTextFormField(
                  context: context,
                  label: "Munícipio ou Código Postal",
                  initialValue:
                      (AuthService().currentUser as ProducerUser)
                          .stores[Provider.of<AuthNotifier>(
                            context,
                            listen: false,
                          ).selectedStoreIndex]
                          .municipality,
                  enabled: false,
                  maxLength: 20,
                ),

                SizedBox(height: 16),
                CheckboxListTile(
                  title: Text("Publicar anúncio já destacado"),
                  value: _highlighted ?? false,
                  onChanged: (val) {
                    setState(() {
                      if (_highlighted == true) _selectedKeywords = {};
                      _highlighted = val ?? false;
                      if (!_highlighted!) _highlightOption = null;
                    });
                  },
                ),
                if (_highlighted ?? false)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Escolha o tipo de destaque:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      RadioListTile<String>(
                        title: Text(
                          "Destaque para o topo da página de pesquisa",
                        ),
                        value: "topo_pesquisa",
                        groupValue: _highlightOption,
                        onChanged:
                            (val) => setState(() => _highlightOption = val),
                      ),
                      RadioListTile<String>(
                        title: Text(
                          "Destaque na top de anúncios (Página Inicial)",
                        ),
                        value: "top_anuncios",
                        groupValue: _highlightOption,
                        onChanged:
                            (val) => setState(() => _highlightOption = val),
                      ),
                    ],
                  ),

                const SizedBox(height: 10),
                Text(
                  "Selecione as categorias em que o seu anúncio se enquadra:",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      Keywords.keywords.map((keyword) {
                        final isSelected = _selectedKeywords.contains(
                          keyword.name,
                        );
                        return FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                keyword.icon,
                                size: 18,
                                color:
                                    isSelected
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.secondary
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
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.secondary
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
                              if (selected) {
                                _selectedKeywords.add(keyword.name);
                              } else {
                                _selectedKeywords.remove(keyword.name);
                              }
                            });
                          },
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          selectedColor: Theme.of(context).colorScheme.surface,
                          checkmarkColor:
                              Theme.of(context).colorScheme.secondary,
                        );
                      }).toList(),
                ),

                SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!_isLoading)
                        Expanded(
                          child: TextButton(
                            onPressed:
                                () => setState(() => _isPreviewing = true),
                            child: Text(
                              "pré-visualizar",
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.inverseSurface,
                              ),
                            ),
                          ),
                        ),
                      _isLoading
                          ? Expanded(
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                              ),
                              onPressed: _submit,
                              child: Text(
                                "Publicar",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container getSubmittedScreen(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/success_icon.png", width: 120),
              Text(
                "Anúncio publicado com sucesso!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  color: Theme.of(context).colorScheme.surface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Clique em \"Ok\""
                " para voltar à página principal!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 55),
              InkWell(
                onTap:
                    () => setState(() {
                      _isSubmitted = false;
                      unit = "Kg";
                      title = null;
                      description = null;
                      images = List.generate(
                        6,
                        (index) => null,
                        growable: true,
                      );
                      qty = null;
                      stock = null;
                      price = null;
                      _selectedKeywords = {};
                      _highlighted = false;
                      category = null;
                    }),
                child: Container(
                  padding: EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "Ok",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedBorderContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final Color color;

  const DashedBorderContainer({
    super.key,
    required this.child,
    this.borderRadius = 8.0,
    this.strokeWidth = 1.0,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedBorderPainter(
        color: color,
        strokeWidth: strokeWidth,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    final path =
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Offset.zero & size,
            Radius.circular(borderRadius),
          ),
        );

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final PathMetrics metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
