// lib/screens/calming_mode_screen.dart
// import 'dart:io';
// import 'dart:math';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:my_fyp/Caregiver/Models/hive_models.dart';
import 'package:my_fyp/Service/hive_service.dart';
import 'package:my_fyp/Utils/app_theme.dart';


class CalmingModeScreen extends StatefulWidget {
  const CalmingModeScreen({super.key});

  @override
  State<CalmingModeScreen> createState() => _CalmingModeScreenState();
}

class _CalmingModeScreenState extends State<CalmingModeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Calming Mode'),
        bottom: TabBar(
          controller: _tabs,
          labelStyle:
              TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle:
              TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          labelColor: const Color(0xFF9B8ED6),
          unselectedLabelColor: AppTheme.textLight,
          indicatorColor: const Color(0xFF9B8ED6),
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Sounds'),
            Tab(text: 'Breathing'),
            Tab(text: 'Family Voices'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _SoundsTab(),
          _BreathingTab(),
          _FamilyVoicesTab(),
        ],
      ),
    );
  }
}

// ─── Sounds Tab ───────────────────────────────────────────────────────────────

class _SoundsTab extends StatefulWidget {
  const _SoundsTab();

  @override
  State<_SoundsTab> createState() => _SoundsTabState();
}

class _SoundsTabState extends State<_SoundsTab> {
  List<CalmingSound> _sounds = [];
  final _player = AudioPlayer();
  String? _playingId;

  static const Map<String, IconData> _icons = {
    'water_drop': Icons.water_drop_rounded,
    'waves': Icons.waves_rounded,
    'flutter_dash': Icons.flutter_dash,
    'piano': Icons.piano_rounded,
    'music_note': Icons.music_note_rounded,
    'air': Icons.air_rounded,
    'forest': Icons.park_rounded,
    'night': Icons.nights_stay_rounded,
  };

  @override
  void initState() {
    super.initState();
    _load();
    _player.onPlayerStateChanged.listen((s) {
      if (s == PlayerState.completed) {
        setState(() => _playingId = null);
      }
    });
  }

  void _load() => setState(() => _sounds = HiveService.getSounds());

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle(CalmingSound s) async {
    if (_playingId == s.id) {
      await _player.stop();
      setState(() => _playingId = null);
    } else {
      if (s.isAsset) {
        await _player.play(AssetSource(s.audioPath.replaceFirst('assets/', '')));
      } else {
        await _player.play(DeviceFileSource(s.audioPath));
      }
      setState(() => _playingId = s.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._sounds.map((s) => _SoundTile(
              sound: s,
              isPlaying: _playingId == s.id,
              icons: _icons,
              onTap: () => _toggle(s),
              onDelete: () async {
                if (_playingId == s.id) await _player.stop();
                await HiveService.deleteSound(s.id);
                _load();
              },
            )),
        const SizedBox(height: 12),
        _AddTile(
          label: 'Add Custom Sound',
          icon: Icons.library_music_rounded,
          color: const Color(0xFF9B8ED6),
          onTap: () => _showAddSoundDialog(context),
        ),
      ],
    );
  }

  void _showAddSoundDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Sound',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(hintText: 'Sound name'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.isEmpty) return;
              final s = CalmingSound(
                id: const Uuid().v4(),
                title: titleCtrl.text,
                audioPath: '',
                isAsset: false,
                iconName: 'music_note',
              );
              await HiveService.addSound(s);
              _load();
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B8ED6)),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _SoundTile extends StatelessWidget {
  final CalmingSound sound;
  final bool isPlaying;
  final Map<String, IconData> icons;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SoundTile({
    required this.sound,
    required this.isPlaying,
    required this.icons,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final icon = icons[sound.iconName] ?? Icons.music_note_rounded;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isPlaying
            ? const Color(0xFF9B8ED6).withOpacity(0.08)
            : AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPlaying
              ? const Color(0xFF9B8ED6).withOpacity(0.5)
              : const Color(0xFFEAE8E4),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: isPlaying
                    ? const Color(0xFF9B8ED6)
                    : const Color(0xFF9B8ED6).withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: isPlaying ? Colors.white : const Color(0xFF9B8ED6),
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF9B8ED6).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF9B8ED6), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sound.title,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppTheme.textDark)),
                if (isPlaying)
                  Text('Now playing…',
                      style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFF9B8ED6),
                          fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppTheme.textLight, size: 20),
          ),
        ],
      ),
    );
  }
}

