library;

/// Página de edição de um item
///     Obtém o ID do item da rota, exibe um formulário com os dados
///     e permite a atualização na API.

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../template/config.dart';
import '../template/myappbar.dart';
import '../template/mydrawer.dart';
import '../template/apptools.dart';

// Instância privada (private) do Dio para requisições HTTP
final Dio _dio = Dio();

// Nome da página para a barra superior
var pageName = 'Editar Item';

// StatefulWidget para gerenciar o estado da página de edição
class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

// A classe de estado da EditPage
class _EditPageState extends State<EditPage> {
  // Chave global para o formulário
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controladores para os campos de texto do formulário
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  dynamic _item;
  bool _isLoading = true;
  String? _itemId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final itemId = ModalRoute.of(context)?.settings.arguments as String?;

    if (itemId == null) {
      if (kDebugMode) {
        print('ID nulo na rota. Redirecionando para a home page.');
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/');
      });
      return;
    }

    if (_itemId == null) {
      _itemId = itemId;
      _fetchItem(itemId);
    }
  }

  // Função para buscar os dados do item
  void _fetchItem(String itemId) async {
    final url = '${Config.endPoint['listOne']}$itemId';
    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200 &&
          response.data is List &&
          response.data.isNotEmpty) {
        final item = response.data[0];
        setState(() {
          _item = item;
          _isLoading = false;
          // Preenche os controladores com os dados do item
          _nameController.text = item['name'] ?? '';
          _descriptionController.text = item['description'] ?? '';
          _photoUrlController.text = item['photoURL'] ?? '';
          _locationController.text = item['location'] ?? '';
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (kDebugMode) {
          print('Falha ao carregar o item.');
        }
        if (!mounted) return;
        showSnackBar(context, 'Item não encontrado.', color: Colors.red);
        Navigator.of(context).pushReplacementNamed('/');
      }
    } on DioException catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (kDebugMode) {
        print('Erro de requisição: $e');
      }
      if (!mounted) return;
      showSnackBar(
        context,
        'Erro ao carregar os dados do item.',
        color: Colors.red,
      );
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  // Função para salvar as alterações do item
  void _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Coleta os dados do formulário
    final updatedData = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'photoURL': _photoUrlController.text,
      'location': _locationController.text,
    };

    final url = '${Config.endPoint['update']}$_itemId';

    try {
      final response = await _dio.patch(
        url,
        data: updatedData,
        options: Options(contentType: Headers.jsonContentType),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        showSnackBar(
          context,
          'Item atualizado com sucesso!',
          color: Colors.green,
        );
        // Retorna `true` para a página anterior para indicar sucesso
        Navigator.of(context).pop(true);
      } else {
        showSnackBar(
          context,
          'Falha ao atualizar o item. Status: ${response.statusCode}',
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
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, 'Ocorreu um erro inesperado.', color: Colors.red);
    }
  }

  // Função para mostrar a caixa de diálogo de confirmação e apagar o item
  void _deleteItem() async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Oooops!'),
          content: Text('Tem certeza que deseja apagar ${_item['name']}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Não apagar
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Apagar
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Apagar'),
            ),
          ],
        );
      },
    );

    // Se a confirmação for true, envia a requisição para a API
    if (confirmDelete == true) {
      final url = '${Config.endPoint['update']}$_itemId';
      try {
        final response = await _dio.patch(
          url,
          data: {'status': 'OFF'},
          options: Options(contentType: Headers.jsonContentType),
        );

        if (!mounted) return;

        if (response.statusCode == 200) {
          showSnackBar(
            context,
            'Item apagado com sucesso!',
            color: Colors.green,
          );
          // Redireciona para a home page
          Navigator.of(context).pushReplacementNamed('/');
        } else {
          showSnackBar(
            context,
            'Falha ao apagar o item. Status: ${response.statusCode}',
            color: Colors.red,
          );
        }
      } on DioException catch (e) {
        if (!mounted) return;
        showSnackBar(
          context,
          'Erro ao enviar a solicitação: ${e.message}',
          color: Colors.red,
        );
      } catch (e) {
        if (!mounted) return;
        showSnackBar(context, 'Ocorreu um erro inesperado.', color: Colors.red);
      }
    }
  }

  @override
  void dispose() {
    // Libera os controladores
    _nameController.dispose();
    _descriptionController.dispose();
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
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : _buildEditForm(),
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
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : _buildEditForm(),
            ),
          );
        }
      },
    );
  }

  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: SizedBox(
          width: 540,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Edite as informações do item e clique em salvar.'),
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
                  controller: _photoUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL da Foto',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.photo),
                  ),
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
                ElevatedButton.icon(
                  onPressed: _saveItem,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20.0), // Espaçamento entre os botões
                // Botão "Apagar" agora com funcionalidade
                ElevatedButton.icon(
                  onPressed: _deleteItem,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Apagar Item'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: Colors.red[600],
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