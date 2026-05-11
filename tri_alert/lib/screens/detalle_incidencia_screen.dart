import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/incidencia_model.dart';
import '../services/incidencia_service.dart';
import '../utils/app_colors.dart';
import '../widgets/tri_alert_appbar.dart';

class DetalleIncidenciaScreen extends StatefulWidget {
  final IncidenciaModel incidencia;
  const DetalleIncidenciaScreen({super.key, required this.incidencia});

  @override
  State<DetalleIncidenciaScreen> createState() =>
      _DetalleIncidenciaScreenState();
}

class _DetalleIncidenciaScreenState extends State<DetalleIncidenciaScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _incService  = IncidenciaService();

  late String _estadoSeleccionado;
  bool _guardando = false;

  final List<String> _estados = ['Reportado', 'En Progreso', 'Resuelto'];

  @override
  void initState() {
    super.initState();
    _estadoSeleccionado = widget.incidencia.estado;
  }

  Future<void> _actualizar() async {
    setState(() => _guardando = true);
    try {
      await _incService.actualizarEstado(
          widget.incidencia.id, _estadoSeleccionado);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estado actualizado correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inc = widget.incidencia;
    final fecha = DateFormat('dd/MM/yyyy').format(inc.fecha);
    final hora  = DateFormat('HH:mm').format(inc.fecha);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.homeBackground,
      appBar: TriAlertAppBar(
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cabecera con flecha y título ──────────────────────
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
                  const Text(
                    'Detalle incidencia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ── Tipo ─────────────────────────────────────────────
            const _Label('Tipo de incidente*'),
            _InfoBox(inc.tipo),
            const SizedBox(height: 10),

            // ── Título ───────────────────────────────────────────
            _InfoBox(inc.titulo),
            const SizedBox(height: 10),

            // ── Descripción ──────────────────────────────────────
            const _Label('Descripcion detallada*'),
            _InfoBox(inc.descripcion, minLines: 3),
            const SizedBox(height: 10),

            // ── Foto ─────────────────────────────────────────────
            const _Label('Fotografia detallada*'),
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.inputHomeBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.inputHomeBorder,
                    style: BorderStyle.solid),
              ),
              child: inc.fotoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(inc.fotoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.broken_image,
                                  color: Colors.white24, size: 48))))
                  : const Center(
                      child: Icon(Icons.camera_alt,
                          color: Colors.white24, size: 48)),
            ),
            const SizedBox(height: 10),

            // ── Ubicación ────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.inputHomeBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.inputHomeBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(inc.ubicacion,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14)),
                  ),
                  const Icon(Icons.location_on_outlined,
                      color: Colors.white38, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Fecha y Hora ─────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('Fecha'),
                      _InfoBox(fecha),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('Hora'),
                      _InfoBox(hora),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Estado + botón Actualizar ─────────────────────────
            const _Label('Estado'),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.inputHomeBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.inputHomeBorder),
                    ),
                    child: DropdownButton<String>(
                      value: _estadoSeleccionado,
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: AppColors.cardDark,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Colors.white70),
                      items: _estados
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Row(
                                  children: [
                                    Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                            color: _estadoColor(e),
                                            shape: BoxShape.circle)),
                                    const SizedBox(width: 8),
                                    Text(e,
                                        style: TextStyle(
                                            color: _estadoColor(e),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14)),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _estadoSeleccionado = v!),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _guardando ? null : _actualizar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successLight,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                    ),
                    child: _guardando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Actualizar',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ],
        ),
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
                  color: AppColors.primary, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF3A2D9A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 26),
            ),
            const Icon(Icons.bar_chart_rounded,
                color: Colors.white60, size: 28),
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
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(text,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
      );
}

class _InfoBox extends StatelessWidget {
  final String text;
  final int minLines;
  const _InfoBox(this.text, {this.minLines = 1});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: AppColors.inputHomeBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.inputHomeBorder),
        ),
        child: Text(text,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
      );
}
