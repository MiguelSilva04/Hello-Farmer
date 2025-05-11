import 'package:flutter/material.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final user = AuthService().currentUser;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Gestão",
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Text(
                  "Visão geral da sua loja!",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
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
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Text(
                                "Próximos passos",
                                textAlign: TextAlign.start,
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
                SizedBox(height: 10),
                SettingsTileGroup(
                  icon: Icons.home,
                  title: "Página Principal",
                  onTap: () {
                    // Navegar para página principal
                  },
                ),
                SettingsTileGroup(
                  icon: Icons.shopping_cart,
                  title: "Encomendas",
                  subOptions: [
                    SettingsSubOption(
                      title: "Faturação",
                      onTap: () {
                        // Navegar para Faturação
                      },
                    ),
                    SettingsSubOption(
                      title: "Compras abandonadas",
                      onTap: () {
                        // Navegar para Compras Abandonadas
                      },
                    ),
                  ],
                ),
                SettingsTileGroup(
                  icon: Icons.inventory,
                  title: "Produtos",
                  subOptions: [
                    SettingsSubOption(
                      title: "Gestão de Stock",
                      onTap: () {
                        // Navegar para Gestão de Stock
                      },
                    ),
                    SettingsSubOption(
                      title: "Gestão de Preços",
                      onTap: () {
                        // Navegar para Gestão de Preços
                      },
                    ),
                    SettingsSubOption(
                      title: "Cabazes",
                      onTap: () {
                        // Navegar para Cabazes
                      },
                    ),
                  ],
                ),
                SettingsTileGroup(
                  icon: Icons.people,
                  title: "Clientes",
                  onTap: () {
                    // Navegar para página principal
                  },
                ),
                SettingsTileGroup(
                  icon: Icons.analytics,
                  title: "Análise de Dados",
                  subOptions: [
                    SettingsSubOption(
                      title: "Gestão de Stock",
                      onTap: () {
                        // Navegar para Gestão de Stock
                      },
                    ),
                    SettingsSubOption(
                      title: "Relatórios",
                      onTap: () {
                        // Navegar para Gestão de Preços
                      },
                    ),
                    SettingsSubOption(
                      title: "Por canal de venda",
                      onTap: () {
                        // Navegar para Cabazes
                      },
                    ),
                    SettingsSubOption(
                      title: "Principais produtores",
                      onTap: () {
                        // Navegar para Cabazes
                      },
                    ),
                    SettingsSubOption(
                      title: "Visitas à banca",
                      onTap: () {
                        // Navegar para Cabazes
                      },
                    ),
                    SettingsSubOption(
                      title: "Finanças",
                      onTap: () {
                        // Navegar para Cabazes
                      },
                    ),
                  ],
                ),
                SettingsTileGroup(
                  icon: Icons.storefront,
                  title: "Canais de Venda",
                  onTap: () {
                    // Navegar para página principal
                  },
                ),
                SettingsTileGroup(
                  icon: Icons.campaign,
                  title: "Anúncios",
                  onTap: () {
                    // Navegar para página principal
                  },
                ),
                SettingsTileGroup(
                  icon: Icons.star,
                  title: "Destaques de Anúncios",
                  onTap: () {
                    // Navegar para página principal
                  },
                ),
                SettingsTileGroup(
                  icon: Icons.attach_money,
                  title: "Finanças",
                  onTap: () {
                    // Navegar para página principal
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? (widget.subOptions!.length * 65.0) : 0,
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

/*

  Text("Conta"),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  UserInfoCardListTile(
                    titleText: "E-mail",
                    subTitleText: _email!,
                    icon: Icons.email,
                    onTap: () async {
                      final TextEditingController emailController =
                          TextEditingController(text: _email);
                      final shouldProceed = await showDialog<bool>(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: Text("Alterar E-mail"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: emailController,
                                    decoration: InputDecoration(
                                      hintText: "Novo E-mail",
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text("Cancelar"),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text("Guardar"),
                                ),
                              ],
                            ),
                      );

                      if (shouldProceed == true) {
                        await showDialog(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                title: Text("Aviso"),
                                content: Text(
                                  "Para mudar o e-mail, será enviado um e-mail de validação para o novo endereço introduzido. "
                                  "Ao prosseguir, a sua sessão será terminada. Deseja continuar?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: Text("Voltar"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final value = emailController.text.trim();
                                      if (value.isNotEmpty) {
                                        try {
                                          await AuthService()
                                              .updateSingleUserField(
                                                email: value,
                                              );
                                          AuthService().logout();
                                          Navigator.of(
                                            context,
                                          ).pushNamedAndRemoveUntil(
                                            AppRoutes.AUTH_OR_APP_PAGE,
                                            (route) => false,
                                          );
                                        } catch (e) {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Erro ao atualizar o e-mail.",
                                              ),
                                            ),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "O campo de e-mail não pode estar vazio.",
                                            ),
                                          ),
                                        );
                                      }
                                      ;
                                    },
                                    child: Text("Confirmar"),
                                  ),
                                ],
                              ),
                        );
                      }
                    },
                  ),
                  UserInfoCardListTile(
                    titleText: "Número de telefone",
                    subTitleText:
                        user!.phone.isNotEmpty ? _phoneNumber! : "Não definido",
                    icon: Icons.phone,
                    onTap:
                        () => _editUserInfoField(
                          context,
                          "Número de telefone",
                          _phoneNumber!,
                          (value) async {
                            try {
                              await AuthService().updateSingleUserField(
                                phone: value,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Número de telefone atualizado com sucesso!",
                                  ),
                                ),
                              );
                              setState(() => _phoneNumber = value);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Erro ao atualizar o número de telefone.",
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                  ),
                  GestureDetector(
                    onTap: _toggleGenderDropdown,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.person),
                        title: Text("Género"),
                        subtitle: Text(_selectedGender),
                        trailing: Icon(
                          _isGenderExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                        ),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    height: _isGenderExpanded ? 160 : 0,
                    width: double.infinity,
                    curve: Curves.fastOutSlowIn,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child:
                        _isGenderExpanded
                            ? SingleChildScrollView(
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: EdgeInsets.only(top: 4),
                                child: Column(
                                  children: [
                                    ListTile(
                                      trailing: Icon(Icons.male),
                                      title: Text("Masculino"),
                                      onTap: () => _updateGender("Masculino"),
                                    ),
                                    ListTile(
                                      trailing: Icon(Icons.female),
                                      title: Text("Feminino"),
                                      onTap: () => _updateGender("Feminino"),
                                    ),
                                    ListTile(
                                      trailing: Icon(
                                        FontAwesomeIcons.arrowsUpDownLeftRight,
                                      ),
                                      title: Text("Outro"),
                                      onTap: () => _updateGender("Outro"),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            : SizedBox.shrink(),
                  ),
                  UserInfoCardListTile(
                    titleText: "E-mail de recuperação",
                    subTitleText:
                        user!.recoveryEmail.isNotEmpty
                            ? _recoveryEmail!
                            : "Não definido",
                    icon: Icons.alternate_email,
                    onTap:
                        () => _editUserInfoField(
                          context,
                          "E-mail de recuperação",
                          _recoveryEmail!,
                          (value) {
                            try {
                              AuthService().updateSingleUserField(
                                recoveryEmail: value,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "E-mail de recuperação atualizado com sucesso!",
                                  ),
                                ),
                              );
                              setState(() => _recoveryEmail = value);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Erro ao atualizar o e-mail de recuperação.",
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                  ),
                ],
              ),
            ).animate().fade(duration: 600.ms).scale(),

            SizedBox(height: 20),
            Text("Preferências"),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.language),
                    title: Text("Mudar Idioma"),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.dark_mode),
                    title: Text("Tema Escuro"),
                    trailing: Consumer<ThemeNotifier>(
                      builder: (context, themeNotifier, _) {
                        final isDarkMode =
                            themeNotifier.themeMode == ThemeMode.dark;
                        return Switch(
                          value: isDarkMode,
                          onChanged: (value) {
                            themeNotifier.toggleTheme(value);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ).animate().slideX(duration: 600.ms),

  void _editUserInfoField(
    BuildContext context,
    String title,
    String? initialValue,
    Function(String) onSave,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: initialValue ?? "",
    );

    if (title == "Número de telefone") {
      PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'PT');

      if (initialValue != null && initialValue.isNotEmpty) {
        PhoneNumber number = await PhoneNumber.getRegionInfoFromPhoneNumber(
          initialValue,
          'PT',
        );
        _phoneNumber = number;
        controller.text =
            number.phoneNumber?.replaceAll(number.dialCode ?? '', '').trim() ??
            '';
      }

      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text("Editar $title"),
            content: InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {
                controller.text =
                    number.phoneNumber
                        ?.replaceAll(number.dialCode ?? '', '')
                        .trim() ??
                    '';
              },
              selectorConfig: SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                useBottomSheetSafeArea: true,
              ),
              ignoreBlank: false,
              autoValidateMode: AutovalidateMode.onUserInteraction,
              errorMessage: "Número de telefone incorreto",
              initialValue: _phoneNumber,
              textFieldController: controller,
              formatInput: true,
              keyboardType: TextInputType.phone,
              hintText: "Número de telemóvel",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () async {
                  onSave("+${_phoneNumber.dialCode} ${controller.text}");
                  Navigator.pop(ctx);
                },
                child: Text("Guardar"),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: Text("Editar $title"),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(hintText: "Novo $title"),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () {
                    onSave(controller.text);
                    Navigator.pop(ctx);
                  },
                  child: Text("Guardar"),
                ),
              ],
            ),
      );
    }
    
  }
  */
