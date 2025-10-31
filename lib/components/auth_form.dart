import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/services.dart';
import 'package:harvestly/components/create_store.dart';
import 'package:harvestly/components/user_image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../core/models/auth_form_data.dart';
import '../core/services/auth/auth_service.dart';
import '../exceptions/auth_exception.dart';
import 'package:flutter/material.dart';

import '../utils/app_routes.dart';
import 'birth_picker.dart';
import 'country_state_picker.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _formData = AuthFormData();
  bool _passwordHidden = true;
  bool _isLoading = false;

  bool _isFirstInfoSignup = true;
  bool _isSecondInfoSignup = false;
  bool _isThirdInfoSignup = false;
  bool _isFourthInfoSignup = false;

  bool _isRecovery = false;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _recoverEmailController = TextEditingController();
  final _recoverPasswordController = TextEditingController();

  DateTime? _selectedDate;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController controller = TextEditingController();
  PhoneNumber number = PhoneNumber(isoCode: 'PT');
  String selectedDialCode = '+351';
  String selectedCountryCode = 'PT';
  String selectedFlagEmoji = '🇵🇹';

  String countryValue = '';
  String municipalityValue = '';
  String cityValue = '';

  void _handleImagePick(File image) {
    _formData.image = image;
  }

  Future<void> _showErrorDialog(String message, bool emailAlreadyExists) async {
    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            icon: Icon(Icons.warning, color: Colors.amber),
            title: const Text('Ocorreu um Erro'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Fechar'),
              ),
              if (emailAlreadyExists)
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    if (mounted) {
                      setState(() {
                        _isFirstInfoSignup = false;
                        _isSecondInfoSignup = false;
                        _isThirdInfoSignup = false;
                        _isRecovery = false;
                        _formData.toggleAuthMode();
                      });
                    }
                  },
                  child: const Text("Fazer login"),
                ),
            ],
          ),
    );
  }

  void _showError(String msg) {
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    if (scaffoldMessenger != null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else {
      debugPrint("Erro: $msg (ScaffoldMessenger não disponível)");
    }
  }

  bool _validateFields() {
    if (_formData.isLogin) {
      if (_emailController.text.trim().isEmpty) {
        _showError('O e-mail precisa de ser preenchido!');
        return false;
      }
      if (_passwordController.text.trim().isEmpty) {
        _showError('A senha precisa de ser preenchida!');
        return false;
      }
    }
    if (_formData.isSignup) {
      if (_formData.image == null && _formData.isSignup) {
        _showError('Imagem não selecionada!');
        return false;
      }

      if (_firstNameController.text.trim().isEmpty ||
          _firstNameController.text.trim().length < 2) {
        _showError('Primeiro nome deve ter no mínimo 2 caracteres.');
        return false;
      }

      if (_lastNameController.text.trim().isEmpty ||
          _lastNameController.text.trim().length < 2) {
        _showError('Último nome deve ter no mínimo 2 caracteres.');
        return false;
      }
      if (_isFirstInfoSignup &&
          _emailController.text.trim().isEmpty &&
          _passwordController.text.trim().isEmpty &&
          _confirmPasswordController.text.trim().isEmpty) {
        _showError('Avance para a página seguinte!');
        return false;
      }
      if (_isSecondInfoSignup) {
        if (_emailController.text.trim().isEmpty ||
            !_emailController.text.contains('@')) {
          _showError('O e-mail precisa de ser preenchido!');
          return false;
        }

        if (_passwordController.text.trim().isEmpty ||
            _passwordController.text.length < 6) {
          _showError('Senha deve ter no mínimo 6 caracteres.');
          return false;
        }

        if (_passwordController.text != _confirmPasswordController.text) {
          _showError('As senhas não coincidem.');
          return false;
        }
      }
      if (_isSecondInfoSignup &&
          !_isThirdInfoSignup &&
          _recoverEmailController.text.trim().isEmpty &&
          _formData.dateOfBirth.isEmpty) {
        _showError("Avance para a última página!");
        return false;
      }
      if (_isThirdInfoSignup) {
        if (_formData.dateOfBirth == "" || _selectedDate == null) {
          _showError('Data de nascimento inválida');
          return false;
        }
        final currentDate = DateTime.now();
        final minAllowedDate = DateTime(
          currentDate.year - 8,
          currentDate.month,
          currentDate.day,
        );
        if (_selectedDate!.isAfter(currentDate) ||
            _selectedDate!.isAfter(minAllowedDate)) {
          _showError(
            'É necessário ter pelo menos 8 anos para criar uma conta.',
          );
          return false;
        }
      }
      if (_isThirdInfoSignup && _recoverEmailController.text.trim().isEmpty) {
        _showError('O email de recuperação precisa de ser preenchido.');
        return false;
      }
      if (countryValue == "" || cityValue == "" || municipalityValue == "") {
        _showError('A localidade precisa de ser preenchida toda corretamente.');
        return false;
      }
    }

    return true;
  }

  Future<void> _submit([String typeOfLogin = ""]) async {
    setState(() => _isLoading = true);
    bool hasError = false;

    if ((typeOfLogin == "" || typeOfLogin == "Normal")) {
      if (!_validateFields()) {
        setState(() => _isLoading = false);
        return;
      }
    }

    _formData.firstName = _firstNameController.text;
    _formData.lastName = _lastNameController.text;
    _formData.email = _emailController.text;
    _formData.password = _passwordController.text;
    _formData.recoverEmail = _recoverEmailController.text;

    try {
      if (!mounted) return;
      setState(() => _isLoading = true);

      if (_formData.isLogin && !_isRecovery && typeOfLogin != "") {
        await AuthService().login(
          _formData.email,
          _formData.password,
          typeOfLogin,
        );
        await AuthService().syncEmailWithFirestore();
      } else if (_formData.isSignup) {
        await AuthService().signup(
          _formData.firstName,
          _formData.lastName,
          _formData.email,
          _formData.password,
          _formData.image,
          _formData.phone,
          _formData.recoverEmail,
          _formData.dateOfBirth,
          countryValue,
          cityValue,
          municipalityValue,
          [],
        );
      } else if (_isRecovery) {
        await AuthService().recoverPassword(_formData.recoverPasswordEmail);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      final errorMessage =
          AuthException.errors[e.code] ?? 'Ocorreu um erro inesperado!';
      final emailAlreadyExists = e.code == "email-already-in-use";

      hasError = true;
      await _showErrorDialog(errorMessage, emailAlreadyExists);
    } catch (error) {
      if (!mounted) return;

      hasError = true;
      await _showErrorDialog(
        'Ocorreu um erro inesperado! Contacte o suporte!\n O erro foi o seguinte: $error',
        false,
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }

    if (_isRecovery && !hasError) {
      bool? confirmed = await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Aviso"),
              content: const Text(
                "Irá ser enviado um link de reposição de password para o email introduzido!",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    setState(() {
                      _isRecovery = false;
                    });
                  },
                  child: const Text("Ok"),
                ),
              ],
            ),
      );

      if (confirmed != true) return;
    }

    if (!hasError &&
        (_formData.isLogin || _formData.isSignup) &&
        !_isRecovery) {
      if (mounted)
        if (AuthService().currentUser != null) {
          final user = await AuthService().getCurrentUserData(
            AuthService().currentUser!.id,
          );
          if (user != null && user['type'] == 'producer') {
            final hasBanca =
                user['bancaId'] != null &&
                user['bancaId'].toString().isNotEmpty;
            if (!hasBanca) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (ctx) => CreateStore(isFirstTime: true),
                ),
                (route) => false,
              );
              return;
            }
          }
        }
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.MAIN_MENU, (route) => false);
    }
  }

  Widget getTextFormField(
    String initialValue,
    String keyText,
    Function(String) onChanged,
    String labelText,
    TextInputType textInputType,
    TextEditingController controller,
    IconData prefixIcon, [
    Widget? suffixIcon,
  ]) {
    return TextFormField(
      key: ValueKey(keyText),
      onChanged: onChanged,
      style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        suffixIconColor: Theme.of(context).colorScheme.tertiary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.inverseSurface,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
          fontSize: 18,
        ),
        labelText: labelText,
      ),
      obscureText: (suffixIcon != null) ? _passwordHidden : false,
      keyboardType: textInputType,
      controller: controller,
      maxLength: textInputType == TextInputType.phone ? 15 : null,
    );
  }

  @override
  void initState() {
    super.initState();
    String modeState = AuthService().isLoggingIn ? "login" : "signup";
    _formData.setMode(modeState);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            Image.asset(
              'assets/images/simpleLogo.png',
              width: MediaQuery.of(context).size.width * 0.35,
            ),
            Text(
              _formData.isLogin ? "Entrar" : "Criar Conta",
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (_formData.isSignup) ...[
                    if (_formData.isSignup && _isFirstInfoSignup) ...[
                      UserImagePicker(
                        onImagePick: _handleImagePick,
                        avatarRadius: 50,
                        image: _formData.image,
                        isSignup: true,
                      ),
                      getTextFormField(
                        _formData.firstName,
                        "first_name",
                        (name) => _formData.firstName = name,
                        "Primeiro Nome",
                        TextInputType.text,
                        _firstNameController,
                        Icons.person_2_sharp,
                      ),
                      SizedBox(height: 10),
                      getTextFormField(
                        _formData.lastName,
                        "last_name",
                        (name) => _formData.lastName = name,
                        "Último Nome",
                        TextInputType.text,
                        _lastNameController,
                        Icons.person_2_sharp,
                      ),
                    ],
                    SizedBox(height: 10),
                    SizedBox(height: 10),
                    if (_formData.isSignup && _isThirdInfoSignup) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.inverseSurface,
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      showCountryPicker(
                                        context: context,
                                        showPhoneCode: true,
                                        onSelect: (Country country) {
                                          setState(() {
                                            selectedDialCode =
                                                '+${country.phoneCode}';
                                            selectedCountryCode =
                                                country.countryCode;
                                            selectedFlagEmoji =
                                                country.flagEmoji;
                                          });
                                        },
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          selectedFlagEmoji,
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          selectedDialCode,
                                          style: TextStyle(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.tertiary,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.tertiary,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(15),
                                      ],
                                      onChanged: (value) {
                                        String phoneNumber =
                                            "$selectedDialCode $value";
                                        _formData.phone = phoneNumber;
                                      },
                                      keyboardType: TextInputType.phone,
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.tertiary,
                                      ),
                                      maxLength: 9,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Número de telefone',
                                        hintStyle: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.tertiary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      BirthPicker(
                        onChanged: (DateTime? dateTime) {
                          setState(() {
                            _selectedDate = dateTime!;
                            _formData.dateOfBirth =
                                _selectedDate!
                                    .toIso8601String()
                                    .split('T')
                                    .first;
                          });
                        },
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.inverseSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.inverseSurface,
                            width: 1.5,
                          ),
                        ),
                        textStyle: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        iconColor: Theme.of(context).colorScheme.tertiary,
                        iconSize: 28,
                      ),
                      SizedBox(height: 10),
                      getTextFormField(
                        _formData.recoverEmail,
                        "recover_email",
                        (recoverEmail) => _formData.recoverEmail = recoverEmail,
                        'E-mail de recuperação',
                        TextInputType.emailAddress,
                        _recoverEmailController,
                        Icons.email,
                      ),
                      SizedBox(height: 10),
                    ],
                  ],
                  if (_formData.isSignup && _isFourthInfoSignup) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Localidade:",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    SelectState(
                      iconColor: Theme.of(context).colorScheme.secondary,
                      dropdownColor:
                          Theme.of(context).colorScheme.secondaryFixed,
                      inStyle: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),

                      onCountryChanged: (value) {
                        setState(() {
                          countryValue = value;
                        });
                      },
                      onStateChanged: (value) {
                        setState(() {
                          municipalityValue = value;
                        });
                      },
                      onCityChanged: (value) {
                        setState(() {
                          cityValue = value;
                        });
                      },
                      isSignup: true,
                    ),
                  ],
                  if (_formData.isLogin && !_isRecovery ||
                      (_formData.isSignup && _isSecondInfoSignup)) ...[
                    getTextFormField(
                      _formData.email,
                      "email",
                      (email) => _formData.email = email,
                      'E-mail',
                      TextInputType.emailAddress,
                      _emailController,
                      Icons.email,
                    ),
                    SizedBox(height: 10),
                    getTextFormField(
                      _formData.password,
                      "password",
                      (password) => _formData.password = password,
                      "Senha",
                      TextInputType.text,
                      _passwordController,
                      Icons.password,
                      IconButton(
                        icon: Icon(
                          _passwordHidden
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordHidden = !_passwordHidden;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    if (_formData.isSignup && _isSecondInfoSignup) ...[
                      getTextFormField(
                        _formData.password,
                        "confirm_password",
                        (password) => _formData.password = password,
                        "Confirmar Senha",
                        TextInputType.text,
                        _confirmPasswordController,
                        Icons.password,
                        IconButton(
                          icon: Icon(
                            _passwordHidden
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordHidden = !_passwordHidden;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ],
                  if (_isRecovery) ...[
                    getTextFormField(
                      _formData.recoverPasswordEmail,
                      "recovery_email",
                      (recoverPasswordEmail) =>
                          _formData.recoverPasswordEmail = recoverPasswordEmail,
                      'E-mail para recuperar senha',
                      TextInputType.emailAddress,
                      _recoverPasswordController,
                      Icons.email,
                    ),
                    SizedBox(height: 10),
                  ],

                  if (_formData.isLogin && !_isRecovery)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isRecovery = true;
                        });
                      },
                      child: Text(
                        'Esqueceu-se da senha?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.tertiary,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                  (_isLoading)
                      ? CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary,
                      )
                      : Row(
                        mainAxisAlignment:
                            (_formData.isSignup)
                                ? MainAxisAlignment.spaceAround
                                : MainAxisAlignment.center,
                        children: [
                          if (_formData.isSignup || _formData.isLogin)
                            InkWell(
                              onTap: () {
                                if (_formData.isSignup && _isFirstInfoSignup) {
                                  setState(() {
                                    _isFirstInfoSignup = false;
                                    _isSecondInfoSignup = true;
                                  });
                                } else if (_formData.isSignup &&
                                    _isSecondInfoSignup) {
                                  setState(() {
                                    _isSecondInfoSignup = false;
                                    _isThirdInfoSignup = true;
                                  });
                                } else if (_formData.isSignup &&
                                    _isThirdInfoSignup) {
                                  setState(() {
                                    _isThirdInfoSignup = false;
                                    _isFourthInfoSignup = true;
                                  });
                                } else {
                                  _formData.isSignup
                                      ? _submit()
                                      : _submit("Normal");
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.65,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.inversePrimary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Center(
                                    child: Text(
                                      _formData.isLogin && !_isRecovery
                                          ? 'Entrar'
                                          : _formData.isSignup &&
                                              _isFourthInfoSignup
                                          ? 'Criar Conta'
                                          : _formData.isSignup &&
                                              !_isFourthInfoSignup
                                          ? 'Continuar'
                                          : "Recuperar Senha",
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                  if (_formData.isLogin && !_isRecovery) ...[
                    TextButton(
                      onPressed: null,
                      child: Text(
                        'Ou',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _submit("Google"),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: Image.asset(
                                    "assets/images/googleIcon.png",
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.08,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Flexible(
                                  flex: 10,
                                  child: Text(
                                    'Continuar com o Google',
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondaryFixed,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                          0.043,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    InkWell(
                      onTap: () => _submit("Facebook"),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(65, 104, 172, 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: Image.asset(
                                    "assets/images/facebookIcon.png",
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.08,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Flexible(
                                  flex: 10,
                                  child: Text(
                                    'Continuar com o Facebook',
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                          0.040,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    InkWell(
                      onTap: () => print("Entrou com a Apple!"),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryFixed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: Image.asset(
                                    "assets/images/appleIcon.png",
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.08,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Flexible(
                                  flex: 10,
                                  child: Text(
                                    'Iniciar sessão com a Apple',
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                          0.040,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  TextButton(
                    onPressed: () {
                      if (_isRecovery) {
                        setState(() {
                          _isRecovery = false;
                        });
                      } else if (_formData.isSignup && _isThirdInfoSignup) {
                        setState(() {
                          _isSecondInfoSignup = true;
                          _isThirdInfoSignup = false;
                        });
                      } else if (_formData.isSignup && _isSecondInfoSignup) {
                        setState(() {
                          _isFirstInfoSignup = true;
                          _isSecondInfoSignup = false;
                        });
                      } else if (_formData.isSignup && _isFourthInfoSignup) {
                        setState(() {
                          _isThirdInfoSignup = true;
                          _isFourthInfoSignup = false;
                        });
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      'Voltar',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
