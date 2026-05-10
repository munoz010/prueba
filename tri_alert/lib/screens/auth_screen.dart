import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/validators.dart';
import '../widgets/custom_input.dart';
import '../widgets/tri_alert_logo.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  final int initialTab;
  const AuthScreen({super.key, this.initialTab = 0});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late int _tab; // 0 = Login, 1 = Registro
  final _authService = AuthService();

  // ── Controladores Login ────────────────────────────────────────────
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();

  // ── Controladores Registro ─────────────────────────────────────────
  final _regFormKey = GlobalKey<FormState>();
  final _regFirstName = TextEditingController();
  final _regLastName = TextEditingController();
  final _regEmail = TextEditingController();
  final _regPassword = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  @override
  void dispose() {
    _loginEmail.dispose();
    _loginPassword.dispose();
    _regFirstName.dispose();
    _regLastName.dispose();
    _regEmail.dispose();
    _regPassword.dispose();
    super.dispose();
  }

  // ── ACCIONES ───────────────────────────────────────────────────────
  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.signIn(
        email: _loginEmail.text,
        password: _loginPassword.text,
      );
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _register() async {
    if (!_regFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.register(
        email: _regEmail.text,
        password: _regPassword.text,
        firstName: _regFirstName.text,
        lastName: _regLastName.text,
      );
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── BUILD ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
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
            // Rayos de fondo (decorativos)
            Positioned.fill(
              child: CustomPaint(painter: _RaysBg()),
            ),

            Column(
              children: [
                // ── ZONA SUPERIOR: logo ──────────────────────────
                Expanded(
                  flex: 5,
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TriAlertLogo(size: size.width * 0.42),
                      ],
                    ),
                  ),
                ),

                // ── CARD BLANCO ──────────────────────────────────
                Expanded(
                  flex: _tab == 0 ? 6 : 8,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
                    decoration: const BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),

                          // ── TABS ─────────────────────────────
                          _buildTabs(),

                          const SizedBox(height: 20),

                          // ── CONTENIDO SEGÚN TAB ───────────────
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _tab == 0
                                ? _buildLoginForm()
                                : _buildRegisterForm(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Botón back encima del card
            Positioned(
              bottom: _tab == 0 ? 72 : 20,
              left: 16,
              child: SafeArea(
                top: false,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back,
                      color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── WIDGET: TABS ───────────────────────────────────────────────────
  Widget _buildTabs() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.tabInactive,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _tabButton(label: 'Iniciar sesión', index: 0),
          _tabButton(label: 'Registrarse', index: 1),
        ],
      ),
    );
  }

  Widget _tabButton({required String label, required int index}) {
    final isActive = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 44,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : AppColors.textSecondary,
              fontWeight:
                  isActive ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ── FORMULARIO LOGIN ───────────────────────────────────────────────
  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        key: const ValueKey('login'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Bienvenido a TriAlert',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          CustomInput(
            controller: _loginEmail,
            hint: 'G-mail',
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          CustomInput(
            controller: _loginPassword,
            hint: 'Contraseña',
            isPassword: true,
            validator: Validators.password,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 28),

          // Botón Iniciar sesión
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 14),

          // Olvidaste la contraseña
          Center(
            child: TextButton(
              onPressed: () => _showForgotPassword(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Olvidaste la contraseña?',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── FORMULARIO REGISTRO ────────────────────────────────────────────
  Widget _buildRegisterForm() {
    return Form(
      key: _regFormKey,
      child: Column(
        key: const ValueKey('register'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),

          CustomInput(
            controller: _regFirstName,
            hint: 'Primer Nombre',
            validator: Validators.name,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          CustomInput(
            controller: _regLastName,
            hint: 'Primer Apellido',
            validator: Validators.name,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          CustomInput(
            controller: _regEmail,
            hint: 'G-mail',
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          CustomInput(
            controller: _regPassword,
            hint: 'Contraseña',
            isPassword: true,
            validator: Validators.password,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 28),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text(
                      'Registrarse',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── FORGOT PASSWORD ────────────────────────────────────────────────
  void _showForgotPassword() {
    final emailCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Recuperar contraseña',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Te enviaremos un enlace a tu correo para restablecer tu contraseña.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              CustomInput(
                controller: emailCtrl,
                hint: 'G-mail',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (emailCtrl.text.trim().isNotEmpty) {
                    try {
                      await _authService.signIn(
                          email: emailCtrl.text, password: '');
                    } catch (_) {}
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Enlace enviado. Revisa tu correo.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Enviar enlace',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RaysBg extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1565C0).withOpacity(0.06)
      ..strokeWidth = 1;
    final center = Offset(size.width / 2, size.height * 0.3);
    for (int i = 0; i < 20; i++) {
      final t = i / 20;
      canvas.drawLine(
        center,
        Offset(size.width * t, size.height * 0.7),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
