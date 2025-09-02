library;

/// Página de contatos
///     Exibe, processa e envia um formulário de contatos

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart'; // Adicionado para formatação de data

import '../template/config.dart';
import '../template/myappbar.dart';
import '../template/myfooter.dart';
import '../template/mydrawer.dart';
import '../template/apptools.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Instância privada (private) do Dio
final Dio _dio = Dio();

// Nome da página (AppBar)
final pageName = 'Login';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final GlobalKey<FormState> _contactsFormKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1080) {
          return Row(
            children: [
              const MyDrawer(),
              Expanded(
                child: Scaffold(
                  appBar: MyAppBar(title: pageName),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: _buildLoginPage(),
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
              child: _buildLoginPage(),
            ),
            bottomNavigationBar: const MyBottomNavBar(),
          );
        }
      },
    );
  }

  Widget _buildLoginPage() {
    return Center(
      child: SizedBox(width: 540, child: Center(child: Text('Conteúdo viual da página aqui'))),
    );
  }
}
