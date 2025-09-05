library;

/// Página de Políticas de Privacidade
///     Mostra as Políticas de Privacidade do App

import 'package:flutter/material.dart';
import '../template/myappbar.dart';
import '../template/mydrawer.dart';

// Nome da página (AppBar)
final pageName = 'Sua Privacidade';

class PoliciesPage extends StatefulWidget {
  const PoliciesPage({super.key});

  @override
  State<PoliciesPage> createState() => _PoliciesPage();
}

class _PoliciesPage extends State<PoliciesPage> {
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
          );
        }
      },
    );
  }

  Widget _pageContent() {
    return Center(
      child: SizedBox(width: 540, child: Text("Políticas de Privacidade...")),
    );
  }
}
