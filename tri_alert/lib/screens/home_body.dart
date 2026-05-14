import 'package:flutter/material.dart';
import '../models/incidencia_model.dart';
import '../services/incidencia_service.dart';
import '../utils/app_colors.dart';

/// Solo contenido — sin Scaffold, AppBar ni NavBar propios.
/// El MainShell los provee globalmente.
class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  final _incService = IncidenciaService();
  String _busqueda  = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── BUSCADOR ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.inputHomeBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.inputHomeBorder),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(Icons.search, color: Colors.white54, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Buscar incidencia..',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (v) => setState(() => _busqueda = v),
                  ),
                ),
                const Icon(Icons.tune, color: Colors.white38, size: 20),
                const SizedBox(width: 14),
              ],
            ),
          ),
        ),

        // ── LISTA ──────────────────────────────────────────────────
        Expanded(
          child: StreamBuilder<List<IncidenciaModel>>(
            stream: _incService.streamTodas(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              var lista = snap.data ?? [];
              if (_busqueda.isNotEmpty) {
                final q = _busqueda.toLowerCase();
                lista = lista.where((i) =>
                  i.titulo.toLowerCase().contains(q) ||
                  i.tipo.toLowerCase().contains(q) ||
                  i.ubicacion.toLowerCase().contains(q)).toList();
              }
              if (lista.isEmpty) {
                return const Center(
                  child: Text('No hay incidencias registradas.',
                      style: TextStyle(color: Colors.white54)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: lista.length,
                itemBuilder: (ctx, i) =>
                    _IncidenciaCard(inc: lista[i], numero: i + 1),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── TARJETA ──────────────────────────────────────────────────────────
class _IncidenciaCard extends StatelessWidget {
  final IncidenciaModel inc;
  final int numero;
  const _IncidenciaCard({required this.inc, required this.numero});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // ← Ruta nombrada con argumento
      onTap: () => Navigator.pushNamed(context, '/detalle', arguments: inc),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('#$numero ${_trunc(inc.titulo, 22)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Container(
                      width: 7, height: 7,
                      decoration: BoxDecoration(
                          color: _estadoColor(inc.estado),
                          shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text(inc.estado,
                        style: TextStyle(
                            color: _estadoColor(inc.estado),
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        color: Colors.white38, size: 14),
                    const SizedBox(width: 4),
                    Text(_trunc(inc.ubicacion, 24),
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                  ]),
                ],
              ),
            ),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(12)),
              // ✅ Thumbnail en lista (carga rápida)
              child: (inc.fotoThumbUrl ?? inc.fotoUrl) != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        inc.fotoThumbUrl ?? inc.fotoUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, progress) =>
                            progress == null
                                ? child
                                : const Center(
                                    child: SizedBox(
                                      width: 20, height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white24))),
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.camera_alt,
                                color: Colors.white24, size: 30)))
                  : const Icon(Icons.camera_alt,
                      color: Colors.white24, size: 30),
            ),
          ],
        ),
      ),
    );
  }

  Color _estadoColor(String e) {
    switch (e) {
      case 'En Progreso': return AppColors.warning;
      case 'Resuelto':    return AppColors.successLight;
      default:            return AppColors.primary;
    }
  }

  String _trunc(String s, int max) =>
      s.length > max ? '${s.substring(0, max)}...' : s;
}
