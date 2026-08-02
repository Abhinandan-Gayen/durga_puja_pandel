import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/firebase_auth_service.dart';
import '../core/services/firestore_service.dart';
import '../models/user_model.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._authService, this._firestoreService) {
    _initialize();
  }

  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  static const String _adminLoginKey = 'is_admin_logged_in';
  static const String _adminEmailKey = 'admin_email';

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<UserModel?>? _userSubscription;

  User? firebaseUser;
  UserModel? currentUserModel;

  bool isLoading = false;
  bool isInitialized = false;
  bool isAdminLoggedIn = false;
  bool hasSeenOnboarding = false;

  String? savedAdminEmail;
  String? errorMessage;

  bool _disposed = false;

  UserModel? get user => currentUserModel;

  bool get isLoggedIn {
    return firebaseUser != null && isAdminLoggedIn;
  }

  bool get isAdmin {
    return currentUserModel?.role.toLowerCase() == 'admin';
  }

  Future<void> _initialize() async {
    try {
      await _loadOnboardingStatus();
      await _loadAdminSession();

      firebaseUser = _authService.currentUser;

      _authSubscription = _authService.authStateChanges.listen(
        _onAuthStateChanged,
      );

      if (isAdminLoggedIn && firebaseUser != null) {
        await fetchCurrentUserData();
        _watchCurrentUserData(firebaseUser!.uid);
      } else if (firebaseUser == null) {
        isAdminLoggedIn = false;
        savedAdminEmail = null;
        await _clearSavedAdminSession();
      }
    } catch (error) {
      debugPrint('Auth initialization error: $error');
    } finally {
      isInitialized = true;
      _safeNotifyListeners();
    }
  }

  Future<void> _onAuthStateChanged(User? user) async {
    firebaseUser = user;

    await _userSubscription?.cancel();
    _userSubscription = null;

    if (user == null) {
      currentUserModel = null;

      if (isAdminLoggedIn) {
        isAdminLoggedIn = false;
        savedAdminEmail = null;
        await _clearSavedAdminSession();
      }

      _safeNotifyListeners();
      return;
    }

    if (isAdminLoggedIn) {
      await fetchCurrentUserData();
      _watchCurrentUserData(user.uid);
    }

    _safeNotifyListeners();
  }

  Future<void> login(String email, String password) async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    _safeNotifyListeners();

    try {
      final String enteredEmail = email.trim().toLowerCase();
      final String enteredPassword = password.trim();

      if (enteredEmail.isEmpty || enteredPassword.isEmpty) {
        errorMessage = 'Email এবং password লিখুন।';
        return;
      }

      /*
       * Firestore structure:
       *
       * admin
       *   └── randomDocumentId
       *        ├── gmail: "abhinandan@gmail.com"
       *        ├── password: "123456"
       *        └── name: "Admin"
       */

      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('admin')
              .where('gmail', isEqualTo: enteredEmail)
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        errorMessage = 'Gmail অথবা password ভুল।';
        return;
      }

      final QueryDocumentSnapshot<Map<String, dynamic>> adminDocument =
          querySnapshot.docs.first;

      final Map<String, dynamic> adminData = adminDocument.data();

      final String firestorePassword =
          adminData['password']?.toString().trim() ?? '';

      if (firestorePassword.isEmpty || firestorePassword != enteredPassword) {
        errorMessage = 'Gmail অথবা password ভুল।';
        return;
      }

      User? authenticatedUser = FirebaseAuth.instance.currentUser;

      /*
       * আগে অন্য anonymous account login থাকলে সেটি ব্যবহার হবে।
       * কোনো account login না থাকলে anonymous sign-in হবে।
       */
      if (authenticatedUser == null) {
        final UserCredential credential = await FirebaseAuth.instance
            .signInAnonymously();

        authenticatedUser = credential.user;
      }

      if (authenticatedUser == null) {
        errorMessage = 'Firebase authentication failed.';
        return;
      }

      final String adminName =
          adminData['name']?.toString().trim().isNotEmpty == true
          ? adminData['name'].toString().trim()
          : 'Admin';

      final UserModel adminUserModel = UserModel(
        uid: authenticatedUser.uid,
        name: adminName,
        email: enteredEmail,
        role: 'admin',
      );

      /*
       * users collection-এ admin profile তৈরি অথবা update করবে।
       */
      await _firestoreService.createUserProfile(adminUserModel);

      firebaseUser = authenticatedUser;
      currentUserModel = adminUserModel;
      isAdminLoggedIn = true;
      savedAdminEmail = enteredEmail;

      await _saveAdminSession(email: enteredEmail);

      _watchCurrentUserData(authenticatedUser.uid);

      debugPrint('Admin login successful');
      debugPrint('Admin email: $enteredEmail');
      debugPrint('Admin UID: ${authenticatedUser.uid}');
    } on FirebaseAuthException catch (error) {
      debugPrint('FirebaseAuthException: ${error.code}');

      if (error.code == 'operation-not-allowed') {
        errorMessage = 'Firebase Console থেকে Anonymous Sign-In enable করুন।';
      } else if (error.code == 'network-request-failed') {
        errorMessage = 'Internet connection check করুন।';
      } else {
        errorMessage = error.message ?? 'Firebase authentication failed.';
      }
    } on FirebaseException catch (error) {
      debugPrint('FirebaseException: ${error.code}');

      if (error.code == 'permission-denied') {
        errorMessage =
            'Firestore permission denied. Firestore Rules check করুন।';
      } else if (error.code == 'unavailable') {
        errorMessage = 'Firebase server এখন unavailable।';
      } else {
        errorMessage = error.message ?? 'Firebase database error.';
      }
    } catch (error, stackTrace) {
      debugPrint('Admin login error: $error');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage = 'Login failed. আবার চেষ্টা করুন।';
    } finally {
      isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    isLoading = true;
    errorMessage = null;
    _safeNotifyListeners();
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> fetchCurrentUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      firebaseUser = null;
      currentUserModel = null;
      return;
    }

    try {
      firebaseUser = user;

      final UserModel? profile = await _firestoreService.fetchUser(user.uid);

      if (profile != null) {
        currentUserModel = profile;
      } else if (isAdminLoggedIn && savedAdminEmail != null) {
        /*
         * users document না পাওয়া গেলে saved admin profile তৈরি করবে।
         */
        final UserModel adminProfile = UserModel(
          uid: user.uid,
          name: 'Admin',
          email: savedAdminEmail!,
          role: 'admin',
        );

        await _firestoreService.createUserProfile(adminProfile);
        currentUserModel = adminProfile;
      }

      debugPrint(
        'Current user: ${currentUserModel?.email}, '
        'role: ${currentUserModel?.role}',
      );
    } catch (error) {
      debugPrint('Current user fetch error: $error');
      errorMessage = 'User profile load করা যায়নি।';
    }

    _safeNotifyListeners();
  }

  void _watchCurrentUserData(String uid) {
    _userSubscription?.cancel();

    _userSubscription = _firestoreService
        .watchUser(uid)
        .listen(
          (UserModel? profile) {
            if (profile != null) {
              currentUserModel = profile;
              _safeNotifyListeners();
            }
          },
          onError: (Object error) {
            debugPrint('User profile listener error: $error');
          },
        );
  }

  Future<void> logout() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    _safeNotifyListeners();

    try {
      await _userSubscription?.cancel();
      _userSubscription = null;

      await _authService.logout();
      await _clearSavedAdminSession();

      firebaseUser = null;
      currentUserModel = null;
      isAdminLoggedIn = false;
      savedAdminEmail = null;

      debugPrint('Admin logout successful');
    } on FirebaseAuthException catch (error) {
      errorMessage = error.message ?? error.code;
    } catch (error) {
      debugPrint('Logout error: $error');
      errorMessage = 'Logout করা যায়নি।';
    } finally {
      isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> _saveAdminSession({required String email}) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    await preferences.setBool(_adminLoginKey, true);

    await preferences.setString(_adminEmailKey, email);
  }

  Future<void> _loadAdminSession() async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();

      isAdminLoggedIn = preferences.getBool(_adminLoginKey) ?? false;

      savedAdminEmail = preferences.getString(_adminEmailKey);

      debugPrint('Saved admin login: $isAdminLoggedIn');
      debugPrint('Saved admin email: $savedAdminEmail');
    } catch (error) {
      debugPrint('Admin session load error: $error');

      isAdminLoggedIn = false;
      savedAdminEmail = null;
    }
  }

  Future<void> _clearSavedAdminSession() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    await preferences.remove(_adminLoginKey);
    await preferences.remove(_adminEmailKey);
  }

  Future<void> _loadOnboardingStatus() async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();

      hasSeenOnboarding = preferences.getBool('has_seen_onboarding') ?? false;
    } catch (error) {
      debugPrint('Onboarding status load error: $error');
      hasSeenOnboarding = false;
    }
  }

  Future<void> completeOnboarding() async {
    hasSeenOnboarding = true;
    _safeNotifyListeners();

    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();

      await preferences.setBool('has_seen_onboarding', true);
    } catch (error) {
      debugPrint('Onboarding save error: $error');
    }
  }

  bool checkUserRole(String role) {
    return currentUserModel?.role.toLowerCase() == role.toLowerCase();
  }

  Future<void> signIn(String email, String password) {
    return login(email, password);
  }

  Future<void> signOut() {
    return logout();
  }

  void clearError() {
    errorMessage = null;
    _safeNotifyListeners();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;

    _authSubscription?.cancel();
    _userSubscription?.cancel();

    super.dispose();
  }
}
