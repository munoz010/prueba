import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/main_shell.dart';
import 'screens/detalle_incidencia_screen.dart';
import 'models/incidencia_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TriAlertApp());
}

class TriAlertApp extends StatelessWidget {
  const TriAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TriAlert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE53935)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/':       (_) => const AuthWrapper(),
        '/splash': (_) => const SplashScreen(),
        '/home':   (_) => const MainShell(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detalle') {
          final inc = settings.arguments as IncidenciaModel;
          return MaterialPageRoute(
            builder: (_) => DetalleIncidenciaScreen(incidencia: inc),
          );
        }
        return null;
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {

        // Cargando — esperamos a que Firebase responda
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF030D24),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFE53935)),
            ),
          );
        }

        // Firebase respondió — hay usuario activo → Home
        if (snapshot.hasData && snapshot.data != null) {
          return const MainShell();
        }

        // Firebase respondió — no hay sesión → Splash / Login
        return const SplashScreen();
      },
    );
  }
}
