// lib/models/types.dart

enum Category { alphabet, animals, seaAnimals, fruits }

enum AppView {
  splash,
  home,
  letters,
  quests,
  friends,
  learn,
  match,
  spelling,
  miniReward,
  challenge,
  gift,
  story,
}

enum StepType {
  intro,
  learn,
  learnUpper,
  learnLower,
  learnWord,
  match,
  spell,
  miniReward,
  challenge,
  story,
}

class LearningItem {
  final String id;
  final String name;
  final String description;
  final String image;
  final Category category;
  final String phonetic;

  const LearningItem({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.category,
    required this.phonetic,
  });
}

class LessonStep {
  final StepType type;
  final LearningItem? item;
  final List<LearningItem>? options;
  final String? title;

  const LessonStep({
    required this.type,
    this.item,
    this.options,
    this.title,
  });
}

class UnitStepMeta {
  final StepType type;
  final String icon;
  final String label;

  const UnitStepMeta({
    required this.type,
    required this.icon,
    required this.label,
  });
}

class CategoryMeta {
  final String title;
  final int color;
  final int darkColor;
  final String icon;
  final String description;

  const CategoryMeta({
    required this.title,
    required this.color,
    required this.darkColor,
    required this.icon,
    required this.description,
  });
}

class UserProgress {
  final int completedUnitIndex;
  final int completedStepIndex;
  final int? stars; // 1. Add this line

  const UserProgress({
    this.completedUnitIndex = 0,
    this.completedStepIndex = 0,
    this.stars = 0, // 2. Add this default value
  });

  UserProgress copyWith(
      {int? completedUnitIndex, int? completedStepIndex, int? stars}) {
    return UserProgress(
      completedUnitIndex: completedUnitIndex ?? this.completedUnitIndex,
      completedStepIndex: completedStepIndex ?? this.completedStepIndex,
      stars: stars ?? this.stars, // 3. Update copyWith
    );
  }

  Map<String, dynamic> toJson() => {
        'completedUnitIndex': completedUnitIndex,
        'completedStepIndex': completedStepIndex,
        'stars': stars, // 4. Update JSON
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
        completedUnitIndex: json['completedUnitIndex'] ?? 0,
        completedStepIndex: json['completedStepIndex'] ?? 0,
        stars: json['stars'] ?? 0, // 5. Update Factory
      );
}
