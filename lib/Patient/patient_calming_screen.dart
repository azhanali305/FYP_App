// lib/Pages/patient_calming_screen.dart
import 'package:flutter/material.dart';
import 'package:my_fyp/Caregiver/Models/hive_models.dart';   // ← Caregiver/Models
import 'package:my_fyp/Service/hive_service.dart';           // ← root Service (matches main.dart)
import 'package:my_fyp/Utils/app_theme.dart';      // ← Caregiver/Utils

class PatientCalmingScreen extends StatefulWidget {
  const PatientCalmingScreen({super.key});

  @override
  State<PatientCalmingScreen> createState() => _PatientCalmingScreenState();
}

class _PatientCalmingScreenState extends State<PatientCalmingScreen>
    with TickerProviderStateMixin {
  List<CalmingSound> _sounds = [];
  List<BreathingTechnique> _techniques = [];
  String? _playingId;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _sounds = HiveService.getSounds();
    _techniques = HiveService.getBreathingTechniques();
    debugPrint('🎵 Calming screen — sounds: ${_sounds.length}, techniques: ${_techniques.length}');
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  IconData _iconFromName(String name) {
    switch (name) {
      case 'water_drop': return Icons.water_drop_rounded;
      case 'waves':      return Icons.waves_rounded;
      case 'flutter_dash': return Icons.flutter_dash;
      case 'piano':      return Icons.piano_rounded;
      default:           return Icons.music_note_rounded;
    }
  }

  void _toggleSound(CalmingSound sound) {
    setState(() {
      if (_playingId == sound.id) {
        _playingId = null;
        // TODO: audioPlayer.stop();
      } else {
        _playingId = sound.id;
        // TODO: audioPlayer.play(sound.isAsset
        //   ? AssetSource(sound.audioPath)
        //   : DeviceFileSource(sound.audioPath));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white70),
        title: const Text('Calm Space',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Calming Sounds'),
            const SizedBox(height: 12),
            _sounds.isEmpty
                ? _emptyCard('No sounds configured yet')
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _sounds.length,
                    itemBuilder: (_, i) => _SoundTile(
                      sound: _sounds[i],
                      isPlaying: _playingId == _sounds[i].id,
                      icon: _iconFromName(_sounds[i].iconName),
                      pulseCtrl: _pulseCtrl,
                      onTap: () => _toggleSound(_sounds[i]),
                    ),
                  ),
            const SizedBox(height: 28),
            _sectionLabel('Breathing Exercises'),
            const SizedBox(height: 12),
            _techniques.isEmpty
                ? _emptyCard('No breathing exercises configured')
                : Column(
                    children: _techniques
                        .map((t) => _BreathingCard(
                              technique: t,
                              onStart: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        _BreathingExerciseScreen(
                                            technique: t)),
                              ),
                            ))
                        .toList(),
                  ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white38,
            letterSpacing: 1.4),
      );

  Widget _emptyCard(String msg) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1B3A5C),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(msg,
            style: const TextStyle(color: Colors.white54, fontSize: 13)),
      );
}

class _SoundTile extends StatelessWidget {
  final CalmingSound sound;
  final bool isPlaying;
  final IconData icon;
  final AnimationController pulseCtrl;
  final VoidCallback onTap;

