library;

/// Configurações globais do aplicativo.
///
/// Centraliza valores constantes e utilitários de configuração, como:
/// - Nome e informações gerais do app;
/// - Expressões regulares úteis (e.g., validação de e-mail);
/// - URLs da API e endpoints REST.
///
/// Obs.: Alterar aqui afeta o app inteiro.
class Config {
  /// Nome do aplicativo
  static const String appName = "Fluttinho";

  /// Informações de copyright exibidas em rodapés, splash ou sobre.
  static const String copyright = "© 2025 Joca da Silva";

  /// Expressão regular para validação de e-mails.
  ///   Segue padrão RFC 5322 simplificado.
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?)*$',
  );

  /// URL base da API consumida pelo app.
  /// Alterar aqui reflete em todos os endpoints.
  static const String apiBaseUrl = "http://localhost:8080";

  /// Endpoints REST usados pelo aplicativo.
  /// As chaves são nomes lógicos e os valores as rotas completas.
  static const Map<String, dynamic> endPoint = {
    // GET: Lista itens ativos, ordenados por data desc.
    //  Retorna um List<Map>
    'listAll': '$apiBaseUrl/items?status=ON&_sort=date&_order=desc',

    // GET: Retorna item específico por ID.
    //  Retorna um List<Map>
    'listOne': '$apiBaseUrl/items?status=ON&id=',

    // POST: Endpoint de contatos.
    'contact': '$apiBaseUrl/contacts',

    // PATCH: Atualiza item existente
    //  Adicione o ID do item no final do endpoint
    'update': '$apiBaseUrl/items/',

    // POST: Cria novo item.
    'new': '$apiBaseUrl/items',

    // GET: Lista/gerencia usuários.
    //  Adicione o ID do user no final do endpoint para GETone
    'users': '$apiBaseUrl/users',

  };
}
