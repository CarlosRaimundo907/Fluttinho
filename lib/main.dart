import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'template/myapp.dart'; // Importe seu MyApp original
import 'firebase_options.dart';
import 'pages/home_page.dart'; // Importe a página principal
import 'pages/login_page.dart'; // Importe a página de login
import 'template/config.dart'; // Importe a sua configuração

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const AuthWrapper());
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasData) {
          // Se o usuário está logado, a rota inicial é a HomePage
          return MyApp(initialRoute: '/');
        }

        // Se o usuário não está logado, a rota inicial é a LoginPage
        return MyApp(initialRoute: '/login');
      },
    );
  }
}