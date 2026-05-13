import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ── LOGIN ───────────────────────────────────────────────────────────
  // Solo autentica con Firebase Auth — NO consulta Firestore.
  // El AuthWrapper detecta el cambio de sesión y navega al home.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // ✅ Listo — Firebase Auth emite el evento en authStateChanges
      // y el AuthWrapper navega automáticamente al MainShell.
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw 'Error inesperado: $e';
    }
  }

  // ── REGISTRO ────────────────────────────────────────────────────────
  // Crea el usuario en Auth y guarda el perfil en Firestore.
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final u = cred.user!;

      // Actualizar displayName en Firebase Auth
      await u.updateDisplayName('$firstName $lastName');

      // Guardar perfil en Firestore (no bloquea la navegación)
      final model = UserModel(
        uid: u.uid,
        email: u.email!,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
      );
      // Guardamos en background — si falla Firestore el usuario
      // igual queda autenticado
      _db.collection('users').doc(u.uid).set(model.toMap()).catchError(
        (e) => print('Firestore error (no crítico): $e'),
      );
      // ✅ Firebase Auth emite el evento — AuthWrapper navega al home
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw 'Error inesperado: $e';
    }
  }

  // ── CERRAR SESIÓN ───────────────────────────────────────────────────
  Future<void> signOut() => _auth.signOut();

  // ── MAPEO DE ERRORES ────────────────────────────────────────────────
  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe una cuenta con ese correo.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'G.mail/Contraseña incorrectos';
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'invalid-email':
        return 'El correo no es válido.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'too-many-requests':
        return 'Demasiados intentos. Inténtalo más tarde.';
      case 'network-request-failed':
        return 'Sin conexión a internet.';
      default:
        return 'Error: ${e.message}';
    }
  }
}
