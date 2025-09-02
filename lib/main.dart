library;

/// Aplicativo principal que implementa a página inicial

import 'package:flutter/material.dart';
import 'template/myapp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Função principal do aplicativo, onde a execução começa.
Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Executa o aplicativo MyApp, que é o widget raiz da árvore de widgets.
  runApp(const MyApp());
}