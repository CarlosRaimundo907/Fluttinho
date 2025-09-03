library;

import 'package:flutter/foundation.dart';
/// Página de perfil
/// Exibe os dados do usuário logado e botões para logout e perfil do Google

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../template/myappbar.dart';
import '../template/mydrawer.dart';

// Instância privada do Dio
final Dio _dio = Dio();

// Nome da página (AppBar)
final pageName = 'Seu Perfil';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  User? _user;

  @override
  void initState() {
    super.initState();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Redireciona para login se não estiver autenticado
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
    } else {
      setState(() {
        _user = currentUser;
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _openGoogleProfile() async {
    final url = Uri.parse('https://myaccount.google.com/');
    if (!await launchUrl(url, webOnlyWindowName: '_blank')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o perfil do Google')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = _buildProfilePage();

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

  Widget _buildProfilePage() {
    if (_user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final photoUrl = _user!.photoURL;
    final displayName = _user!.displayName ?? 'Nome não disponível';
    final email = _user!.email ?? 'Email não disponível';
    final creationDate = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(_user!.metadata.creationTime!);
    final lastSignIn = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(_user!.metadata.lastSignInTime!);

    return Center(
      child: SizedBox(
        width: 540,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (photoUrl != null)
              CircleAvatar(radius: 48, backgroundImage: NetworkImage(photoUrl))
            else
              const CircleAvatar(
                radius: 48,
                child: Icon(Icons.person, size: 48),
              ),
            const SizedBox(height: 16),
            Text(
              displayName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(email, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text('Promeiro login: $creationDate'),
            Text('Último login: $lastSignIn'),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _openGoogleProfile,
              icon: const Icon(Icons.open_in_new),
              label: const Text(
                'Ver perfil no Google',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text(
                'Logout / Sair',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
