import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:lifetours/models/models.dart';
import 'package:lifetours/models/firestore_constants.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _userModel;
  String? _error;
  StreamSubscription<User?>? _authSubscription;
  bool _isCreatingAccount = false;

  AuthStatus get status => _status;
  UserModel? get userModel => _userModel;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAdmin => _userModel?.isAdmin ?? false;
  String? get uid => _userModel?.uid;

  AuthProvider() {
    _init();
  }

  void _init() {
    try {
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _authSubscription =
          _auth!.authStateChanges().listen(_onAuthStateChanged);
    } catch (_) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _userModel = null;
      _error = null;
      notifyListeners();
      return;
    }

    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final doc = await _firestore!
          .collection(FirestoreCollections.users)
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists) {
        _userModel = UserModel.fromDocumentSnapshot(doc);
        _status = AuthStatus.authenticated;
        _error = null;
      } else if (_isCreatingAccount) {
        _status = AuthStatus.loading;
        return;
      } else if (firebaseUser.email != null) {
        final snap = await _firestore!
            .collection(FirestoreCollections.users)
            .where(UserFields.email, isEqualTo: firebaseUser.email)
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty) {
          _userModel = UserModel.fromDocumentSnapshot(snap.docs.first);
          _status = AuthStatus.authenticated;
          _error = null;
        } else {
          _userModel = null;
          _status = AuthStatus.unauthenticated;
          _error = 'No se encontró perfil de usuario en Firestore.';
        }
      } else {
        _userModel = null;
        _status = AuthStatus.unauthenticated;
        _error = 'No se encontró perfil de usuario en Firestore.';
      }
    } catch (e) {
      _userModel = null;
      _status = AuthStatus.unauthenticated;
      _error = 'Error al cargar perfil de usuario.';
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    if (_auth == null) {
      _error = 'Firebase no está inicializado.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    _error = null;
    notifyListeners();
    try {
      await _auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _error = 'Error al iniciar sesión. Intenta de nuevo.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (_auth == null) {
      _error = 'Firebase no está inicializado.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    _error = null;
    _isCreatingAccount = true;
    notifyListeners();

    try {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;

      final userModel = UserModel(
        uid: uid,
        name: name.trim(),
        email: email.trim(),
        role: UserRole.user,
        createdAt: DateTime.now(),
      );

      await _firestore!
          .collection(FirestoreCollections.users)
          .doc(uid)
          .set(userModel.toMap());
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e);
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _error = 'Error al crear la cuenta. Intenta de nuevo.';
      _status = AuthStatus.unauthenticated;
    } finally {
      _isCreatingAccount = false;
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await _auth?.signOut();
    } catch (_) {}
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No se encontró una cuenta con este correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-credential':
        return 'Credenciales inválidas. Verifica tu correo y contraseña.';
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'invalid-email':
        return 'El formato del correo no es válido.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde.';
      case 'operation-not-allowed':
        return 'El registro con correo no está habilitado. Contacta al administrador.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet e intenta de nuevo.';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }
}
