// lib/Pages/patient_location_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_fyp/Caregiver/Models/hive_models.dart';   // ← Caregiver/Models
import 'package:my_fyp/Service/hive_service.dart';           // ← root Service (matches main.dart)
import 'package:my_fyp/Utils/app_theme.dart';      // ← Caregiver/Utils

class PatientLocationScreen extends StatefulWidget {
  const PatientLocationScreen({super.key});

  @override
  State<PatientLocationScreen> createState() =>
      _PatientLocationScreenState();
}

class _PatientLocationScreenState extends State<PatientLocationScreen> {
  List<LocationSnapshot> _locations = [];
  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _locations = HiveService.getLocations();
    debugPrint('📍 Location screen — saved locations: ${_locations.length}');
    _clockTimer = Timer.periodic(
        const Duration(seconds: 1), (_) => setState(() => _now = DateTime.now()));
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm').format(_now);
    final amPm = DateFormat('a').format(_now);
    final dateStr = DateFormat('EEEE, MMMM d').format(_now);
    final yearStr = DateFormat('y').format(_now);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white70),
        title: const Text('Where Am I',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClockCard(timeStr, amPm, dateStr, yearStr),
            const SizedBox(height: 20),
            const Text(
              'SAVED LOCATIONS',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white38,
                  letterSpacing: 1.4),
            ),
            const SizedBox(height: 12),
            if (_locations.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3A5C),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: Colors.white.withOpacity(0.07)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_off_rounded,
                        color: Colors.white38, size: 26),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'No saved locations yet.\nAsk your caregiver to save some.',
                        style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._locations.map((loc) => _LocationCard(snapshot: loc)),
          ],
        ),
      ),
    );
  }

  Widget _buildClockCard(
      String time, String amPm, String date, String year) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B3A5C), Color(0xFF0D2137)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time,
                  style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1)),
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 4),
                child: Text(amPm,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accent)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(date,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70)),
          Text(year,
              style: const TextStyle(fontSize: 14, color: Colors.white38)),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final LocationSnapshot snapshot;
  const _LocationCard({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('MMM d, y · hh:mm a').format(snapshot.savedAt);
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
              color: AppTheme.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.location_on_rounded,
                color: AppTheme.success, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(snapshot.label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
                const SizedBox(height: 3),
                Text(snapshot.addressLine,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        color: Colors.white38, size: 11),
                    const SizedBox(width: 4),
                    Text(dateStr,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
