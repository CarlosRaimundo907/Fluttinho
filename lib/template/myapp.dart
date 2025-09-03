import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttinho/pages/policies_page.dart';
import 'package:fluttinho/pages/profile_page.dart';

// Import das páginas do aplicativo
import '../pages/contacts_page.dart';
import '../pages/edit_page.dart';
import '../pages/home_page.dart';
import '../pages/info_page.dart';
import '../pages/login_page.dart';
import '../pages/new_page.dart';
import '../pages/view_page.dart';
import 'config.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  final user = FirebaseAuth.instance.currentUser;

  // 🔓 Rotas livres (acessíveis com ou sem login)
  const freeRoutes = ['/', '/contacts', '/view', '/info', '/policies'];

  // 🔒 Rotas privadas (exigem login)
  const privateRoutes = ['/profile', '/edit', '/new'];

  // 🚫 Rotas públicas (só acessíveis se estiver deslogado)
  const publicRoutes = ['/login'];

  // Redireciona se necessário
  if (publicRoutes.contains(settings.name) && user != null) {
    return MaterialPageRoute(builder: (_) => const HomePage());
  }

  if (privateRoutes.contains(settings.name) && user == null) {
    return MaterialPageRoute(builder: (_) => const LoginPage());
  }

  // Roteamento normal
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const HomePage());
    case '/login':
      return MaterialPageRoute(builder: (_) => const LoginPage());
    case '/profile':
      return MaterialPageRoute(builder: (_) => const ProfilePage());
    case '/contacts':
      return MaterialPageRoute(builder: (_) => const ContactsPage());
    case '/view':
      return MaterialPageRoute(builder: (_) => const ViewPage());
    case '/edit':
      return MaterialPageRoute(builder: (_) => const EditPage());
    case '/new':
      return MaterialPageRoute(builder: (_) => const NewPage());
    case '/info':
      return MaterialPageRoute(builder: (_) => const InfoPage());
    case '/policies':
      return MaterialPageRoute(builder: (_) => const PoliciesPage());
    default:
      return MaterialPageRoute(
        builder: (_) =>
            const Scaffold(body: Center(child: Text('Página não encontrada'))),
      );
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Config.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
      // Usa a rota inicial passada pelo construtor
      initialRoute: initialRoute,
      onGenerateRoute: generateRoute,
    );
  }
}
