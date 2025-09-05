library;

import 'package:firebase_auth/firebase_auth.dart';
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
  List<dynamic> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  void _fetchItems() async {
    final url = Config.endPoint['listAll'];
    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> allItems = response.data;
        setState(() {
          _items = allItems;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } on DioException {
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Wrapper para o FloatingActionButton para controlar sua visibilidade
        Widget? floatingActionButton;

        // Use um StreamBuilder para decidir se o FAB deve ser exibido
        floatingActionButton = StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            final user = snapshot.data;
            if (user != null) {
              // Se o usuário estiver logado, exibe o FAB
              return FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/new');
                },
                child: const Icon(Icons.add),
              );
            } else {
              // Se não estiver logado, retorna null para não exibir o FAB
              return const SizedBox.shrink();
            }
          },
        );

        // Se a largura é de 1080+
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
                        : PageContent(items: _items, isDesktop: true),
                  ),
                  floatingActionButton: floatingActionButton,
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
                  : PageContent(items: _items),
            ),
            floatingActionButton: floatingActionButton,
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