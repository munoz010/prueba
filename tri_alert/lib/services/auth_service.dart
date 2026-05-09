import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream del estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // =========================
  // LOGIN CON EMAIL
  // =========================
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;

      if (user == null) return null;

      return UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // =========================
  // REGISTRO CON EMAIL
  // =========================
  Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;

      if (user == null) return null;

      // Actualizar nombre
      await user.updateDisplayName(displayName);

      // Recargar usuario
      await user.reload();

      final updatedUser = _auth.currentUser;

      // Crear modelo
      final newUser = UserModel(
        uid: updatedUser!.uid,
        email: updatedUser.email ?? '',
        displayName: updatedUser.displayName ?? '',
      );

      // Guardar en Firestore
      await _firestore.collection('users').doc(updatedUser.uid).set(
            newUser.toMap(),
          );

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // =========================
  // RECUPERAR CONTRASEÑA
  // =========================
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // =========================
  // CERRAR SESIÓN
  // =========================
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  // =========================
  // MANEJO DE ERRORES
  // =========================
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe una cuenta con ese correo.';

      case 'wrong-password':
        return 'Contraseña incorrecta.';

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

      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';

      default:
        return e.message ?? 'Ocurrió un error de autenticación.';
    }
  }
}