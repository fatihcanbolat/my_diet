import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/meal_entry.dart';
import '../providers/meal_provider.dart';

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

        // Öğün türlerine göre grupla
        final groupedMeals = <String, List<MealEntry>>{};
        for (final meal in meals) {
          groupedMeals.putIfAbsent(meal.mealType, () => []).add(meal);
        }

        return ListView.builder(
          itemCount: groupedMeals.length,
          itemBuilder: (context, index) {
            final mealType = groupedMeals.keys.elementAt(index);
            final mealsOfType = groupedMeals[mealType]!;
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    child: Text(
                      mealType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...mealsOfType.map((meal) => _buildMealTile(context, meal)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMealTile(BuildContext context, MealEntry meal) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
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
      title: Text(
        meal.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
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
          if (value == 'delete') {
            _showDeleteDialog(context, meal);
          }
        },
        itemBuilder: (context) => [
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