// ─── Breathing Tab ────────────────────────────────────────────────────────────

class _BreathingTab extends StatefulWidget {
  const _BreathingTab();

  @override
  State<_BreathingTab> createState() => _BreathingTabState();
}

class _BreathingTabState extends State<_BreathingTab> {
  List<BreathingTechnique> _techniques = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() => _techniques = HiveService.getBreathingTechniques());

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._techniques.map((t) => _BreathingCard(
              technique: t,
              onStart: () => _openBreathingPlayer(t),
              onDelete: () async {
                await HiveService.deleteBreathing(t.id);
                _load();
              },
            )),
        const SizedBox(height: 12),
        _AddTile(
          label: 'Add Custom Technique',
          icon: Icons.add_circle_outline_rounded,
          color: const Color(0xFF64B5F6),
          onTap: () => _openAddTechniqueSheet(),
        ),
      ],
    );
  }

  void _openBreathingPlayer(BreathingTechnique t) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _BreathingPlayerScreen(technique: t)),
    );
  }

  void _openAddTechniqueSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddBreathingSheet(onSaved: _load),
    );
  }
}

class _BreathingCard extends StatelessWidget {
  final BreathingTechnique technique;
  final VoidCallback onStart;
  final VoidCallback onDelete;

  const _BreathingCard({
    required this.technique,
    required this.onStart,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAE8E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(technique.name,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppTheme.textDark)),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppTheme.textLight, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(technique.description,
              style: TextStyle(
                  fontSize: 13, color: AppTheme.textMid)),
          const SizedBox(height: 14),
          Row(
            children: [
              _PhaseChip('Inhale', technique.inhaleSeconds, const Color(0xFF64B5F6)),
              const SizedBox(width: 8),
              if (technique.holdSeconds > 0) ...[
                _PhaseChip('Hold', technique.holdSeconds, const Color(0xFFFFB74D)),
                const SizedBox(width: 8),
              ],
              _PhaseChip('Exhale', technique.exhaleSeconds, const Color(0xFF81C784)),
              const SizedBox(width: 8),
              _PhaseChip('×${technique.cycles}', null, const Color(0xFF9B8ED6)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text('Start Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B8ED6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  final String label;
  final int? seconds;
  final Color color;

  const _PhaseChip(this.label, this.seconds, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        seconds != null ? '$label ${seconds}s' : label,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

// ─── Breathing Player ─────────────────────────────────────────────────────────

class _BreathingPlayerScreen extends StatefulWidget {
  final BreathingTechnique technique;
  const _BreathingPlayerScreen({required this.technique});

  @override
  State<_BreathingPlayerScreen> createState() => _BreathingPlayerScreenState();
}

class _BreathingPlayerScreenState extends State<_BreathingPlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _circleCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _circleAnim;
  late Animation<double> _pulseAnim;

  int _currentCycle = 0;
  String _phase = 'Ready';
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _circleCtrl = AnimationController(vsync: this);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _circleAnim = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _circleCtrl, curve: Curves.easeInOut));
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _circleCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() => _running = true);
    final t = widget.technique;
    for (int cycle = 1; cycle <= t.cycles; cycle++) {
      if (!_running) break;
      setState(() {
        _currentCycle = cycle;
        _phase = 'Inhale';
      });
      _circleCtrl.duration =
          Duration(seconds: t.inhaleSeconds);
      await _circleCtrl.forward(from: 0);

      if (t.holdSeconds > 0 && _running) {
        setState(() => _phase = 'Hold');
        await Future.delayed(Duration(seconds: t.holdSeconds));
      }

      if (_running) {
        setState(() => _phase = 'Exhale');
        _circleCtrl.duration =
            Duration(seconds: t.exhaleSeconds);
        await _circleCtrl.reverse();
      }
    }
    if (mounted) {
      setState(() {
        _running = false;
        _phase = 'Done ✓';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.technique;
    return Scaffold(
      backgroundColor: const Color(0xFF1A1333),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white70),
        title: Text(t.name,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([_circleAnim, _pulseAnim]),
              builder: (_, __) {
                final scale = _running
                    ? _circleAnim.value
                    : _pulseAnim.value * 0.6;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 220, height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF9B8ED6).withOpacity(0.15),
                      border: Border.all(
                          color: const Color(0xFF9B8ED6).withOpacity(0.6),
                          width: 3),
                    ),
                    child: Center(
                      child: Text(
                        _phase,
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            if (_running)
              Text(
                'Cycle $_currentCycle of ${t.cycles}',
                style: TextStyle(
                    color: Colors.white70, fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            const SizedBox(height: 24),
            if (!_running)
              ElevatedButton.icon(
                onPressed: _start,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Begin'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9B8ED6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14)),
              )
            else
              TextButton(
                onPressed: () => setState(() => _running = false),
                child: Text('Stop',
                    style: TextStyle(
                        color: Colors.white60, fontSize: 15)),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddBreathingSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const _AddBreathingSheet({required this.onSaved});

  @override
  State<_AddBreathingSheet> createState() => _AddBreathingSheetState();
}

class _AddBreathingSheetState extends State<_AddBreathingSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int _inhale = 4, _hold = 4, _exhale = 4, _cycles = 4;

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty) return;
    final t = BreathingTechnique(
      id: const Uuid().v4(),
      name: _nameCtrl.text,
      description: _descCtrl.text,
      inhaleSeconds: _inhale,
      holdSeconds: _hold,
      exhaleSeconds: _exhale,
      cycles: _cycles,
    );
    await HiveService.addBreathing(t);
    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
              child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFE0DDD8),
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text('Add Breathing Technique',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700,
                    color: AppTheme.textDark)),
            const SizedBox(height: 16),
            TextField(controller: _nameCtrl,
                decoration: const InputDecoration(hintText: 'Technique name')),
            const SizedBox(height: 12),
            TextField(controller: _descCtrl,
                decoration: const InputDecoration(hintText: 'Description')),
            const SizedBox(height: 16),
            _CounterRow('Inhale (s)', _inhale, (v) => setState(() => _inhale = v), const Color(0xFF64B5F6)),
            _CounterRow('Hold (s)', _hold, (v) => setState(() => _hold = v), const Color(0xFFFFB74D)),
            _CounterRow('Exhale (s)', _exhale, (v) => setState(() => _exhale = v), const Color(0xFF81C784)),
            _CounterRow('Cycles', _cycles, (v) => setState(() => _cycles = v), const Color(0xFF9B8ED6)),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity,
                child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9B8ED6)),
                    child: const Text('Save Technique'))),
          ],
        ),
      ),
    );
  }

  Widget _CounterRow(String label, int val, ValueChanged<int> onChange, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(label,
              style: TextStyle(fontWeight: FontWeight.w600,
                  fontSize: 14, color: AppTheme.textDark))),
          IconButton(
            onPressed: val > 0 ? () => onChange(val - 1) : null,
            icon: const Icon(Icons.remove_circle_outline_rounded),
            color: color,
          ),
          Container(
            width: 40, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text('$val',
                style: TextStyle(fontWeight: FontWeight.w800,
                    fontSize: 15, color: color))),
          ),
          IconButton(
            onPressed: () => onChange(val + 1),
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: color,
          ),
        ],
      ),
    );
  }
}

