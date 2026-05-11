import 'package:flutter/material.dart';
import '../models/incidencia_model.dart';
import '../services/auth_service.dart';
import '../services/incidencia_service.dart';
import '../utils/app_colors.dart';
import '../widgets/tri_alert_appbar.dart';
import 'add_incidencia_screen.dart';
import 'detalle_incidencia_screen.dart';
import 'estadisticas_screen.dart';
import '../screens/splash_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _incService  = IncidenciaService();
  final _authService = AuthService();
  int    _navIndex   = 0;
  String _busqueda   = '';

  void _onNavTap(int index) {
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddIncidenciaScreen()));
      return;
    }
    if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const EstadisticasScreen()));
      return;
    }
    setState(() => _navIndex = index);
  }

  Future<void> _cerrarSesion() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user   = _authService.currentUser;
    final nombre = user?.displayName ?? user?.email ?? 'Usuario';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.homeBackground,
      drawer: _buildDrawer(nombre),
      appBar: TriAlertAppBar(onMenuTap: () => _scaffoldKey.currentState?.openDrawer()),
      body: Column(
        children: [
          // ── BUSCADOR ─────────────────────────────────────────────
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

          // ── LISTA ─────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<IncidenciaModel>>(
              stream: _incService.streamTodas(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
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
                        style: TextStyle(color: Colors.white54)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: lista.length,
                  itemBuilder: (ctx, i) => _IncidenciaCard(inc: lista[i], numero: i + 1),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: TriAlertNavBar(currentIndex: _navIndex, onTap: _onNavTap),
    );
  }

  Widget _buildDrawer(String nombre) {
    return Drawer(
      backgroundColor: AppColors.drawerBg,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: AppColors.appBarPurple,
              child: Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bienvenido',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(_trunc(nombre, 16),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: _cerrarSesion,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  children: [
                    Text('Cerrar Sesión',
                        style: TextStyle(color: Colors.white70, fontSize: 15)),
                    SizedBox(width: 10),
                    Icon(Icons.logout, color: Colors.white70, size: 22),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _trunc(String s, int max) => s.length > max ? '${s.substring(0, max)}...' : s;
}

// ── TARJETA ────────────────────────────────────────────────────────────
class _IncidenciaCard extends StatelessWidget {
  final IncidenciaModel inc;
  final int numero;
  const _IncidenciaCard({required this.inc, required this.numero});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => DetalleIncidenciaScreen(incidencia: inc))),
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
                            shape: BoxShape.circle)),
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
                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ]),
                ],
              ),
            ),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(12)),
              child: inc.fotoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(inc.fotoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.camera_alt, color: Colors.white24, size: 30)))
                  : const Icon(Icons.camera_alt, color: Colors.white24, size: 30),
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

  String _trunc(String s, int max) => s.length > max ? '${s.substring(0, max)}...' : s;
}
