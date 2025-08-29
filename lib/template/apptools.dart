import 'package:flutter/material.dart';

/// Método auxiliar para exibir a SnackBar
/// Requer um BuildContext para funcionar.
void showSnackBar(BuildContext context, String message, {Color? color}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ),
  );
}