import 'package:flutter/material.dart';

import 'presets_store.dart';

/// Pantalla donde el usuario gestiona la lista de "detalles predefinidos"
/// (palabras/frases que se precargan automáticamente al crear una nueva
/// Nota de Venta). Se guardan de forma persistente con shared_preferences.
class PresetsPage extends StatefulWidget {
  const PresetsPage({super.key});

  @override
  State<PresetsPage> createState() => _PresetsPageState();
}

class _PresetsPageState extends State<PresetsPage> {
  static const Color azul = Color(0xFF1565C0);

  final TextEditingController _nuevoCtrl = TextEditingController();
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    await PresetsStore.instance.cargar();
    setState(() => _cargando = false);
  }

  @override
  void dispose() {
    _nuevoCtrl.dispose();
    super.dispose();
  }

  Future<void> _agregar() async {
    final texto = _nuevoCtrl.text;
    if (texto.trim().isEmpty) return;
    await PresetsStore.instance.agregar(texto);
    _nuevoCtrl.clear();
    setState(() {});
  }

  Future<void> _eliminar(int index) async {
    await PresetsStore.instance.eliminar(index);
    setState(() {});
  }

  Future<void> _editar(int index, String actual) async {
    final ctrl = TextEditingController(text: actual);
    final nuevoTexto = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar detalle'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (nuevoTexto != null && nuevoTexto.trim().isNotEmpty) {
      await PresetsStore.instance.editar(index, nuevoTexto);
      setState(() {});
    }
  }

  Future<void> _confirmarLimpiarTodo() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar todos los detalles'),
        content: const Text(
          '¿Seguro que deseas eliminar todos los detalles predefinidos? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, borrar todo'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await PresetsStore.instance.limpiarTodo();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final detalles = PresetsStore.instance.detalles;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: azul,
        foregroundColor: Colors.white,
        title: const Text('Detalles predefinidos'),
        actions: [
          if (detalles.isNotEmpty)
            IconButton(
              tooltip: 'Borrar todos',
              onPressed: _confirmarLimpiarTodo,
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nuevoCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Nuevo detalle',
                              hintText: 'Ej: Producto, servicio, etc...',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onSubmitted: (_) => _agregar(),
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _agregar,
                          style: FilledButton.styleFrom(backgroundColor: azul),
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: detalles.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Aún no agregaste ningún detalle predefinido.\n\n'
                                'Estos son textos que se precargarán '
                                'automáticamente en la columna "Detalle" '
                                'cada vez que crees una nueva Nota de Venta.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ),
                          )
                        : ReorderableListView.builder(
                            padding: const EdgeInsets.only(bottom: 12),
                            itemCount: detalles.length,
                            onReorder: (oldIndex, newIndex) async {
                              await PresetsStore.instance.reordenar(
                                oldIndex,
                                newIndex,
                              );
                              setState(() {});
                            },
                            itemBuilder: (context, index) {
                              final texto = detalles[index];
                              return ListTile(
                                key: ValueKey('$index-$texto'),
                                leading: const Icon(
                                  Icons.drag_indicator,
                                  color: Colors.grey,
                                ),
                                title: Text(texto),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: azul,
                                      ),
                                      onPressed: () => _editar(index, texto),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _eliminar(index),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