// ─── Family Voices Tab ────────────────────────────────────────────────────────

class _FamilyVoicesTab extends StatefulWidget {
  const _FamilyVoicesTab();

  @override
  State<_FamilyVoicesTab> createState() => _FamilyVoicesTabState();
}

class _FamilyVoicesTabState extends State<_FamilyVoicesTab> {
  List<FamilyVoiceMessage> _messages = [];
  final _player = AudioPlayer();
  String? _playingId;
  bool _isRecording = false;
  final _recorder = AudioRecorder();
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _player.onPlayerStateChanged.listen((s) {
      if (s == PlayerState.completed) setState(() => _playingId = null);
    });
  }

  void _load() => setState(() => _messages = HiveService.getVoiceMessages());

  @override
  void dispose() {
    _player.dispose();
    _recorder.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleRecord() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      if (path != null && _nameCtrl.text.isNotEmpty) {
        final msg = FamilyVoiceMessage(
          id: const Uuid().v4(),
          senderName: _nameCtrl.text,
          audioPath: path,
          recordedAt: DateTime.now(),
        );
        await HiveService.addVoiceMessage(msg);
        _load();
        _nameCtrl.clear();
      }
      setState(() => _isRecording = false);
    } else {
      if (_nameCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter your name first')),
        );
        return;
      }
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) return;
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/family_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(), path: path);
      setState(() => _isRecording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Record new message card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF9B8ED6).withOpacity(0.8),
                const Color(0xFF64B5F6).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Record a Message',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
              const SizedBox(height: 4),
              Text('Leave a comforting voice message for the patient.',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 14),
              TextField(
                controller: _nameCtrl,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Your name (e.g. "Daughter Sara")',
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person_rounded,
                      color: Colors.white70),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _toggleRecord,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: _isRecording
                        ? Colors.red
                        : Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                        color: Colors.white, size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isRecording
                            ? 'Stop & Save'
                            : 'Start Recording',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      ),
                      if (_isRecording) ...[
                        const SizedBox(width: 10),
                        const SizedBox(width: 10, height: 10,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_messages.isNotEmpty)
          Text('Saved Messages (${_messages.length})',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                  fontSize: 14)),
        const SizedBox(height: 10),
        ..._messages.map((msg) => _VoiceMessageTile(
              msg: msg,
              isPlaying: _playingId == msg.id,
              onTap: () async {
                if (_playingId == msg.id) {
                  await _player.stop();
                  setState(() => _playingId = null);
                } else {
                  await _player.play(DeviceFileSource(msg.audioPath));
                  setState(() => _playingId = msg.id);
                }
              },
              onDelete: () async {
                if (_playingId == msg.id) await _player.stop();
                await HiveService.deleteVoiceMessage(msg.id);
                _load();
              },
            )),
      ],
    );
  }
}

class _VoiceMessageTile extends StatelessWidget {
  final FamilyVoiceMessage msg;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _VoiceMessageTile({
    required this.msg,
    required this.isPlaying,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAE8E4)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: isPlaying
                    ? const Color(0xFF9B8ED6)
                    : const Color(0xFF9B8ED6).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: isPlaying ? Colors.white : const Color(0xFF9B8ED6),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(msg.senderName,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14, color: AppTheme.textDark)),
                Text(
                  '${msg.recordedAt.day}/${msg.recordedAt.month}/${msg.recordedAt.year}',
                  style: TextStyle(
                      fontSize: 11, color: AppTheme.textMid),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppTheme.textLight, size: 20),
          ),
        ],
      ),
    );
  }
}

// ─── Shared helper ────────────────────────────────────────────────────────────

class _AddTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AddTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: color.withOpacity(0.3),
              style: BorderStyle.solid),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14, color: color)),
          ],
        ),
      ),
    );
  }
}
