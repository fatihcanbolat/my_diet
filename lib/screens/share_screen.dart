import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:intl/intl.dart';
import '../models/meal_entry.dart';
import '../models/user_profile.dart';
import '../providers/meal_provider.dart';
import '../providers/user_profile_provider.dart';

class ShareScreen extends StatefulWidget {
  final DateTime selectedDate;

  const ShareScreen({
    super.key,
    required this.selectedDate,
  });

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${DateFormat('dd/MM/yyyy', 'tr_TR').format(widget.selectedDate)} - Diyet Raporu'),
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
      body: Consumer2<MealProvider, UserProfileProvider>(
        builder: (context, mealProvider, userProfileProvider, child) {
          final meals = mealProvider.getMealsForDate(widget.selectedDate);
          final userProfile = userProfileProvider.userProfile;
          
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

          return SafeArea(
            child: SingleChildScrollView(
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
                            DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(widget.selectedDate),
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
                              _buildStatCard('Toplam Kalori', '${_calculateTotalCalories(meals).toStringAsFixed(0)} kcal'),
                              _buildStatCard('Öğün Türü', _getUniqueMealTypes(meals).length.toString()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Screenshot için widget
                  Screenshot(
                    controller: screenshotController,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _buildScreenshotContent(meals, userProfile),
                    ),
                  ),
                  
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
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScreenshotContent(List<MealEntry> meals, UserProfile? userProfile) {
    // Yemekleri saate göre sırala
    final sortedMeals = List<MealEntry>.from(meals);
    sortedMeals.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.restaurant,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Günlük Diyet Raporu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(widget.selectedDate),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Kullanıcı profil bilgileri
        if (userProfile != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '👤 Kullanıcı Bilgileri',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ad: ${userProfile.name}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Yaş: ${userProfile.age}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Boy: ${userProfile.height}cm',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Kilo: ${userProfile.weight}kg',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Hedef: ${_getGoalText(userProfile.goal)}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Günlük Hedef: ${userProfile.dailyCalorieNeed.toStringAsFixed(0)} kcal',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // İstatistikler
        Row(
          children: [
            Expanded(
              child: _buildScreenshotStatCard('Toplam Öğün', meals.length.toString()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildScreenshotStatCard('Toplam Kalori', '${_calculateTotalCalories(meals).toStringAsFixed(0)} kcal'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildScreenshotStatCard('Öğün Türü', _getUniqueMealTypes(meals).length.toString()),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Besin değerleri özeti
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📊 Günlük Besin Değerleri Özeti',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildNutritionItem('🔥 Kalori', '${_calculateTotalCalories(meals).toStringAsFixed(0)} kcal'),
                  ),
                  Expanded(
                    child: _buildNutritionItem('🥩 Protein', '${_calculateTotalNutrition(meals)['protein']!.toStringAsFixed(1)}g'),
                  ),
                  Expanded(
                    child: _buildNutritionItem('🍞 Karbonhidrat', '${_calculateTotalNutrition(meals)['carbs']!.toStringAsFixed(1)}g'),
                  ),
                  Expanded(
                    child: _buildNutritionItem('🧈 Yağ', '${_calculateTotalNutrition(meals)['fat']!.toStringAsFixed(1)}g'),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Yemek listesi
        const Text(
          '🍽️ Günlük Yemek Listesi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 12),
        
        ...sortedMeals.map((meal) => _buildScreenshotMealItem(meal)),
      ],
    );
  }

  Widget _buildScreenshotStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotMealItem(MealEntry meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst satır - Yemek adı, türü ve kalori
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resim
              if (meal.imagePath != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Image.file(
                      File(meal.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.broken_image, color: Colors.grey, size: 20),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              
              // Yemek bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            meal.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            meal.mealType,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (meal.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        meal.description,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '🕐 ${DateFormat('HH:mm', 'tr_TR').format(meal.dateTime)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '🔥 ${meal.totalCalories.toStringAsFixed(1)} kcal',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Alt satır - Besin değerleri
          if (meal.foodItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📋 Besin Değerleri:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '🥩 Protein: ${meal.totalProtein.toStringAsFixed(1)}g',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '🍞 Karbonhidrat: ${meal.totalCarbs.toStringAsFixed(1)}g',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '🧈 Yağ: ${meal.totalFat.toStringAsFixed(1)}g',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  if (meal.foodItems.length > 1) ...[
                    const SizedBox(height: 4),
                    const Text(
                      '🍽️ Yiyecekler:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ...meal.foodItems.map((food) => Padding(
                      padding: const EdgeInsets.only(left: 8, top: 1),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '• ${food.name} (${food.amount}) - ${food.calories.toStringAsFixed(1)} kcal',
                              style: const TextStyle(fontSize: 9, color: Colors.grey),
                            ),
                          ),
                          if (food.protein == 0 && food.carbs == 0 && food.fat == 0) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.orange.shade300),
                              ),
                              child: const Text(
                                'Manuel',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ],
        ],
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

  Set<String> _getUniqueMealTypes(List<MealEntry> meals) {
    return meals.map((meal) => meal.mealType).toSet();
  }

  double _calculateTotalCalories(List<MealEntry> meals) {
    return meals.fold(0.0, (sum, meal) => sum + meal.totalCalories);
  }

  Map<String, double> _calculateTotalNutrition(List<MealEntry> meals) {
    double totalProtein = 0.0;
    double totalCarbs = 0.0;
    double totalFat = 0.0;

    for (final meal in meals) {
      totalProtein += meal.totalProtein;
      totalCarbs += meal.totalCarbs;
      totalFat += meal.totalFat;
    }

    return {
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
    };
  }

  Widget _buildNutritionItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getGoalText(String goal) {
    switch (goal) {
      case 'lose_weight':
        return 'Kilo Vermek';
      case 'gain_weight':
        return 'Kilo Almak';
      case 'maintain_weight':
        return 'Kilo Korumak';
      default:
        return goal;
    }
  }

  void _shareReport(BuildContext context) async {
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    final meals = mealProvider.getMealsForDate(widget.selectedDate);
    
    if (meals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paylaşılacak yemek kaydı yok')),
      );
      return;
    }

    try {
      // Screenshot al
      final Uint8List? imageBytes = await screenshotController.capture();
      
      if (imageBytes != null) {
        // Geçici dosya oluştur
        final tempDir = await Directory.systemTemp.createTemp('diet_report');
        final file = File('${tempDir.path}/diet_report_${DateFormat('yyyyMMdd', 'tr_TR').format(widget.selectedDate)}.png');
        await file.writeAsBytes(imageBytes);
        
        // Paylaş
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: '${DateFormat('dd/MM/yyyy', 'tr_TR').format(widget.selectedDate)} - Günlük Diyet Raporu',
          text: 'Günlük diyet raporum',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Paylaşma sırasında hata oluştu: $e')),
      );
    }
  }
} 