import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/incidencia_model.dart';
import '../services/incidencia_service.dart';
import '../utils/app_colors.dart';

/// Esta pantalla SÍ tiene su propio Scaffold porque se abre
/// ENCIMA del MainShell con Navigator.pushNamed('/detalle').
class DetalleIncidenciaScreen extends StatefulWidget {
  final IncidenciaModel incidencia;
  const DetalleIncidenciaScreen({super.key, required this.incidencia});

  @override
  State<DetalleIncidenciaScreen> createState() =>
      _DetalleIncidenciaScreenState();
}

class _DetalleIncidenciaScreenState
    extends State<DetalleIncidenciaScreen> {
  final _incService = IncidenciaService();
  late String _estadoSeleccionado;
  bool _guardando = false;
  final List<String> _estados = ['Reportado', 'En Progreso', 'Resuelto'];

  String? _alertType;
  String? _alertMsg;

  void _showAlert(String type, String msg) {
    setState(() { _alertType = type; _alertMsg = msg; });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() { _alertType = null; _alertMsg = null; });
    });
  }

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
        _showAlert('success', 'Actualizado con éxito');
        // Espera que el usuario vea la alerta y vuelve al home
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
        }
      }
    } catch (e) {
      if (mounted) _showAlert('error', 'Error: $e');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inc   = widget.incidencia;
    final fecha = DateFormat('dd/MM/yyyy').format(inc.fecha);
    final hora  = DateFormat('HH:mm').format(inc.fecha);

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      // ── AppBar propio con botón back ───────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.appBarPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          // Vuelve al MainShell sin acumular rutas
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detalle incidencia',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none,
                color: Colors.white, size: 26),
            onPressed: () {},
          ),
        ],
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipo
            const _Label('Tipo de incidente*'),
            _InfoBox(inc.tipo),
            const SizedBox(height: 10),
            _InfoBox(inc.titulo),
            const SizedBox(height: 10),

            // Descripción
            const _Label('Descripcion detallada*'),
            _InfoBox(inc.descripcion, minLines: 3),
            const SizedBox(height: 10),

            // Foto — toca para ver en pantalla completa (imagen original)
            const _Label('Fotografia detallada*'),
            GestureDetector(
              onTap: inc.fotoUrl != null
                  ? () => _abrirImagenCompleta(inc.fotoUrl!)
                  : null,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity, height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.inputHomeBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.inputHomeBorder),
                    ),
                    child: inc.fotoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              inc.fotoThumbUrl ?? inc.fotoUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (ctx, child, progress) =>
                                  progress == null ? child :
                                  const Center(child: CircularProgressIndicator(
                                      color: AppColors.primary, strokeWidth: 2)),
                              errorBuilder: (_, __, ___) =>
                                  const Center(child: Icon(Icons.broken_image,
                                      color: Colors.white24, size: 48))))
                        : const Center(child: Icon(Icons.camera_alt,
                            color: Colors.white24, size: 48)),
                  ),
                  // Ícono de lupa para indicar que se puede ampliar
                  if (inc.fotoUrl != null)
                    Positioned(
                      bottom: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.zoom_in,
                            color: Colors.white, size: 18),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Ubicación
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.inputHomeBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.inputHomeBorder),
              ),
              child: Row(children: [
                Expanded(child: Text(inc.ubicacion,
                    style: const TextStyle(color: Colors.white, fontSize: 14))),
                const Icon(Icons.location_on_outlined,
                    color: Colors.white38, size: 18),
              ]),
            ),
            const SizedBox(height: 14),

            // Fecha y Hora
            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [const _Label('Fecha'), _InfoBox(fecha)],
              )),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [const _Label('Hora'), _InfoBox(hora)],
              )),
            ]),
            const SizedBox(height: 14),

            // Estado + Actualizar
            const _Label('Estado'),
            Row(children: [
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
                    items: _estados.map((e) => DropdownMenuItem(
                      value: e,
                      child: Row(children: [
                        Container(width: 8, height: 8,
                            decoration: BoxDecoration(
                                color: _estadoColor(e),
                                shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text(e, style: TextStyle(
                            color: _estadoColor(e),
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                      ]),
                    )).toList(),
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
                        borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                  ),
                  child: _guardando
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Actualizar',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ]),
          ],
        ),
          ),
          // ── BANNER FLOTANTE ────────────────────────────────────
          if (_alertType != null)
            Positioned(
              top: 8,
              left: 16,
              right: 16,
              child: _buildAlertBanner(),
            ),
        ],
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
            // Home — vuelve al MainShell en tab 0
            GestureDetector(
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (_) => false),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColors.navBarActive, shape: BoxShape.circle),
                child: const Icon(Icons.home_rounded,
                    color: AppColors.primary, size: 26),
              ),
            ),
            // + Agregar — va al MainShell en tab 1
            GestureDetector(
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (_) => false,
                  arguments: 1),
              child: Container(
                width: 52, height: 52,
                decoration: const BoxDecoration(
                    color: Color(0xFF3A2D9A), shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.white, size: 26),
              ),
            ),
            // Estadísticas — va al MainShell en tab 2
            GestureDetector(
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (_) => false,
                  arguments: 2),
              child: const Icon(Icons.bar_chart_rounded,
                  color: Colors.white60, size: 26),
            ),
          ],
        ),
      ),
    );
  }

  // Abre la imagen original en pantalla completa
  void _abrirImagenCompleta(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ImagenCompletaScreen(url: url),
      ),
    );
  }

  Widget _buildAlertBanner() {
    Color bg; IconData icon;
    switch (_alertType) {
      case 'error':   bg = const Color(0xFFD32F2F); icon = Icons.error_outline; break;
      case 'warning': bg = const Color(0xFF795B00); icon = Icons.warning_amber_rounded; break;
      default:        bg = const Color(0xFF1B5E20); icon = Icons.check_circle_outline;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(_alertMsg ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 14))),
      ]),
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
    child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
  );
}

class _InfoBox extends StatelessWidget {
  final String text;
  final int minLines;
  const _InfoBox(this.text, {this.minLines = 1});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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


// ── PANTALLA DE IMAGEN COMPLETA ────────────────────────────────────────
class _ImagenCompletaScreen extends StatelessWidget {
  final String url;
  const _ImagenCompletaScreen({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Fotografía',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: Center(
        child: InteractiveViewer(
          // Permite hacer zoom con los dedos
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (ctx, child, progress) {
              if (progress == null) return child;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    const Text('Cargando imagen...',
                        style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              );
            },
            errorBuilder: (_, __, ___) => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.white38, size: 64),
                SizedBox(height: 12),
                Text('No se pudo cargar la imagen',
                    style: TextStyle(color: Colors.white38)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

