class AttendanceRecord {
  final String id;
  final String studentId;
  final String studentName;
  final String sessionId;
  final DateTime timestamp;
  final AttendanceStatus status;
  final bool bleVerified;
  final bool qrVerified;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.sessionId,
    required this.timestamp,
    this.status = AttendanceStatus.present,
    this.bleVerified = false,
    this.qrVerified = false,
  });

  bool get isFullyVerified => bleVerified && qrVerified;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'sessionId': sessionId,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString().split('.').last,
      'bleVerified': bleVerified,
      'qrVerified': qrVerified,
    };
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      studentId: json['studentId'],
      studentName: json['studentName'],
      sessionId: json['sessionId'],
      timestamp: DateTime.parse(json['timestamp']),
      status: AttendanceStatus.values.firstWhere(
        (e) => e.toString() == 'AttendanceStatus.${json['status']}',
      ),
      bleVerified: json['bleVerified'] ?? false,
      qrVerified: json['qrVerified'] ?? false,
    );
  }
}

enum AttendanceStatus { present, absent, late }