  const _SoundTile({
    required this.sound,
    required this.isPlaying,
    required this.icon,
    required this.pulseCtrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: pulseCtrl,
        builder: (_, child) => Transform.scale(
          scale: isPlaying ? 1.0 + 0.03 * pulseCtrl.value : 1.0,
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: isPlaying
                ? const LinearGradient(
                    colors: [Color(0xFF9B8ED6), Color(0xFF64B5F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)
                : const LinearGradient(
                    colors: [Color(0xFF1B3A5C), Color(0xFF1B3A5C)]),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isPlaying
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.07),
            ),
            boxShadow: isPlaying
                ? [
                    BoxShadow(
                        color: const Color(0xFF9B8ED6).withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: isPlaying ? Colors.white : Colors.white54,
                  size: 32),
              const SizedBox(height: 8),
              Text(sound.title,
                  style: TextStyle(
                      color: isPlaying ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
              const SizedBox(height: 6),
              Icon(
                isPlaying
                    ? Icons.pause_circle_rounded
                    : Icons.play_circle_rounded,
                color: isPlaying ? Colors.white : Colors.white30,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreathingCard extends StatelessWidget {
  final BreathingTechnique technique;
  final VoidCallback onStart;
  const _BreathingCard({required this.technique, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3A5C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.air_rounded,
                color: AppTheme.accent, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(technique.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                const SizedBox(height: 2),
                Text(technique.description,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _pill('↑ ${technique.inhaleSeconds}s',
                        Colors.blue[300]!),
                    const SizedBox(width: 6),
                    if (technique.holdSeconds > 0) ...[
                      _pill('⏸ ${technique.holdSeconds}s',
                          Colors.orange[300]!),
                      const SizedBox(width: 6),
                    ],
                    _pill('↓ ${technique.exhaleSeconds}s', AppTheme.accent),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onStart,
            icon: const Icon(Icons.play_circle_rounded,
                color: AppTheme.accent, size: 36),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w700)),
      );
}

class _BreathingExerciseScreen extends StatefulWidget {
  final BreathingTechnique technique;
  const _BreathingExerciseScreen({required this.technique});

  @override
  State<_BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<_BreathingExerciseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  int _currentCycle = 0;
  String _phase = 'Inhale';
  bool _running = false;

  int get _totalSeconds =>
      widget.technique.inhaleSeconds +
      widget.technique.holdSeconds +
      widget.technique.exhaleSeconds;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: Duration(seconds: _totalSeconds));
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) _nextCycle();
    });
    _ctrl.addListener(_updatePhase);
  }

  void _updatePhase() {
    final elapsed = _ctrl.value * _totalSeconds;
    String phase;
    if (elapsed < widget.technique.inhaleSeconds) {
      phase = 'Inhale';
    } else if (elapsed <
        widget.technique.inhaleSeconds + widget.technique.holdSeconds) {
      phase = 'Hold';
    } else {
      phase = 'Exhale';
    }
    if (phase != _phase) setState(() => _phase = phase);
  }

  void _nextCycle() {
    if (_currentCycle + 1 >= widget.technique.cycles) {
      setState(() {
        _running = false;
        _phase = 'Done!';
      });
      return;
    }
    setState(() => _currentCycle++);
    _ctrl.forward(from: 0);
  }

  void _start() {
    setState(() {
      _running = true;
      _currentCycle = 0;
      _phase = 'Inhale';
    });
    _ctrl.forward(from: 0);
  }

  void _stop() {
    _ctrl.stop();
    setState(() {
      _running = false;
      _phase = 'Inhale';
      _currentCycle = 0;
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white70),
        title: Text(widget.technique.name,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                final scale = _phase == 'Inhale'
                    ? 0.6 + 0.4 * _ctrl.value
                    : _phase == 'Exhale'
                        ? 1.0 - 0.4 * _ctrl.value
                        : 1.0;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 200 * scale + 40,
                      height: 200 * scale + 40,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accent.withOpacity(0.08)),
                    ),
                    Container(
                      width: 200 * scale,
                      height: 200 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          AppTheme.accent.withOpacity(0.6),
                          AppTheme.primary.withOpacity(0.4),
                        ]),
                        border: Border.all(
                            color: AppTheme.accent.withOpacity(0.4),
                            width: 2),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),
            Text(_phase,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              _running
                  ? 'Cycle ${_currentCycle + 1} of ${widget.technique.cycles}'
                  : widget.technique.description,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            if (!_running)
              ElevatedButton.icon(
                onPressed: _start,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Begin Exercise'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _stop,
                icon: const Icon(Icons.stop_rounded),
                label: const Text('Stop'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white60,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
