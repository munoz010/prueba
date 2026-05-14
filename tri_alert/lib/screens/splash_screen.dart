import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_images.dart';
import '../widgets/app_logo.dart';
import 'auth_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── IMAGEN DE FONDO (cubre toda la pantalla) ─────────
            AppImages.fondoLogin(
              width: size.width,
              height: size.height,
              fit: BoxFit.cover,
            ),

            // ── OVERLAY OSCURO ────────────────────────────────────
            Container(color: Colors.black.withOpacity(0.35)),

            // ── CONTENIDO ─────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Logo completo con fondo transparente
                  AppLogo(
                    type: LogoType.completo,
                    width: size.width,
                    height: size.height * 0.40,
                  ),

                  const Spacer(flex: 3),

                  // Botón Iniciar sesión
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

                  // Link Registrarse
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
