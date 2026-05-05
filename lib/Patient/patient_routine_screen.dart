// lib/Pages/patient_routine_screen.dart
import 'package:flutter/material.dart';
import 'package:my_fyp/Caregiver/Models/hive_models.dart';
import 'package:my_fyp/Service/hive_service.dart';
import 'package:my_fyp/Utils/app_theme.dart';

// ✅ Import the shared notifier from daily_routine_screen
import 'package:my_fyp/Caregiver/screens/daily_routine_screen.dart'
    show routineChangeNotifier;

class PatientRoutineScreen extends StatefulWidget {
  const PatientRoutineScreen({super.key});

  @override
  State<PatientRoutineScreen> createState() => _PatientRoutineScreenState();
}

class _PatientRoutineScreenState extends State<PatientRoutineScreen>
    with SingleTickerProviderStateMixin {
  List<RoutineItem> _routines = [];
  late TabController _tabCtrl;
  final List<String> _days = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];
  int _selectedDay = DateTime.now().weekday - 1;

  @override
  void initState() {
    super.initState();

    _tabCtrl = TabController(
        length: 7, vsync: this, initialIndex: _selectedDay);
    _tabCtrl.addListener(() {
      if (_tabCtrl.indexIsChanging) return;
      setState(() => _selectedDay = _tabCtrl.index);
    });

    // ✅ Load routines once on init — no notification rescheduling here
    _loadRoutines();

    // ✅ Listen for changes made in DailyRoutineScreen (caregiver side)
    routineChangeNotifier.addListener(_onRoutineChanged);
  }

  /// Called by routineChangeNotifier whenever the caregiver adds/edits/deletes.
  void _onRoutineChanged() {
    if (mounted) _loadRoutines();
  }

  Future<void> _loadRoutines() async {
    // Just reload from Hive — notifications are already scheduled by
    // DailyRoutineScreen when the caregiver creates/toggles routines.
    // We do NOT reschedule here to avoid duplicates.
    setState(() {
      _routines = HiveService.getRoutines();
    });
  }

  @override
  void dispose() {
    // ✅ Always remove listeners to avoid memory leaks
    routineChangeNotifier.removeListener(_onRoutineChanged);
    _tabCtrl.dispose();
    super.dispose();
  }

  List<RoutineItem> get _filtered =>
      _routines.where((r) => r.isEnabled && r.repeatDays[_selectedDay]).toList()
        ..sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text('Daily Routine',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: AppTheme.textDark)),
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEAE8E4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabCtrl,
              indicator: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textMid,
              labelStyle: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600),
              tabs: _days.map((d) => Tab(text: d)).toList(),
            ),
          ),
        ),
      ),
      body: _filtered.isEmpty ? _buildEmpty() : _buildList(context),
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filtered.length,
      itemBuilder: (context, i) => _RoutineTile(item: _filtered[i]),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available_rounded,
              size: 60, color: AppTheme.textLight),
          const SizedBox(height: 14),
          Text('No routines for ${_days[_selectedDay]}',
              style: const TextStyle(
                  color: AppTheme.textMid,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Routine tile (read-only for patient)
// ─────────────────────────────────────────────────────────────────────────────
class _RoutineTile extends StatelessWidget {
  final RoutineItem item;
  const _RoutineTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cat = RoutineCategory.fromKey(item.category);
    final time =
        TimeOfDay(hour: item.hour, minute: item.minute).format(context);
    final now = DateTime.now();
    final itemMinutes = item.hour * 60 + item.minute;
    final nowMinutes = now.hour * 60 + now.minute;
    final isPast = itemMinutes < nowMinutes;
    final isNext = !isPast && (itemMinutes - nowMinutes) <= 30;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isNext ? cat.color.withOpacity(0.08) : AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNext
              ? cat.color.withOpacity(0.4)
              : const Color(0xFFEAE8E4),
          width: isNext ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              child: Column(
                children: [
                  Text(time,
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color:
                              isPast ? AppTheme.textLight : cat.color)),
                  if (isNext)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: cat.color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('NEXT',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w800)),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 2,
              height: 44,
              decoration: BoxDecoration(
                color: isPast
                    ? const Color(0xFFEAE8E4)
                    : cat.color.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isPast
                    ? const Color(0xFFEAE8E4)
                    : cat.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(cat.icon,
                  color: isPast ? AppTheme.textLight : cat.color,
                  size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isPast
                              ? AppTheme.textLight
                              : AppTheme.textDark,
                          decoration: isPast
                              ? TextDecoration.lineThrough
                              : null)),
                  if (item.description.isNotEmpty)
                    Text(item.description,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textLight),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cat.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(cat.label,
                  style: TextStyle(
                      color: cat.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}