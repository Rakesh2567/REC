import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:attendify/utils/theme.dart';

class StudentLeaderboard extends StatelessWidget {
  const StudentLeaderboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Leaderboard',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'See how you rank among your peers',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Your Rank Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.gradientGreen,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withAlpha((0.3 * 255).round()),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.2 * 255).round()),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    FontAwesomeIcons.medal,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Current Rank',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Keep climbing to reach the top!',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '#7',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '1,250 points',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Top 3 Podium
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd Place
              Expanded(
                child: _buildPodiumCard(
                  rank: 2,
                  name: 'Sarah Wilson',
                  points: 1890,
                  color: Colors.grey.shade400,
                  height: 180,
                ),
              ),
              const SizedBox(width: 8),
              // 1st Place
              Expanded(
                child: _buildPodiumCard(
                  rank: 1,
                  name: 'Alex Chen',
                  points: 2150,
                  color: const Color(0xFFFFD700),
                  height: 220,
                ),
              ),
              const SizedBox(width: 8),
              // 3rd Place
              Expanded(
                child: _buildPodiumCard(
                  rank: 3,
                  name: 'Mike Johnson',
                  points: 1720,
                  color: const Color(0xFFCD7F32),
                  height: 160,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Full Leaderboard
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Full Rankings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(10, (index) {
                    final isCurrentUser = index == 6;
                    return _buildLeaderboardItem(
                      rank: index + 1,
                      name: _getStudentName(index),
                      points: _getStudentPoints(index),
                      isCurrentUser: isCurrentUser,
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumCard({
    required int rank,
    required String name,
    required int points,
    required Color color,
    required double height,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color, color.withAlpha((0.7 * 255).round())],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha((0.4 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            rank == 1 ? FontAwesomeIcons.crown : FontAwesomeIcons.medal,
            color: Colors.white,
            size: rank == 1 ? 32 : 24,
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.3 * 255).round()),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              FontAwesomeIcons.user,
              color: Colors.white,
              size: 24,
            ),
          ),
          Column(
            children: [
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$points pts',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required String name,
    required int points,
    required bool isCurrentUser,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.success.withAlpha((0.1 * 255).round())
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser ? AppColors.success : Colors.grey.shade200,
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCurrentUser ? AppColors.success : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? AppColors.success.withAlpha((0.1 * 255).round())
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              FontAwesomeIcons.user,
              size: 20,
              color: isCurrentUser ? AppColors.success : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isCurrentUser ? '$name (You)' : name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
                color: isCurrentUser ? AppColors.success : Colors.black,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                points.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser ? AppColors.success : Colors.black,
                ),
              ),
              const Text(
                'points',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStudentName(int index) {
    final names = [
      'Alex Chen',
      'Sarah Wilson',
      'Mike Johnson',
      'Emma Davis',
      'James Wilson',
      'Lisa Brown',
      'John Doe',
      'Tom Miller',
      'Anna Garcia',
      'Chris Lee',
    ];
    return names[index];
  }

  int _getStudentPoints(int index) {
    final points = [2150, 1890, 1720, 1650, 1520, 1380, 1250, 1120, 980, 850];
    return points[index];
  }
}
