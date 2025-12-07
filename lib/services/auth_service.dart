import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_kantin/models/users_model.dart';

class AuthService {
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  late FirebaseFirestore _firestore;
  bool _firestoreInit = false;
  final StreamController<UsersModel?> _userController = StreamController.broadcast();
  UsersModel? _currentUser;
  bool _isInit = false;

  Stream<UsersModel?> get userStream => _userController.stream;

  static const _kUserIdKey = 'logged_in_user_id';

  /// Inisialisasi service: baca session yang tersimpan dan publish user bila ada
  Future<void> init() async {
    if (_isInit) return;
    _isInit = true;

    // initialize firestore lazily when init is called
    _firestore = FirebaseFirestore.instance;
    _firestoreInit = true;

    final uid = await getLoggedInUserId();
    if (uid == null) {
      _userController.add(null);
      return;
    }

    try {
      await _saveSession(uid);
    } catch (_) {
      _userController.add(null);
    }
  }

  /// Register manual: simpan user di collection `users` (Firestore)
  /// Validasi: email harus berakhiran `@poliwangi.ac.id`
  Future<String?> register({
    required String fullName,
    required String email,
    required String password,
    String? nim,
  }) async {
    // normalize input: trim and lowercase to avoid mismatches
    final normalizedEmail = email.trim().toLowerCase();
    final emailRegex = RegExp(r'^[\w\.-]+@poliwangi\.ac\.id$');
    if (!emailRegex.hasMatch(normalizedEmail)) {
      throw Exception('Email harus berakhiran @poliwangi.ac.id');
    }

    // ensure firestore available
    if (!_firestoreInit) {
      _firestore = FirebaseFirestore.instance;
      _firestoreInit = true;
    }

    // cek apakah email sudah terdaftar (gunakan normalized email)
    final existing = await _firestore.collection('users').where('email', isEqualTo: normalizedEmail).limit(1).get();
    if (existing.docs.isNotEmpty) {
      throw Exception('Email sudah terdaftar');
    }

    final docRef = _firestore.collection('users').doc();
    final userId = docRef.id;

    final userMap = {
      'userId': userId,
      'email': normalizedEmail,
      'fullName': fullName,
      if (nim != null) 'nim': nim,
      // Menyimpan password plaintext sesuai instruksi tim (PERINGATAN: tidak aman)
      'password': password,
    };

    await docRef.set(userMap);
    await _saveSession(userId);
    return userId;
  }

  /// Login manual: cari user berdasarkan email lalu cocokkan password
  Future<String?> login({required String email, required String password}) async {

    // normalize input: trim and lowercase
    final normalizedEmail = email.trim().toLowerCase();
    final emailRegex = RegExp(r'^[\w\.-]+@poliwangi\.ac\.id$');
    if (!emailRegex.hasMatch(normalizedEmail)) {
      throw Exception('Email harus berakhiran @poliwangi.ac.id');
    }

    if (!_firestoreInit) {
      _firestore = FirebaseFirestore.instance;
      _firestoreInit = true;
    }

    final query = await _firestore.collection('users').where('email', isEqualTo: normalizedEmail).limit(1).get();
    if (query.docs.isEmpty) {
      throw Exception('Pengguna tidak ditemukan');
    }

    final doc = query.docs.first;
    final data = doc.data();
    final storedPassword = data['password'];
    if (storedPassword == null) {
      throw Exception('Password tidak ditemukan pada record user');
    }

    if (storedPassword != password) {
      throw Exception('Password salah');
    }

    final uid = doc.id;
    await _saveSession(uid);
    return uid;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserIdKey);
    _currentUser = null;
    _userController.add(null);
  }

  Future<UsersModel?> fetchCurrentUserModel() async {
    final uid = await getLoggedInUserId();
    if (uid == null) return null;
    if (!_firestoreInit) {
      _firestore = FirebaseFirestore.instance;
      _firestoreInit = true;
    }
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UsersModel.fromSnapshot(doc);
  }

  Future<void> _saveSession(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserIdKey, uid);

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
    return uid;
  }

  void dispose() {
    _userController.close();
  }
}
