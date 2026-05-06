import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum MedStatus { done, due, missed }
enum MedFrequency { daily, twiceDaily, weekly, custom }

class Medication {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final String form;
  final Color color;
  final MedFrequency frequency;
  final List<TimeOfDay> reminderTimes;
  final String instructions;
  bool takenToday;
  final DateTime createdAt;

  Medication({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.form,
    required this.color,
    required this.frequency,
    required this.reminderTimes,
    this.instructions = '',
    this.takenToday = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ── Firestore → Medication ───────────────────────────────────────────────
  factory Medication.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Medication(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      dosage: data['dosage'] ?? '',
      form: data['form'] ?? 'Tablet',
      color: Color(data['colorValue'] ?? 0xFF4A9B7F),
      frequency: MedFrequency.values.firstWhere(
        (f) => f.name == (data['frequency'] ?? 'daily'),
        orElse: () => MedFrequency.daily,
      ),
      reminderTimes: (data['reminderTimes'] as List<dynamic>? ?? [])
          .map((t) => TimeOfDay(
                hour: (t as Map<String, dynamic>)['hour'] as int,
                minute: t['minute'] as int,
              ))
          .toList(),
      instructions: data['instructions'] ?? '',
      takenToday: data['takenToday'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ── Medication → Firestore ───────────────────────────────────────────────
  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'name': name,
    'dosage': dosage,
    'form': form,
    'colorValue': color.value,
    'frequency': frequency.name,
    'reminderTimes': reminderTimes
        .map((t) => {'hour': t.hour, 'minute': t.minute})
        .toList(),
    'instructions': instructions,
    'takenToday': takenToday,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  Medication copyWith({bool? takenToday}) => Medication(
    id: id,
    userId: userId,
    name: name,
    dosage: dosage,
    form: form,
    color: color,
    frequency: frequency,
    reminderTimes: reminderTimes,
    instructions: instructions,
    takenToday: takenToday ?? this.takenToday,
    createdAt: createdAt,
  );
}

// ── User Profile ──────────────────────────────────────────────────────────────
class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String? bloodType;
  final String? conditions;
  final String? allergies;
  final bool notificationsEnabled;
  final String language;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.bloodType,
    this.conditions,
    this.allergies,
    this.notificationsEnabled = true,
    this.language = 'English',
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      bloodType: data['bloodType'],
      conditions: data['conditions'],
      allergies: data['allergies'],
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      language: data['language'] ?? 'English',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'email': email,
    'bloodType': bloodType,
    'conditions': conditions,
    'allergies': allergies,
    'notificationsEnabled': notificationsEnabled,
    'language': language,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
