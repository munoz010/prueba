import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/app_images.dart';

/// Widget que muestra el logo desde base64 — sin assets externos
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
    final String b64 = switch (type) {
      LogoType.icono    => AppImages.icono,
      LogoType.texto    => AppImages.logoTexto,
      LogoType.completo => AppImages.logoCompleto,
    };

    return Image.memory(
      base64Decode(b64),
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}

enum LogoType { icono, texto, completo }
