import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/meal_entry.dart';

class MealProvider with ChangeNotifier {
  List<MealEntry> _meals = [];
  static const String _storageKey = 'meals';

  List<MealEntry> get meals => _meals;

  List<MealEntry> getMealsForDate(DateTime date) {
    return _meals.where((meal) {
      return meal.dateTime.year == date.year &&
          meal.dateTime.month == date.month &&
          meal.dateTime.day == date.day;
    }).toList();
  }

  Future<void> loadMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final mealsJson = prefs.getStringList(_storageKey) ?? [];
    
    _meals = mealsJson
        .map((json) => MealEntry.fromJson(jsonDecode(json)))
        .toList();
    
    notifyListeners();
  }

  Future<void> saveMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final mealsJson = _meals
        .map((meal) => jsonEncode(meal.toJson()))
        .toList();
    
    await prefs.setStringList(_storageKey, mealsJson);
  }

  Future<void> addMeal(MealEntry meal) async {
    _meals.add(meal);
    await saveMeals();
    notifyListeners();
  }

  Future<void> updateMeal(MealEntry meal) async {
    final index = _meals.indexWhere((m) => m.id == meal.id);
    if (index != -1) {
      _meals[index] = meal;
      await saveMeals();
      notifyListeners();
    }
  }

  Future<void> deleteMeal(String id) async {
    final meal = _meals.firstWhere((m) => m.id == id);
    
    // Resmi sil
    if (meal.imagePath != null) {
      try {
        final file = File(meal.imagePath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Resim silinirken hata: $e');
      }
    }
    
    _meals.removeWhere((m) => m.id == id);
    await saveMeals();
    notifyListeners();
  }

  Future<String?> saveImage(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/meal_images');
      
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await imageFile.copy('${imagesDir.path}/$fileName');
      
      return savedImage.path;
    } catch (e) {
      print('Resim kaydedilirken hata: $e');
      return null;
    }
  }

  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
} 