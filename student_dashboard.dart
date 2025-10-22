import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:attendify/services/auth_service.dart';
import 'package:attendify/utils/theme.dart';
import 'package:attendify/widgets/stat_card.dart';
import 'package:attendify/screens/login/login_page.dart';
import 'student_scanner.dart';
import 'student_leaderboard.dart';
import 'student_rewards.dart';
import 'student_history.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const FaIcon(FontAwesomeIcons.qrcode, color: AppColors.success),
            const SizedBox(width: 12),
            const Text('Attendify'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Student',
                style: TextStyle(fontSize: 12, color: AppColors.success),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Capture the service before the async gap to avoid using
              // BuildContext across an await. Guard post-await use with
              // `context.mounted`.
              final authService = context.read<AuthService>();
              await authService.logout();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _StudentDashboardContent(),
          StudentScanner(),
          StudentLeaderboard(),
          StudentRewards(),
          StudentHistory(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scanner',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.card_giftcard),
            label: 'Rewards',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}

class _StudentDashboardContent extends StatelessWidget {
  const _StudentDashboardContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student Dashboard',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track your attendance and academic progress',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Stats
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: const [
              StatCard(
                title: 'Classes Attended',
                value: '42',
                icon: FontAwesomeIcons.calendarCheck,
                color: AppColors.success,
                backgroundColor: Color(0xFFD1FAE5),
              ),
              StatCard(
                title: 'Attendance Rate',
                value: '85%',
                icon: FontAwesomeIcons.percent,
                color: AppColors.info,
                backgroundColor: Color(0xFFDBEAFE),
              ),
              StatCard(
                title: 'Late Arrivals',
                value: '3',
                icon: FontAwesomeIcons.clock,
                color: AppColors.warning,
                backgroundColor: Color(0xFFFEF3C7),
              ),
              StatCard(
                title: 'Total Points',
                value: '1,250',
                icon: FontAwesomeIcons.coins,
                color: Color(0xFF9333EA),
                backgroundColor: Color(0xFFF3E8FF),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attendance Progress',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: 82,
                            title: '82%',
                            color: AppColors.success,
                            radius: 80,
                          ),
                          PieChartSectionData(
                            value: 12,
                            title: '12%',
                            color: AppColors.danger,
                            radius: 80,
                          ),
                          PieChartSectionData(
                            value: 6,
                            title: '6%',
                            color: AppColors.warning,
                            radius: 80,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLegend('Present', AppColors.success),
                      _buildLegend('Absent', AppColors.danger),
                      _buildLegend('Late', AppColors.warning),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
