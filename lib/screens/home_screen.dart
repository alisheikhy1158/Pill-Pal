import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../widgets/shared.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state   = context.watch<AppState>();
    final meds    = state.medications;
    final taken   = state.takenCount;
    final total   = state.totalCount;
    final name    = state.user?.displayName?.split(' ').first ?? 'there';
    final hour    = DateTime.now().hour;
    final greeting= hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    final now     = DateTime.now();
    final dateStr = '${_weekday(now.weekday)}, ${_month(now.month)} ${now.day}';

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: AppColors.dark,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 20, right: 20, bottom: 18),
            width: double.infinity,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(greeting, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, letterSpacing: 1.0, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w300, color: AppColors.background, letterSpacing: -0.5)),
              const SizedBox(height: 2),
              Text(dateStr, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ]),
          ),
          Container(
            color: AppColors.background,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text("Today's progress", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                Text('$taken of $total taken', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : taken / total,
                  minHeight: 7,
                  backgroundColor: AppColors.surfaceAlt,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.dark),
                ),
              ),
            ]),
          ),
          const SectionHeader('Upcoming Doses'),
          Expanded(
            child: meds.isEmpty
                ? const Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.medication_outlined, size: 48, color: AppColors.textMuted),
                      SizedBox(height: 12),
                      Text('No medications added yet', style: TextStyle(fontSize: 16, color: AppColors.textMuted)),
                      SizedBox(height: 6),
                      Text('Tap + to add your first medication', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                    ]))
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: meds.length,
                    itemBuilder: (_, i) => MedRow(
                      med: meds[i],
                      onToggle: () => state.toggleTaken(meds[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _weekday(int d) => const ['','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'][d];
  String _month(int m)   => const ['','January','February','March','April','May','June','July','August','September','October','November','December'][m];
}
