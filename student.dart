class Student {
  final String id;
  final String name;
  final String email;
  final int attendanceCount;
  final int totalClasses;
  final int points;
  final int rank;
  final List<String> badges;

  Student({
    required this.id,
    required this.name,
    required this.email,
    this.attendanceCount = 0,
    this.totalClasses = 0,
    this.points = 0,
    this.rank = 0,
    this.badges = const [],
  });

  double get attendanceRate {
    if (totalClasses == 0) return 0.0;
    return (attendanceCount / totalClasses) * 100;
  }

  String get attendanceRateString => '${attendanceRate.toStringAsFixed(1)}%';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'attendanceCount': attendanceCount,
      'totalClasses': totalClasses,
      'points': points,
      'rank': rank,
      'badges': badges,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      attendanceCount: json['attendanceCount'] ?? 0,
      totalClasses: json['totalClasses'] ?? 0,
      points: json['points'] ?? 0,
      rank: json['rank'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
    );
  }
}
