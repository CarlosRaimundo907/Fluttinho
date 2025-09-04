library;

/// Página de visualização de um item
///     Obtém o ID do item da rota e exibe os dados detalhados

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../template/config.dart';
import '../template/myappbar.dart';
import '../template/mydrawer.dart';

// Instância privada (private) do Dio para requisições HTTP
final Dio _dio = Dio();

// Nome da página para a barra superior
var pageName = 'Item';

// StatefulWidget para gerenciar o estado dos dados do item
class ViewPage extends StatefulWidget {
  final String? id;
  const ViewPage({super.key, required this.id});

  @override
  // Cria o estado mutável para este widget
  State<ViewPage> createState() => _ViewPageState();
}

// A classe de estado da ViewPage
class _ViewPageState extends State<ViewPage> {
  // Variável para armazenar os dados do item
  dynamic _item;
  // Variável para armazenar o nome do proprietário
  String? _ownerName;

  // Variável para controlar o estado de carregamento
  bool _isLoading = true;

  // Variável para armazenar o ID do item
  String? _itemId;

  @override
  void initState() {
    super.initState();

    // Se o ID estiver ausente, redireciona para a Home
    if (widget.id == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/');
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtém o ID do item dos argumentos da rota
    // final itemId = ModalRoute.of(context)?.settings.arguments as String?;

    // Se o ID for nulo (porque a página foi recarregada),
    // redireciona para a home page
    if (widget.id == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/');
      });
      return;
    }

    if (_itemId == null) {
      _itemId = widget.id;
      _fetchItem(widget.id!);
    }
  }

  // Função assíncrona para buscar os dados do item da API
  void _fetchItem(String itemId) async {
    final url = '${Config.endPoint['listOne']}$_itemId';

    if (kDebugMode) {
      print('Iniciando a requisição para $url...');
    }

    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        if (response.data is List && response.data.isNotEmpty) {
          final fetchedItem = response.data[0];
          // Agora que temos o item, vamos buscar o nome do proprietário
          if (fetchedItem['ownerId'] != null) {
            await _fetchOwnerName(fetchedItem['ownerId'].toString());
          }

          setState(() {
            _item = fetchedItem;
            _isLoading = false; // Carregamento concluído
          });

          if (kDebugMode) {
            print('Requisição bem-sucedida! Item carregado:');
            print(_item);
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          if (kDebugMode) {
            print('Falha ao carregar o item: Lista de dados vazia.');
          }
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        if (kDebugMode) {
          print('Falha ao carregar o item. Status: ${response.statusCode}');
        }
      }
    } on DioException catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (kDebugMode) {
        print('Erro de requisição: $e');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (kDebugMode) {
        print('Erro inesperado: $e');
      }
    }
  }

  // Nova função para buscar o nome do proprietário
  Future<void> _fetchOwnerName(String ownerId) async {
    final url = '${Config.endPoint['users']}/$ownerId';
    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _ownerName = response.data['name'];
        });
      } else {
        setState(() {
          _ownerName = 'Desconhecido';
        });
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar o nome do proprietário: $e');
      }
      setState(() {
        _ownerName = 'Desconhecido';
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erro inesperado ao buscar o nome do proprietário: $e');
      }
      setState(() {
        _ownerName = 'Desconhecido';
      });
    }
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
                        : _item != null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Passa o nome do proprietário para o widget ItemView
                        ItemView(item: _item, ownerName: _ownerName),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/edit', arguments: _item['id'].toString()).then((result) {
                              if (result == true) {
                                _fetchItem(_item['id'].toString());
                              }
                            });
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed('/');
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Voltar para a Lista'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    )
                        : const Text('Item não encontrado.'),
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
                  : _item != null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Passa o nome do proprietário para o widget ItemView
                  ItemView(item: _item, ownerName: _ownerName),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/edit', arguments: _item['id'].toString()).then((result) {
                        if (result == true) {
                          _fetchItem(_item['id'].toString());
                        }
                      });
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Voltar para a Lista'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              )
                  : const Text('Item não encontrado.'),
            ),
          );
        }
      },
    );
  }
}

// Widget para exibir os detalhes do item
class ItemView extends StatelessWidget {
  final dynamic item;
  final String? ownerName; // Novo parâmetro para o nome do proprietário

  const ItemView({super.key, required this.item, required this.ownerName});

  // Função para mapear chaves de campos para nomes traduzidos
  String _mapFieldName(String key) {
    switch (key) {
      case 'date':
        return 'Cadastrado';
      case 'ownerId': // Este caso não será mais usado, mas o mantemos para consistência
        return 'Proprietário';
      case 'location':
        return 'Localização';
      case 'status':
        return 'Situação';
      default:
        return key;
    }
  }

  // Função para formatar a data
  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      // Formato 'dd/MM/yyyy às HH:mm'
      return DateFormat('dd/MM/yyyy \'às\' HH:mm').format(date);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao formatar a data: $e');
      }
      return dateString; // Retorna a string original em caso de erro
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se a photoURL é uma string válida, caso contrário usa uma imagem de fallback.
    final String? photoUrl = item['photoURL'] is String
        ? item['photoURL']
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Imagem do item com bordas arredondadas ou fallback
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: photoUrl != null
                ? Image.network(
              photoUrl,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Icon(Icons.error));
              },
            )
                : const SizedBox(
              height: 300,
              child: Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Nome do item
          Text(
            item['name'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 8),
          // Descrição do item
          Text(
            item['description'],
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          // Exibe o nome do proprietário
          if (ownerName != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                'Proprietário: $ownerName',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          // Outros campos do item em formato de lista
          ...item.keys.map((key) {
            // Ignora os campos já exibidos e o ownerId, que será exibido separadamente
            if (key == 'id' ||
                key == 'name' ||
                key == 'photoURL' ||
                key == 'description' ||
                key == 'ownerId') {
              return const SizedBox.shrink();
            }

            // Traduz a chave e formata a data se for o campo 'date'
            final String fieldName = _mapFieldName(key);
            final dynamic fieldValue = key == 'date'
                ? _formatDate(item[key])
                : item[key];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                '$fieldName: $fieldValue',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}