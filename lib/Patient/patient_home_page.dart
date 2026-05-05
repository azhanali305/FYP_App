// lib/Pages/patient_home_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_fyp/Services/auth_service.dart';
import 'package:my_fyp/Pages/splash_page.dart';
import 'package:my_fyp/Caregiver/Models/hive_models.dart';  
import 'package:my_fyp/Service/hive_service.dart';          
import 'package:my_fyp/Utils/app_theme.dart';      
import 'package:my_fyp/Patient/patient_memory_screen.dart';
import 'package:my_fyp/Patient/patient_routine_screen.dart';
import 'package:my_fyp/Patient/patient_calming_screen.dart';
import 'package:my_fyp/Patient/patient_location_screen.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  List<MemoryCard> _memories = [];
  List<RoutineItem> _todayRoutines = [];
  int _memoriesCount = 0;
  int _routinesCount = 0;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _fadeCtrl.forward();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _loadData() {
    if (!mounted) return;

    final memories = HiveService.getMemories();
    final routines = HiveService.getRoutines();
    final dayIndex = DateTime.now().weekday - 1; // Mon=0 … Sun=6

    // Debug — remove after confirming data shows up
    debugPrint('🧠 Memories: ${memories.length}');
    debugPrint('📅 Routines: ${routines.length}');

    setState(() {
      _memories = memories;
      _memoriesCount = memories.length;
      _todayRoutines = routines
          .where((r) => r.isEnabled && r.repeatDays[dayIndex])
          .toList();
      _routinesCount = _todayRoutines.length;
    });
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(),
              _buildGreetingCard(),
              _buildSectionLabel("Today's Routine"),
              _todayRoutines.isEmpty
                  ? _buildEmptyRoutine()
                  : _buildRoutinePreview(context),
              _buildSectionLabel('Your Spaces'),
              _buildFeatureGrid(context),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Calm Mind',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark)),
                Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMid,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Spacer(),
            Builder(
              builder: (ctx) => IconButton(
                onPressed: () async {
                  await AuthService().logout();
                  if (!ctx.mounted) return;
                  Navigator.pushReplacement(ctx,
                      MaterialPageRoute(builder: (_) => const SplashPage()));
                },
                icon: const Icon(Icons.logout_rounded, size: 22),
                color: AppTheme.textMid,
                tooltip: 'Logout',
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildGreetingCard() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_greeting,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    const Text('Ahmad Abdullah',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _statBadge(Icons.photo_library_rounded,
                            '$_memoriesCount memories'),
                        const SizedBox(width: 8),
                        _statBadge(
                            Icons.checklist_rounded, '$_routinesCount today'),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.person_rounded,
                    color: Colors.white, size: 36),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildSectionLabel(String label) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textLight,
              letterSpacing: 1.3),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildEmptyRoutine() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEAE8E4)),
          ),
          child: Row(
            children: [
              Icon(Icons.event_note_rounded,
                  color: AppTheme.textLight, size: 28),
              const SizedBox(width: 14),
              Text('No routines scheduled for today',
                  style: TextStyle(
                      color: AppTheme.textMid,
                      fontWeight: FontWeight.w500,
                      fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildRoutinePreview(BuildContext context) {
    final preview = _todayRoutines.take(3).toList();
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            ...preview.map((r) => _RoutinePreviewTile(item: r)),
            if (_todayRoutines.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PatientRoutineScreen()),
                  ).then((_) => _loadData()),
                  child: Text(
                    '+ ${_todayRoutines.length - 3} more reminders',
                    style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  SliverPadding _buildFeatureGrid(BuildContext context) {
    final features = [
      _PatientFeature(
        title: 'Memory\nAlbum',
        icon: Icons.photo_album_rounded,
        gradient: [const Color(0xFFFF8C69), const Color(0xFFFF6B9D)],
        onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PatientMemoryScreen()))
            .then((_) => _loadData()),
      ),
      _PatientFeature(
        title: 'Daily\nRoutine',
        icon: Icons.schedule_rounded,
        gradient: [const Color(0xFF5B7FA6), const Color(0xFF7EC8B0)],
        onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PatientRoutineScreen()))
            .then((_) => _loadData()),
      ),
      _PatientFeature(
        title: 'Calm\nSpace',
        icon: Icons.spa_rounded,
        gradient: [const Color(0xFF9B8ED6), const Color(0xFF64B5F6)],
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PatientCalmingScreen())),
      ),
      _PatientFeature(
        title: 'Where\nAm I',
        icon: Icons.location_on_rounded,
        gradient: [const Color(0xFF52B788), const Color(0xFF40C9A2)],
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PatientLocationScreen())),
      ),
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) => _FeatureTile(feature: features[i]),
          childCount: features.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.1,
        ),
      ),
    );
  }
}

class _RoutinePreviewTile extends StatelessWidget {
  final RoutineItem item;
  const _RoutinePreviewTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cat = RoutineCategory.fromKey(item.category);
    final time =
        TimeOfDay(hour: item.hour, minute: item.minute).format(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAE8E4)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cat.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(cat.icon, color: cat.color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.textDark)),
                if (item.description.isNotEmpty)
                  Text(item.description,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textLight),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(time,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cat.color)),
        ],
      ),
    );
  }
}

class _PatientFeature {
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _PatientFeature(
      {required this.title,
      required this.icon,
      required this.gradient,
      required this.onTap});
}

class _FeatureTile extends StatelessWidget {
  final _PatientFeature feature;
  const _FeatureTile({required this.feature});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: feature.onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: feature.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: feature.gradient[0].withOpacity(0.32),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(feature.icon, color: Colors.white, size: 24),
              ),
              const Spacer(),
              Text(feature.title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2)),
            ],
          ),
        ),
      ),
    );
  }
}
