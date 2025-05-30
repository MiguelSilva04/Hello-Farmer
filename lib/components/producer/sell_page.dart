import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:harvestly/core/services/other/bottom_navigation_notifier.dart';
import 'package:harvestly/core/services/other/manage_section_notifier.dart';
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
  String? location;
  List<String> deliveryOptions = [];
  String? unit = 'Kg';
  String? qty;
  String? price;
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
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios.'),
        ),
      );
    } else if (images.every((image) => image == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, adicione pelo menos uma imagem.')),
      );
      return;
    } else if (category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecione uma categoria.')),
      );
      return;
    } else if (deliveryOptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, selecione pelo menos uma opção de entrega.',
          ),
        ),
      );
      return;
    } else {
      _formKey.currentState!.save();
      setState(() {
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
    return Column(
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
                    color: Theme.of(context).colorScheme.onInverseSurface,
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
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 30,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: activeImages[index]!,
                                        fit: BoxFit.cover,
                                      ),
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
                              margin: const EdgeInsets.symmetric(horizontal: 4),
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

              Text(
                title ?? "Sem titulo",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.surface,
                ),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onTertiary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  location ?? 'Sem Localização',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiaryFixed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

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
    );
  }

  Container getMainScreen(BuildContext context) {
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
                TextFormField(
                  decoration: InputDecoration(labelText: "Título do anúncio"),
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

                TextFormField(
                  decoration: InputDecoration(labelText: "Descrição"),
                  initialValue: description,
                  maxLines: 4,
                  maxLength: 10000,
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
                  items: [
                    DropdownMenuItem(value: "Fruta", child: Text("Fruta")),
                    DropdownMenuItem(value: "Legumes", child: Text("Legumes")),
                    DropdownMenuItem(value: "Ervas", child: Text("Ervas")),
                    DropdownMenuItem(value: "Flores", child: Text("Flores")),
                  ],
                  onChanged: (val) => setState(() => category = val),
                  decoration: InputDecoration(
                    labelText: "Selecione uma categoria",
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.tertiaryFixed,
                  ),
                  dropdownColor: Theme.of(context).colorScheme.secondary,
                ),

                SizedBox(height: 16),
                Text(
                  "Localização:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Freguesia ou código postal",
                  ),
                  onChanged: (val) => location = val,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "A localização não pode estar vazia.";
                    }
                    if (val.length < 3) {
                      return "A localização deve ter pelo menos 3 caracteres.";
                    }
                    return null;
                  },
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
                        value: (AuthService().currentUser! as ProducerUser)
                            .store
                            .preferredDeliveryMethod!
                            .contains(method),
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                ),

                // CheckboxListTile(
                //   title: Text("Entrega ao domicílio"),
                //   value: deliveryOptions.contains("Entrega ao domicílio"),
                //   onChanged:
                //       (val) => toggleDelivery("Entrega ao domicílio", val!),
                // ),
                // CheckboxListTile(
                //   title: Text("Recolha num local à escolha"),
                //   value: deliveryOptions.contains(
                //     "Recolha num local à escolha",
                //   ),
                //   onChanged:
                //       (val) =>
                //           toggleDelivery("Recolha num local à escolha", val!),
                // ),
                // CheckboxListTile(
                //   title: Text("Entrega por transportadora"),
                //   value: deliveryOptions.contains("Entrega por transportadora"),
                //   onChanged:
                //       (val) =>
                //           toggleDelivery("Entrega por transportadora", val!),
                // ),
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
                      child: TextFormField(
                        decoration: InputDecoration(labelText: "Preço (€)"),
                        initialValue: price,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
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
                      ),
                    ),
                    SizedBox(width: 5),
                    Flexible(
                      flex: 3,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "Stock (${unit})",
                        ),
                        initialValue: price,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (val) => price = val,
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
                  decoration: InputDecoration(labelText: "Nome"),
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
                  decoration: InputDecoration(labelText: "Número de telefone"),
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

                SizedBox(height: 16),
                CheckboxListTile(
                  title: Text("Publicar anúncio já destacado"),
                  value: _highlighted ?? false,
                  onChanged: (val) {
                    setState(() {
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

                SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => setState(() => _isPreviewing = true),
                          child: Text(
                            "pré-visualizar",
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inverseSurface,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                          ),
                          onPressed: () {
                            _submit();
                          },
                          child: Text(
                            "Publicar",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
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
