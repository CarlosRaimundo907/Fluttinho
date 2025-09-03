library;

/// Página de login
/// Exibe um botão para autenticação via Google.

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../template/myappbar.dart';
import '../template/mydrawer.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

// Instância privada do Dio
final Dio _dio = Dio();

// Nome da página (AppBar)
final pageName = 'Login';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  // Função para fazer login com o Google
  Future<void> _signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        final googleProvider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithProvider(googleProvider);
      }

      // ✅ Redireciona para Home após login bem-sucedido
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Erro no Firebase Auth: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro de login: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = _buildLoginPage();

        if (constraints.maxWidth > 1080) {
          return Row(
            children: [
              const MyDrawer(),
              Expanded(
                child: Scaffold(
                  appBar: MyAppBar(title: pageName),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: content,
                  ),
                ),
              ),
            ],
          );
        } else {
          return Scaffold(
            appBar: MyAppBar(title: pageName),
            drawer: const MyDrawer(),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: content,
            ),
          );
        }
      },
    );
  }

  Widget _buildLoginPage() {
    return Center(
      child: SizedBox(
        width: 540,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Clique no botão abaixo para fazer login com sua conta do Google.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _signInWithGoogle,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.login),
                  SizedBox(width: 8),
                  Text('Login com Google'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
