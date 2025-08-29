library;

/// Aplicativo principal
/// - Define a estrutura base do app.
/// - Configura tema, internacionalização e rotas nomeadas.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Import das páginas do aplicativo
import '../pages/contacts_page.dart';
import '../pages/edit_page.dart';
import '../pages/home_page.dart';
import '../pages/new_page.dart';
import '../pages/view_page.dart';
import 'config.dart';

/// Classe raiz do aplicativo.
/// É um widget imutável que configura o [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Nome exibido no título da aplicação
      title: Config.appName,

      // Tema global do app (cores, tipografia, densidade)
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      // Delegados para internacionalização (i18n)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,   // Textos padrão do Material
        GlobalWidgetsLocalizations.delegate,   // Widgets com suporte a idiomas
        GlobalCupertinoLocalizations.delegate, // Estilo iOS
      ],

      // Idiomas suportados pela aplicação
      supportedLocales: const [
        Locale('pt', 'BR'), // Português (Brasil)
        Locale('en', 'US'), // Inglês (Estados Unidos)
      ],

      // Rota inicial exibida ao abrir o app
      initialRoute: '/',

      // Rotas nomeadas do app
      // Cada chave é um caminho e o valor é a página correspondente.
      routes: {
        '/': (context) => const HomePage(),
        '/contacts': (context) => const ContactsPage(),
        '/view': (context) => const ViewPage(),
        '/edit': (context) => const EditPage(),
        '/new': (context) => const NewPage(),
      },
    );
  }
}
