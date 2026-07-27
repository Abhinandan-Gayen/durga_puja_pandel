import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/services/firebase_auth_service.dart';
import '../core/services/firestore_service.dart';
import '../models/user_model.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._authService, this._firestoreService) {
    firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      fetchCurrentUserData();
      _watchCurrentUserData(firebaseUser!.uid);
    }
    _authSubscription = _authService.authStateChanges.listen(_onAuthChanged);
  }

  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<UserModel?>? _userSubscription;

  User? firebaseUser;
  UserModel? currentUserModel;
  bool isLoading = false;
  String? errorMessage;

  UserModel? get user => currentUserModel;
  bool get isLoggedIn => firebaseUser != null;
  bool get isAdmin => checkUserRole('admin');
  bool get isUser => checkUserRole('user');

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    await _run(() async {
      final credential = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      await _firestoreService.createUserProfile(
        UserModel(uid: uid, name: name, email: email, role: 'user'),
      );
      firebaseUser = credential.user;
      await fetchCurrentUserData();
      _watchCurrentUserData(uid);
    });
  }

  Future<void> login(String email, String password) async {
    await _run(() async {
      final credential = await _authService.loginWithEmailPassword(
        email: email,
        password: password,
      );
      firebaseUser = credential.user;
      await fetchCurrentUserData();
      if (credential.user != null) {
        _watchCurrentUserData(credential.user!.uid);
      }
    });
  }

  Future<void> logout() async {
    await _run(() async {
      await _authService.logout();
      firebaseUser = null;
      currentUserModel = null;
      await _userSubscription?.cancel();
      _userSubscription = null;
    });
  }

  Future<void> resetPassword(String email) async {
    await _run(() => _authService.resetPassword(email));
  }

  Future<void> fetchCurrentUserData() async {
    final user = _authService.currentUser;
    firebaseUser = user;

    if (user == null) {
      currentUserModel = null;
      isLoading = false;
      errorMessage = null;
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUserModel = await _firestoreService
          .fetchUser(user.uid)
          .timeout(const Duration(seconds: 8));

      debugPrint(
        'Current user loaded: ${currentUserModel?.email}, '
        'role: ${currentUserModel?.role}',
      );
    } on TimeoutException {
      errorMessage = 'Unable to connect to Firestore. Request timed out.';
      debugPrint('fetchCurrentUserData: Firestore timeout');
    } catch (error, stackTrace) {
      errorMessage = error.toString();
      debugPrint('fetchCurrentUserData error: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isLoading = false;
      notifyListeners();
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

  Future<void> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
    } on FirebaseAuthException catch (error) {
      errorMessage = error.message ?? error.code;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _onAuthChanged(User? nextUser) {
    firebaseUser = nextUser;
    _userSubscription?.cancel();
    _userSubscription = null;
    currentUserModel = null;

    if (nextUser != null) {
      fetchCurrentUserData();
      _watchCurrentUserData(nextUser.uid);
    }

    notifyListeners();
  }

  void _watchCurrentUserData(String uid) {
    _userSubscription?.cancel();
    _userSubscription = _firestoreService
        .watchUser(uid)
        .listen(
          (profile) {
            currentUserModel = profile;
            notifyListeners();
          },
          onError: (Object error) {
            errorMessage = error.toString();
            notifyListeners();
          },
        );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }
}
