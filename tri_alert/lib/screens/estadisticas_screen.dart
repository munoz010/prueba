import 'package:flutter/material.dart';
import '../services/incidencia_service.dart';
import '../utils/app_colors.dart';
import '../widgets/tri_alert_appbar.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _incService  = IncidenciaService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.homeBackground,
      appBar: TriAlertAppBar(
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _incService.estadisticas(),
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

          final data        = snap.data!;
          final total       = data['total'] as int;
          final reportados  = data['reportados'] as int;
          final enProgreso  = data['enProgreso'] as int;
          final resueltos   = data['resueltos'] as int;
          final porTipo     = data['porTipo'] as Map<String, int>;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Cabecera ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text('Estadísticas',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

                // ── Tarjeta Total ──────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total de Incidencias',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
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
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── Tarjetas de estado ─────────────────────────
                Row(
                  children: [
                    _StatCard(
                      value: '$reportados',
                      label: 'Reportados',
                      color: const Color(0xFF8B1A1A),
                      textColor: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      value: '$enProgreso',
                      label: 'En Progreso',
                      color: const Color(0xFF2A3080),
                      textColor: Colors.blueAccent,
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      value: '$resueltos',
                      label: 'Resueltos',
                      color: const Color(0xFF1A4030),
                      textColor: AppColors.successLight,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Incidencias por tipo ───────────────────────
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
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: AppColors.navBarBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home_rounded,
                  color: Colors.white60, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
            Container(
              width: 48, height: 48,
              decoration: const BoxDecoration(
                  color: Color(0xFF3A2D9A), shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 26),
            ),
            const Icon(Icons.bar_chart_rounded,
                color: AppColors.primary, size: 28),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color textColor;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: Colors.white60, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _TipoRow extends StatelessWidget {
  final String tipo;
  final int cantidad;
  const _TipoRow({required this.tipo, required this.cantidad});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.inputHomeBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(tipo,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
          Text('$cantidad',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
