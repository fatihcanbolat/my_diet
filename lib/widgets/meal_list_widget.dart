import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/meal_entry.dart';
import '../providers/meal_provider.dart';
import '../screens/add_meal_screen.dart';

class MealListWidget extends StatelessWidget {
  final DateTime selectedDate;

  const MealListWidget({
    super.key,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MealProvider>(
      builder: (context, mealProvider, child) {
        final meals = mealProvider.getMealsForDate(selectedDate);
        
        if (meals.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Bu tarihte henüz yemek kaydı yok',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Yeni yemek eklemek için + butonuna tıklayın',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        // Yemekleri saate göre sırala
        final sortedMeals = List<MealEntry>.from(meals);
        sortedMeals.sort((a, b) => a.dateTime.compareTo(b.dateTime));

        return ListView.builder(
          itemCount: sortedMeals.length,
          itemBuilder: (context, index) {
            final meal = sortedMeals[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildMealTile(context, meal),
            );
          },
        );
      },
    );
  }

  Widget _buildMealTile(BuildContext context, MealEntry meal) {
    return ExpansionTile(
      leading: meal.imagePath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 60,
                child: Image.file(
                  File(meal.imagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              ),
            )
          : Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.restaurant, color: Colors.grey),
            ),
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${meal.totalCalories.toStringAsFixed(1)} kcal',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              meal.mealType,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (meal.description.isNotEmpty) ...[
            Text(meal.description),
            const SizedBox(height: 4),
          ],
          Text(
            DateFormat('HH:mm', 'tr_TR').format(meal.dateTime),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            _editMeal(context, meal);
          } else if (value == 'delete') {
            _showDeleteDialog(context, meal);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, color: Colors.blue),
                SizedBox(width: 8),
                Text('Düzenle'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Sil'),
              ],
            ),
          ),
        ],
      ),
      children: [
        if (meal.foodItems.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yiyecekler:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...meal.foodItems.map((food) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text('${food.name} (${food.amount})'),
                            if (food.protein == 0 && food.carbs == 0 && food.fat == 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange.shade300),
                                ),
                                child: const Text(
                                  'Manuel',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        '${food.calories.toStringAsFixed(1)} kcal',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Toplam:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${meal.totalCalories.toStringAsFixed(1)} kcal',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _editMeal(BuildContext context, MealEntry meal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMealScreen(editingMeal: meal),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, MealEntry meal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yemeği Sil'),
        content: Text('${meal.name} yemeğini silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<MealProvider>(context, listen: false)
                  .deleteMeal(meal.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Yemek silindi')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
} 