import '../../models/types.dart';

class FirestoreLearningItem {
  final String id;
  final String name;
  final String description;
  final String image;
  final String category;
  final String phonetic;

  const FirestoreLearningItem({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.category,
    required this.phonetic,
  });

  factory FirestoreLearningItem.fromMap(Map<String, dynamic> map) {
    return FirestoreLearningItem(
      id: _sanitize(map['id']),
      name: _sanitize(map['name']),
      description: _sanitize(map['description']),
      image: _sanitize(map['image']),
      category: _sanitize(map['category']),
      phonetic: _sanitize(map['phonetic']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'category': category,
      'phonetic': phonetic,
    };
  }

  LearningItem toLearningItem() {
    return LearningItem(
      id: id,
      name: name,
      description: description,
      image: image,
      category: _parseCategory(category),
      phonetic: phonetic,
    );
  }

  static String _sanitize(dynamic val) {
    if (val == null) return '';
    String s = val.toString();
    // Remove leading and trailing double/single quotes if they exist (even multiple sets)
    while (s.length >= 2 &&
        ((s.startsWith('"') && s.endsWith('"')) ||
            (s.startsWith("'") && s.endsWith("'")))) {
      s = s.substring(1, s.length - 1);
    }
    return s.trim();
  }

  static Category _parseCategory(String value) {
    switch (value) {
      case 'alphabet':
        return Category.alphabet;
      case 'animals':
        return Category.animals;
      case 'seaAnimals':
        return Category.seaAnimals;
      case 'fruits':
        return Category.fruits;
      default:
        return Category.alphabet;
    }
  }
}
