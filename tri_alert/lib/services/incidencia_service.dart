import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incidencia_model.dart';

class IncidenciaService {
  static final IncidenciaService _instance = IncidenciaService._internal();
  factory IncidenciaService() => _instance;
  IncidenciaService._internal();

  final _col = FirebaseFirestore.instance.collection('incidencias');

  // ── STREAM lista en tiempo real ─────────────────────────────────────
  Stream<List<IncidenciaModel>> streamTodas() {
    return _col
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => IncidenciaModel.fromMap(d.data(), d.id))
            .toList());
  }

  // ── CREAR ───────────────────────────────────────────────────────────
  Future<void> crear(IncidenciaModel inc) async {
    await _col.add(inc.toMap());
  }

  // ── ACTUALIZAR ESTADO ───────────────────────────────────────────────
  Future<void> actualizarEstado(String id, String nuevoEstado) async {
    await _col.doc(id).update({'estado': nuevoEstado});
  }

  // ── ELIMINAR ────────────────────────────────────────────────────────
  Future<void> eliminar(String id) async {
    await _col.doc(id).delete();
  }

  // ── ESTADÍSTICAS ────────────────────────────────────────────────────
  Future<Map<String, dynamic>> estadisticas() async {
    final snap = await _col.get();
    final lista =
        snap.docs.map((d) => IncidenciaModel.fromMap(d.data(), d.id)).toList();

    final total = lista.length;
    final reportados =
        lista.where((i) => i.estado == 'Reportado').length;
    final enProgreso =
        lista.where((i) => i.estado == 'En Progreso').length;
    final resueltos =
        lista.where((i) => i.estado == 'Resuelto').length;

    // Conteo por tipo
    final Map<String, int> porTipo = {};
    for (final i in lista) {
      porTipo[i.tipo] = (porTipo[i.tipo] ?? 0) + 1;
    }

    return {
      'total': total,
      'reportados': reportados,
      'enProgreso': enProgreso,
      'resueltos': resueltos,
      'porTipo': porTipo,
    };
  }
}
