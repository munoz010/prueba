class Validators {
  Validators._();

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'El correo es obligatorio.';
    final reg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!reg.hasMatch(v.trim())) return 'Ingresa un correo válido.';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'La contraseña es obligatoria.';
    if (v.length < 6) return 'Mínimo 6 caracteres.';
    return null;
  }

  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'Este campo es obligatorio.';
    if (v.trim().length < 2) return 'Mínimo 2 caracteres.';
    return null;
  }
}
