import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_kantin/models/users_model.dart';

class AuthService {
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _kUserIdKey = 'logged_in_user_id';

  Future<String?> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
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
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserIdKey);
  }

  Future<UsersModel?> fetchCurrentUserModel() async {
    final uid = await getLoggedInUserId();
    if (uid == null) return null;
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UsersModel.fromSnapshot(doc);
  }

  Future<void> _saveSession(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserIdKey, uid);
  }

  Future<String?> getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(_kUserIdKey);
    if (uid != null) return uid;

    // fallback to firebase current user
    final fb.User? firebaseUser = _auth.currentUser;
    return firebaseUser?.uid;
  }
}
