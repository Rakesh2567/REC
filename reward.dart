class Reward {
  final String id;
  final String name;
  final String description;
  final int points;
  final RewardCategory category;
  final String icon;
  final bool available;

  Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.points,
    required this.category,
    required this.icon,
    this.available = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'points': points,
      'category': category.toString().split('.').last,
      'icon': icon,
      'available': available,
    };
  }

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      points: json['points'],
      category: RewardCategory.values.firstWhere(
        (e) => e.toString() == 'RewardCategory.${json['category']}',
      ),
      icon: json['icon'],
      available: json['available'] ?? true,
    );
  }
}

enum RewardCategory { digital, physical, experience }
