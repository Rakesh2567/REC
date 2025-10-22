import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:attendify/models/student.dart';
import 'package:attendify/utils/theme.dart';
import 'package:attendify/widgets/stat_card.dart';

class TeacherStudents extends StatelessWidget {
  const TeacherStudents({super.key});

  @override
  Widget build(BuildContext context) {
    final students = _getMockStudents();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student Management',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your students and their attendance records',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Stats
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total Students',
                  value: '156',
                  icon: FontAwesomeIcons.users,
                  color: AppColors.info,
                  backgroundColor: Color(0xFFDBEAFE),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'At Risk',
                  value: '14',
                  icon: FontAwesomeIcons.triangleExclamation,
                  color: AppColors.warning,
                  backgroundColor: Color(0xFFFEF3C7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Students List
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Students List',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return _StudentCard(student: student);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Student> _getMockStudents() {
    return [
      Student(
        id: 'STU001',
        name: 'Alice Johnson',
        email: 'alice@university.edu',
        attendanceCount: 42,
        totalClasses: 45,
        points: 1800,
        rank: 1,
      ),
      Student(
        id: 'STU002',
        name: 'Bob Smith',
        email: 'bob@university.edu',
        attendanceCount: 38,
        totalClasses: 45,
        points: 1500,
        rank: 5,
      ),
      Student(
        id: 'STU003',
        name: 'Carol Davis',
        email: 'carol@university.edu',
        attendanceCount: 30,
        totalClasses: 45,
        points: 1200,
        rank: 12,
      ),
    ];
  }
}

class _StudentCard extends StatelessWidget {
  final Student student;

  const _StudentCard({required this.student});

  @override
  Widget build(BuildContext context) {
    final rate = student.attendanceRate;
    final Color statusColor;

    if (rate >= 85) {
      statusColor = AppColors.success;
    } else if (rate >= 70) {
      statusColor = AppColors.warning;
    } else {
      statusColor = AppColors.danger;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: statusColor.withAlpha((0.1 * 255).round()),
              shape: BoxShape.circle,
            ),
            child: Icon(FontAwesomeIcons.user, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  student.id,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Attendance: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      student.attendanceRateString,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${student.attendanceCount}/${student.totalClasses}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${student.points} pts',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
