import 'dart:io';
import 'package:harvestly/components/producer/store_page.dart';
import 'package:harvestly/core/models/consumer_user.dart';
import 'package:harvestly/core/models/order.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/services/other/bottom_navigation_notifier.dart';
import 'package:harvestly/core/services/other/settings_notifier.dart';
import 'package:provider/provider.dart';

import '../components/country_state_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/models/app_user.dart';
import '../core/models/product_ad.dart';
import '../core/services/auth/auth_notifier.dart';
import '../core/services/auth/auth_service.dart';
import '../core/services/chat/chat_service.dart';
import '../utils/app_routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilePage extends StatefulWidget {
  final AppUser? user;
  ProfilePage([this.user]);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  String? userName;

  bool _isEditingName = false;
  bool _isEditingPassword = false;
  bool _isLoading = false;
  bool _isButtonVisible = false;
  bool _isEditingBackgroundImage = false;
  // bool _isEditingNickname = false;
  // bool _isEditingAboutMe = false;
  bool _isEditingEmail = false;
  bool _dataChanged = false;

  String _countryCode = 'PT';
  // String? _phone;
  String? countryValue;
  String? stateValue;
  String? cityValue;

  File? _backgroundImage;
  File? _profileImage;

  // String? _errorMessage;
  // String? _currentPopUpTextMessage;
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  // final _lastNameTextController = TextEditingController();

  late AppUser? user;
  late List<Order>? orders;

  void _initStatus() async {
    final loadedUser = widget.user ?? await AuthService().getCurrentUser();
    if (loadedUser == null) return;

    setState(() {
      user = loadedUser;

      if (user!.isProducer) {
        final producer = user as ProducerUser;
        orders =
            producer.stores.isNotEmpty
                ? (producer.stores.first.orders ?? [])
                    .where((o) => o.state == OrderState.Delivered)
                    .toList()
                : [];
      } else {
        final consumer = user as ConsumerUser;
        orders =
            (consumer.orders ?? [])
                .where((o) => o.state == OrderState.Delivered)
                .toList();
      }
      userName = "${user?.firstName} ${user?.lastName}";
      final phoneParts = user?.phone.trim().split(" ");
      user?.phone = phoneParts!.isNotEmpty ? phoneParts.last : "";
    });
  }

  @override
  void initState() {
    super.initState();
    _initStatus();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxWidth: 150,
    );

    if (pickedImage != null) {
      setState(() {
        _isEditingBackgroundImage
            ? _backgroundImage = File(pickedImage.path)
            : _profileImage = File(pickedImage.path);
      });
    }
    _isEditingBackgroundImage = false;
    _isButtonVisible = true;
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pushNamedAndRemoveUntil(
                    AppRoutes.AUTH_OR_APP_PAGE,
                    (Route<dynamic> route) => false,
                  );
                  AuthService().logout();
                },
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  Widget _buildTextField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.secondary,
            border: OutlineInputBorder(borderSide: BorderSide.none),
          ),
          onChanged: (val) => setState(() => _dataChanged = true),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _customButton(
    String label,
    GestureTapCallback onTap, {
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color:
                isPrimary
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).colorScheme.secondary,
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    isPrimary
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.secondaryFixed,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {});
      return;
    }
    setState(() => _isLoading = true);
    if (_isButtonVisible &&
        !_isEditingPassword &&
        !_isEditingName &&
        !_isEditingEmail) {
      try {
        if (_profileImage != null)
          await AuthService().updateProfileImage(_profileImage);
        if (_backgroundImage != null)
          await AuthService().updateBackgroundImage(_backgroundImage);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imagem atualizado com sucesso!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar perfil: $error')),
        );
      }
    }

    // if (_isEditingEmail)
    //   await AuthService().updateSingleUserField(
    //     firstName: _textController.text,
    //     lastName: _lastNameTextController.text,
    //   );

    if (_isEditingEmail) {
      _showAlert(
        "Verificação necessária",
        "Um e-mail de confirmação irá ser enviado para ${user?.recoveryEmail}. A sua sessão irá depois disso expirar.",
      );
      await AuthService().updateSingleUserField(email: user?.recoveryEmail);
    }
    if (_isEditingPassword) {
      // criar um metodo para enviar email de recuperação para o seu email
      // await AuthService().updateSingleUserField(email: _textController.text);
      _showAlert(
        "Verificação necessária",
        "Um e-mail de recuperação irá ser enviado para o seu email, ${_textController.text}. A sua sessão irá expirar depois disso.",
      );
    }

    // if (_isEditingNickname)
    //   await AuthService().updateSingleUserField(nickname: _textController.text);
    // if (_isEditingAboutMe)
    //   await AuthService().updateSingleUserField(aboutMe: _textController.text);

    setState(() {
      _isLoading = false;
      _isEditingName = false;
      // _isEditingNickname = false;
      // _isEditingAboutMe = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: widget.user != null,
      appBar:
          widget.user == null
              ? AppBar(
                centerTitle: false,
                title: Text(
                  userName ?? "Nome de perfil",
                  style: TextStyle(fontSize: 25),
                ),
                actions: [
                  Stack(
                    children: [
                      TextButton(
                        onPressed:
                            () => setState(() => _isEditing = !_isEditing),
                        child: Text(
                          _isEditing ? "Voltar" : "Editar Perfil",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
              : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.25,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image:
                              _backgroundImage != null && user != null
                                  ? DecorationImage(
                                    image: FileImage(_backgroundImage!),
                                    fit: BoxFit.cover,
                                  )
                                  : (user!.backgroundUrl?.isNotEmpty ?? false)
                                  ? DecorationImage(
                                    image: NetworkImage(user!.backgroundUrl!),
                                    fit: BoxFit.cover,
                                  )
                                  : const DecorationImage(
                                    image: AssetImage(
                                      'assets/images/background_logo.png',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: TextButton(
                            onPressed: () {
                              _isEditingBackgroundImage = true;
                              _pickImage();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text(
                              _backgroundImage == null
                                  ? "Definir imagem"
                                  : "Mudar imagem",
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.tertiaryFixed,
                              ),
                            ),
                          ),
                        ),
                      if (_isButtonVisible)
                        Positioned(
                          bottom: 0,
                          right: 10,
                          child:
                              (_isLoading && _isEditing)
                                  ? const CircularProgressIndicator()
                                  : TextButton(
                                    onPressed: _submit,
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.surface,
                                      textStyle: const TextStyle(fontSize: 12),
                                    ),
                                    child: const Text("Guardar alterações"),
                                  ),
                        ),
                      Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.18,
                            ),
                            child: Center(
                              child: CircleAvatar(
                                radius: 80,
                                backgroundImage:
                                    _profileImage != null
                                        ? FileImage(_profileImage!)
                                        : (user!.imageUrl.isNotEmpty)
                                        ? NetworkImage(user!.imageUrl)
                                            as ImageProvider
                                        : const AssetImage(
                                          'assets/images/default_user.png',
                                        ),
                              ),
                            ),
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 5,
                              left: MediaQuery.of(context).size.width * 0.30,
                              child: CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                                child: IconButton(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.photo_camera),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _isEditing
                      ? getEditingProfile()
                      : getOnlyViewingProfile(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding getEditingProfile() {
    final phone = user!.phone.split(" ").last;
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 25),
      child: Column(
        children: [
          _buildTextField("Nome", user!.firstName + " " + user!.lastName),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Localidade",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Container(
            color: Theme.of(context).colorScheme.secondary,
            child: SelectState(
              dropdownColor: Theme.of(context).colorScheme.secondary,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.tertiaryFixed,
              ),

              onCountryChanged: (value) {
                setState(() {
                  countryValue = value;
                });
              },
              onStateChanged: (value) {
                setState(() {
                  stateValue = value;
                });
              },
              onCityChanged: (value) {
                setState(() {
                  cityValue = value;
                });
              },
            ),
          ),

          _buildTextField("Cidade", user!.city ?? ""),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Número de telefone",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 5),
          IntlPhoneField(
            initialCountryCode: _countryCode,
            initialValue: phone,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).colorScheme.secondary,
            ),
            onChanged: (phone) {
              _countryCode = phone.countryCode;
              // _phone = phone.completeNumber;
            },
          ),

          if (_dataChanged)
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Alterações guardadas com sucesso!')),
                );
                setState(() {
                  _dataChanged = false;
                });
              },
              child: const Text('Guardar Alterações'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary,
                backgroundColor: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),

          SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _customButton("Alterar E-mail", () {
                  navigateToSettings(5);
                }),
              ),
              Expanded(
                child: _customButton("Gerir dados\n de pagamento", () {
                  navigateToSettings(2);
                }, isPrimary: true),
              ),
              Expanded(
                child: _customButton("Alterar Senha", () {
                  navigateToSettings(5);
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void navigateToSettings(int index) {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(AppRoutes.SETTINGS_PAGE);
    Provider.of<SettingsNotifier>(context, listen: false).setIndex(index);
  }

  Column getOnlyViewingProfile(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${user!.firstName} ${user!.lastName} ${user!.isProducer ? "🧑‍🌾" : ""}",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            if (!user!.isProducer) Icon(FontAwesomeIcons.person),
          ],
        ),
        Text(
          '📍${user!.city}',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.secondaryFixed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user!.phone.startsWith('+351')
              ? '+351 ' +
                  user!.phone
                      .substring(5)
                      .replaceAllMapped(
                        RegExp(r'.{1,3}'),
                        (match) => '${match.group(0)} ',
                      )
                      .trim()
              : user!.phone
                  .replaceAllMapped(
                    RegExp(r'.{1,3}'),
                    (match) => '${match.group(0)} ',
                  )
                  .trim(),
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.secondaryFixed,
            fontStyle: FontStyle.italic,
          ),
        ),
        if (user!.isProducer && (user as ProducerUser).stores.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text("🏪 Bancas", style: TextStyle(fontSize: 20)),
          const SizedBox(height: 5),
          InkWell(
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (ctx) => StorePage(
                          store: (user as ProducerUser).stores.first,
                        ),
                  ),
                ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      (user as ProducerUser).stores.first.name!,
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      " 📍 ${(user as ProducerUser).stores.first.city!}",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Icon(Icons.keyboard_arrow_right_outlined),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),

        if (user!.id != AuthService().currentUser!.id)
          ElevatedButton.icon(
            // onPressed: () => _showStartChatModal(context),
            onPressed: () {},

            //  async {
            //   final TextEditingController _messageController =
            //       TextEditingController();
            //   final result = await showDialog<String>(
            //     context: context,
            //     builder:
            //         (ctx) => AlertDialog(
            //           title: Text("Enviar mensagem"),
            //           content: TextField(
            //             controller: _messageController,
            //             decoration: const InputDecoration(
            //               hintText: "Escreve a tua mensagem...",
            //             ),
            //             maxLines: null,
            //             autofocus: true,
            //           ),
            //           actions: [
            //             TextButton(
            //               onPressed: () => Navigator.of(ctx).pop(),
            //               child: const Text("Fechar"),
            //             ),
            //             TextButton(
            //               onPressed: () {
            //                 Navigator.of(
            //                   ctx,
            //                 ).pop(_messageController.text.trim());
            //               },
            //               child: const Text("Enviar"),
            //             ),
            //           ],
            //         ),
            //         if (result != null && result.isNotEmpty) {
            //             final chatService = Provider.of<ChatService>(
            //               context,
            //               listen: false,
            //             );

            //             final newChat = await chatService.createChat(
            //               isProducer ? user.id : currentUser!.id,
            //               isProducer ? currentUser!.id : user.id,
            //             );

            //             await chatService.save(
            //               result,
            //               currentUser!,
            //               newChat.id,
            //             );

            //             Navigator.of(context).pop();
            //             Navigator.of(context).pushNamed(AppRoutes.CHAT_PAGE);
            //           }
            //   );
            // },
            icon: Icon(
              Icons.message,
              color: Theme.of(context).colorScheme.secondary,
            ),
            label: const Text('Enviar mensagem'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.secondary,
              backgroundColor: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        const SizedBox(width: 16),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sobre mim',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user!.aboutMe == null || user!.aboutMe!.isEmpty
                        ? 'Ainda sem descrição...'
                        : user!.aboutMe!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.secondaryFixed,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (orders != null && orders!.isNotEmpty) ...[
                Text(
                  user!.isProducer ? "Produtos em destaque" : 'Últimas compras',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Column(
                  children:
                      orders!.map((order) {
                        final String? firstProductAdId =
                            order.ordersItems.isNotEmpty
                                ? order.ordersItems.first.produtctAdId
                                : null;

                        ProductAd? matchedProductAd;

                        if (firstProductAdId != null) {
                          for (final user in AuthService().users) {
                            if (user is ProducerUser) {
                              for (final store in user.stores) {
                                try {
                                  final productAd = store.productsAds!
                                      .firstWhere(
                                        (ad) => ad.id == firstProductAdId,
                                      );
                                  matchedProductAd = productAd;
                                  break;
                                } catch (e) {
                                  // Não encontrado nesta loja, continua
                                }
                              }
                            }

                            if (matchedProductAd != null) break;
                          }
                        }

                        final AppUser? producerUser =
                            AuthService().users
                                .where((u) => u.id == order.producerId)
                                .first;

                        final producerName =
                            '${producerUser!.firstName} ${producerUser.lastName}';
                        final producerImage = producerUser.imageUrl;

                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 8,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.asset(
                                            matchedProductAd!
                                                .product
                                                .imageUrl
                                                .first,
                                            width: 70,
                                            height: 70,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${matchedProductAd.product.name} e +${order.ordersItems.length - 1}itens",
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                'Quantidade: ${matchedProductAd.product.unit == "kg" ? order.ordersItems.first.qty.toStringAsFixed(2) : order.ordersItems.first.qty.toStringAsFixed(0)} ${matchedProductAd.product.unit}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .tertiaryFixed,
                                                ),
                                              ),
                                              Text(
                                                '${order.totalPrice.toStringAsFixed(2)}€',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .tertiaryFixed,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (user != null && !user!.isProducer)
                                    Flexible(
                                      flex: 3,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      ProfilePage(producerUser),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Produtor:",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            ClipOval(
                                              child: Image.network(
                                                producerImage,
                                                width: 35,
                                                height: 35,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (_, __, ___) => const Icon(
                                                      Icons.person,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              producerName,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.tertiaryFixed,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Divider(),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }
}
