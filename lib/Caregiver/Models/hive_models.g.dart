// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: flutter packages pub run build_runner build

part of 'hive_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemoryCardAdapter extends TypeAdapter<MemoryCard> {
  @override
  final int typeId = 0;

  @override
  MemoryCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemoryCard(
      id: fields[0] as String,
      imagePath: fields[1] as String,
      description: fields[2] as String,
      voicePath: fields[3] as String?,
      personName: fields[4] as String,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MemoryCard obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.voicePath)
      ..writeByte(4)
      ..write(obj.personName)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RoutineItemAdapter extends TypeAdapter<RoutineItem> {
  @override
  final int typeId = 1;

  @override
  RoutineItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoutineItem(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      hour: fields[3] as int,
      minute: fields[4] as int,
      category: fields[5] as String,
      isEnabled: fields[6] as bool,
      repeatDays: (fields[7] as List).cast<bool>(),
    );
  }

  @override
  void write(BinaryWriter writer, RoutineItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.hour)
      ..writeByte(4)
      ..write(obj.minute)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.isEnabled)
      ..writeByte(7)
      ..write(obj.repeatDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CalmingSoundAdapter extends TypeAdapter<CalmingSound> {
  @override
  final int typeId = 2;

  @override
  CalmingSound read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalmingSound(
      id: fields[0] as String,
      title: fields[1] as String,
      audioPath: fields[2] as String,
      isAsset: fields[3] as bool,
      iconName: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CalmingSound obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.audioPath)
      ..writeByte(3)
      ..write(obj.isAsset)
      ..writeByte(4)
      ..write(obj.iconName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalmingSoundAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BreathingTechniqueAdapter extends TypeAdapter<BreathingTechnique> {
  @override
  final int typeId = 3;

  @override
  BreathingTechnique read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BreathingTechnique(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      inhaleSeconds: fields[3] as int,
      holdSeconds: fields[4] as int,
      exhaleSeconds: fields[5] as int,
      cycles: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BreathingTechnique obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.inhaleSeconds)
      ..writeByte(4)
      ..write(obj.holdSeconds)
      ..writeByte(5)
      ..write(obj.exhaleSeconds)
      ..writeByte(6)
      ..write(obj.cycles);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreathingTechniqueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FamilyVoiceMessageAdapter extends TypeAdapter<FamilyVoiceMessage> {
  @override
  final int typeId = 4;

  @override
  FamilyVoiceMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FamilyVoiceMessage(
      id: fields[0] as String,
      senderName: fields[1] as String,
      audioPath: fields[2] as String,
      transcription: fields[3] as String?,
      recordedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FamilyVoiceMessage obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.senderName)
      ..writeByte(2)
      ..write(obj.audioPath)
      ..writeByte(3)
      ..write(obj.transcription)
      ..writeByte(4)
      ..write(obj.recordedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilyVoiceMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocationSnapshotAdapter extends TypeAdapter<LocationSnapshot> {
  @override
  final int typeId = 5;

  @override
  LocationSnapshot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationSnapshot(
      id: fields[0] as String,
      latitude: fields[1] as double,
      longitude: fields[2] as double,
      addressLine: fields[3] as String,
      savedAt: fields[4] as DateTime,
      label: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LocationSnapshot obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.latitude)
      ..writeByte(2)
      ..write(obj.longitude)
      ..writeByte(3)
      ..write(obj.addressLine)
      ..writeByte(4)
      ..write(obj.savedAt)
      ..writeByte(5)
      ..write(obj.label);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationSnapshotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
