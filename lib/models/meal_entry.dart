import 'food_item.dart';

class MealEntry {
  final String id;
  final String name;
  final String description;
  final DateTime dateTime;
  final String? imagePath;
  final String mealType; // kahvaltı, öğle yemeği, akşam yemeği, ara öğün
  final List<FoodItem> foodItems;

  MealEntry({
    required this.id,
    required this.name,
    required this.description,
    required this.dateTime,
    this.imagePath,
    required this.mealType,
    this.foodItems = const [],
  });

  // Toplam kalori hesapla
  double get totalCalories {
    return foodItems.fold(0.0, (sum, food) => sum + food.calories);
  }

  // Toplam protein hesapla
  double get totalProtein {
    return foodItems.fold(0.0, (sum, food) => sum + food.protein);
  }

  // Toplam karbonhidrat hesapla
  double get totalCarbs {
    return foodItems.fold(0.0, (sum, food) => sum + food.carbs);
  }

  // Toplam yağ hesapla
  double get totalFat {
    return foodItems.fold(0.0, (sum, food) => sum + food.fat);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'imagePath': imagePath,
      'mealType': mealType,
      'foodItems': foodItems.map((food) => food.toJson()).toList(),
    };
  }

  factory MealEntry.fromJson(Map<String, dynamic> json) {
    List<FoodItem> foodItems = [];
    if (json['foodItems'] != null) {
      foodItems = (json['foodItems'] as List)
          .map((foodJson) => FoodItem.fromJson(foodJson))
          .toList();
    }
    
    return MealEntry(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      dateTime: DateTime.parse(json['dateTime']),
      imagePath: json['imagePath'],
      mealType: json['mealType'],
      foodItems: foodItems,
    );
  }

  MealEntry copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? dateTime,
    String? imagePath,
    String? mealType,
    List<FoodItem>? foodItems,
  }) {
    return MealEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      imagePath: imagePath ?? this.imagePath,
      mealType: mealType ?? this.mealType,
      foodItems: foodItems ?? this.foodItems,
    );
  }
} 