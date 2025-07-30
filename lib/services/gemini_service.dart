import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContentq';
  
  static String get _apiKey {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print('Warning: GEMINI_API_KEY not found in environment variables.');
      return '';
    }
    return apiKey;
  }

  static Future<Map<String, dynamic>> calculateCalories(String foodName, String amount) async {
    // Önce yerel veritabanından kontrol et
    final localResult = _getFromLocalDatabase(foodName, amount);
    print('Yerel veritabanından bulunan değerler: $localResult');
    
    // API'yi denemek için timeout ile çağır
    try {
      final prompt = '''
$foodName ($amount) için besin değerlerini hesapla.

Sadece şu JSON formatında yanıt ver:
{"calories": 150, "protein": 10.5, "carbs": 20.3, "fat": 5.2}

Başka hiçbir açıklama ekleme, sadece JSON.
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': prompt,
                },
              ],
            },
          ],
        }),
      ).timeout(const Duration(seconds: 10));

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // API yanıtının yapısını kontrol et
        if (data['candidates'] == null || data['candidates'].isEmpty) {
          print('API yanıtında candidates bulunamadı');
          return localResult; // Yerel veritabanından döndür
        }
        
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        print('API Text Response: $text');
        
        // JSON'u temizle ve parse et
        final cleanText = text.trim();
        print('Cleaned Text: $cleanText');
        
        try {
          final nutritionData = jsonDecode(cleanText);
          print('Parsed Nutrition Data: $nutritionData');
          
          return {
            'calories': nutritionData['calories'].toDouble(),
            'protein': nutritionData['protein'].toDouble(),
            'carbs': nutritionData['carbs'].toDouble(),
            'fat': nutritionData['fat'].toDouble(),
          };
        } catch (parseError) {
          print('JSON parse hatası: $parseError');
          print('Raw text that failed to parse: $cleanText');
          
          // JSON parse başarısız olursa, metinden sayıları çıkarmaya çalış
          final extractedResult = _extractNutritionFromText(cleanText);
          if (extractedResult['calories'] > 0) {
            return extractedResult;
          }
          return localResult; // Yerel veritabanından döndür
        }
      } else {
        print('API Error Response: ${response.body}');
        return localResult; // Yerel veritabanından döndür
      }
    } catch (e) {
      // Hata durumunda yerel veritabanından döndür
      print('Gemini API hatası: $e');
      return localResult;
    }
  }

  // Yerel besin veritabanı
  static final Map<String, Map<String, double>> _localFoodDatabase = {
    'elma': {'calories': 52, 'protein': 0.3, 'carbs': 14, 'fat': 0.2},
    'muz': {'calories': 89, 'protein': 1.1, 'carbs': 23, 'fat': 0.3},
    'portakal': {'calories': 47, 'protein': 0.9, 'carbs': 12, 'fat': 0.1},
    'ekmek': {'calories': 265, 'protein': 9, 'carbs': 49, 'fat': 3.2},
    'süt': {'calories': 42, 'protein': 3.4, 'carbs': 5, 'fat': 1},
    'yumurta': {'calories': 155, 'protein': 13, 'carbs': 1.1, 'fat': 11},
    'tavuk': {'calories': 165, 'protein': 31, 'carbs': 0, 'fat': 3.6},
    'pirinç': {'calories': 130, 'protein': 2.7, 'carbs': 28, 'fat': 0.3},
    'makarna': {'calories': 131, 'protein': 5, 'carbs': 25, 'fat': 1.1},
    'balık': {'calories': 84, 'protein': 18, 'carbs': 0, 'fat': 0.5},
    'et': {'calories': 250, 'protein': 26, 'carbs': 0, 'fat': 15},
    'yoğurt': {'calories': 59, 'protein': 10, 'carbs': 3.6, 'fat': 0.4},
    'peynir': {'calories': 113, 'protein': 7, 'carbs': 0.4, 'fat': 9},
    'salata': {'calories': 15, 'protein': 1.4, 'carbs': 2.9, 'fat': 0.2},
    'domates': {'calories': 18, 'protein': 0.9, 'carbs': 3.9, 'fat': 0.2},
    'havuç': {'calories': 41, 'protein': 0.9, 'carbs': 10, 'fat': 0.2},
    'patates': {'calories': 77, 'protein': 2, 'carbs': 17, 'fat': 0.1},
    'soğan': {'calories': 40, 'protein': 1.1, 'carbs': 9, 'fat': 0.1},
    'zeytin': {'calories': 115, 'protein': 0.8, 'carbs': 6, 'fat': 11},
    'fındık': {'calories': 628, 'protein': 15, 'carbs': 17, 'fat': 61},
    'ceviz': {'calories': 654, 'protein': 15, 'carbs': 14, 'fat': 65},
    'badem': {'calories': 579, 'protein': 21, 'carbs': 22, 'fat': 50},
    'çikolata': {'calories': 545, 'protein': 4.9, 'carbs': 61, 'fat': 31},
    'dondurma': {'calories': 207, 'protein': 3.5, 'carbs': 24, 'fat': 11},
    'kola': {'calories': 42, 'protein': 0, 'carbs': 11, 'fat': 0},
    'su': {'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0},
    'çay': {'calories': 1, 'protein': 0, 'carbs': 0.2, 'fat': 0},
    'kahve': {'calories': 2, 'protein': 0.3, 'carbs': 0, 'fat': 0},
    'omlet': {'calories': 154, 'protein': 11, 'carbs': 1.1, 'fat': 12},
    'menemen': {'calories': 120, 'protein': 8, 'carbs': 4, 'fat': 8},
    'çorba': {'calories': 50, 'protein': 2, 'carbs': 8, 'fat': 1},
    'pilav': {'calories': 130, 'protein': 2.7, 'carbs': 28, 'fat': 0.3},
    'köfte': {'calories': 200, 'protein': 20, 'carbs': 5, 'fat': 12},
    'döner': {'calories': 300, 'protein': 25, 'carbs': 15, 'fat': 18},
    'pizza': {'calories': 266, 'protein': 11, 'carbs': 33, 'fat': 10},
    'hamburger': {'calories': 295, 'protein': 12, 'carbs': 30, 'fat': 12},
  };

  // Yerel veritabanından besin değerlerini bul
  static Map<String, dynamic> _getFromLocalDatabase(String foodName, String amount) {
    final normalizedName = foodName.toLowerCase().trim();
    
    // Tam eşleşme ara
    if (_localFoodDatabase.containsKey(normalizedName)) {
      final baseValues = _localFoodDatabase[normalizedName]!;
      return {
        'calories': baseValues['calories']!,
        'protein': baseValues['protein']!,
        'carbs': baseValues['carbs']!,
        'fat': baseValues['fat']!,
      };
    }
    
    // Kısmi eşleşme ara
    for (final entry in _localFoodDatabase.entries) {
      if (normalizedName.contains(entry.key) || entry.key.contains(normalizedName)) {
        final baseValues = entry.value;
        return {
          'calories': baseValues['calories']!,
          'protein': baseValues['protein']!,
          'carbs': baseValues['carbs']!,
          'fat': baseValues['fat']!,
        };
      }
    }
    
    // Eşleşme bulunamazsa varsayılan değerler
    return {
      'calories': 100.0,
      'protein': 5.0,
      'carbs': 15.0,
      'fat': 2.0,
    };
  }

  // Metinden besin değerlerini çıkarmaya çalışan yardımcı metod
  static Map<String, dynamic> _extractNutritionFromText(String text) {
    print('Trying to extract nutrition from text: $text');
    
    // Basit regex pattern'ları ile sayıları bulmaya çalış
    final caloriesPattern = RegExp(r'(\d+(?:\.\d+)?)\s*(?:kcal|kalori|calories)', caseSensitive: false);
    final proteinPattern = RegExp(r'(\d+(?:\.\d+)?)\s*(?:g|gram)\s*(?:protein|proteini)', caseSensitive: false);
    final carbsPattern = RegExp(r'(\d+(?:\.\d+)?)\s*(?:g|gram)\s*(?:karbonhidrat|carbs|carb)', caseSensitive: false);
    final fatPattern = RegExp(r'(\d+(?:\.\d+)?)\s*(?:g|gram)\s*(?:yağ|fat)', caseSensitive: false);
    
    // Sadece sayıları bulmaya çalış
    final numberPattern = RegExp(r'(\d+(?:\.\d+)?)');
    final numbers = numberPattern.allMatches(text).map((m) => double.tryParse(m.group(1) ?? '0') ?? 0.0).toList();
    
    double calories = 0.0;
    double protein = 0.0;
    double carbs = 0.0;
    double fat = 0.0;
    
    // Kalori değerini bul
    final caloriesMatch = caloriesPattern.firstMatch(text);
    if (caloriesMatch != null) {
      calories = double.tryParse(caloriesMatch.group(1) ?? '0') ?? 0.0;
    } else if (numbers.isNotEmpty) {
      // İlk sayıyı kalori olarak kabul et
      calories = numbers.first;
    }
    
    // Protein değerini bul
    final proteinMatch = proteinPattern.firstMatch(text);
    if (proteinMatch != null) {
      protein = double.tryParse(proteinMatch.group(1) ?? '0') ?? 0.0;
    } else if (numbers.length > 1) {
      protein = numbers[1];
    }
    
    // Karbonhidrat değerini bul
    final carbsMatch = carbsPattern.firstMatch(text);
    if (carbsMatch != null) {
      carbs = double.tryParse(carbsMatch.group(1) ?? '0') ?? 0.0;
    } else if (numbers.length > 2) {
      carbs = numbers[2];
    }
    
    // Yağ değerini bul
    final fatMatch = fatPattern.firstMatch(text);
    if (fatMatch != null) {
      fat = double.tryParse(fatMatch.group(1) ?? '0') ?? 0.0;
    } else if (numbers.length > 3) {
      fat = numbers[3];
    }
    
    print('Extracted values - Calories: $calories, Protein: $protein, Carbs: $carbs, Fat: $fat');
    
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
} 
