library;

/// Página de login
/// Exibe um botão para autenticação via Google.

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../template/config.dart';
import '../template/myappbar.dart';
import '../template/mydrawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      // 1. Inicia o fluxo de autenticação do Google
      UserCredential userCredential;
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        userCredential = await FirebaseAuth.instance.signInWithPopup(
          googleProvider,
        );
      } else {
        final googleProvider = GoogleAuthProvider();
        userCredential = await FirebaseAuth.instance.signInWithProvider(
          googleProvider,
        );
      }

      final User? user = userCredential.user;

      // 2. Sincroniza o usuário com a API, se o login for bem-sucedido
      if (user != null) {
        await _syncUserWithApi(user);
      }

      // ✅ Redireciona para Home após o login e a sincronização
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

  Future<void> _syncUserWithApi(User user) async {
    try {
      final String usersApiUrl = '${Config.endPoint['users']}?uid=${user.uid}';

      // Consulta a API para verificar se o usuário já existe
      final Response response = await _dio.get(usersApiUrl);
      final List userList = response.data;

      if (userList.isEmpty) {
        // Se o usuário não existe, cria um novo registro
        await _createNewUser(user);
      } else {
        // Se o usuário já existe, atualiza o registro existente
        final existingUserId = userList[0]['id'];
        await _updateExistingUser(existingUserId, user);
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Erro ao sincronizar usuário com a API: ${e.message}');
      }
    }
  }

  Future<void> _createNewUser(User user) async {
    final Map<String, dynamic> userData = {
      'uid': user.uid,
      'displayName': user.displayName,
      'email': user.email,
      'photoURL': user.photoURL,
      'phoneNumber': user.phoneNumber,
      'createdAt': user.metadata.creationTime?.toIso8601String(),
      'lastLoginAt': user.metadata.lastSignInTime?.toIso8601String(),
    };
    await _dio.post(Config.endPoint['users']!, data: userData);
  }

  Future<void> _updateExistingUser(int userId, User user) async {
    final Map<String, dynamic> userData = {
      'displayName': user.displayName,
      'email': user.email,
      'photoURL': user.photoURL,
      'phoneNumber': user.phoneNumber,
      'lastLoginAt': user.metadata.lastSignInTime?.toIso8601String(),
    };
    final String updateUrl = '${Config.endPoint['users']}/$userId';
    await _dio.patch(updateUrl, data: userData);
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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
