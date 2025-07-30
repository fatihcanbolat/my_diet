class UserProfile {
  final String id;
  final String name;
  final String email;
  final double height; // cm cinsinden
  final double weight; // kg cinsinden
  final int age;
  final String goal; // 'lose_weight', 'gain_weight', 'maintain_weight'
  final String gender; // 'male', 'female'
  final String activityLevel; // 'sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active'
  final DateTime createdAt;
  final double? customCalorieTarget; // Kullanıcının belirlediği özel kalori hedefi

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.height,
    required this.weight,
    required this.age,
    required this.goal,
    required this.gender,
    required this.activityLevel,
    required this.createdAt,
    this.customCalorieTarget,
  });

  // Günlük kalori ihtiyacını hesapla
  double get dailyCalorieNeed {
    // Eğer özel kalori hedefi belirlenmişse onu kullan
    if (customCalorieTarget != null) {
      return customCalorieTarget!;
    }
    
    // Harris-Benedict formülü kullanarak BMR hesapla
    double bmr;
    if (gender == 'male') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }

    // Aktivite seviyesine göre çarpan
    double activityMultiplier;
    switch (activityLevel) {
      case 'sedentary':
        activityMultiplier = 1.2;
        break;
      case 'lightly_active':
        activityMultiplier = 1.375;
        break;
      case 'moderately_active':
        activityMultiplier = 1.55;
        break;
      case 'very_active':
        activityMultiplier = 1.725;
        break;
      case 'extremely_active':
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.2;
    }

    double maintenanceCalories = bmr * activityMultiplier;

    // Hedefe göre kalori ayarla
    switch (goal) {
      case 'lose_weight':
        return maintenanceCalories - 500; // Haftada 0.5 kg vermek için
      case 'gain_weight':
        return maintenanceCalories + 500; // Haftada 0.5 kg almak için
      case 'maintain_weight':
      default:
        return maintenanceCalories;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'height': height,
      'weight': weight,
      'age': age,
      'goal': goal,
      'gender': gender,
      'activityLevel': activityLevel,
      'createdAt': createdAt.toIso8601String(),
      'customCalorieTarget': customCalorieTarget,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
      age: json['age'],
      goal: json['goal'],
      gender: json['gender'],
      activityLevel: json['activityLevel'],
      createdAt: DateTime.parse(json['createdAt']),
      customCalorieTarget: json['customCalorieTarget']?.toDouble(),
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    double? height,
    double? weight,
    int? age,
    String? goal,
    String? gender,
    String? activityLevel,
    DateTime? createdAt,
    double? customCalorieTarget,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      goal: goal ?? this.goal,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      createdAt: createdAt ?? this.createdAt,
      customCalorieTarget: customCalorieTarget ?? this.customCalorieTarget,
    );
  }
} 