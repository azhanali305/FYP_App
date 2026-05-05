// lib/Caregiver/Screens/where_am_i_screen.dart
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import '../Models/hive_models.dart';
import '../../Service/hive_service.dart';
import 'package:my_fyp/Utils/app_theme.dart';

class WhereAmIScreen extends StatefulWidget {
  const WhereAmIScreen({super.key});

  @override
  State<WhereAmIScreen> createState() => _WhereAmIScreenState();
}

class _WhereAmIScreenState extends State<WhereAmIScreen> {
  String _address = 'Fetching location…';
  String _city = '';
  double? _lat, _lng;
  bool _loading = false;
  List<LocationSnapshot> _saved = [];
  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSaved();
    _fetchLocation();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  void _loadSaved() =>
      setState(() => _saved = HiveService.getLocations());

  Future<void> _fetchLocation() async {
    setState(() => _loading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _address = 'Location services disabled';
          _loading = false;
        });
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          setState(() {
            _address = 'Location permission denied';
            _loading = false;
          });
          return;
        }
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      final placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.street,
          p.subLocality,
          p.locality,
        ].where((s) => s != null && s.isNotEmpty).toList();

        setState(() {
          _lat = pos.latitude;
          _lng = pos.longitude;
          _city = p.locality ?? '';
          _address = parts.join(', ');
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _address = 'Could not fetch location';
        _loading = false;
      });
    }
  }

  Future<void> _saveLocation() async {
    if (_lat == null) return;
    final labelCtrl = TextEditingController(text: 'Home');
    final label = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Save Location',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: labelCtrl,
          decoration: const InputDecoration(
              hintText: 'Label (e.g. "Home", "Hospital")'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, labelCtrl.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (label == null || label.isEmpty) return;
    final snap = LocationSnapshot(
      id: const Uuid().v4(),
      latitude: _lat!,
      longitude: _lng!,
      addressLine: _address,
      savedAt: DateTime.now(),
      label: label,
    );
    await HiveService.saveLocation(snap);
    _loadSaved();
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
        title: Text('Where Am I',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            onPressed: _fetchLocation,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Clock
            _buildClockCard(timeStr, amPm, dateStr, yearStr),
            const SizedBox(height: 16),

            // Location card
            _buildLocationCard(),
            const SizedBox(height: 16),

            // Save button
            if (_lat != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveLocation,
                  icon: const Icon(Icons.bookmark_add_rounded),
                  label: const Text('Save This Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            const SizedBox(height: 24),

            if (_saved.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Saved Locations',
                    style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ),
              const SizedBox(height: 12),
              ..._saved.map((s) => _SavedLocationTile(
                    snapshot: s,
                    onDelete: () async {
                      await HiveService.deleteLocation(s.id);
                      _loadSaved();
                    },
                  )),
            ],
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
              Text(
                time,
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 4),
                child: Text(
                  amPm,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF52B788),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          Text(
            year,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3A5C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_on_rounded,
                    color: AppTheme.success, size: 22),
              ),
              const SizedBox(width: 12),
              Text('Current Location',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
              const Spacer(),
              if (_loading)
                const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.success))
              else
                GestureDetector(
                  onTap: _fetchLocation,
                  child: const Icon(Icons.my_location_rounded,
                      color: AppTheme.success, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _loading ? 'Getting your location…' : _address,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white),
          ),
          if (_city.isNotEmpty && !_loading)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(_city,
                  style: TextStyle(
                      fontSize: 13, color: Colors.white54)),
            ),
          if (_lat != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.white38),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SavedLocationTile extends StatelessWidget {
  final LocationSnapshot snapshot;
  final VoidCallback onDelete;

  const _SavedLocationTile({
    required this.snapshot,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, y · hh:mm a').format(snapshot.savedAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3A5C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.bookmark_rounded,
                color: AppTheme.warning, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(snapshot.label,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                Text(snapshot.addressLine,
                    style: TextStyle(
                        color: Colors.white60, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(dateStr,
                    style: TextStyle(
                        color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded,
                color: Colors.white30, size: 20),
          ),
        ],
      ),
    );
  }
}
