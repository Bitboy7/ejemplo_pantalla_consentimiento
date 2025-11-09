import 'package:flutter/material.dart';
import 'screens/consent_screen.dart';

void main() {
  runApp(const ConsentApp());
}

/// Widget raíz de la aplicación
class ConsentApp extends StatelessWidget {
  const ConsentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pantalla de Consentimiento',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ConsentScreen(),
    );
  }
}
