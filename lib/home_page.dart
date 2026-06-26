import 'package:flutter/material.dart';

import 'nota_venta_page.dart';
import 'presets_page.dart';

/// Menú principal de la app. Desde aquí se navega a las distintas
/// pantallas (por ahora solo "Nota de Entrega", pero queda listo para
/// agregar más tipos de documentos a futuro).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color azul = Color(0xFF1565C0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: azul,
        foregroundColor: Colors.white,
        title: const Text('Mis Notas'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            const Text(
              '¿Qué deseas hacer?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: azul,
              ),
            ),
            const SizedBox(height: 16),
            _MenuCard(
              icon: Icons.receipt_long_outlined,
              title: 'Nota de Entrega',
              subtitle: 'Crear una nueva nota de entrega/venta',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotaVentaPage()),
                );
              },
            ),
            const SizedBox(height: 10),
            _MenuCard(
              icon: Icons.list_alt_outlined,
              title: 'Detalles predefinidos',
              subtitle: 'Configurar textos que se precargan en cada nota',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PresetsPage()),
                );
              },
            ),
            // Aquí se pueden agregar más opciones en el futuro, por ejemplo:
            // _MenuCard(
            //   icon: Icons.history_outlined,
            //   title: 'Historial',
            //   subtitle: 'Ver notas generadas anteriormente',
            //   onTap: () {},
            // ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: HomePage.azul.withOpacity(0.25)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: HomePage.azul.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: HomePage.azul, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
