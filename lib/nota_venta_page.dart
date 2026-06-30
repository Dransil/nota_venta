import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

import 'pdf_generator.dart';
import 'presets_store.dart';

/// Pantalla de la Nota de Entrega (antes vivía directamente en main.dart).
/// Una fila de detalle: Cant. / Detalle / P.U. / Total
class DetalleItem {
  TextEditingController cant = TextEditingController();
  TextEditingController detalle = TextEditingController();
  TextEditingController pu = TextEditingController();
  TextEditingController total = TextEditingController();

  double get cantidad => double.tryParse(cant.text.replaceAll(',', '.')) ?? 0;
  double get precioUnitario =>
      double.tryParse(pu.text.replaceAll(',', '.')) ?? 0;
  double get totalCalculado => cantidad * precioUnitario;
  double get totalValue =>
      double.tryParse(total.text.replaceAll(',', '.')) ?? 0;

  void recalcularTotal() {
    if (cant.text.isEmpty && pu.text.isEmpty) {
      total.text = '';
    } else {
      total.text = totalCalculado.toStringAsFixed(2);
    }
  }

  void dispose() {
    cant.dispose();
    detalle.dispose();
    pu.dispose();
    total.dispose();
  }
}

class NotaVentaPage extends StatefulWidget {
  const NotaVentaPage({super.key});

  @override
  State<NotaVentaPage> createState() => _NotaVentaPageState();
}

class _NotaVentaPageState extends State<NotaVentaPage> {
  final lugarCtrl = TextEditingController();
  final diaCtrl = TextEditingController();
  final mesCtrl = TextEditingController();
  final anoCtrl = TextEditingController();
  final senorCtrl = TextEditingController();
  final porLoSiguienteCtrl = TextEditingController();

  /// N° de nota: texto libre, vacío por defecto.
  final TextEditingController nroNotaCtrl = TextEditingController();

  final List<DetalleItem> detalles = [];

  static const Color azul = Color(0xFF1565C0);
  static const Color azulClaro = Color(0xFFD6ECFA);

  @override
  void initState() {
    super.initState();
    _cargarFilasIniciales();
  }

  /// Carga los detalles predefinidos (ya guardados con shared_preferences)
  /// y los usa para precargar la columna "Detalle" de las primeras filas.
  /// Si no hay presets guardados, deja filas vacías como antes.
  Future<void> _cargarFilasIniciales() async {
    await PresetsStore.instance.cargar();
    setState(() {
      _crearFilas();
    });
  }

  /// Construye las filas de detalle: una por cada preset guardado
  /// (con el texto ya escrito), más algunas filas vacías extra para que
  /// se puedan seguir agregando ítems manuales.
  void _crearFilas() {
    for (final d in detalles) {
      d.dispose();
    }
    detalles.clear();

    final presets = PresetsStore.instance.detalles;

    for (final texto in presets) {
      final item = DetalleItem();
      item.detalle.text = texto;
      detalles.add(item);
    }

    // Filas vacías adicionales: si no hay presets, deja 10 como antes;
    // si ya hay presets, agrega algunas extra por si se necesita más.
    final extras = presets.isEmpty ? 10 : 5;
    for (int i = 0; i < extras; i++) {
      detalles.add(DetalleItem());
    }
  }

  @override
  void dispose() {
    lugarCtrl.dispose();
    diaCtrl.dispose();
    mesCtrl.dispose();
    anoCtrl.dispose();
    senorCtrl.dispose();
    porLoSiguienteCtrl.dispose();
    nroNotaCtrl.dispose();
    for (final d in detalles) {
      d.dispose();
    }
    super.dispose();
  }

  double get totalGeneral =>
      detalles.fold(0.0, (sum, item) => sum + item.totalValue);

  /// Suma de la columna CANT. de todas las filas.
  double get cantidadGeneral =>
      detalles.fold(0.0, (sum, item) => sum + item.cantidad);

  /// Formatea un número quitando decimales si es un entero exacto
  /// (ej. 12.0 -> "12", 12.5 -> "12.50").
  String _formatoCantidad(double valor) {
    if (valor == valor.roundToDouble()) {
      return valor.toInt().toString();
    }
    return valor.toStringAsFixed(2);
  }

  void _agregarFila() {
    setState(() {
      detalles.add(DetalleItem());
    });
  }

  void _eliminarFila(int index) {
    setState(() {
      detalles[index].dispose();
      detalles.removeAt(index);
    });
  }

  Future<Uint8List> _construirPdfBytes() async {
    final items = detalles
        .where(
          (d) =>
              d.detalle.text.trim().isNotEmpty ||
              d.cant.text.trim().isNotEmpty ||
              d.pu.text.trim().isNotEmpty ||
              d.total.text.trim().isNotEmpty,
        )
        .map(
          (d) => DetalleItemPdf(
            cant: d.cant.text,
            detalle: d.detalle.text,
            pu: d.pu.text,
            total: d.total.text,
          ),
        )
        .toList();

    return NotaVentaPdfGenerator.build(
      nroNota: nroNotaCtrl.text,
      lugar: lugarCtrl.text,
      dia: diaCtrl.text,
      mes: mesCtrl.text,
      ano: anoCtrl.text,
      senor: senorCtrl.text,
      porLoSiguiente: porLoSiguienteCtrl.text,
      items: items,
      totalGeneral: totalGeneral,
      cantidadGeneral: cantidadGeneral,
    );
  }

