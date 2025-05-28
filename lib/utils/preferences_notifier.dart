import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesNotifier with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

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

  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
    notifyListeners();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
