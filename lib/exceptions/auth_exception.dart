class AuthException implements Exception {
  static const Map<String, String> errors = {
    "email_exists": "E-mail já registado.",
    "invalid-email": "Introduza um e-mail válido.",
    "operation_not_allowed": "A operação não é permitida.",
    "too_many_attempts_try_later":
        "Acesso bloqueado temporariamente. Tente novamente mais tarde.",
    "email_not_found": "E-mail não encontrado.",
    "email-already-in-use": "Esse e-mail já tem uma conta associada",
    "invalid_password": "A senha introduzida está inválida.",
    "invalid_login_credentials": "A senha introduzida é inválida.",
    "user-disabled": "A conta do utilizador foi desabilitada.",
    "reset_password_exceed_limit":
        "Excedeu os limites de pedido de recuperação de password com o e-mail inserido.",
    "internal-error": "Ocorreu um erro interno, tente mais tarde.",
    "invalid-credential": "As credenciais introduzidas estão inválidas.",
    "requires-recent-login":
        "Esta operação é sensível e requere uma autenticação recente. Volte a autenticar-se para realizar esta ação.",
    "network-request-failed":
        "Por favor verifique que a sua conexão à internet é estável para proceder à autenticação!",
  };

  final String key;

  AuthException(this.key);

  @override
  String toString() {
    return errors[key] ?? key;
  }
}
