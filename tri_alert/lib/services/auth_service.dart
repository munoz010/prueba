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

  // ── LOGIN ──────────────────────────────────────────────────────────
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final u = cred.user!;
      final doc = await _db.collection('users').doc(u.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, u.uid);
      }
      return UserModel(
          uid: u.uid, email: u.email!, firstName: '', lastName: '');
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  // ── REGISTRO ───────────────────────────────────────────────────────
  Future<UserModel?> register({
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
      await u.updateDisplayName('$firstName $lastName');

      final model = UserModel(
        uid: u.uid,
        email: u.email!,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
      );
      await _db.collection('users').doc(u.uid).set(model.toMap());
      return model;
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  // ── CERRAR SESIÓN ──────────────────────────────────────────────────
  Future<void> signOut() => _auth.signOut();

  // ── MAPEO DE ERRORES ───────────────────────────────────────────────
  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe una cuenta con ese correo.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
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
