import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Representación simple de una fila de detalle, ya convertida a texto,
/// para no depender de TextEditingController dentro del generador de PDF.
class DetalleItemPdf {
  final String cant;
  final String detalle;
  final String pu;
  final String total;

  DetalleItemPdf({
    required this.cant,
    required this.detalle,
    required this.pu,
    required this.total,
  });
}

/// Genera el PDF de la Nota de Venta replicando el formato del talonario físico.
class NotaVentaPdfGenerator {
  static const PdfColor azul = PdfColor.fromInt(0xFF1565C0);
  static const PdfColor azulClaro = PdfColor.fromInt(0xFFD6ECFA);

  static Future<List<int>> build({
    required String nroNota,
    required String lugar,
    required String dia,
    required String mes,
    required String ano,
    required String senor,
    required String porLoSiguiente,
    required List<DetalleItemPdf> items,
    required double totalGeneral,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(nroNota, lugar, dia, mes, ano),
              pw.SizedBox(height: 12),
              _buildSenor(senor, porLoSiguiente),
              pw.SizedBox(height: 12),
              _buildTabla(items),
              pw.SizedBox(height: 10),
              _buildTotal(totalGeneral),
              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  '¡Gracias por su preferencia!',
                  style: pw.TextStyle(
                    fontStyle: pw.FontStyle.italic,
                    color: azul,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildHeader(
      String nroNota, String lugar, String dia, String mes, String ano) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'NOTA DE VENTA',
                style: pw.TextStyle(
                  color: azul,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text('N° $nroNota', style: const pw.TextStyle(fontSize: 11)),
            ],
          ),
        ),
        pw.Expanded(
          flex: 4,
          child: pw.Table(
            border: pw.TableBorder.all(color: azul, width: 0.7),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: azul),
                children: [
                  _headerCell('LUGAR'),
                  _headerCell('DÍA'),
                  _headerCell('MES'),
                  _headerCell('AÑO'),
                ],
              ),
              pw.TableRow(
                children: [
                  _valueCell(lugar),
                  _valueCell(dia),
                  _valueCell(mes),
                  _valueCell(ano),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSenor(String senor, String porLoSiguiente) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Text('Señor (es): ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            pw.Expanded(
              child: pw.Container(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                ),
                child: pw.Text(senor, style: const pw.TextStyle(fontSize: 10)),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Row(
          children: [
            pw.Text('Por lo siguiente: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            pw.Expanded(
              child: pw.Container(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                ),
                child: pw.Text(porLoSiguiente,
                    style: const pw.TextStyle(fontSize: 10)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTabla(List<DetalleItemPdf> items) {
    final filas = items.isEmpty
        ? [DetalleItemPdf(cant: '', detalle: '', pu: '', total: '')]
        : items;

    return pw.Table(
      border: pw.TableBorder.all(color: azul, width: 0.7),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.2),
        1: pw.FlexColumnWidth(4),
        2: pw.FlexColumnWidth(1.4),
        3: pw.FlexColumnWidth(1.6),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: azul),
          children: [
            _headerCell('CANT.'),
            _headerCell('DETALLE'),
            _headerCell('P.U.'),
            _headerCell('TOTAL'),
          ],
        ),
        ...filas.map(
          (item) => pw.TableRow(
            children: [
              _valueCell(item.cant, align: pw.TextAlign.center),
              _valueCell(item.detalle, align: pw.TextAlign.left),
              _valueCell(item.pu, align: pw.TextAlign.right),
              _valueCell(item.total, align: pw.TextAlign.right),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTotal(double totalGeneral) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: pw.BoxDecoration(
          color: azulClaro,
          border: pw.Border.all(color: azul, width: 0.7),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          'TOTAL Bs. ${totalGeneral.toStringAsFixed(2)}',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 13,
            color: azul,
          ),
        ),
      ),
    );
  }

  static pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 3),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 9,
        ),
      ),
    );
  }

  static pw.Widget _valueCell(String text, {pw.TextAlign? align}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 3),
      child: pw.Text(
        text,
        textAlign: align ?? pw.TextAlign.center,
        style: const pw.TextStyle(fontSize: 9),
      ),
    );
  }
}
