import 'package:flutter/material.dart';

import 'home_page.dart';

void main() {
  runApp(const NotaVentaApp());
}

class NotaVentaApp extends StatelessWidget {
  const NotaVentaApp({super.key});

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF1565C0);
    return MaterialApp(
      title: 'Mis Notas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: azul,
        scaffoldBackgroundColor: const Color(0xFFEAF4FB),
        inputDecorationTheme: const InputDecorationTheme(
          isDense: true,
          border: UnderlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        ),
      ),
      home: const HomePage(),
    );
  }
}
