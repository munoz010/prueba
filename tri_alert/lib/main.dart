import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';

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
      home: const AuthWrapper(),
    );
  }
}

/// Si el usuario ya tiene sesión activa → HomeScreen
/// Si no → SplashScreen (con los botones de login/registro)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF030D24),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFE53935)),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }
        return const SplashScreen();
      },
    );
  }
}
