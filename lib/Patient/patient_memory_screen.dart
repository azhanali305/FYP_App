// lib/Pages/patient_memory_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:my_fyp/Caregiver/Models/hive_models.dart';   // ← Caregiver/Models
import 'package:my_fyp/Service/hive_service.dart';           // ← root Service (matches main.dart)
import 'package:my_fyp/Utils/app_theme.dart';      // ← Caregiver/Utils

class PatientMemoryScreen extends StatefulWidget {
  const PatientMemoryScreen({super.key});

  @override
  State<PatientMemoryScreen> createState() => _PatientMemoryScreenState();
}

class _PatientMemoryScreenState extends State<PatientMemoryScreen> {
  List<MemoryCard> _memories = [];

  @override
  void initState() {
    super.initState();
    _memories = HiveService.getMemories();
    debugPrint('🖼️ Memory screen — cards loaded: ${_memories.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text('Memory Album',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: AppTheme.textDark)),
        iconTheme: const IconThemeData(color: AppTheme.textDark),
      ),
      body: _memories.isEmpty ? _buildEmpty() : _buildGrid(),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemCount: _memories.length,
      itemBuilder: (context, i) => _MemoryCardTile(card: _memories[i]),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_album_rounded, size: 64, color: AppTheme.textLight),
          const SizedBox(height: 16),
          Text('No memories yet',
              style: TextStyle(
                  color: AppTheme.textMid,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Ask your caregiver to add some!',
              style: TextStyle(color: AppTheme.textLight, fontSize: 13)),
        ],
      ),
    );
  }
}

class _MemoryCardTile extends StatelessWidget {
  final MemoryCard card;
  const _MemoryCardTile({required this.card});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _MemoryDetailScreen(card: card)),
      ),
      child: Hero(
        tag: 'memory_${card.id}',
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEAE8E4)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  child: _buildImage(),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card.personName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: AppTheme.textDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(card.description,
                        style: TextStyle(
                            fontSize: 11, color: AppTheme.textLight),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (card.imagePath.startsWith('assets/')) {
      return Image.asset(card.imagePath,
          fit: BoxFit.cover, width: double.infinity);
    }
    final file = File(card.imagePath);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover, width: double.infinity);
    }
    return Container(
      color: const Color(0xFFEAE8E4),
      child: const Center(
        child: Icon(Icons.image_not_supported_rounded,
            color: AppTheme.textLight, size: 36),
      ),
    );
  }
}

// ─── Detail Screen ────────────────────────────────────────────────────────────

class _MemoryDetailScreen extends StatefulWidget {
  final MemoryCard card;
  const _MemoryDetailScreen({required this.card});

  @override
  State<_MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<_MemoryDetailScreen> {
  late final AudioPlayer _player;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    // Keep the play/pause icon in sync with actual player state
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play(DeviceFileSource(widget.card.voicePath!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white70),
        title: Text(card.personName,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'memory_${card.id}',
              child: SizedBox(
                  width: double.infinity, height: 300, child: _buildImage()),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(card.personName,
                        style: const TextStyle(
                            color: AppTheme.primaryLight,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                  const SizedBox(height: 16),
                  Text(card.description,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          height: 1.6)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: Colors.white38, size: 14),
                      const SizedBox(width: 6),
                      Text(_formatDate(card.createdAt),
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                  if (card.voicePath != null) ...[
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _togglePlayback,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B3A5C),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.mic_rounded,
                                color: AppTheme.accent, size: 22),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text('Voice note attached',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w600)),
                            ),
                            // ← Toggles between play and pause
                            Icon(
                              _isPlaying
                                  ? Icons.pause_circle_rounded
                                  : Icons.play_circle_rounded,
                              color: AppTheme.accent,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (widget.card.imagePath.startsWith('assets/')) {
      return Image.asset(widget.card.imagePath, fit: BoxFit.cover);
    }
    final file = File(widget.card.imagePath);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return Container(
      color: const Color(0xFF1B3A5C),
      child: const Center(
        child: Icon(Icons.image_not_supported_rounded,
            color: Colors.white24, size: 60),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}