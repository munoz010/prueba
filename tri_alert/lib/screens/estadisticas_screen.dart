import 'package:flutter/material.dart';
import '../services/incidencia_service.dart';
import '../utils/app_colors.dart';

/// Solo contenido — sin Scaffold, AppBar ni NavBar propios.
/// El MainShell los provee globalmente.
class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ StreamBuilder — se actualiza automáticamente en tiempo real
    return StreamBuilder<Map<String, dynamic>>(
      stream: IncidenciaService().streamEstadisticas(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snap.hasError) {
          return Center(
            child: Text('Error: ${snap.error}',
                style: const TextStyle(color: Colors.white60)),
          );
        }

        final data       = snap.data!;
        final total      = data['total']      as int;
        final reportados = data['reportados'] as int;
        final enProgreso = data['enProgreso'] as int;
        final resueltos  = data['resueltos']  as int;
        final porTipo    = data['porTipo']    as Map<String, int>;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('Estadísticas',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),

              // ── Total ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total de Incidencias',
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                      const SizedBox(height: 6),
                      Text('$total',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.bar_chart_rounded,
                      color: Colors.white, size: 40),
                ]),
              ),
              const SizedBox(height: 14),

              // ── Por estado ────────────────────────────────────
              Row(children: [
                _StatCard(value: '$reportados', label: 'Reportados',
                    bg: const Color(0xFF8B1A1A), textColor: AppColors.primary),
                const SizedBox(width: 10),
                _StatCard(value: '$enProgreso', label: 'En Progreso',
                    bg: const Color(0xFF2A3080), textColor: Colors.blueAccent),
                const SizedBox(width: 10),
                _StatCard(value: '$resueltos', label: 'Resueltos',
                    bg: const Color(0xFF1A4030), textColor: AppColors.successLight),
              ]),
              const SizedBox(height: 16),

              // ── Por tipo ──────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Incidencias por tipo',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (porTipo.isEmpty)
                      const Text('Sin datos',
                          style: TextStyle(color: Colors.white54))
                    else
                      ...porTipo.entries
                          .map((e) => _TipoRow(tipo: e.key, cantidad: e.value))
                          .toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final Color bg, textColor;
  const _StatCard({required this.value, required this.label,
      required this.bg, required this.textColor});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Text(value,
            style: TextStyle(
                color: textColor, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ]),
    ),
  );
}

class _TipoRow extends StatelessWidget {
  final String tipo;
  final int cantidad;
  const _TipoRow({required this.tipo, required this.cantidad});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
        color: AppColors.inputHomeBg,
        borderRadius: BorderRadius.circular(10)),
    child: Row(children: [
      Expanded(child: Text(tipo,
          style: const TextStyle(color: Colors.white, fontSize: 14))),
      Text('$cantidad',
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    ]),
  );
}
