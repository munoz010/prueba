import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/incidencia_model.dart';
import '../services/auth_service.dart';
import '../services/incidencia_service.dart';
import '../utils/app_colors.dart';
import '../widgets/tri_alert_appbar.dart';

class AddIncidenciaScreen extends StatefulWidget {
  const AddIncidenciaScreen({super.key});

  @override
  State<AddIncidenciaScreen> createState() => _AddIncidenciaScreenState();
}

class _AddIncidenciaScreenState extends State<AddIncidenciaScreen> {
  final _scaffoldKey  = GlobalKey<ScaffoldState>();
  final _formKey      = GlobalKey<FormState>();
  final _incService   = IncidenciaService();
  final _authService  = AuthService();

  final _tituloCtrl      = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _ubicacionCtrl   = TextEditingController();

  String? _tipoSeleccionado;
  bool _guardando = false;

  final List<String> _tipos = [
    'Eléctrico',
    'Hidráulico',
    'Seguridad',
    'Limpieza',
    'Infraestructura',
    'Otro',
  ];

  final DateTime _ahora = DateTime.now();

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    _ubicacionCtrl.dispose();
    super.dispose();
  }

  Future<void> _reportar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tipoSeleccionado == null) {
      _showAlert('warning', 'Selecciona el tipo de incidente.');
      return;
    }

    setState(() => _guardando = true);
    try {
      final uid = _authService.currentUser?.uid ?? '';
      final inc = IncidenciaModel(
        id:          '',
        tipo:        _tipoSeleccionado!,
        titulo:      _tituloCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim(),
        ubicacion:   _ubicacionCtrl.text.trim(),
        estado:      'Reportado',
        fecha:       _ahora,
        usuarioId:   uid,
      );
      await _incService.crear(inc);
      if (mounted) {
        _showAlert('success', 'Incidencia reportada con éxito');
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      _showAlert('error', 'Error al reportar: $e');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  // ── ALERTAS ─────────────────────────────────────────────────────────
  String? _alertType;
  String? _alertMsg;

  void _showAlert(String type, String msg) {
    setState(() { _alertType = type; _alertMsg = msg; });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() { _alertType = null; _alertMsg = null; });
    });
  }

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat('dd/MM/yyyy').format(_ahora);
    final hora  = DateFormat('HH:mm').format(_ahora);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.homeBackground,
      appBar: TriAlertAppBar(
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cabecera ──────────────────────────────────────
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
                    const Expanded(
                      child: Text('Agregar Incidencia',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar',
                          style: TextStyle(
                              color: Colors.blueAccent, fontSize: 14)),
                    ),
                  ],
                ),
              ),

              // ── Alerta ────────────────────────────────────────
              if (_alertType != null) ...[
                _buildAlertBanner(),
                const SizedBox(height: 10),
              ],

              // ── Tipo (dropdown) ───────────────────────────────
              const _Label('Tipo de incidente*'),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.inputHomeBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.inputHomeBorder),
                ),
                child: DropdownButton<String>(
                  value: _tipoSeleccionado,
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: AppColors.cardDark,
                  hint: const Text('Seleccione el tipo',
                      style: TextStyle(color: Colors.white38, fontSize: 14)),
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: Colors.white70),
                  items: _tipos
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _tipoSeleccionado = v),
                ),
              ),
              const SizedBox(height: 12),

              // ── Título ────────────────────────────────────────
              _HomeInput(
                controller: _tituloCtrl,
                hint: 'Título de la incidencia*',
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'El título es obligatorio.'
                    : null,
              ),
              const SizedBox(height: 12),

              // ── Descripción ───────────────────────────────────
              const _Label('Descripcion detallada*'),
              _HomeInput(
                controller: _descripcionCtrl,
                hint: 'Describe el problema en detalle...',
                maxLines: 3,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'La descripción es obligatoria.'
                    : null,
              ),
              const SizedBox(height: 12),

              // ── Foto (placeholder) ────────────────────────────
              const _Label('Fotografia detallada*'),
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.inputHomeBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.inputHomeBorder,
                      style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.upload, color: Colors.white38, size: 36),
                    SizedBox(height: 6),
                    Text('Obligatorio',
                        style:
                            TextStyle(color: Colors.white38, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Ubicación ─────────────────────────────────────
              _HomeInput(
                controller: _ubicacionCtrl,
                hint: 'Ingrese ubicacion(Ej: Bloque 2 - sala 204)',
                suffixIcon: const Icon(Icons.location_on_outlined,
                    color: Colors.white38, size: 18),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'La ubicación es obligatoria.'
                    : null,
              ),
              const SizedBox(height: 14),

              // ── Fecha y Hora (automáticas) ─────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Fecha'),
                        _ReadBox(fecha),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Hora'),
                        _ReadBox(hora),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Botón Reportar ────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _reportar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 3,
                  ),
                  child: _guardando
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white))
                      : const Text('Reportar',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
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
                  color: Colors.white60, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
            Container(
              width: 48, height: 48,
              decoration: const BoxDecoration(
                color: AppColors.primary,
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

  Widget _buildAlertBanner() {
    Color bg; IconData icon;
    switch (_alertType) {
      case 'error':
        bg = const Color(0xFFD32F2F); icon = Icons.error_outline; break;
      case 'warning':
        bg = const Color(0xFF795B00); icon = Icons.warning_amber_rounded; break;
      default:
        bg = const Color(0xFF1B5E20); icon = Icons.check_circle_outline;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(_alertMsg ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 14)),
        ),
      ]),
    );
  }
}

// ── Widgets auxiliares ─────────────────────────────────────────────────
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

class _HomeInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const _HomeInput({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Colors.white38, fontSize: 14),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.inputHomeBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide:
              const BorderSide(color: AppColors.inputHomeBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide:
              const BorderSide(color: AppColors.inputHomeBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(
              color: Colors.purpleAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide:
              const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}

class _ReadBox extends StatelessWidget {
  final String text;
  const _ReadBox(this.text);
  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.inputHomeBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.inputHomeBorder),
        ),
        child: Text(text,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
      );
}
