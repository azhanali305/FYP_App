// lib/services/hive_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_fyp/Caregiver/Models/hive_models.dart';

class HiveService {
  static const _memoryBox = 'memory_cards';
  static const _routineBox = 'routine_items';
  static const _soundBox = 'calming_sounds';
  static const _breathBox = 'breathing_techniques';
  static const _voiceBox = 'family_voice_messages';
  static const _locationBox = 'location_snapshots';

  /// Call once at app startup (before runApp)
  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(MemoryCardAdapter());
    Hive.registerAdapter(RoutineItemAdapter());
    Hive.registerAdapter(CalmingSoundAdapter());
    Hive.registerAdapter(BreathingTechniqueAdapter());
    Hive.registerAdapter(FamilyVoiceMessageAdapter());
    Hive.registerAdapter(LocationSnapshotAdapter());

    await Hive.openBox<MemoryCard>(_memoryBox);
    await Hive.openBox<RoutineItem>(_routineBox);
    await Hive.openBox<CalmingSound>(_soundBox);
    await Hive.openBox<BreathingTechnique>(_breathBox);
    await Hive.openBox<FamilyVoiceMessage>(_voiceBox);
    await Hive.openBox<LocationSnapshot>(_locationBox);

    await _seedDefaultsIfEmpty();
  }

  // ── Memory Cards ──────────────────────────────────────────────────────────

  static Box<MemoryCard> get _memories => Hive.box<MemoryCard>(_memoryBox);

  static List<MemoryCard> getMemories() => _memories.values.toList();

  static Future<void> addMemory(MemoryCard card) =>
      _memories.put(card.id, card);

  static Future<void> deleteMemory(String id) => _memories.delete(id);

  // ── Routine Items ─────────────────────────────────────────────────────────

  static Box<RoutineItem> get _routines => Hive.box<RoutineItem>(_routineBox);

  static List<RoutineItem> getRoutines() {
    final items = _routines.values.toList();
    items.sort((a, b) {
      final aMin = a.hour * 60 + a.minute;
      final bMin = b.hour * 60 + b.minute;
      return aMin.compareTo(bMin);
    });
    return items;
  }

  static Future<void> addRoutine(RoutineItem item) =>
      _routines.put(item.id, item);

  static Future<void> updateRoutine(RoutineItem item) =>
      _routines.put(item.id, item);

  static Future<void> deleteRoutine(String id) => _routines.delete(id);

  // ── Calming Sounds ────────────────────────────────────────────────────────

  static Box<CalmingSound> get _sounds => Hive.box<CalmingSound>(_soundBox);

  static List<CalmingSound> getSounds() => _sounds.values.toList();

  static Future<void> addSound(CalmingSound sound) =>
      _sounds.put(sound.id, sound);

  static Future<void> deleteSound(String id) => _sounds.delete(id);

  // ── Breathing Techniques ──────────────────────────────────────────────────

  static Box<BreathingTechnique> get _breaths =>
      Hive.box<BreathingTechnique>(_breathBox);

  static List<BreathingTechnique> getBreathingTechniques() =>
      _breaths.values.toList();

  static Future<void> addBreathing(BreathingTechnique t) =>
      _breaths.put(t.id, t);

  static Future<void> deleteBreathing(String id) => _breaths.delete(id);

  // ── Family Voice Messages ─────────────────────────────────────────────────

  static Box<FamilyVoiceMessage> get _voices =>
      Hive.box<FamilyVoiceMessage>(_voiceBox);

  static List<FamilyVoiceMessage> getVoiceMessages() =>
      _voices.values.toList();

  static Future<void> addVoiceMessage(FamilyVoiceMessage msg) =>
      _voices.put(msg.id, msg);

  static Future<void> deleteVoiceMessage(String id) => _voices.delete(id);

  // ── Location Snapshots ────────────────────────────────────────────────────

  static Box<LocationSnapshot> get _locations =>
      Hive.box<LocationSnapshot>(_locationBox);

  static List<LocationSnapshot> getLocations() => _locations.values.toList();

  static Future<void> saveLocation(LocationSnapshot loc) =>
      _locations.put(loc.id, loc);

  static Future<void> deleteLocation(String id) => _locations.delete(id);

  // ── Seed defaults ─────────────────────────────────────────────────────────

  static Future<void> _seedDefaultsIfEmpty() async {
    if (_breaths.isEmpty) {
      final defaults = [
        BreathingTechnique(
          id: 'box',
          name: 'Box Breathing',
          description: 'Equal counts of inhale, hold, exhale, hold. Reduces stress.',
          inhaleSeconds: 4,
          holdSeconds: 4,
          exhaleSeconds: 4,
          cycles: 4,
        ),
        BreathingTechnique(
          id: '478',
          name: '4-7-8 Breathing',
          description: 'Promotes sleep and relaxation.',
          inhaleSeconds: 4,
          holdSeconds: 7,
          exhaleSeconds: 8,
          cycles: 4,
        ),
        BreathingTechnique(
          id: 'diaphragmatic',
          name: 'Deep Belly Breathing',
          description: 'Slow belly breathing to calm the nervous system.',
          inhaleSeconds: 5,
          holdSeconds: 0,
          exhaleSeconds: 5,
          cycles: 6,
        ),
      ];
      for (final t in defaults) {
        await _breaths.put(t.id, t);
      }
    }

    if (_sounds.isEmpty) {
      final defaults = [
        CalmingSound(
          id: 'rain',
          title: 'Rain',
          audioPath: 'assets/sounds/rain.mp3',
          isAsset: true,
          iconName: 'water_drop',
        ),
        CalmingSound(
          id: 'ocean',
          title: 'Ocean Waves',
          audioPath: 'assets/sounds/ocean.mp3',
          isAsset: true,
          iconName: 'waves',
        ),
        CalmingSound(
          id: 'birds',
          title: 'Birds',
          audioPath: 'assets/sounds/birds.mp3',
          isAsset: true,
          iconName: 'flutter_dash',
        ),
        CalmingSound(
          id: 'piano',
          title: 'Soft Piano',
          audioPath: 'assets/sounds/piano.mp3',
          isAsset: true,
          iconName: 'piano',
        ),
      ];
      for (final s in defaults) {
        await _sounds.put(s.id, s);
      }
    }
  }
}
