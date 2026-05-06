import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication.dart';
import 'auth_service.dart';

class MedicationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _auth;

  MedicationService(this._auth);

  // ── Collection reference for current user's meds ─────────────────────────
  CollectionReference<Map<String, dynamic>> get _medsRef =>
      _db.collection('users').doc(_auth.uid).collection('medications');

  // ── Real-time stream of all medications ───────────────────────────────────
  Stream<List<Medication>> getMedications() {
    return _medsRef
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Medication.fromFirestore(doc))
            .toList());
  }

  // ── Add new medication ────────────────────────────────────────────────────
  Future<String> addMedication(Medication med) async {
    final doc = await _medsRef.add(med.toFirestore());
    return doc.id;
  }

  // ── Update medication ─────────────────────────────────────────────────────
  Future<void> updateMedication(Medication med) async {
    await _medsRef.doc(med.id).update(med.toFirestore());
  }

  // ── Delete medication ─────────────────────────────────────────────────────
  Future<void> deleteMedication(String medId) async {
    await _medsRef.doc(medId).delete();
  }

  // ── Toggle taken today ────────────────────────────────────────────────────
  Future<void> toggleTaken(String medId, bool taken) async {
    await _medsRef.doc(medId).update({
      'takenToday': taken,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Reset all "takenToday" flags (call at midnight via Cloud Function) ────
  Future<void> resetDailyTaken() async {
    final batch = _db.batch();
    final snap = await _medsRef.where('takenToday', isEqualTo: true).get();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'takenToday': false});
    }
    await batch.commit();
  }

  // ── Adherence stats for profile ───────────────────────────────────────────
  Future<Map<String, dynamic>> getAdherenceStats() async {
    final logsSnap = await _db
        .collection('users')
        .doc(_auth.uid)
        .collection('logs')
        .orderBy('date', descending: true)
        .limit(30)
        .get();

    if (logsSnap.docs.isEmpty) {
      return {'adherence': 0, 'streak': 0, 'totalMeds': 0};
    }

    final logs = logsSnap.docs.map((d) => d.data()).toList();
    final totalExpected = logs.fold<int>(0, (sum, l) => sum + (l['expected'] as int? ?? 0));
    final totalTaken    = logs.fold<int>(0, (sum, l) => sum + (l['taken'] as int? ?? 0));
    final adherence = totalExpected == 0
        ? 0
        : ((totalTaken / totalExpected) * 100).round();

    // Streak: count consecutive days from today backwards
    int streak = 0;
    for (final log in logs) {
      final taken    = log['taken'] as int? ?? 0;
      final expected = log['expected'] as int? ?? 1;
      if (taken >= expected) {
        streak++;
      } else {
        break;
      }
    }

    final medsSnap = await _medsRef.get();

    return {
      'adherence': adherence,
      'streak': streak,
      'totalMeds': medsSnap.docs.length,
    };
  }

  // ── Log today's dose taken ────────────────────────────────────────────────
  Future<void> logDoseTaken({
    required String medId,
    required int totalExpectedToday,
    required int totalTakenToday,
  }) async {
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    await _db
        .collection('users')
        .doc(_auth.uid)
        .collection('logs')
        .doc(dateKey)
        .set({
      'date': dateKey,
      'taken': totalTakenToday,
      'expected': totalExpectedToday,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
