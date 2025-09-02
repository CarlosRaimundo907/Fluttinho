import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Import das páginas do aplicativo
import '../pages/contacts_page.dart';
import '../pages/edit_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/new_page.dart';
import '../pages/view_page.dart';
import 'config.dart';

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({
    super.key,
    required this.initialRoute,
  });

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
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      // Usa a rota inicial passada pelo construtor
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const HomePage(),
        '/contacts': (context) => const ContactsPage(),
        '/view': (context) => const ViewPage(),
        '/edit': (context) => const EditPage(),
        '/new': (context) => const NewPage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}