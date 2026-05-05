// lib/Services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // ─── INIT ────────────────────────────────────────────────────────────────────
  static Future<void> init() async {
    tz.initializeTimeZones();

    try {
      // FlutterTimezone.getLocalTimezone() returns a plain String — no .identifier.
      final String timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ─── SCHEDULE ROUTINE ────────────────────────────────────────────────────────
  /// [notifId] must be a **positive** integer. Use `uuid.hashCode.abs()`.
  /// Each day-slot gets its own notification ID: `notifId * 10 + dayIndex`.
  static Future<void> scheduleRoutine({
    required int notifId,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required List<bool> repeatDays,
  }) async {
    // Cancel all 7 existing day-slots before rescheduling.
    await cancelRoutine(notifId);

    final futures = <Future<void>>[];

    for (int i = 0; i < 7; i++) {
      if (!repeatDays[i]) continue;

      final scheduledDate = _nextInstanceOfWeekday(i, hour, minute);

      futures.add(
        _notifications.zonedSchedule(
          notifId * 10 + i, // unique per-day slot
          title,
          body.isNotEmpty ? body : 'Time for your routine!',
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'routine_channel',
              'Routine Notifications',
              channelDescription: 'Daily routine reminders',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        ),
      );
    }

    await Future.wait(futures);
  }

  // ─── CANCEL ROUTINE ──────────────────────────────────────────────────────────
  static Future<void> cancelRoutine(int notifId) async {
    await Future.wait(
      List.generate(7, (i) => _notifications.cancel(notifId * 10 + i)),
    );
  }

  // ─── CANCEL ALL ──────────────────────────────────────────────────────────────
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  // ─── NEXT OCCURRENCE OF A WEEKDAY ────────────────────────────────────────────
  /// Returns the soonest future [tz.TZDateTime] that falls on [weekdayIndex]
  /// (0 = Monday … 6 = Sunday) at [hour]:[minute].
  ///
  /// Fixes the original bug where the loop kept adding days even when the
  /// correct weekday had already been found but the time was still in the
  /// future today.
  static tz.TZDateTime _nextInstanceOfWeekday(
      int weekdayIndex, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    // tz weekday: Mon=1 … Sun=7
    final targetWeekday = weekdayIndex + 1;

    // Start from today at the requested time.
    var candidate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Advance day-by-day until we land on the right weekday AND the
    // scheduled time is strictly in the future.
    while (candidate.weekday != targetWeekday || !candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }

    return candidate;
  }
}