import 'package:flutter/material.dart';

enum MedStatus { done, due, missed }
enum MedFrequency { daily, twiceDaily, weekly, custom }

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String form;
  final Color color;
  final MedFrequency frequency;
  final List<TimeOfDay> reminderTimes;
  final String instructions;
  bool takenToday;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.form,
    required this.color,
    required this.frequency,
    required this.reminderTimes,
    this.instructions = '',
    this.takenToday = false,
  });
}

// Sample data
final List<Medication> sampleMeds = [
  Medication(
    id: '1',
    name: 'Metformin',
    dosage: '500mg',
    form: 'Tablet',
    color: const Color(0xFF4A9B7F),
    frequency: MedFrequency.twiceDaily,
    reminderTimes: [const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 14, minute: 0)],
    instructions: 'Take with meal',
    takenToday: true,
  ),
  Medication(
    id: '2',
    name: 'Lisinopril',
    dosage: '10mg',
    form: 'Tablet',
    color: const Color(0xFF4A6FA5),
    frequency: MedFrequency.daily,
    reminderTimes: [const TimeOfDay(hour: 14, minute: 0)],
    instructions: 'Before meal',
    takenToday: false,
  ),
  Medication(
    id: '3',
    name: 'Atorvastatin',
    dosage: '20mg',
    form: 'Tablet',
    color: const Color(0xFFA0522D),
    frequency: MedFrequency.daily,
    reminderTimes: [const TimeOfDay(hour: 21, minute: 0)],
    instructions: 'At night',
    takenToday: false,
  ),
  Medication(
    id: '4',
    name: 'Vitamin D3',
    dosage: '1000 IU',
    form: 'Capsule',
    color: const Color(0xFFC0831A),
    frequency: MedFrequency.daily,
    reminderTimes: [const TimeOfDay(hour: 8, minute: 0)],
    instructions: 'Any time',
    takenToday: true,
  ),
];
