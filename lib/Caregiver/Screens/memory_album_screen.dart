// lib/screens/memory_album_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../Models/hive_models.dart';
import '../../Service/hive_service.dart';
import 'package:my_fyp/Utils/app_theme.dart';

class MemoryAlbumScreen extends StatefulWidget {
  const MemoryAlbumScreen({super.key});

  @override
  State<MemoryAlbumScreen> createState() => _MemoryAlbumScreenState();
}

class _MemoryAlbumScreenState extends State<MemoryAlbumScreen> {
  List<MemoryCard> _cards = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() => _cards = HiveService.getMemories());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Memory Album'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        backgroundColor: const Color(0xFFFF8C69),
        icon: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white),
        label: Text(
          'Add Memory',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: _cards.isEmpty ? _buildEmpty() : _buildGrid(),
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
              color: const Color(0xFFFF8C69).withOpacity(0.12),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.photo_album_rounded,
                size: 52, color: Color(0xFFFF8C69)),
          ),
          const SizedBox(height: 20),
          Text('No memories yet',
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700,
                  color: AppTheme.textDark)),
          const SizedBox(height: 8),
          Text('Add photos of loved ones with\ndescriptions and voice notes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: AppTheme.textMid)),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (_, i) => _MemoryCardWidget(
        card: _cards[i],
        onDelete: () async {
          await HiveService.deleteMemory(_cards[i].id);
          _load();
        },
      ),
    );
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMemorySheet(onSaved: _load),
    );
  }
}

class _MemoryCardWidget extends StatelessWidget {
  final MemoryCard card;
  final VoidCallback onDelete;
  const _MemoryCardWidget({required this.card, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final player = AudioPlayer();
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAE8E4)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(File(card.imagePath), fit: BoxFit.cover),
                Positioned(
                  top: 6, right: 6,
                  child: GestureDetector(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('Delete Memory?',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete',
                                    style: TextStyle(color: AppTheme.error))),
                          ],
                        ),
                      );
                      if (confirm == true) onDelete();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            child: Text(card.personName,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppTheme.textDark),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
            child: Text(card.description,
                style: TextStyle(
                    fontSize: 11, color: AppTheme.textMid),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
          if (card.voicePath != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: GestureDetector(
                onTap: () => player.play(DeviceFileSource(card.voicePath!)),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8C69).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_circle_filled_rounded,
                          size: 16, color: Color(0xFFFF8C69)),
                      const SizedBox(width: 4),
                      Text('Voice',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF8C69))),
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

class _AddMemorySheet extends StatefulWidget {
  final VoidCallback onSaved;
  const _AddMemorySheet({required this.onSaved});

  @override
  State<_AddMemorySheet> createState() => _AddMemorySheetState();
}

class _AddMemorySheetState extends State<_AddMemorySheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _imagePath;
  String? _voicePath;
  bool _isRecording = false;
  final _recorder = AudioRecorder();
  final _picker = ImagePicker();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _imagePath = img.path);
  }

  Future<void> _takePhoto() async {
    final img = await _picker.pickImage(source: ImageSource.camera);
    if (img != null) setState(() => _imagePath = img.path);
  }

  Future<void> _toggleRecord() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() {
        _voicePath = path;
        _isRecording = false;
      });
    } else {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) return;
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(), path: path);
      setState(() => _isRecording = true);
    }
  }

  Future<void> _save() async {
    if (_imagePath == null || _nameCtrl.text.isEmpty) return;
    final card = MemoryCard(
      id: const Uuid().v4(),
      imagePath: _imagePath!,
      description: _descCtrl.text,
      voicePath: _voicePath,
      personName: _nameCtrl.text,
      createdAt: DateTime.now(),
    );
    await HiveService.addMemory(card);
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
            Text('Add a Memory',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark)),
            const SizedBox(height: 20),

            // Image picker
            GestureDetector(
              onTap: _showImageOptions,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EDE8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: _imagePath != null
                          ? const Color(0xFFFF8C69)
                          : const Color(0xFFE0DDD8),
                      width: 2),
                  image: _imagePath != null
                      ? DecorationImage(
                          image: FileImage(File(_imagePath!)),
                          fit: BoxFit.cover)
                      : null,
                ),
                child: _imagePath == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate_rounded,
                              size: 40, color: AppTheme.textLight),
                          const SizedBox(height: 8),
                          Text('Tap to add photo',
                              style: TextStyle(
                                  color: AppTheme.textLight,
                                  fontWeight: FontWeight.w600)),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                hintText: 'Person\'s name (e.g. "Uncle Tariq")',
                prefixIcon:
                    Icon(Icons.person_rounded, color: AppTheme.primary),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    'Write a description (who is this person, your relationship…)',
                prefixIcon:
                    Icon(Icons.notes_rounded, color: AppTheme.primary),
              ),
            ),
            const SizedBox(height: 16),

            // Voice recording
            Text('Voice Description',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                    fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: _toggleRecord,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _isRecording
                          ? AppTheme.error
                          : const Color(0xFFFF8C69),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isRecording
                              ? Icons.stop_rounded
                              : Icons.mic_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isRecording ? 'Stop' : 'Record',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (_voicePath != null)
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppTheme.success, size: 18),
                      const SizedBox(width: 4),
                      Text('Recorded!',
                          style: TextStyle(
                              color: AppTheme.success,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ],
                  ),
                if (_isRecording)
                  Row(
                    children: [
                      const SizedBox(
                          width: 8,
                          height: 8,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.error)),
                      const SizedBox(width: 8),
                      Text('Recording…',
                          style: TextStyle(
                              color: AppTheme.error,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (_imagePath != null && _nameCtrl.text.isNotEmpty)
                        ? _save
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C69),
                ),
                child: const Text('Save Memory'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded,
                color: AppTheme.primary),
            title: Text('Choose from Gallery',
                style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              _pickImage();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded,
                color: AppTheme.primary),
            title: Text('Take a Photo',
                style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              _takePhoto();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
