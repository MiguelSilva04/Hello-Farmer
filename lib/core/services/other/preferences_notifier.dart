import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:light_sensor/light_sensor.dart';

enum Language { PORTUGUESE, ENGLISH }

enum ReturnPolicy { NONE, THREE_DAYS, WEEK, MONTH }

extension ReturnPolicyExtension on ReturnPolicy {
  String toDisplayString() {
    switch (this) {
      case ReturnPolicy.NONE:
        return 'Sem devolução';
      case ReturnPolicy.THREE_DAYS:
        return '3 dias após a entrega';
      case ReturnPolicy.WEEK:
        return '1 semana após a entrega';
      case ReturnPolicy.MONTH:
        return '1 mês após a entrega';
    }
  }
}

class PreferencesNotifier with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _autoTheme = false;
  Language language = Language.PORTUGUESE;
  bool _isActivePin = false;
  bool _biometricsAuthentication = false;
  bool _permissions = false;
  bool _localization = false;
  bool _notifications = false;
  bool _inventoryManagement = false;
  bool _receiptsByEmail = false;
  String _receiptMessage = "";
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _recomendations = true;
  bool _productsUpdates = true;
  ReturnPolicy _returnPolicy = ReturnPolicy.THREE_DAYS;

  Locale get currentLocale {
    switch (language) {
      case Language.ENGLISH:
        return const Locale('en');
      case Language.PORTUGUESE:
        return const Locale('pt');
    }
  }

  bool get receiptsByEmail => _receiptsByEmail;
  void setReceiptsByEmail(bool value) {
    if (_receiptsByEmail != value) {
      _receiptsByEmail = value;
      notifyListeners();
    }
  }

  String get receiptMessage => _receiptMessage;
  void setReceiptMessage(String value) {
    if (_receiptMessage != value) {
      _receiptMessage = value;
      notifyListeners();
    }
  }

  bool get pushNotifications => _pushNotifications;
  void setPushNotifications(bool value) {
    if (_pushNotifications != value) {
      _pushNotifications = value;
      notifyListeners();
    }
  }

  bool get emailNotifications => _emailNotifications;
  void setEmailNotifications(bool value) {
    if (_emailNotifications != value) {
      _emailNotifications = value;
      notifyListeners();
    }
  }

  bool get recomendations => _recomendations;
  void setRecomendations(bool value) {
    if (_recomendations != value) {
      _recomendations = value;
      notifyListeners();
    }
  }

  bool get productsUpdates => _productsUpdates;
  void setProductsUpdates(bool value) {
    if (_productsUpdates != value) {
      _productsUpdates = value;
      notifyListeners();
    }
  }

  ReturnPolicy get returnPolicy => _returnPolicy;
  void setReturnPolicy(ReturnPolicy value) {
    if (_returnPolicy != value) {
      _returnPolicy = value;
      notifyListeners();
    }
  }

  bool get inventoryManagement => _inventoryManagement;
  void setInventoryManagement(bool value) {
    if (_inventoryManagement != value) {
      _inventoryManagement = value;
      notifyListeners();
    }
  }

  bool get isActivePin => _isActivePin;
  void setActivePin(bool value) {
    if (_isActivePin != value) {
      _isActivePin = value;
      notifyListeners();
    }
  }

  Future<void> _updateThemeBasedOnLightSensor() async {
    final hasSensor = await LightSensor.hasSensor();
    if (!hasSensor) {
      _themeMode = ThemeMode.light;
      notifyListeners();
      return;
    }

    try {
      final lux = await LightSensor.luxStream().first;
      print('Current lux: $lux');

      if (lux < 50) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }

      notifyListeners();
    } catch (e) {
      _themeMode = ThemeMode.light;
      notifyListeners();
    }
  }

  bool get isAutoTheme => _autoTheme;
  Future<void> setAutoTheme(bool value) async {
    _autoTheme = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoTheme', value);

    if (_autoTheme) {
      await _updateThemeBasedOnLightSensor();
    }

    notifyListeners();
  }

  bool get biometricsAuthentication => _biometricsAuthentication;
  void setBiometricsAuthentication(bool value) {
    if (_biometricsAuthentication != value) {
      _biometricsAuthentication = value;
      notifyListeners();
    }
  }

  bool get permissions => _permissions;
  void setPermissions(bool value) {
    if (_permissions != value) {
      _permissions = value;
      notifyListeners();
    }
  }

  bool get localization => _localization;
  void setLocalization(bool value) {
    if (_localization != value) {
      _localization = value;
      notifyListeners();
    }
  }

  bool get notifications => _notifications;
  void setNotifications(bool value) {
    if (_notifications != value) {
      _notifications = value;
      notifyListeners();
    }
  }

  Future<void> setLanguage(Language lang) async {
    if (language != lang) {
      language = lang;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', lang.toString());
    }
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    // Carregar tema
    _autoTheme = prefs.getBool('autoTheme') ?? false;
    if (_autoTheme) {
      await _updateThemeBasedOnLightSensor();
    } else {
      final isDark = prefs.getBool('isDark') ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    }

    // Carregar linguagem
    final langString = prefs.getString('language');
    if (langString != null) {
      language = Language.values.firstWhere(
        (e) => e.toString() == langString,
        orElse: () => Language.PORTUGUESE,
      );
    }

    notifyListeners();
  }

  final String conditions = '''
Termos e Condições de Utilização


Última atualização: 28 de maio de 2025

Bem-vindo à Hello Farmer! Estes Termos e Condições regulam o acesso e utilização da aplicação móvel e dos serviços fornecidos pela Hello Farmer, uma plataforma dedicada a facilitar a comercialização de produtos agrícolas diretamente entre produtores e consumidores.

1. Aceitação dos Termos
Ao utilizar a aplicação Hello Farmer, o utilizador aceita integralmente e sem reservas os presentes Termos e Condições. Caso não concorde com alguma disposição, deverá abster-se de utilizar a aplicação.

2. Descrição do Serviço
A Hello Farmer fornece uma plataforma digital onde produtores agrícolas podem:

Criar e gerir perfis pessoais e comerciais;

Publicar anúncios de produtos com imagem, descrição, preço, stock e unidade;

Receber e gerir encomendas de consumidores;

Emitir faturas e visualizar estatísticas financeiras semanais;

Destacar anúncios na pesquisa ou página principal mediante subscrição;

Escolher métodos de entrega preferidos.

3. Registo e Conta
O utilizador é responsável por fornecer informações verdadeiras e manter os dados da sua conta atualizados. A Hello Farmer reserva-se o direito de suspender contas com dados fraudulentos ou uso indevido da plataforma.

4. Responsabilidades do Utilizador
O utilizador compromete-se a:

Cumprir com todas as leis locais relacionadas com a venda e transporte de produtos agrícolas;

Garantir a veracidade das informações dos produtos anunciados;

Tratar os dados dos clientes com confidencialidade;

Respeitar os métodos de pagamento e envio acordados com o consumidor.

5. Encomendas e Transações
As encomendas realizadas na aplicação ficam registadas no perfil do produtor. Cada encomenda associa-se a um ou mais anúncios e indica a quantidade pedida. Os valores e lucros são automaticamente calculados com base nas vendas registadas.

6. Destacar Anúncios
O utilizador pode optar por destacar anúncios:

Topo da Pesquisa (SEARCH): o anúncio aparece em primeiro lugar nos resultados de pesquisa.

Página Principal (HOME): o anúncio é promovido na homepage da aplicação.

Estes destaques têm duração limitada e podem ter custos associados, visíveis antes da confirmação da promoção.

7. Privacidade e Segurança
A Hello Farmer implementa medidas de segurança como:

Autenticação por biometria ou PIN;

Gestão de sessões ativas (logout remoto);

Controlo de permissões (ex: localização e notificações).

A política de privacidade descreve em detalhe a recolha, tratamento e proteção de dados.

8. Limitação de Responsabilidade
A Hello Farmer não se responsabiliza por:

Qualidade ou entrega de produtos vendidos;

Danos decorrentes de erros ou omissões no conteúdo inserido pelos utilizadores;

Interrupções de serviço devido a fatores técnicos ou de força maior.

9. Modificações
A Hello Farmer pode alterar os Termos e Condições a qualquer momento. Os utilizadores serão notificados de alterações materiais e a continuação do uso da aplicação implica aceitação dos novos termos.

10. Cancelamento e Eliminação de Conta
O utilizador pode, a qualquer momento, eliminar a sua conta através das definições. A Hello Farmer reserva-se o direito de suspender ou eliminar contas que violem estes Termos.
''';

  ThemeMode get themeMode => _themeMode;

  ThemeNotifier() {
    _loadTheme();
  }

  Future<void> toggleTheme(bool isDark) async {
    if (_autoTheme) return;

    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
    await prefs.setBool('autoTheme', false);
    _autoTheme = false;

    notifyListeners();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  PreferencesNotifier() {
    loadPreferences();
  }
}
