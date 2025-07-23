import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/meal_entry.dart';
import '../providers/meal_provider.dart';

class ShareScreen extends StatelessWidget {
  final DateTime selectedDate;

  const ShareScreen({
    super.key,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${DateFormat('dd/MM/yyyy', 'tr_TR').format(selectedDate)} - Diyet Raporu'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReport(context),
            tooltip: 'Paylaş',
          ),
        ],
      ),
      body: Consumer<MealProvider>(
        builder: (context, mealProvider, child) {
          final meals = mealProvider.getMealsForDate(selectedDate);
          
          if (meals.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.report_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Bu tarihte paylaşılacak yemek kaydı yok',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Günlük Diyet Raporu',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard('Toplam Öğün', meals.length.toString()),
                            _buildStatCard('Öğün Türü', _getUniqueMealTypes(meals).length.toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Yemek listesi
                ..._buildMealSections(meals),
                
                const SizedBox(height: 24),
                
                // Paylaş butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _shareReport(context),
                    icon: const Icon(Icons.share),
                    label: const Text('Diyetisyenimle Paylaş'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMealSections(List<MealEntry> meals) {
    final groupedMeals = <String, List<MealEntry>>{};
    for (final meal in meals) {
      groupedMeals.putIfAbsent(meal.mealType, () => []).add(meal);
    }

    return groupedMeals.entries.map((entry) {
      final mealType = entry.key;
      final mealsOfType = entry.value;
      
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
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
            ...mealsOfType.map((meal) => _buildMealItem(meal)),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildMealItem(MealEntry meal) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resim
          if (meal.imagePath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child: Image.file(
                  File(meal.imagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          
          // Yemek bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (meal.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    meal.description,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Saat: ${DateFormat('HH:mm', 'tr_TR').format(meal.dateTime)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Set<String> _getUniqueMealTypes(List<MealEntry> meals) {
    return meals.map((meal) => meal.mealType).toSet();
  }

  void _shareReport(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    final meals = mealProvider.getMealsForDate(selectedDate);
    
    if (meals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paylaşılacak yemek kaydı yok')),
      );
      return;
    }

    final report = _generateReport(meals);
    
    Share.share(
      report,
      subject: '${DateFormat('dd/MM/yyyy', 'tr_TR').format(selectedDate)} - Günlük Diyet Raporu',
    );
  }

  String _generateReport(List<MealEntry> meals) {
    final buffer = StringBuffer();
    
    buffer.writeln('🍽️ GÜNLÜK DİYET RAPORU');
    buffer.writeln('📅 ${DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(selectedDate)}');
    buffer.writeln('');
    
    final groupedMeals = <String, List<MealEntry>>{};
    for (final meal in meals) {
      groupedMeals.putIfAbsent(meal.mealType, () => []).add(meal);
    }
    
    for (final entry in groupedMeals.entries) {
      final mealType = entry.key;
      final mealsOfType = entry.value;
      
      buffer.writeln('─' * 10);
      buffer.writeln('${_getMealTypeEmoji(mealType)} $mealType');
      
      for (final meal in mealsOfType) {
        buffer.writeln('• ${meal.name}');
        if (meal.description.isNotEmpty) {
          buffer.writeln('  ${meal.description}');
        }
        buffer.writeln('  🕐 ${DateFormat('HH:mm', 'tr_TR').format(meal.dateTime)}');
        // if (meal.imagePath != null) {
        //   buffer.writeln('  📸 Fotoğraf eklendi');
        // }
        buffer.writeln('');
      }
    }
    
    buffer.writeln('📊 ÖZET');
    buffer.writeln('─' * 10);
    buffer.writeln('• Toplam Öğün: ${meals.length}');
    buffer.writeln('• Öğün Türü: ${_getUniqueMealTypes(meals).length}');
    buffer.writeln('• Fotoğraflı Öğün: ${meals.where((m) => m.imagePath != null).length}');
    
    return buffer.toString();
  }

  String _getMealTypeEmoji(String mealType) {
    switch (mealType) {
      case 'Kahvaltı':
        return '🌅';
      case 'Öğle Yemeği':
        return '☀️';
      case 'Akşam Yemeği':
        return '🌙';
      case 'Ara Öğün':
        return '🍎';
      default:
        return '🍽️';
    }
  }
} 