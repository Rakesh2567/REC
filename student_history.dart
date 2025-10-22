import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:attendify/models/attendance_record.dart';
import 'package:attendify/utils/theme.dart';
import 'package:attendify/widgets/stat_card.dart';

class StudentHistory extends StatelessWidget {
  const StudentHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance History',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'View your complete attendance record',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Stats
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Present',
                  value: '42',
                  icon: FontAwesomeIcons.circleCheck,
                  color: AppColors.success,
                  backgroundColor: Color(0xFFD1FAE5),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Absent',
                  value: '8',
                  icon: FontAwesomeIcons.circleXmark,
                  color: AppColors.danger,
                  backgroundColor: Color(0xFFFEE2E2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Late',
                  value: '3',
                  icon: FontAwesomeIcons.clock,
                  color: AppColors.warning,
                  backgroundColor: Color(0xFFFEF3C7),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Total Classes',
                  value: '53',
                  icon: FontAwesomeIcons.bookOpen,
                  color: AppColors.info,
                  backgroundColor: Color(0xFFDBEAFE),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Monthly Trend Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Attendance Trend',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const months = [
                                  'Jan',
                                  'Feb',
                                  'Mar',
                                  'Apr',
                                  'May',
                                  'Jun',
                                ];
                                if (value.toInt() >= 0 &&
                                    value.toInt() < months.length) {
                                  return Text(months[value.toInt()]);
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 85),
                              FlSpot(1, 78),
                              FlSpot(2, 82),
                              FlSpot(3, 88),
                              FlSpot(4, 85),
                              FlSpot(5, 90),
                            ],
                            isCurved: true,
                            color: AppColors.success,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.success
                                  .withAlpha((0.1 * 255).round()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Recent Records
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Attendance Records',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._getHistoryRecords().map(
                    (record) => _buildHistoryCard(record),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> record) {
    final status = record['status'] as AttendanceStatus;
    final Color statusColor;
    final IconData statusIcon;

    switch (status) {
      case AttendanceStatus.present:
        statusColor = AppColors.success;
        statusIcon = FontAwesomeIcons.circleCheck;
        break;
      case AttendanceStatus.absent:
        statusColor = AppColors.danger;
        statusIcon = FontAwesomeIcons.circleXmark;
        break;
      case AttendanceStatus.late:
        statusColor = AppColors.warning;
        statusIcon = FontAwesomeIcons.clock;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
            color: statusColor.withAlpha((0.3 * 255).round()), width: 2),
        borderRadius: BorderRadius.circular(12),
        color: statusColor.withAlpha((0.05 * 255).round()),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withAlpha((0.1 * 255).round()),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record['subject'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(record['date'] as DateTime),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
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
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toString().split('.').last.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                record['time'] as String,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getHistoryRecords() {
    return [
      {
        'subject': 'Mathematics',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'status': AttendanceStatus.present,
        'time': '09:15 AM',
      },
      {
        'subject': 'Physics',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'status': AttendanceStatus.present,
        'time': '10:30 AM',
      },
      {
        'subject': 'Chemistry',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'status': AttendanceStatus.absent,
        'time': '-',
      },
      {
        'subject': 'Mathematics',
        'date': DateTime.now().subtract(const Duration(days: 4)),
        'status': AttendanceStatus.late,
        'time': '09:25 AM',
      },
      {
        'subject': 'Physics',
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'status': AttendanceStatus.present,
        'time': '10:28 AM',
      },
    ];
  }
}
