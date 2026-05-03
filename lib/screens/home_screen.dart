import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/medication.dart';
import '../widgets/shared.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Medication> _meds = sampleMeds;

  int get _taken => _meds.where((m) => m.takenToday).length;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    final dateStr =
        '${_weekday(now.weekday)}, ${_month(now.month)} ${now.day}, ${now.year}';

    return Scaffold(
      body: Column(
        children: [
          // ── Dark header ──────────────────────────────────────────────────
          Container(
            color: AppColors.dark,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 20, right: 20, bottom: 18,
            ),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ali',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: AppColors.background,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // ── Progress strip ───────────────────────────────────────────────
          Container(
            color: AppColors.background,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Today's progress",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary),
                    ),
                    Text(
                      '$_taken of ${_meds.length} taken',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _meds.isEmpty ? 0 : _taken / _meds.length,
                    minHeight: 7,
                    backgroundColor: AppColors.surfaceAlt,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.dark),
                  ),
                ),
              ],
            ),
          ),

          // ── Med list ─────────────────────────────────────────────────────
          const SectionHeader('Upcoming Doses'),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _meds.length,
              itemBuilder: (_, i) => MedRow(
                med: _meds[i],
                onToggle: () => setState(() => _meds[i].takenToday = !_meds[i].takenToday),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _weekday(int d) => const [
        '', 'Monday', 'Tuesday', 'Wednesday',
        'Thursday', 'Friday', 'Saturday', 'Sunday'
      ][d];

  String _month(int m) => const [
        '', 'January', 'February', 'March', 'April',
        'May', 'June', 'July', 'August', 'September',
        'October', 'November', 'December'
      ][m];
}
