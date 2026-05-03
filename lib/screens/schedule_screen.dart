import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/medication.dart';
import '../widgets/shared.dart';

enum _TimeFilter { all, morning, afternoon, evening }

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedDayOffset = 0; // 0 = today
  _TimeFilter _filter = _TimeFilter.all;

  // Build the 7-day week strip centred on today
  List<DateTime> get _weekDays {
    final today = DateTime.now();
    return List.generate(7, (i) => today.subtract(Duration(days: 3 - i)));
  }

  String _dayName(int weekday) =>
      ['', 'M', 'T', 'W', 'T', 'F', 'S', 'S'][weekday];

  List<({Medication med, TimeOfDay time, MedStatus status})> get _slots {
    final all = <({Medication med, TimeOfDay time, MedStatus status})>[];
    for (final m in sampleMeds) {
      for (final t in m.reminderTimes) {
        final status = m.takenToday
            ? MedStatus.done
            : MedStatus.due;
        all.add((med: m, time: t, status: status));
      }
    }
    // Sort by time
    all.sort((a, b) => a.time.hour * 60 + a.time.minute
        - (b.time.hour * 60 + b.time.minute));
    return all;
  }

  List<({Medication med, TimeOfDay time, MedStatus status})> get _filtered {
    return _slots.where((s) {
      if (_filter == _TimeFilter.all) return true;
      final h = s.time.hour;
      return switch (_filter) {
        _TimeFilter.morning   => h >= 5 && h < 12,
        _TimeFilter.afternoon => h >= 12 && h < 17,
        _TimeFilter.evening   => h >= 17,
        _TimeFilter.all       => true,
      };
    }).toList();
  }

  // Group slots by time-of-day label
  Map<String, List<({Medication med, TimeOfDay time, MedStatus status})>>
      get _grouped {
    final map = <String, List<({Medication med, TimeOfDay time, MedStatus status})>>{};
    for (final s in _filtered) {
      final label = _groupLabel(s.time.hour);
      map.putIfAbsent(label, () => []).add(s);
    }
    return map;
  }

  String _groupLabel(int hour) {
    if (hour >= 5 && hour < 12) return 'Morning';
    if (hour >= 12 && hour < 17) return 'Afternoon';
    return 'Evening';
  }

  String _fmtTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final week = _weekDays;

    return Scaffold(
      body: Column(
        children: [
          // ── Dark header with weekly calendar ────────────────────────────
          Container(
            color: AppColors.dark,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 20, right: 20, bottom: 14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Schedule',
                  style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w400,
                    color: AppColors.background, letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: week.map((day) {
                    final isToday = day.day == today.day &&
                        day.month == today.month;
                    final offset = day.difference(today).inDays;
                    final isSelected = offset == _selectedDayOffset;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedDayOffset = offset),
                      child: Column(
                        children: [
                          Text(
                            _dayName(day.weekday),
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected
                                  ? AppColors.background
                                  : AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 30, height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isToday && isSelected
                                  ? AppColors.background
                                  : isSelected
                                      ? Colors.white24
                                      : Colors.transparent,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isToday
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: isToday && isSelected
                                    ? AppColors.dark
                                    : isSelected
                                        ? AppColors.background
                                        : AppColors.textMuted,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 5, height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.background
                                  : AppColors.textMuted.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // ── Filter tabs ──────────────────────────────────────────────────
          Container(
            color: AppColors.background,
            child: Row(
              children: _TimeFilter.values.map((f) {
                final label = f.name[0].toUpperCase() + f.name.substring(1);
                final active = _filter == f;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: active ? AppColors.dark : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(height: 1, color: AppColors.border),

          // ── Timeline ────────────────────────────────────────────────────
          Expanded(
            child: _grouped.isEmpty
                ? const Center(
                    child: Text('No doses scheduled',
                        style: TextStyle(color: AppColors.textMuted,
                            fontSize: 14)))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    children: _grouped.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: Text(
                              entry.key.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700,
                                color: AppColors.textMuted, letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          ...entry.value.map((slot) => _TimelineCard(slot: slot, fmtTime: _fmtTime)),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final ({Medication med, TimeOfDay time, MedStatus status}) slot;
  final String Function(TimeOfDay) fmtTime;

  const _TimelineCard({required this.slot, required this.fmtTime});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Dot
          Container(
            width: 10, height: 10,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: slot.med.color, shape: BoxShape.circle,
            ),
          ),
          // Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${slot.med.name} ${slot.med.dosage}',
                          style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${fmtTime(slot.time)} · ${slot.med.instructions}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(slot.status),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