  /// Nombre de archivo con la fecha de hoy en formato ddMMyy.
  /// Ej.: 23/06/2026 -> "nota_venta_230626"
  String _nombreArchivoConFecha() {
    final ahora = DateTime.now();
    final dd = ahora.day.toString().padLeft(2, '0');
    final mm = ahora.month.toString().padLeft(2, '0');
    final yy = (ahora.year % 100).toString().padLeft(2, '0');
    return 'nota_venta_$dd$mm$yy';
  }

  Future<void> _generarPdf() async {
    final bytes = await _construirPdfBytes();
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: _nombreArchivoConFecha(),
    );
  }

  Future<void> _compartirPdf() async {
    final bytes = await _construirPdfBytes();
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${_nombreArchivoConFecha()}.pdf',
    );
  }

  void _nuevaNota() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva nota de entrega'),
        content: const Text(
          '¿Deseas limpiar todos los campos y empezar una nota nueva?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                lugarCtrl.clear();
                diaCtrl.clear();
                mesCtrl.clear();
                anoCtrl.clear();
                senorCtrl.clear();
                porLoSiguienteCtrl.clear();
                _crearFilas();
                nroNotaCtrl.clear();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Sí, nueva nota'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: azul,
        foregroundColor: Colors.white,
        title: const Text('Nota de entrega'),
        actions: [
          IconButton(
            tooltip: 'Generar / Imprimir PDF',
            onPressed: _generarPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
          IconButton(
            tooltip: 'Compartir PDF',
            onPressed: _compartirPdf,
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(
            tooltip: 'Nueva nota',
            onPressed: _nuevaNota,
            icon: const Icon(Icons.note_add_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Card(
            elevation: 3,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: azul.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 12),
                  _buildSenor(),
                  const SizedBox(height: 14),
                  _buildTablaDetalle(),
                  const SizedBox(height: 10),
                  _buildAgregarBoton(),
                  const Divider(height: 24),
                  _buildTotales(),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text(
                      '¡Gracias por su preferencia!',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: azul,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NOTA DE ENTREGA',
                style: TextStyle(
                  color: azul,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    'N° ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 70,
                    child: TextField(
                      controller: nroNotaCtrl,
                      keyboardType: TextInputType.text,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: azul),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Table(
              border: TableBorder.symmetric(inside: BorderSide(color: azul)),
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: azul),
                  children: const [
                    _HeaderCell('LUGAR'),
                    _HeaderCell('DÍA'),
                    _HeaderCell('MES'),
                    _HeaderCell('AÑO'),
                  ],
                ),
                TableRow(
                  children: [
                    _CampoCell(controller: lugarCtrl),
                    _CampoCell(controller: diaCtrl, numero: true),
                    _CampoCell(controller: mesCtrl, numero: true),
                    _CampoCell(controller: anoCtrl, numero: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSenor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Señor (es): ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(child: TextField(controller: senorCtrl)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              'Por lo siguiente: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(child: TextField(controller: porLoSiguienteCtrl)),
          ],
        ),
      ],
    );
  }

  Widget _buildTablaDetalle() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: azul),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Container(
            color: azul,
            child: const Row(
              children: [
                SizedBox(width: 50, child: _HeaderCell('CANT.')),
                Expanded(child: _HeaderCell('DETALLE')),
                SizedBox(width: 56, child: _HeaderCell('P.U.')),
                SizedBox(width: 64, child: _HeaderCell('TOTAL')),
                SizedBox(width: 36, child: SizedBox()),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: detalles.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: azul.withOpacity(0.3)),
            itemBuilder: (context, index) {
              final item = detalles[index];
              return Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        controller: item.cant,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.center,
                        onChanged: (_) =>
                            setState(() => item.recalcularTotal()),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(controller: item.detalle),
                    ),
                  ),
                  SizedBox(
                    width: 56,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        controller: item.pu,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.right,
                        onChanged: (_) =>
                            setState(() => item.recalcularTotal()),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 64,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        controller: item.total,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.red,
                      ),
                      onPressed: () => _eliminarFila(index),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAgregarBoton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        onPressed: _agregarFila,
        icon: const Icon(Icons.add),
        label: const Text('Agregar fila de detalle'),
        style: OutlinedButton.styleFrom(foregroundColor: azul),
      ),
    );
  }

  /// Muestra la cantidad total (suma de la columna CANT.) junto con el
  /// Total Bs. general, alineados a la derecha como en la nota física.
  Widget _buildTotales() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: azulClaro,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: azul),
          ),
          child: Text(
            'CANT. TOTAL: ${_formatoCantidad(cantidadGeneral)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: azul,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: azulClaro,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: azul),
          ),
          child: Text(
            'TOTAL Bs. ${totalGeneral.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: azul,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _CampoCell extends StatelessWidget {
  final TextEditingController controller;
  final bool numero;
  const _CampoCell({required this.controller, this.numero = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: numero ? TextInputType.number : TextInputType.text,
        inputFormatters: numero
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
      ),
    );
  }
}
