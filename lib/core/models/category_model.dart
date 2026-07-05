class CategoryModel {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final String promptHint;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.promptHint,
  });
}

class AppCategories {
  static const List<CategoryModel> all = [
    CategoryModel(
      id: 'selfie',
      name: 'Selfie',
      emoji: '📸',
      description: 'Personal photos & selfies',
      promptHint: 'selfie or personal photo',
    ),
    CategoryModel(
      id: 'love',
      name: 'Love',
      emoji: '❤️',
      description: 'Couple & romantic posts',
      promptHint: 'couple or romantic moment',
    ),
    CategoryModel(
      id: 'attitude',
      name: 'Attitude',
      emoji: '😎',
      description: 'Swag & attitude vibes',
      promptHint: 'attitude or swag moment',
    ),
    CategoryModel(
      id: 'travel',
      name: 'Travel',
      emoji: '✈️',
      description: 'Travel & adventure',
      promptHint: 'travel or adventure moment',
    ),
    CategoryModel(
      id: 'gym',
      name: 'Gym',
      emoji: '💪',
      description: 'Fitness & workout',
      promptHint: 'gym or fitness moment',
    ),
    CategoryModel(
      id: 'bike',
      name: 'Bike',
      emoji: '🏍',
      description: 'Bike & ride posts',
      promptHint: 'bike or motorcycle ride',
    ),
    CategoryModel(
      id: 'nature',
      name: 'Nature',
      emoji: '🌄',
      description: 'Nature & scenery',
      promptHint: 'nature or scenic view',
    ),
    CategoryModel(
      id: 'linkedin',
      name: 'LinkedIn',
      emoji: '👔',
      description: 'Professional achievements',
      promptHint: 'professional achievement or milestone',
    ),
    CategoryModel(
      id: 'funny',
      name: 'Funny',
      emoji: '😂',
      description: 'Funny & humorous',
      promptHint: 'funny or humorous moment',
    ),
    CategoryModel(
      id: 'birthday',
      name: 'Birthday',
      emoji: '🎂',
      description: 'Birthday celebrations',
      promptHint: 'birthday celebration',
    ),
  ];
}
