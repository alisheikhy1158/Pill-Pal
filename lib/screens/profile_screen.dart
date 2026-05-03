import 'package:flutter/material.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsOn = true;
  bool _darkModeOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Dark header ──────────────────────────────────────────────────
          Container(
            color: AppColors.dark,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 20,
            ),
            child: Column(
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF3A3A38),
                    border: Border.all(
                        color: Colors.white24, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'MA',
                    style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600,
                      color: Color(0xFFCCCCC8), letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Muhammad Ali',
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w400,
                    color: AppColors.background, letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'ali@example.com',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),

          // ── Stats strip ──────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  _StatCell(value: '94%', label: 'Adherence'),
                  const VerticalDivider(
                      width: 1, thickness: 1, color: AppColors.border),
                  _StatCell(value: '5', label: 'Active Meds'),
                  const VerticalDivider(
                      width: 1, thickness: 1, color: AppColors.border),
                  _StatCell(value: '42', label: 'Day Streak'),
                ],
              ),
            ),
          ),

          // ── Account section ──────────────────────────────────────────────
          _SectionHead('Account'),
          _NavRow(
            icon: Icons.person_outline_rounded,
            iconBg: const Color(0xFFE5E0D8),
            title: 'Personal Info',
            subtitle: 'Name, DOB, blood type',
            onTap: () {},
          ),
          _NavRow(
            icon: Icons.local_hospital_outlined,
            iconBg: const Color(0xFFDCEFE8),
            title: 'Health Profile',
            subtitle: 'Conditions, allergies',
            onTap: () {},
          ),
          _NavRow(
            icon: Icons.history_rounded,
            iconBg: const Color(0xFFDCE4F5),
            title: 'Medication History',
            subtitle: 'Past medications',
            onTap: () {},
          ),

          // ── Preferences section ──────────────────────────────────────────
          _SectionHead('Preferences'),
          _ToggleRow(
            icon: Icons.notifications_outlined,
            iconBg: const Color(0xFFF5EDD8),
            title: 'Notifications',
            value: _notificationsOn,
            onChanged: (v) => setState(() => _notificationsOn = v),
          ),
          _ToggleRow(
            icon: Icons.dark_mode_outlined,
            iconBg: const Color(0xFFE5E0D8),
            title: 'Dark Mode',
            value: _darkModeOn,
            onChanged: (v) => setState(() => _darkModeOn = v),
          ),
          _NavRow(
            icon: Icons.language_rounded,
            iconBg: const Color(0xFFDCF0DC),
            title: 'Language',
            subtitle: 'English',
            onTap: () {},
          ),
          _NavRow(
            icon: Icons.security_outlined,
            iconBg: const Color(0xFFE5E0D8),
            title: 'Privacy & Security',
            onTap: () {},
          ),

          // ── Logout ───────────────────────────────────────────────────────
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFFD0D0), width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.logout_rounded,
                        size: 18, color: Color(0xFFC0392B)),
                    SizedBox(width: 10),
                    Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: Color(0xFFC0392B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small widgets ─────────────────────────────────────────────────────────────

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w600,
                  color: AppColors.textMuted, letterSpacing: 0.8)),
        ],
      ),
    ),
  );
}

class _SectionHead extends StatelessWidget {
  final String text;
  const _SectionHead(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11, fontWeight: FontWeight.w700,
        color: AppColors.textMuted, letterSpacing: 1.0,
      ),
    ),
  );
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _NavRow({
    required this.icon, required this.iconBg,
    required this.title, this.subtitle, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(color: AppColors.borderLight, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 17, color: AppColors.darkMid),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(subtitle!,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted)),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              size: 18, color: AppColors.textMuted),
        ],
      ),
    ),
  );
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon, required this.iconBg,
    required this.title, required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    decoration: const BoxDecoration(
      border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1)),
    ),
    child: Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
              color: iconBg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 17, color: AppColors.darkMid),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary)),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.dark,
          inactiveThumbColor: AppColors.background,
          inactiveTrackColor: AppColors.surfaceAlt,
        ),
      ],
    ),
  );
}
