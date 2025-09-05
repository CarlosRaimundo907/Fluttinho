// template/mydrawer.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'config.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              if (user != null) {
                return _buildLoggedInHeader(context, user);
              } else {
                return _buildLoggedOutHeader(context);
              }
            },
          ),
          ListTile(
            title: const Text('Início'),
            leading: const Icon(Icons.home),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/');
            },
          ),
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              if (user != null) {
                return ListTile(
                  title: const Text('Novo Item'),
                  leading: const Icon(Icons.add_circle),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/new');
                  },
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          ListTile(
            title: const Text('Contatos'),
            leading: const Icon(Icons.contact_mail),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/contacts');
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Privacidade'),
            leading: const Icon(Icons.lock),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/policies');
            },
          ),
          ListTile(
            title: const Text('Informações'),
            leading: const Icon(Icons.info),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/info');
            },
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  '${Config.copyright}\nTodos os direitos reservados',
                  style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInHeader(BuildContext context, User user) {
    final displayName = user.displayName ?? '';
    final names = displayName.split(' ');
    String displayUserName;

    if (names.length > 1) {
      displayUserName = '${names.first} ${names.last}';
    } else {
      displayUserName = names.first;
    }

    return DrawerHeader(
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/profile');
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: user.photoURL != null
                  ? NetworkImage(user.photoURL!)
                  : null,
              child: user.photoURL == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayUserName.isEmpty ? 'Usuário' : displayUserName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      overflow: TextOverflow.ellipsis, // Evita estouro de texto
                    ),
                  ),
                  const Text(
                    'Ver perfil',
                    style: TextStyle(fontSize: 14.0, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedOutHeader(BuildContext context) {
    return DrawerHeader(
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/login');
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 30, child: Icon(Icons.person, size: 40)),
            SizedBox(width: 16),
            Text(
              'Login / Entrar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
          ],
        ),
      ),
    );
  }
}