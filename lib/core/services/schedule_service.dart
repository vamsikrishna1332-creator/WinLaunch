import 'dart:convert';
import '../models/schedule_model.dart';
import '../database/database_helper.dart';
import 'package:uuid/uuid.dart';

class ScheduleService {
  static final ScheduleService _instance = ScheduleService._internal();
  factory ScheduleService() => _instance;
  ScheduleService._internal();

  static const int maxSchedules = 20;
  final _uuid = const Uuid();

  Future<List<Schedule>> loadSchedules({String profileId = 'default'}) async {
    final rows = await DatabaseHelper.instance.queryAll(
      'schedules',
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'start_time ASC',
    );
    return rows.map((r) => Schedule.fromJson({
          ...r,
          'repeatDays': jsonDecode(r['repeat_days'] as String? ?? '[]'),
          'startTime': r['start_time'],
          'endTime': r['end_time'],
          'enableNotification': r['enable_notification'],
          'notifyMinutesBefore': r['notify_minutes_before'],
          'isActive': r['is_active'],
          'createdAt': r['created_at'],
          'profileId': r['profile_id'],
        })).toList();
  }

  Future<Schedule?> getCurrentSchedule({String profileId = 'default'}) async {
    final schedules = await loadSchedules(profileId: profileId);
    for (final s in schedules) {
      if (!s.isActive) continue;
      if (s.isRunning) return s;
    }
    return null;
  }

  Future<Schedule?> getNextSchedule({String profileId = 'default'}) async {
    final schedules = await loadSchedules(profileId: profileId);
    final now = DateTime.now();
    Schedule? next;
    for (final s in schedules) {
      if (!s.isActive) continue;
      if (s.startTime.isAfter(now)) {
        if (next == null || s.startTime.isBefore(next.startTime)) {
          next = s;
        }
      }
    }
    return next;
  }

  Future<Schedule> addSchedule(Schedule schedule) async {
    final schedules = await loadSchedules(profileId: schedule.profileId);
    if (schedules.length >= maxSchedules) {
      throw Exception('Maximum $maxSchedules schedules reached.');
    }
    final newSchedule = schedule.copyWith(id: schedule.id.isEmpty ? _uuid.v4() : null);
    await _save(newSchedule);
    return newSchedule;
  }

  Future<void> updateSchedule(Schedule schedule) async {
    await _save(schedule);
  }

  Future<void> deleteSchedule(String id) async {
    await DatabaseHelper.instance.delete('schedules', id);
  }

  Future<void> toggleActive(String id, bool active) async {
    final db = DatabaseHelper.instance;
    await db.update('schedules', {'is_active': active ? 1 : 0}, id);
  }

  Future<void> _save(Schedule s) async {
    await DatabaseHelper.instance.insert('schedules', {
      'id': s.id,
      'profile_id': s.profileId,
      'title': s.title,
      'description': s.description,
      'start_time': s.startTime.toIso8601String(),
      'end_time': s.endTime.toIso8601String(),
      'repeat': s.repeat.name,
      'repeat_days': jsonEncode(s.repeatDays),
      'color': s.color,
      'priority': s.priority.name,
      'icon': s.icon,
      'enable_notification': s.enableNotification ? 1 : 0,
      'notify_minutes_before': s.notifyMinutesBefore,
      'status': s.status.name,
      'is_active': s.isActive ? 1 : 0,
      'created_at': s.createdAt.toIso8601String(),
    });
  }
}
