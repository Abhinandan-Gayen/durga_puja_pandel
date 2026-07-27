import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/services/firebase_auth_service.dart';
import '../core/services/firestore_service.dart';
import '../models/user_model.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._authService, this._firestoreService) {
    _init();
  }

  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<UserModel?>? _userSubscription;

  User? firebaseUser;
  UserModel? currentUserModel;
  bool isLoading = false;
  String? errorMessage;

  Future<void>? _pendingFetch;
  bool _initialized = false;
  bool _disposed = false;

  UserModel? get user => currentUserModel;

  bool get isLoggedIn => firebaseUser != null;

  bool get isAdmin => currentUserModel?.role == 'admin';

  bool get isInitialized => _initialized;

  void _init() {
    firebaseUser = _authService.currentUser;
    _authSubscription = _authService.authStateChanges.listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? nextUser) async {
    final uid = nextUser?.uid;
    final previousUid = firebaseUser?.uid;
    final sameUser = uid != null && uid == previousUid;
    final hasData = currentUserModel != null;

    firebaseUser = nextUser;

    if (sameUser && hasData) {
      if (!_initialized) {
        _initialized = true;
        if (!_disposed) notifyListeners();
      }
      return;
    }

    _userSubscription?.cancel();
    _userSubscription = null;
    currentUserModel = null;
    _pendingFetch = null;

    if (nextUser != null) {
      try {
        await fetchCurrentUserData().timeout(
          const Duration(seconds: 10),
        );
        _watchCurrentUserData(nextUser.uid);
      } catch (_) {}
    }

    _initialized = true;
    if (!_disposed) notifyListeners();
  }

  Future<void> fetchCurrentUserData() async {
    if (_pendingFetch != null) return _pendingFetch!;

    final user = _authService.currentUser;
    if (user == null) {
      currentUserModel = null;
      if (!_disposed) notifyListeners();
      return;
    }

    firebaseUser = user;
    _pendingFetch = _doFetch(user.uid);
    try {
      await _pendingFetch;
    } finally {
      _pendingFetch = null;
    }
  }

  Future<void> _doFetch(String uid) async {
    isLoading = true;
    errorMessage = null;
    if (!_disposed) notifyListeners();
    try {
      currentUserModel = await _firestoreService.fetchUser(uid);
      debugPrint('Current user loaded: ${currentUserModel?.email}, '
          'role: ${currentUserModel?.role}');
    } catch (error) {
      errorMessage = error.toString();
      debugPrint('Failed to load user data: $error');
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    if (!_disposed) notifyListeners();
    try {
      final credential = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
      );
      final fbUser = credential.user;
      if (fbUser == null) {
        errorMessage = 'Signup succeeded but no user returned.';
        return;
      }
      await _firestoreService.createUserProfile(
        UserModel(uid: fbUser.uid, name: name, email: email, role: 'user'),
      );
      firebaseUser = fbUser;
      await fetchCurrentUserData();
      _watchCurrentUserData(fbUser.uid);
    } on FirebaseAuthException catch (error) {
      errorMessage = error.message ?? error.code;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    if (!_disposed) notifyListeners();
    try {
      final credential = await _authService.loginWithEmailPassword(
        email: email,
        password: password,
      );
      final fbUser = credential.user;
      if (fbUser == null) {
        errorMessage = 'Login succeeded but no user returned.';
        return;
      }
      firebaseUser = fbUser;
      await fetchCurrentUserData();
      _watchCurrentUserData(fbUser.uid);
    } on FirebaseAuthException catch (error) {
      errorMessage = error.message ?? error.code;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    firebaseUser = null;
    currentUserModel = null;
    _pendingFetch = null;
    _userSubscription?.cancel();
    _userSubscription = null;
    if (!_disposed) notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    isLoading = true;
    errorMessage = null;
    if (!_disposed) notifyListeners();
    try {
      await _authService.resetPassword(email);
    } on FirebaseAuthException catch (error) {
      errorMessage = error.message ?? error.code;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  bool checkUserRole(String role) {
    return currentUserModel?.role == role;
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return signup(name: name, email: email, password: password);
  }

  Future<void> signIn(String email, String password) {
    return login(email, password);
  }

  Future<void> signOut() => logout();

  Future<void> sendPasswordReset(String email) => resetPassword(email);

  void _watchCurrentUserData(String uid) {
    _userSubscription?.cancel();
    _userSubscription = _firestoreService.watchUser(uid).listen(
      (profile) {
        currentUserModel = profile;
        if (!_disposed) notifyListeners();
      },
      onError: (Object error) {
        errorMessage = error.toString();
        if (!_disposed) notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _authSubscription?.cancel();
    _userSubscription?.cancel();
    _pendingFetch = null;
    super.dispose();
  }
}
