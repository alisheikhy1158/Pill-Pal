import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/home_screen.dart';
import 'screens/add_medication_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/profile_screen.dart';

void main() => runApp(const PillPalApp());

class PillPalApp extends StatelessWidget {
  const PillPalApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Pill Pal',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    home: const MainShell(),
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Screens mapped to bottom nav (index 2 is the FAB — no tab)
  final List<Widget> _screens = const [
    HomeScreen(),
    ScheduleScreen(),
    SizedBox(), // placeholder for FAB slot
    _MedsListPlaceholder(),
    ProfileScreen(),
  ];

  void _onNavTap(int index) {
    if (index == 2) {
      // FAB: open Add Medication as modal bottom sheet style
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
      );
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today_rounded),
              label: 'Schedule',
            ),
            // Centre FAB item
            BottomNavigationBarItem(
              icon: Container(
                width: 42, height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.dark,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add,
                    color: AppColors.background, size: 24),
              ),
              label: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.medication_outlined),
              activeIcon: Icon(Icons.medication_rounded),
              label: 'Meds',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for Meds list screen
class _MedsListPlaceholder extends StatelessWidget {
  const _MedsListPlaceholder();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Text('My Medications',
          style: TextStyle(fontSize: 18, color: AppColors.textMuted)),
    ),
  );
}
