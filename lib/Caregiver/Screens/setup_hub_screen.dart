// lib/screens/setup_hub_screen.dart
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:my_fyp/Utils/app_theme.dart';
import 'memory_album_screen.dart';
import 'daily_routine_screen.dart';
import 'calming_mode_screen.dart';
import 'where_am_i_screen.dart';

class SetupHubScreen extends StatelessWidget {
  const SetupHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(),
            _buildPatientCard(),
            _buildSectionLabel('Setup Features'),
            _buildFeatureGrid(context),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CareCompanion',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  'Caregiver Setup Panel',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMid,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: AppTheme.primary,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildPatientCard() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient Profile',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ahmad Abdullah',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Memory Care · Room 4B',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: (){
                  print("Edit Button Pressed");
                },
                icon: Icon(Icons.edit_rounded),
                color: Colors.white70,
                iconSize: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSectionLabel(String label) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textLight,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  SliverPadding _buildFeatureGrid(BuildContext context) {
    final features = [
      _FeatureItem(
        title: 'Memory Album',
        subtitle: 'Photos, descriptions & voice',
        icon: Icons.photo_album_rounded,
        gradient: [const Color(0xFFFF8C69), const Color(0xFFFF6B9D)],
        screen: const MemoryAlbumScreen(),
        count: '0 memories',
      ),
      _FeatureItem(
        title: 'Daily Routine',
        subtitle: 'Meals, prayers & medication',
        icon: Icons.schedule_rounded,
        gradient: [const Color(0xFF5B7FA6), const Color(0xFF7EC8B0)],
        screen: const DailyRoutineScreen(),
        count: '0 reminders',
      ),
      _FeatureItem(
        title: 'Calming Mode',
        subtitle: 'Sounds, breathing & voices',
        icon: Icons.spa_rounded,
        gradient: [const Color(0xFF9B8ED6), const Color(0xFF64B5F6)],
        screen: const CalmingModeScreen(),
        count: '4 sounds',
      ),
      _FeatureItem(
        title: 'Where Am I',
        subtitle: 'Location, date & time',
        icon: Icons.location_on_rounded,
        gradient: [const Color(0xFF52B788), const Color(0xFF40C9A2)],
        screen: const WhereAmIScreen(),
        count: 'Live',
      ),
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _FeatureCard(item: features[index]),
          childCount: features.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.85,
        ),
      ),
    );
  }
}

class _FeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Widget screen;
  final String count;

  const _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.screen,
    required this.count,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem item;
  const _FeatureCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => item.screen),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: item.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: item.gradient[0].withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: Colors.white, size: 26),
              ),
              const Spacer(),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.count,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
