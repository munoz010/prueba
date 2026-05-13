import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/tri_alert_logo.dart';
import 'auth_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.2,
            colors: [
              Color(0xFF0D2B6B),
              Color(0xFF071640),
              Color(0xFF030D24),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Rayos de luz de fondo
            Positioned.fill(
              child: CustomPaint(painter: _RaysPainter()),
            ),

            // Silueta del globo terráqueo (fondo sutil)
            Positioned(
              right: -60,
              top: MediaQuery.of(context).size.height * 0.15,
              child: Opacity(
                opacity: 0.12,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blueAccent,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ── LOGO ──────────────────────────────────────
                  const TriAlertLogo(size: 200),

                  const SizedBox(height: 24),

                  // ── NOMBRE DE LA APP ──────────────────────────
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF64B5F6), Colors.white, Color(0xFF64B5F6)],
                    ).createShader(bounds),
                    child: const Text(
                      'TriAlert',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // ── BOTÓN INICIAR SESIÓN ──────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => _goToAuth(context, initialTab: 0),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: AppColors.primary.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── LINK REGISTRARSE ──────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No tienes cuenta? ',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => _goToAuth(context, initialTab: 1),
                        child: const Text(
                          'Registrarse',
                          style: TextStyle(
                            color: Color(0xFF64B5F6),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF64B5F6),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToAuth(BuildContext context, {required int initialTab}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AuthScreen(initialTab: initialTab),
      ),
    );
  }
}

/// Pinta los rayos de luz de fondo
class _RaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1565C0).withOpacity(0.08)
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height * 0.38);
    const rays = 18;
    for (int i = 0; i < rays; i++) {
      final angle = (i / rays) * 2 * 3.14159;
      final dx = center.dx + size.width * 1.2 * (0.5 * (i % 2 == 0 ? 1 : 0.7)) * 
                  (i < rays / 2 ? 1 : -1) * (i % 3 == 0 ? 0.8 : 1);
      final dy = center.dy + size.height * 0.9 * (i / rays - 0.5);
      canvas.drawLine(center, Offset(
        center.dx + (size.width) * (angle < 3.14 ? 1 : -1),
        center.dy + size.height,
      ), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
