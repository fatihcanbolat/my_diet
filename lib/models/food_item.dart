class FoodItem {
  final String id;
  final String name;
  final String amount;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime addedAt;

  FoodItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      amount: json['amount'],
      calories: json['calories'].toDouble(),
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fat: json['fat'].toDouble(),
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  FoodItem copyWith({
    String? id,
    String? name,
    String? amount,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    DateTime? addedAt,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      addedAt: addedAt ?? this.addedAt,
    );
  }
} 