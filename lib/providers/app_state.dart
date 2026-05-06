import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medication.dart';
import '../services/auth_service.dart';
import '../services/medication_service.dart';

class AppState extends ChangeNotifier {
  final AuthService authService = AuthService();
  late final MedicationService medService = MedicationService(authService);

  // ── Auth state ────────────────────────────────────────────────────────────
  User? _user;
  User? get user => _user;
  bool get isLoggedIn => _user != null;

  // ── Medications ───────────────────────────────────────────────────────────
  List<Medication> _medications = [];
  List<Medication> get medications => _medications;
  StreamSubscription<List<Medication>>? _medSub;

  // ── Loading/error ─────────────────────────────────────────────────────────
  bool _loading = false;
  bool get loading => _loading;
  String? _error;
  String? get error => _error;

  // ── Profile stats ─────────────────────────────────────────────────────────
  int adherence = 0;
  int streak = 0;

  AppState() {
    authService.authStateChanges.listen(_onAuthChange);
  }

  void _onAuthChange(User? user) {
    _user = user;
    if (user != null) {
      _startMedStream();
      _loadStats();
    } else {
      _medSub?.cancel();
      _medications = [];
    }
    notifyListeners();
  }

  void _startMedStream() {
    _medSub?.cancel();
    _medSub = medService.getMedications().listen((meds) {
      _medications = meds;
      notifyListeners();
    });
  }

  Future<void> _loadStats() async {
    final stats = await medService.getAdherenceStats();
    adherence = stats['adherence'] as int;
    streak    = stats['streak'] as int;
    notifyListeners();
  }

  // ── Auth actions ──────────────────────────────────────────────────────────
  Future<String?> signUp(String name, String email, String password) async {
    try {
      _loading = true; notifyListeners();
      await authService.signUp(name: name, email: email, password: password);
      _error = null;
      return null;
    } on FirebaseAuthException catch (e) {
      _error = _authError(e.code);
      return _error;
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      _loading = true; notifyListeners();
      await authService.signIn(email: email, password: password);
      _error = null;
      return null;
    } on FirebaseAuthException catch (e) {
      _error = _authError(e.code);
      return _error;
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> signOut() async {
    await authService.signOut();
  }

  // ── Med actions ───────────────────────────────────────────────────────────
  Future<void> addMedication(Medication med) async {
    await medService.addMedication(med);
  }

  Future<void> toggleTaken(Medication med) async {
    final updated = med.copyWith(takenToday: !med.takenToday);
    await medService.toggleTaken(med.id, updated.takenToday);

    final taken   = _medications.where((m) => m.id == med.id
        ? updated.takenToday : m.takenToday).length;
    await medService.logDoseTaken(
      medId: med.id,
      totalExpectedToday: _medications.length,
      totalTakenToday: taken,
    );
  }

  Future<void> deleteMedication(String id) async {
    await medService.deleteMedication(id);
  }

  // Convenience getters
  int get takenCount => _medications.where((m) => m.takenToday).length;
  int get totalCount  => _medications.length;

  String _authError(String code) => switch (code) {
    'email-already-in-use'   => 'This email is already registered.',
    'invalid-email'          => 'Please enter a valid email.',
    'weak-password'          => 'Password must be at least 6 characters.',
    'user-not-found'         => 'No account found with this email.',
    'wrong-password'         => 'Incorrect password.',
    'too-many-requests'      => 'Too many attempts. Please try again later.',
    _                        => 'Something went wrong. Please try again.',
  };

  @override
  void dispose() {
    _medSub?.cancel();
    super.dispose();
  }
}
