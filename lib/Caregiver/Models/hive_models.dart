// lib/models/hive_models.dart
import 'package:hive/hive.dart';

part 'hive_models.g.dart';

// ─── Memory Album ────────────────────────────────────────────────────────────

@HiveType(typeId: 0)
class MemoryCard extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String imagePath;

  @HiveField(2)
  String description;

  @HiveField(3)
  String? voicePath; // recorded or picked audio

  @HiveField(4)
  String personName;

  @HiveField(5)
  DateTime createdAt;

  MemoryCard({
    required this.id,
    required this.imagePath,
    required this.description,
    this.voicePath,
    required this.personName,
    required this.createdAt,
  });
}

// ─── Daily Routine ───────────────────────────────────────────────────────────

@HiveType(typeId: 1)
class RoutineItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  int hour;

  @HiveField(4)
  int minute;

  @HiveField(5)
  String category; // meal, prayer, medication, exercise, hydration, sleep

  @HiveField(6)
  bool isEnabled;

  @HiveField(7)
  List<bool> repeatDays; // Mon–Sun

  RoutineItem({
    required this.id,
    required this.title,
    required this.description,
    required this.hour,
    required this.minute,
    required this.category,
    this.isEnabled = true,
    List<bool>? repeatDays,
  }) : repeatDays = repeatDays ?? List.filled(7, true);
}

// ─── Calming Mode ────────────────────────────────────────────────────────────

@HiveType(typeId: 2)
class CalmingSound extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String audioPath; // local or bundled asset key

  @HiveField(3)
  bool isAsset; // true = bundled asset, false = local file

  @HiveField(4)
  String iconName;

  CalmingSound({
    required this.id,
    required this.title,
    required this.audioPath,
    required this.isAsset,
    required this.iconName,
  });
}

@HiveType(typeId: 3)
class BreathingTechnique extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  int inhaleSeconds;

  @HiveField(4)
  int holdSeconds;

  @HiveField(5)
  int exhaleSeconds;

  @HiveField(6)
  int cycles;

  BreathingTechnique({
    required this.id,
    required this.name,
    required this.description,
    required this.inhaleSeconds,
    required this.holdSeconds,
    required this.exhaleSeconds,
    required this.cycles,
  });
}

@HiveType(typeId: 4)
class FamilyVoiceMessage extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String senderName;

  @HiveField(2)
  String audioPath;

  @HiveField(3)
  String? transcription;

  @HiveField(4)
  DateTime recordedAt;

  FamilyVoiceMessage({
    required this.id,
    required this.senderName,
    required this.audioPath,
    this.transcription,
    required this.recordedAt,
  });
}

// ─── Where Am I (saved location snapshot) ────────────────────────────────────

@HiveType(typeId: 5)
class LocationSnapshot extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double latitude;

  @HiveField(2)
  double longitude;

  @HiveField(3)
  String addressLine;

  @HiveField(4)
  DateTime savedAt;

  @HiveField(5)
  String label; // e.g. "Home", "Hospital"

  LocationSnapshot({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.addressLine,
    required this.savedAt,
    required this.label,
  });
}
