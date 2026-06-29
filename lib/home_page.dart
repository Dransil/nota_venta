import 'package:flutter/material.dart';

import 'nota_venta_page.dart';
import 'presets_page.dart';

/// Menú principal de la app. Desde aquí se navega a las distintas
/// pantallas (por ahora "Nota de Entrega" y "Detalles predefinidos").
/// Las tarjetas ocupan la mayor parte de la pantalla para que sean
/// grandes y fáciles de tocar.
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: _MenuCard(
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
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _MenuCard(
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
              ),
              // Para agregar más opciones a futuro, agrega otro
              // SizedBox(height: 16) + Expanded(child: _MenuCard(...))
              // y ajusta el "flex" si quieres tamaños distintos entre tarjetas.
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
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: HomePage.azul.withOpacity(0.25)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: HomePage.azul.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: HomePage.azul, size: 64),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
