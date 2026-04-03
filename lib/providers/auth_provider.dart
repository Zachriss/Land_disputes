import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  String? _userUid;
  UserModel? _currentUser;
  String? _errorMessage;
  StreamSubscription<User?>? _authStateSubscription;

  // Getters
  AuthStatus get status => _status;
  String? get userUid => _userUid;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isInitialized => _status != AuthStatus.initial;

  AuthProvider() {
    // Listen for auth state changes
    _authStateSubscription = _authService.userStream.listen(_onAuthStateChanged);
  }

  // Login
  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential? result = await _authService.login(
        email: email,
        password: password,
      );

      if (result?.user != null) {
        _userUid = result!.user!.uid;
        // Fetch user data from Firestore
        await _loadUserData(_userUid!);
        return true;
      } else {
        _errorMessage = 'Login failed';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    required UserModel user,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential? result = await _authService.register(
        email: email,
        password: password,
        user: user,
      );

      if (result?.user != null) {
        _userUid = result!.user!.uid;
        _currentUser = user.copyWith(id: _userUid);
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Registration failed';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _authService.logout();
      _status = AuthStatus.unauthenticated;
      _currentUser = null;
      _userUid = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // Load user data
  Future<void> _loadUserData(String uid) async {
    try {
      UserModel? userData = await _authService.getUserData(uid);
      _currentUser = userData;
      if (userData != null) {
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  // Handle auth state change
  void _onAuthStateChanged(User? user) {
    if (user != null) {
      _userUid = user.uid;
      _loadUserData(_userUid!);
    } else {
      _status = AuthStatus.unauthenticated;
      _currentUser = null;
      _userUid = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}