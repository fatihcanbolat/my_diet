class MealEntry {
  final String id;
  final String name;
  final String description;
  final DateTime dateTime;
  final String? imagePath;
  final String mealType; // kahvaltı, öğle yemeği, akşam yemeği, ara öğün

  MealEntry({
    required this.id,
    required this.name,
    required this.description,
    required this.dateTime,
    this.imagePath,
    required this.mealType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'imagePath': imagePath,
      'mealType': mealType,
    };
  }

  factory MealEntry.fromJson(Map<String, dynamic> json) {
    return MealEntry(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      dateTime: DateTime.parse(json['dateTime']),
      imagePath: json['imagePath'],
      mealType: json['mealType'],
    );
  }

  MealEntry copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? dateTime,
    String? imagePath,
    String? mealType,
  }) {
    return MealEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      imagePath: imagePath ?? this.imagePath,
      mealType: mealType ?? this.mealType,
    );
  }
} 