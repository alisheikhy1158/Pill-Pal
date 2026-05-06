import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../models/medication.dart';
import '../widgets/shared.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _instrCtrl  = TextEditingController();

  String _selectedForm = 'Tablet';
  MedFrequency _freq   = MedFrequency.daily;
  Color _selectedColor = const Color(0xFF4A9B7F);
  final List<TimeOfDay> _times = [const TimeOfDay(hour: 8, minute: 0)];
  bool _saving = false;

  static const _forms = ['Tablet', 'Capsule', 'Liquid', 'Injection', 'Patch'];
  static const _colors = [
    Color(0xFF4A9B7F), Color(0xFF4A6FA5), Color(0xFFA0522D),
    Color(0xFF7B5EA7), Color(0xFFC0831A), Color(0xFF555550),
  ];
  static const _freqLabels = {
    MedFrequency.daily:      'Daily',
    MedFrequency.twiceDaily: 'Twice/day',
    MedFrequency.weekly:     'Weekly',
    MedFrequency.custom:     'Custom',
  };

  @override
  void dispose() {
    _nameCtrl.dispose(); _dosageCtrl.dispose(); _instrCtrl.dispose();
    super.dispose();
  }

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.dark)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _times.add(picked));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final state = context.read<AppState>();
    final med = Medication(
      id: '',
      userId: state.user!.uid,
      name: _nameCtrl.text.trim(),
      dosage: _dosageCtrl.text.trim(),
      form: _selectedForm,
      color: _selectedColor,
      frequency: _freq,
      reminderTimes: List.from(_times),
      instructions: _instrCtrl.text.trim(),
    );

    try {
      await state.addMedication(med);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'),
              backgroundColor: const Color(0xFFC0392B),
              behavior: SnackBarBehavior.floating));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _fmtTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: darkAppBar(title: 'Add Medication', showBack: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _label('Medication Name'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameCtrl,
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'e.g. Metformin'),
              textCapitalization: TextCapitalization.words,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('Dosage'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _dosageCtrl,
                  style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                  decoration: const InputDecoration(hintText: '500 mg'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('Form'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedForm,
                  decoration: const InputDecoration(),
                  style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                  items: _forms.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                  onChanged: (v) => setState(() => _selectedForm = v!),
                ),
              ])),
            ]),
            const SizedBox(height: 16),

            _label('Pill Color'),
            const SizedBox(height: 10),
            Row(children: _colors.map((c) => GestureDetector(
              onTap: () => setState(() => _selectedColor = c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 28, height: 28,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: _selectedColor == c ? Border.all(color: AppColors.dark, width: 2.5) : null,
                  boxShadow: _selectedColor == c
                      ? [BoxShadow(color: c.withOpacity(0.4), blurRadius: 6, spreadRadius: 1)]
                      : null,
                ),
              ),
            )).toList()),
            const SizedBox(height: 16),

            _label('Frequency'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: MedFrequency.values.map((f) {
                final active = _freq == f;
                return GestureDetector(
                  onTap: () => setState(() => _freq = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.dark : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: active ? AppColors.dark : AppColors.border, width: 1.5)),
                    child: Text(_freqLabels[f]!,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                            color: active ? AppColors.background : AppColors.textSecondary)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            _label('Reminder Times'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                ..._times.asMap().entries.map((e) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(_fmtTime(e.value),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => setState(() => _times.removeAt(e.key)),
                      child: const Icon(Icons.close, size: 14, color: AppColors.textMuted)),
                  ]),
                )),
                GestureDetector(
                  onTap: _addTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border, width: 1.5)),
                    child: const Text('+ Add time',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _label('Instructions (optional)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _instrCtrl,
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'e.g. Take with food'),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dark, foregroundColor: AppColors.background,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.4),
                ),
                child: _saving
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background))
                    : const Text('Save Medication'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text.toUpperCase(),
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
          color: AppColors.textMuted, letterSpacing: 1.0));
}
