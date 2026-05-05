// lib/Caregiver/screens/daily_routine_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../Models/hive_models.dart';
import '../../Service/hive_service.dart';
import 'package:my_fyp/Utils/app_theme.dart';
import '../../Services/notification_service.dart';

class _RoutineNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

/// Singleton — import this in PatientRoutineScreen to listen for changes.
final routineChangeNotifier = _RoutineNotifier();

class DailyRoutineScreen extends StatefulWidget {
  const DailyRoutineScreen({super.key});

  @override
  State<DailyRoutineScreen> createState() => _DailyRoutineScreenState();
}

class _DailyRoutineScreenState extends State<DailyRoutineScreen> {
  List<RoutineItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    if (mounted) setState(() => _items = HiveService.getRoutines());
  }

  String _formatTime(int h, int m) {
    final period = h < 12 ? 'AM' : 'PM';
    final hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '${hour.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Daily Routine Helper')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_alarm_rounded, color: Colors.white),
        label: const Text('Add Reminder',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: _items.isEmpty ? _buildEmpty() : _buildList(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.schedule_rounded,
                size: 52, color: AppTheme.primary),
          ),
          const SizedBox(height: 20),
          const Text('No reminders yet',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark)),
          const SizedBox(height: 8),
          const Text('Add meals, prayers, medications\nand other daily reminders.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.textMid)),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _RoutineCard(
        key: ValueKey(_items[i].id),
        item: _items[i],
        onToggle: (val) => _handleToggle(i, val),
        onDelete: () => _handleDelete(i),
        formatTime: _formatTime,
      ),
    );
  }

  /// Toggle enabled state — save to Hive, update notification, refresh UI.
  Future<void> _handleToggle(int index, bool val) async {
    // 1. Optimistically update UI first so the switch flips instantly.
    setState(() => _items[index].isEnabled = val);

    final item = _items[index];

    // 2. Persist + schedule/cancel simultaneously.
    await Future.wait([
      HiveService.updateRoutine(item),
      val
          ? NotificationService.scheduleRoutine(
              notifId: _notifId(item.id),
              title: item.title,
              body: item.description,
              hour: item.hour,
              minute: item.minute,
              repeatDays: item.repeatDays,
            )
          : NotificationService.cancelRoutine(_notifId(item.id)),
    ]);

    // 3. Notify patient screen of the change.
    routineChangeNotifier.notify();
  }

  /// Delete a routine — remove from Hive, cancel notification, refresh UI.
  Future<void> _handleDelete(int index) async {
    final item = _items[index];

    // 1. Remove from local list immediately so it disappears right away.
    setState(() => _items.removeAt(index));

    // 2. Persist deletion + cancel notifications simultaneously.
    await Future.wait([
      HiveService.deleteRoutine(item.id),
      NotificationService.cancelRoutine(_notifId(item.id)),
    ]);

    // 3. Notify patient screen of the change.
    routineChangeNotifier.notify();
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddRoutineSheet(
        onSaved: (RoutineItem newItem) {
          // Add to local list immediately — no round-trip needed.
          setState(() => _items.add(newItem));
          routineChangeNotifier.notify();
        },
      ),
    );
  }

  /// Convert a UUID string to a stable positive notification ID.
  /// We take the absolute value of the hashCode to avoid negatives.
  static int _notifId(String uuid) => uuid.hashCode.abs();
}

// ─────────────────────────────────────────────────────────────────────────────
// Routine card widget
// ─────────────────────────────────────────────────────────────────────────────
class _RoutineCard extends StatelessWidget {
  final RoutineItem item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  final String Function(int, int) formatTime;

  const _RoutineCard({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    final cat = RoutineCategory.fromKey(item.category);
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAE8E4)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: cat.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(cat.icon, color: cat.color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(item.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppTheme.textDark)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: cat.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(cat.label,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: cat.color)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(formatTime(item.hour, item.minute),
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary)),
                const SizedBox(height: 4),
                Text(item.description,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMid),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(7, (i) {
                    final active = item.repeatDays[i];
                    return Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(right: 3),
                      decoration: BoxDecoration(
                        color: active ? cat.color : const Color(0xFFEAE8E4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(days[i],
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: active
                                    ? Colors.white
                                    : AppTheme.textLight)),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Switch(
                value: item.isEnabled,
                onChanged: onToggle,
                activeColor: cat.color,
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppTheme.textLight, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add routine bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class _AddRoutineSheet extends StatefulWidget {
  /// Called with the newly created [RoutineItem] after it has been saved.
  final void Function(RoutineItem) onSaved;
  const _AddRoutineSheet({required this.onSaved});

  @override
  State<_AddRoutineSheet> createState() => _AddRoutineSheetState();
}

class _AddRoutineSheetState extends State<_AddRoutineSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TimeOfDay _time = TimeOfDay.now();
  String _category = 'meal';
  List<bool> _repeatDays = List.filled(7, true);
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) setState(() => _time = t);
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || _isSaving) return;
    setState(() => _isSaving = true);

    final item = RoutineItem(
      id: const Uuid().v4(),
      title: title,
      description: _descCtrl.text.trim(),
      hour: _time.hour,
      minute: _time.minute,
      category: _category,
      repeatDays: List<bool>.from(_repeatDays),
      isEnabled: true, // always enabled on creation
    );

    // Save to Hive AND schedule notifications simultaneously.
    await Future.wait([
      HiveService.addRoutine(item),
      NotificationService.scheduleRoutine(
        notifId: item.id.hashCode.abs(), // always positive
        title: item.title,
        body: item.description,
        hour: item.hour,
        minute: item.minute,
        repeatDays: item.repeatDays,
      ),
    ]);

    // Close sheet first, then call onSaved so the parent list updates
    // while the sheet is still animating out — feels instant.
    if (mounted) Navigator.pop(context);
    widget.onSaved(item);
  }

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final canSave = _titleCtrl.text.trim().isNotEmpty && !_isSaving;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0DDD8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Add Reminder',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark)),
            const SizedBox(height: 20),

            // Time picker
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      _time.format(context),
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                    const Spacer(),
                    const Text('Tap to change',
                        style:
                            TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Category',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                    fontSize: 14)),
            const SizedBox(height: 10),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: RoutineCategory.all.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final cat = RoutineCategory.all[i];
                  final selected = _category == cat.key;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 64,
                      decoration: BoxDecoration(
                        color: selected
                            ? cat.color
                            : cat.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? cat.color : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(cat.icon,
                              color: selected ? Colors.white : cat.color,
                              size: 24),
                          const SizedBox(height: 4),
                          Text(cat.label,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? Colors.white
                                      : cat.color)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                hintText: 'Reminder title (e.g. "Lunch Time")',
                prefixIcon:
                    Icon(Icons.title_rounded, color: AppTheme.primary),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                hintText: 'Additional instructions…',
                prefixIcon:
                    Icon(Icons.notes_rounded, color: AppTheme.primary),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Repeat on',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                    fontSize: 14)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final active = _repeatDays[i];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _repeatDays[i] = !_repeatDays[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: active
                          ? AppTheme.primary
                          : const Color(0xFFEEEBE6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(days[i],
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: active
                                  ? Colors.white
                                  : AppTheme.textLight)),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canSave ? _save : null,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Save Reminder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}