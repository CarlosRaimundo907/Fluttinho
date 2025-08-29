library;

/// Página inicial do aplicativo
///     Obtém, processa e exibe a lista de itens da API

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../template/config.dart';
import '../template/myappbar.dart';
import '../template/mydrawer.dart';

// Instância privada (private) do Dio para requisições HTTP
final Dio _dio = Dio();

// Nome da página para a barra superior
var pageName = Config.appName;

// Convertemos a HomePage para StatefulWidget para gerenciar o estado dos dados
class HomePage extends StatefulWidget {
  // Construtor
  const HomePage({super.key});

  @override
  // Cria o estado mutável para este widget
  State<HomePage> createState() => _HomePageState();
}

// A classe de estado da HomePage
class _HomePageState extends State<HomePage> {
  // Lista para armazenar os itens da API
  List<dynamic> _items = [];

  // Variável para controlar o estado de carregamento
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Chama a função para buscar os itens da API assim que o widget é criado
    _fetchItems();
  }

  // Função assíncrona para buscar os itens da API
  void _fetchItems() async {
    // Usamos o endpoint 'listAll' do arquivo config.dart, que já tem os filtros
    final url = Config.endPoint['listAll'];

    try {
      // Faz a requisição GET para o endpoint da API
      final response = await _dio.get(url);

      // Verifica se a resposta foi bem-sucedida (status code 200)
      if (response.statusCode == 200) {
        // Converte a resposta em uma lista de objetos
        final List<dynamic> allItems = response.data;

        // Atualiza o estado com a lista filtrada e ordenada (agora que o backend faz o trabalho)
        setState(() {
          _items = allItems;
          _isLoading = false; // Define o carregamento como concluído
        });
      } else {
        // Em caso de erro, define o carregamento como falso
        setState(() {
          _isLoading = false;
        });
      }
    } on DioException {
      // Trata erros de requisição, como problemas de rede
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // Trata outros erros inesperados
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder permite ajustar o conteúdo para resoluções diferentes
    return LayoutBuilder(
      builder: (context, constraints) {
        // Se a largura é de 1080+
        if (constraints.maxWidth > 1080) {
          // Versão para desktop
          return Row(
            children: [
              const MyDrawer(), // O menu lateral fixo
              Expanded(
                // Usei um Scaffold aninhado para ter uma AppBar na página
                child: Scaffold(
                  appBar: MyAppBar(title: pageName),
                  // O conteúdo principal da página
                  body: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator() // Exibe um indicador de carregamento
                        : PageContent(items: _items, isDesktop: true),
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/new');
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
            ],
          );
        } else {
          // Versão para mobile/tablet
          return Scaffold(
            appBar: MyAppBar(title: pageName),
            drawer: const MyDrawer(), // O menu deslizante
            body: Center(
              child: _isLoading
                  ? const CircularProgressIndicator() // Exibe um indicador de carregamento
                  : PageContent(items: _items),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/new');
              },
              child: const Icon(Icons.add),
            ),
          );
        }
      },
    );
  }
}

// Conteúdo da página atual a ser usado em qualquer resolução
class PageContent extends StatelessWidget {
  // Lista de itens a ser exibida
  final List<dynamic> items;
  final bool isDesktop;

  const PageContent({super.key, required this.items, this.isDesktop = false});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Nenhum item encontrado.'),
          SizedBox(height: 20),
          Text('Verifique se o seu servidor JSON está ativo.'),
        ],
      );
    }

    // Define o número de colunas baseado no tamanho da tela
    final crossAxisCount = isDesktop ? 4 : 2;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.9,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
      ),
      padding: const EdgeInsets.all(16.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        // Retorna o novo Card personalizado
        return ItemCard(item: item);
      },
    );
  }
}

// O Widget de Card personalizado para cada item
class ItemCard extends StatelessWidget {
  final dynamic item;

  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // Trunca a descrição com um limite de 50 caracteres e adiciona '...'
    String truncatedDescription = item['description'].length > 50
        ? '${item['description'].substring(0, 50)}...'
        : item['description'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Torna o Card clicável e adiciona o feedback visual
        onTap: () {
          // Navega para a rota "/view" passando o 'id' como argumento, convertido para String
          Navigator.of(
            context,
          ).pushNamed('/view', arguments: item['id'].toString());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagem do item com altura fixa para garantir a proporção dos cards
            SizedBox(
              height: 150,
              // Altura fixa para todas as imagens
              width: double.infinity,
              // Garante que a imagem ocupe toda a largura disponível
              child: Image.network(
                item['photoURL'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.error));
                },
              ),
            ),
            // Título e descrição do item
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1, // Limita o título a uma linha
                    overflow: TextOverflow
                        .ellipsis, // Adiciona "..." se o título for muito longo
                  ),
                  const SizedBox(height: 4),
                  Text(
                    truncatedDescription,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    maxLines: 2, // Limita a descrição a duas linhas
                    overflow: TextOverflow
                        .ellipsis, // Adiciona "..." se o texto for muito longo
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}