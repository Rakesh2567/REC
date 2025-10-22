import 'package:uuid/uuid.dart';

class AttendanceSession {
  final String id;
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final String teacherId;
  final List<String> attendedStudents;
  final SessionStatus status;

  AttendanceSession({
    String? id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.teacherId,
    List<String>? attendedStudents,
    this.status = SessionStatus.active,
  }) : id = id ?? const Uuid().v4(),
       attendedStudents = attendedStudents ?? [];

  bool get isExpired => DateTime.now().isAfter(endTime);

  Duration get remainingTime {
    if (isExpired) return Duration.zero;
    return endTime.difference(DateTime.now());
  }

  String get qrData => '$id|$name|${startTime.millisecondsSinceEpoch}';

  factory AttendanceSession.fromQR(String qrData) {
    final parts = qrData.split('|');
    return AttendanceSession(
      id: parts[0],
      name: parts[1],
      startTime: DateTime.fromMillisecondsSinceEpoch(int.parse(parts[2])),
      endTime: DateTime.fromMillisecondsSinceEpoch(
        int.parse(parts[2]),
      ).add(const Duration(hours: 1)),
      teacherId: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'teacherId': teacherId,
      'attendedStudents': attendedStudents,
      'status': status.toString().split('.').last,
    };
  }

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      id: json['id'],
      name: json['name'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      teacherId: json['teacherId'],
      attendedStudents: List<String>.from(json['attendedStudents'] ?? []),
      status: SessionStatus.values.firstWhere(
        (e) => e.toString() == 'SessionStatus.${json['status']}',
      ),
    );
  }
}

enum SessionStatus { active, completed, expired }
