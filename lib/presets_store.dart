import 'package:shared_preferences/shared_preferences.dart';

/// Almacén de los "detalles predefinidos" que se quieren precargar
/// automáticamente al crear una nueva Nota de Venta.
///
/// Usa `shared_preferences` para persistir la lista en el dispositivo
/// (no es una base de datos: es solo un archivo simple de configuración
/// clave-valor). Esto significa que los detalles predefinidos se mantienen
/// guardados aunque cierres la app por completo o reinicies el celular.
///
/// Es un singleton sencillo: cualquier pantalla puede leer/modificar la
/// misma lista llamando a `PresetsStore.instance`.
class PresetsStore {
  PresetsStore._internal();

  static final PresetsStore instance = PresetsStore._internal();

  static const String _prefsKey = 'detalles_predefinidos';

  final List<String> _detalles = [];
  bool _cargado = false;

  /// Copia de solo lectura de los detalles predefinidos actuales.
  List<String> get detalles => List.unmodifiable(_detalles);

  bool get isEmpty => _detalles.isEmpty;

  /// Carga los detalles guardados desde el disco. Debe llamarse una vez
  /// (por ejemplo al iniciar la app, antes de mostrar el menú); las
  /// siguientes llamadas no vuelven a leer del disco si ya se cargó.
  Future<void> cargar() async {
    if (_cargado) return;
    final prefs = await SharedPreferences.getInstance();
    final guardados = prefs.getStringList(_prefsKey) ?? [];
    _detalles
      ..clear()
      ..addAll(guardados);
    _cargado = true;
  }

  Future<void> _guardar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _detalles);
  }

  Future<void> agregar(String detalle) async {
    final texto = detalle.trim();
    if (texto.isEmpty) return;
    if (_detalles.contains(texto)) return; // evita duplicados exactos
    _detalles.add(texto);
    await _guardar();
  }

  Future<void> editar(int index, String nuevoTexto) async {
    final texto = nuevoTexto.trim();
    if (texto.isEmpty) return;
    if (index < 0 || index >= _detalles.length) return;
    _detalles[index] = texto;
    await _guardar();
  }

  Future<void> eliminar(int index) async {
    if (index < 0 || index >= _detalles.length) return;
    _detalles.removeAt(index);
    await _guardar();
  }

  Future<void> reordenar(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _detalles.removeAt(oldIndex);
    _detalles.insert(newIndex, item);
    await _guardar();
  }

  Future<void> limpiarTodo() async {
    _detalles.clear();
    await _guardar();
  }
}
