import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_kantin/models/users_model.dart';

class AuthService {
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  late final fb.FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  bool _isInit = false;
  final StreamController<UsersModel?> _userController = StreamController.broadcast();

  Stream<UsersModel?> get userStream => _userController.stream;
  UsersModel? _currentUser;

  static const _kUserIdKey = 'logged_in_user_id';

  Future<String?> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await _ensureInitialized();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user?.uid;
      if (uid == null) return null;

      final user = UsersModel(
        userId: uid,
        email: email,
        fullName: fullName,
        password: password,
      );

      await _firestore.collection('users').doc(uid).set(user.toMap());
      await _saveSession(uid);
      return uid;
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Firebase registration error');
    }
  }

  Future<String?> login({required String email, required String password}) async {
    await _ensureInitialized();
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final uid = cred.user?.uid;
      if (uid == null) return null;
      await _saveSession(uid);
      return uid;
    } on fb.FirebaseAuthException catch (e) {
      // Convert to friendlier exception messages used by the UI
      String msg = e.message ?? 'Firebase login error';
      if (e.code == 'user-not-found') msg = 'Pengguna tidak ditemukan';
      if (e.code == 'wrong-password') msg = 'Password salah';
      if (e.code == 'invalid-email') msg = 'Format email tidak valid';
      throw Exception(msg);
    }
  }

  Future<void> signOut() async {
    await _ensureInitialized();
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserIdKey);
    _currentUser = null;
    _userController.add(null);
  }

  Future<UsersModel?> fetchCurrentUserModel() async {
    await _ensureInitialized();
    final uid = await getLoggedInUserId();
    if (uid == null) return null;
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UsersModel.fromSnapshot(doc);
  }

  Future<void> _saveSession(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserIdKey, uid);
    // update current user and notify listeners
    try {
      final userModel = await fetchCurrentUserModel();
      _currentUser = userModel;
      _userController.add(_currentUser);
    } catch (_) {
      _userController.add(null);
    }
  }

  Future<String?> getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(_kUserIdKey);
    if (uid != null) return uid;

    // fallback to firebase current user
    await _ensureInitialized();
    final fb.User? firebaseUser = _auth.currentUser;
    return firebaseUser?.uid;
  }

  Future<void> _ensureInitialized() async {
    if (!_isInit) {
      init();
    }
  }

  // Initialize the auth listener that syncs firebase auth changes to app session
  void init() {
    if (_isInit) return;
    _isInit = true;
    // initialize instances
    _auth = fb.FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;

    // listen to Firebase Auth state changes
    _auth.authStateChanges().listen((fb.User? fbUser) async {
      if (fbUser == null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_kUserIdKey);
        _currentUser = null;
        _userController.add(null);
      } else {
        // save uid in prefs and fetch user model
        await _saveSession(fbUser.uid);
      }
    });
  }

  void dispose() {
    _userController.close();
  }
}
