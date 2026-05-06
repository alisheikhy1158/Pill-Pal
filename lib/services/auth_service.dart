import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Current user stream ───────────────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;

  // ── Sign Up ───────────────────────────────────────────────────────────────
  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Update display name
    await cred.user!.updateDisplayName(name.trim());

    // Create Firestore user document
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name.trim(),
      'email': email.trim(),
      'notificationsEnabled': true,
      'language': 'English',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return cred;
  }

  // ── Sign In ───────────────────────────────────────────────────────────────
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────
  Future<void> signOut() => _auth.signOut();

  // ── Password Reset ────────────────────────────────────────────────────────
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  // ── Fetch user profile ────────────────────────────────────────────────────
  Future<UserProfile?> getUserProfile() async {
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  // ── Update user profile ───────────────────────────────────────────────────
  Future<void> updateProfile(UserProfile profile) async {
    await _db
        .collection('users')
        .doc(uid)
        .set(profile.toFirestore(), SetOptions(merge: true));
    if (profile.name.isNotEmpty) {
      await currentUser?.updateDisplayName(profile.name);
    }
  }
}
