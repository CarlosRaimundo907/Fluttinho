library;

/// Página de cadastro de um novo item
///     Exibe um formulário para o usuário preencher os dados do novo item
///     e envia para a API.

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'dart:math';

// Nota: Para que o seletor de data apareça em português (locale 'pt_BR'),
// você deve adicionar as dependências 'flutter_localizations'
// e 'intl' em seu arquivo pubspec.yaml e configurar o MaterialApp em main.dart.
// Exemplo de main.dart:
//
// return MaterialApp(
//   // ...
//   localizationsDelegates: [
//     GlobalMaterialLocalizations.delegate,
//     GlobalWidgetsLocalizations.delegate,
//     GlobalCupertinoLocalizations.delegate,
//   ],
//   supportedLocales: const [
//     Locale('pt', 'BR'),
//     Locale('en', 'US'), // Adicione outros que precisar
//   ],
// );
import 'package:flutter_localizations/flutter_localizations.dart';

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

  // Variáveis para o seletor de usuários
  List<dynamic> _users = [];
  dynamic _selectedUser;
  bool _isLoadingUsers = true;
  bool _isSaving = false;

  // Variável para armazenar a data selecionada como um objeto DateTime
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    // Preenche a data com a data atual formatada
    _dateController.text =
        DateFormat('dd/MM/yyyy HH:mm:ss').format(_selectedDate);
    // Preenche a photoURL com uma URL aleatória
    _photoUrlController.text =
    'https://picsum.photos/400?random=${Random().nextInt(100)}';
  }

  // Função para buscar os usuários da API
  void _fetchUsers() async {
    try {
      final response = await _dio.get(Config.endPoint['users']);
      if (response.statusCode == 200) {
        setState(() {
          _users = response.data;
          _isLoadingUsers = false;
        });
      } else {
        setState(() {
          _isLoadingUsers = false;
        });
      }
    } on DioException {
      setState(() {
        _isLoadingUsers = false;
      });
    }
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
        _dateController.text = DateFormat('dd/MM/yyyy HH:mm:ss')
            .format(_selectedDate);
      });
    }
  }

  // Função para salvar o novo item
  void _saveItem() async {
    if (!_formKey.currentState!.validate() || _selectedUser == null) {
      showSnackBar(
        context,
        'Por favor, preencha todos os campos e selecione um usuário.',
        color: Colors.red,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final newItem = {
      'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedDate),
      'ownerId': _selectedUser['id'],
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
                  readOnly: true, // Impede que o usuário digite
                  onTap: () => _selectDate(context), // Abre o seletor de data
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
                const SizedBox(height: 20.0),
                if (_isLoadingUsers)
                  const CircularProgressIndicator()
                else
                  DropdownButtonFormField<dynamic>(
                    value: _selectedUser,
                    decoration: const InputDecoration(
                      labelText: 'Proprietário (Usuário)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: _users.map<DropdownMenuItem<dynamic>>((user) {
                      return DropdownMenuItem<dynamic>(
                        value: user,
                        child: Text(user['name']),
                      );
                    }).toList(),
                    onChanged: (dynamic? newUser) {
                      setState(() {
                        _selectedUser = newUser;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor, selecione um usuário.';
                      }
                      return null;
                    },
                  ),
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