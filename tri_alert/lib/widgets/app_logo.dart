import 'package:flutter/material.dart';
import '../utils/app_images.dart';

/// Widget que carga el logo desde Firebase Storage
class AppLogo extends StatelessWidget {
  final LogoType type;
  final double width;
  final double? height;

  const AppLogo({
    super.key,
    this.type = LogoType.completo,
    this.width = 200,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final String url = switch (type) {
      LogoType.icono    => AppImages.icono,
      LogoType.texto    => AppImages.logoTexto,
      LogoType.completo => AppImages.logoCompleto,
    };

    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.contain,
      // Mientras carga — spinner pequeño
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          width: width,
          height: height ?? width * 0.6,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white54,
              strokeWidth: 2,
            ),
          ),
        );
      },
      // Si falla la carga — ícono de respaldo
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          width: width,
          height: height ?? width * 0.6,
          child: const Center(
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.white54,
              size: 48,
            ),
          ),
        );
      },
    );
  }
}

enum LogoType { icono, texto, completo }
