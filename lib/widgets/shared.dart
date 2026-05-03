import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/medication.dart';

// ── Section header label ──────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String text;
  const SectionHeader(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 1.0,
      ),
    ),
  );
}

// ── Status badge ──────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final MedStatus status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      MedStatus.done   => (AppColors.doneBg,  AppColors.doneText,  'Done'),
      MedStatus.due    => (AppColors.dueBg,   AppColors.dueText,   'Due'),
      MedStatus.missed => (AppColors.missBg,  AppColors.missText,  'Missed'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

// ── Medication row (used on Home screen) ─────────────────────────────────────
class MedRow extends StatelessWidget {
  final Medication med;
  final VoidCallback? onToggle;

  const MedRow({super.key, required this.med, this.onToggle});

  @override
  Widget build(BuildContext context) {
    final timeStr = med.reminderTimes.isNotEmpty
        ? _fmt(med.reminderTimes.first)
        : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 11, height: 11,
            decoration: BoxDecoration(color: med.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text('${med.dosage} · ${med.instructions}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(timeStr,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: med.takenToday ? AppColors.dark : Colors.transparent,
                    border: Border.all(
                      color: med.takenToday ? AppColors.dark : AppColors.textMuted,
                      width: 2,
                    ),
                  ),
                  child: med.takenToday
                      ? const Icon(Icons.check, size: 13, color: AppColors.background)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }
}

// ── Dark app bar shared across screens ───────────────────────────────────────
PreferredSizeWidget darkAppBar({
  required String title,
  List<Widget>? actions,
  bool showBack = false,
}) =>
    AppBar(
      backgroundColor: AppColors.dark,
      foregroundColor: AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: showBack,
      leading: showBack
          ? const BackButton(color: AppColors.background)
          : null,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: AppColors.background,
          letterSpacing: -0.3,
        ),
      ),
      actions: actions,
    );
