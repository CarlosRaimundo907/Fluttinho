library;

/// Página de contatos
///     Exibe, processa e envia um formulário de contatos

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa o Firebase Auth

import '../template/config.dart';
import '../template/myappbar.dart';
import '../template/mydrawer.dart';
import '../template/apptools.dart';

// Instância privada (private) do Dio
final Dio _dio = Dio();

// Nome da página (AppBar)
final pageName = 'Faça contato';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPage();
}

class _ContactsPage extends State<ContactsPage> {
  final GlobalKey<FormState> _contactsFormKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    // Verifica se há um usuário logado
    if (user != null) {
      // Preenche os campos com os dados do usuário, se disponíveis
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
    }
  }

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
                    child: _buildContactForm(),
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
              child: _buildContactForm(),
            ),
          );
        }
      },
    );
  }

  Widget _buildContactForm() {
    return Center(
      child: SizedBox(
        width: 540,
        child: Form(
          key: _contactsFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Preencha todos os campos abaixo para entrar em contato conosco.',
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, escreva seu nome.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, escreva seu e-mail.';
                  }
                  if (!Config.emailRegex.hasMatch(value)) {
                    return 'Por favor, insira um email válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Assunto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.subject),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, escreva o assunto.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Mensagem',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, escreva sua mensagem.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton.icon(
                onPressed: _submitContactForm,
                icon: const Icon(Icons.send),
                label: const Text('Enviar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitContactForm() async {
    if (_contactsFormKey.currentState!.validate()) {
      final name = _nameController.text;
      final email = _emailController.text;
      final subject = _subjectController.text;
      final message = _messageController.text;

      final now = DateTime.now();
      final formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(now.toUtc());

      final Map<String, dynamic> formData = {
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
        'date': formattedDate,
        'status': 'ON',
      };

      try {
        final Response response = await _dio.post(
          Config.endPoint['contact'],
          data: formData,
          options: Options(contentType: Headers.jsonContentType),
        );

        if (!mounted) return;

        if (response.statusCode == 200 || response.statusCode == 201) {
          showSnackBar(
            context,
            'Mensagem enviada com sucesso!',
            color: Colors.green,
          );
          _nameController.clear();
          _emailController.clear();
          _subjectController.clear();
          _messageController.clear();
          // Preenche novamente caso o usuário esteja logado
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            _nameController.text = user.displayName ?? '';
            _emailController.text = user.email ?? '';
          }
        } else {
          showSnackBar(
            context,
            'Falha ao enviar mensagem. Status: ${response.statusCode}',
            color: Colors.red,
          );
        }
      } on DioException catch (e) {
        if (!mounted) return;
        if (e.response != null) {
          showSnackBar(
            context,
            'Falha ao enviar. Erro do servidor: ${e.response!.statusCode}',
            color: Colors.red,
          );
        } else {
          showSnackBar(
            context,
            'Erro de conexão. Verifique sua rede e o servidor.',
            color: Colors.red,
          );
        }
      } catch (e) {
        if (!mounted) return;
        showSnackBar(context, 'Ocorreu um erro inesperado.', color: Colors.red);
      }
    } else {
      showSnackBar(
        context,
        'Por favor, preencha todos os campos corretamente.',
        color: Colors.red,
      );
    }
  }
}