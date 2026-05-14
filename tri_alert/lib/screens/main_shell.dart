import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../widgets/tri_alert_appbar.dart';
import 'home_body.dart';
import 'add_incidencia_screen.dart';
import 'estadisticas_screen.dart';

/// Scaffold ÚNICO con Drawer, AppBar y NavBar compartidos.
/// Solo el body cambia con IndexedStack según _navIndex.
/// Detalle de incidencia abre encima con Navigator.pushNamed('/detalle').
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _authService = AuthService();
  int _navIndex = 0;

  // Las 3 páginas — sin Scaffold propio cada una
  final _pages = const [
    HomeBody(),
    AddIncidenciaScreen(),
    EstadisticasScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Leer tab inicial si viene desde detalle_incidencia
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      setState(() => _navIndex = args);
    }
  }

  void _onNavTap(int index) => setState(() => _navIndex = index);

  Future<void> _cerrarSesion() async {
    _scaffoldKey.currentState?.closeDrawer();
    await _authService.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/splash', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user   = _authService.currentUser;
    final nombre = user?.displayName ?? user?.email ?? 'Usuario';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.homeBackground,

      // ── DRAWER GLOBAL ────────────────────────────────────────────────
      drawer: _buildDrawer(nombre),

      // ── APPBAR GLOBAL ────────────────────────────────────────────────
      appBar: TriAlertAppBar(
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
      ),

      // ── BODY: cambia según _navIndex (no recrea los widgets) ─────────
      body: IndexedStack(
        index: _navIndex,
        children: _pages,
      ),

      // ── NAVBAR GLOBAL ────────────────────────────────────────────────
      bottomNavigationBar: TriAlertNavBar(
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }

  // ── DRAWER ────────────────────────────────────────────────────────────
  Widget _buildDrawer(String nombre) {
    return Drawer(
      backgroundColor: AppColors.drawerBg,
      child: SafeArea(
        child: Column(
          children: [
            // Header usuario
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bienvenido',
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(
                          nombre.split(' ').first,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Cerrar sesión
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
}
