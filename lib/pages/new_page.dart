// pages/new_page.dart

library;

/// Página de cadastro de um novo item
///     Exibe um formulário para o usuário preencher os dados do novo item
///     e envia para a API.

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart'; // Importe o Firebase Auth

import '../template/config.dart';
import '../template/myappbar.dart';
import '../template/mydrawer.dart';
import '../template/apptools.dart';

// Instância privada (private) do Dio para requisições HTTP
final Dio _dio = Dio();

// Nome da página para a barra superior
var pageName = 'Novo Item';

// StatefulWidget para gerenciar o estado da página de cadastro
class NewPage extends StatefulWidget {
  const NewPage({super.key});

  @override
  State<NewPage> createState() => _NewPageState();
}

// A classe de estado da NewPage
class _NewPageState extends State<NewPage> {
  // Chave global para o formulário
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controladores para os campos de texto do formulário
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Variável para controlar o estado de salvamento
  bool _isSaving = false;

  // Variável para armazenar a data selecionada como um objeto DateTime
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Preenche a data com a data atual formatada
    _dateController.text =
        DateFormat('dd/MM/yyyy HH:mm:ss').format(_selectedDate);
    // Preenche a photoURL com uma URL aleatória
    _photoUrlController.text =
    'https://picsum.photos/400?random=${Random().nextInt(100)}';
  }

  // Função para abrir o seletor de data
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Atualiza o controlador com a nova data selecionada e a hora atual
        _dateController.text = DateFormat('dd/MM/yyyy HH:mm:ss').format(_selectedDate);
      });
    }
  }

  // Função para salvar o novo item
  void _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      showSnackBar(
        context,
        'Por favor, preencha todos os campos obrigatórios.',
        color: Colors.red,
      );
      return;
    }

    // Obtém o UID do usuário logado
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showSnackBar(
        context,
        'Você precisa estar logado para cadastrar um novo item.',
        color: Colors.red,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final newItem = {
      'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedDate),
      'ownerId': user.uid, // Atribui o UID do usuário logado
      'name': _nameController.text,
      'description': _descriptionController.text,
      'location': _locationController.text,
      'photoURL': _photoUrlController.text,
      'status': 'ON',
    };

    try {
      final response = await _dio.post(
        Config.endPoint['new'],
        data: newItem,
        options: Options(contentType: Headers.jsonContentType),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        showSnackBar(
          context,
          'Item cadastrado com sucesso!',
          color: Colors.green,
        );
        Navigator.of(context).pushReplacementNamed('/');
      } else {
        showSnackBar(
          context,
          'Falha ao cadastrar o item. Status: ${response.statusCode}',
          color: Colors.red,
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      showSnackBar(
        context,
        'Erro ao enviar os dados: ${e.message}',
        color: Colors.red,
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _photoUrlController.dispose();
    _locationController.dispose();
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
                  body: Center(
                    child: _buildNewItemForm(),
                  ),
                ),
              ),
            ],
          );
        } else {
          return Scaffold(
            appBar: MyAppBar(title: pageName),
            drawer: const MyDrawer(),
            body: Center(
              child: _buildNewItemForm(),
            ),
          );
        }
      },
    );
  }

  Widget _buildNewItemForm() {
    // Adiciona uma verificação para garantir que o usuário está logado
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Acesso restrito. Faça login para continuar.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Conteúdo do formulário para o usuário logado
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: SizedBox(
          width: 540,
          child: _isSaving
              ? const CircularProgressIndicator()
              : Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Preencha as informações do novo item e clique em salvar.',
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.drive_file_rename_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a descrição.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: const InputDecoration(
                    labelText: 'Data de Cadastro',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a data.';
                    }
                    return null;
                  },
                ),
                // O DropdownButtonFormField foi removido daqui
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Localização',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _photoUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL da Foto',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.photo),
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton.icon(
                  onPressed: _saveItem,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}