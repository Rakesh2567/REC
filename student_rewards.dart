import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:attendify/models/reward.dart';
import 'package:attendify/utils/theme.dart';

class StudentRewards extends StatefulWidget {
  const StudentRewards({super.key});

  @override
  State<StudentRewards> createState() => _StudentRewardsState();
}

class _StudentRewardsState extends State<StudentRewards> {
  int _availablePoints = 1250;
  RewardCategory? _selectedCategory;

  final List<Reward> _rewards = [
    Reward(
      id: '1',
      name: 'Coffee Shop Voucher',
      description: '\$5 voucher for campus coffee shop',
      points: 500,
      category: RewardCategory.physical,
      icon: 'coffee',
    ),
    Reward(
      id: '2',
      name: 'Digital Certificate',
      description: 'Personalized achievement certificate',
      points: 200,
      category: RewardCategory.digital,
      icon: 'certificate',
    ),
    Reward(
      id: '3',
      name: 'Library Late Fee Waiver',
      description: 'Waive one late fee at the library',
      points: 300,
      category: RewardCategory.experience,
      icon: 'book',
    ),
    Reward(
      id: '4',
      name: 'Premium Study App',
      description: '3-month premium subscription',
      points: 800,
      category: RewardCategory.digital,
      icon: 'mobile',
    ),
    Reward(
      id: '5',
      name: 'Campus Store Discount',
      description: '20% off next purchase',
      points: 600,
      category: RewardCategory.physical,
      icon: 'shopping-bag',
    ),
    Reward(
      id: '6',
      name: 'Priority Registration',
      description: 'Early course registration access',
      points: 1000,
      category: RewardCategory.experience,
      icon: 'fast-forward',
    ),
    Reward(
      id: '7',
      name: 'Parking Pass',
      description: 'One week premium parking',
      points: 1200,
      category: RewardCategory.physical,
      icon: 'car',
    ),
    Reward(
      id: '8',
      name: 'Study Room Booking',
      description: 'Reserve study room for 4 hours',
      points: 400,
      category: RewardCategory.experience,
      icon: 'door-open',
    ),
  ];

  List<Reward> get _filteredRewards {
    if (_selectedCategory == null) return _rewards;
    return _rewards.where((r) => r.category == _selectedCategory).toList();
  }

  void _redeemReward(Reward reward) {
    if (_availablePoints < reward.points) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient points!'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Redemption'),
        content: Text('Redeem ${reward.name} for ${reward.points} points?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _availablePoints -= reward.points;
              });
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('${reward.name} redeemed successfully!'),
                    ],
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'coffee':
        return FontAwesomeIcons.mugHot;
      case 'certificate':
        return FontAwesomeIcons.certificate;
      case 'book':
        return FontAwesomeIcons.book;
      case 'mobile':
        return FontAwesomeIcons.mobileScreen;
      case 'shopping-bag':
        return FontAwesomeIcons.bagShopping;
      case 'fast-forward':
        return FontAwesomeIcons.forward;
      case 'car':
        return FontAwesomeIcons.car;
      case 'door-open':
        return FontAwesomeIcons.doorOpen;
      default:
        return FontAwesomeIcons.gift;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rewards Store',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Exchange your points for amazing rewards',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Points Balance
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9333EA).withAlpha((0.3 * 255).round()),
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
                    FontAwesomeIcons.coins,
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
                        'Available Points',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ready to spend on rewards',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$_availablePoints',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'points',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Badges Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Badges',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildBadge(
                        'Perfect Attendance',
                        FontAwesomeIcons.calendarCheck,
                        true,
                      ),
                      _buildBadge('Early Bird', FontAwesomeIcons.sun, true),
                      _buildBadge('Streak Master', FontAwesomeIcons.fire, true),
                      _buildBadge(
                        'Class Champion',
                        FontAwesomeIcons.crown,
                        false,
                      ),
                      _buildBadge('Study Star', FontAwesomeIcons.star, false),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Category Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('All', null),
                const SizedBox(width: 8),
                _buildCategoryChip('Digital', RewardCategory.digital),
                const SizedBox(width: 8),
                _buildCategoryChip('Physical', RewardCategory.physical),
                const SizedBox(width: 8),
                _buildCategoryChip('Experience', RewardCategory.experience),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Rewards Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _filteredRewards.length,
            itemBuilder: (context, index) {
              final reward = _filteredRewards[index];
              return _buildRewardCard(reward);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String name, IconData icon, bool earned) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: earned
            ? AppColors.success.withAlpha((0.1 * 255).round())
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: earned ? AppColors.success : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            icon,
            size: 16,
            color: earned ? AppColors.success : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: earned ? AppColors.success : Colors.grey,
            ),
          ),
          if (earned) ...[
            const SizedBox(width: 4),
            const Icon(Icons.check_circle, size: 14, color: AppColors.success),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, RewardCategory? category) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: AppColors.success,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildRewardCard(Reward reward) {
    final canAfford = _availablePoints >= reward.points;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconData(reward.icon),
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              reward.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              reward.description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.coins,
                      size: 14,
                      color: Color(0xFF9333EA),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${reward.points}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    reward.category.toString().split('.').last,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canAfford ? () => _redeemReward(reward) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAfford
                      ? const Color(0xFF9333EA)
                      : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  canAfford ? 'Redeem' : 'Insufficient',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
