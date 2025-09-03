library;

/// Página de informações(Sobre)
///     Exibe informações sobre o App

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../template/myappbar.dart';
import '../template/myfooter.dart';
import '../template/mydrawer.dart';

// Instância privada (private) do Dio
final Dio _dio = Dio();

// Nome da página (AppBar)
final pageName = 'Faça contato';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPage();
}

class _InfoPage extends State<InfoPage> {
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
                    child: _pageContent(),
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
              child: _pageContent(),
            ),
            bottomNavigationBar: const MyBottomNavBar(),
          );
        }
      },
    );
  }

  Widget _pageContent() {
    return Center(
      child: SizedBox(width: 540, child: Text("Informações do Aplicativo...")),
    );
  }
}
