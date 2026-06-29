import 'package:flutter/material.dart';

import 'nota_venta_page.dart';
import 'presets_page.dart';

/// Menú principal de la app. Muestra el logo y el título arriba, y debajo
/// dos tarjetas cuadradas en fila (horizontal) con íconos grandes.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color azul = Color(0xFF1565C0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB),
      appBar: AppBar(
        backgroundColor: azul,
        foregroundColor: Colors.white,
        title: const Text('Mis notas'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Logo + título arriba
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icon/icon.png',
                      height: 120,
                      width: 120,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'MIS NOTAS DE ENTREGA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: azul,
                      ),
                    ),
                  ],
                ),
              ),
              // Tarjetas cuadradas en fila, centradas en el espacio restante
              Expanded(
                flex: 5,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: _MenuCard(
                            icon: Icons.receipt_long_outlined,
                            title: 'Nota de\nEntrega',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotaVentaPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: _MenuCard(
                            icon: Icons.list_alt_outlined,
                            title: 'Detalles\npredefinidos',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PresetsPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: HomePage.azul.withOpacity(0.25)),
          ),
          width: double.infinity,
          height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // El ícono crece ocupando la mayor parte del cuadrado.
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Icon(icon, color: HomePage.azul),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
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
