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
          // Use um StreamBuilder para ouvir as mudanças de autenticação
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data; // O usuário logado ou null
              if (user != null) {
                return _buildLoggedInHeader(context, user);
              } else {
                return _buildLoggedOutHeader(context);
              }
            },
          ),

          // Acesso à página inicial → '/'
          ListTile(
            title: const Text('Início'),
            leading: const Icon(Icons.home),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/');
            },
          ),

          // Adicione o StreamBuilder para mostrar o "Novo Item" condicionalmente
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              // O if condicional garante que o ListTile seja exibido apenas se o usuário não for nulo
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
                return const SizedBox.shrink(); // Retorna um widget vazio se não estiver logado
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

  // A função agora recebe o objeto User
  Widget _buildLoggedInHeader(BuildContext context, User user) {
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
              // Use a photoURL do usuário
              backgroundImage: user.photoURL != null
                  ? NetworkImage(user.photoURL!)
                  : null,
              child: user.photoURL == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // Use o displayName do usuário
                  user.displayName ?? 'Usuário',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                const Text(
                  'Ver perfil',
                  style: TextStyle(fontSize: 14.0, color: Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// As funções _buildLoggedOutHeader e o restante do código não mudaram.
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