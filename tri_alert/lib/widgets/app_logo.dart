import 'package:flutter/material.dart';
import '../utils/app_images.dart';

enum LogoType { icono, texto, completo }

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
    return switch (type) {
      LogoType.icono    => AppImages.icono(width: width, height: height),
      LogoType.texto    => AppImages.logoTexto(width: width, height: height),
      LogoType.completo => AppImages.logoCompleto(width: width, height: height),
    };
  }
}
