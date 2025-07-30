import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/meal_entry.dart';
import '../models/food_item.dart';
import '../providers/meal_provider.dart';
import '../services/gemini_service.dart';

class AddMealScreen extends StatefulWidget {
  final MealEntry? editingMeal;

  const AddMealScreen({
    super.key,
    this.editingMeal,
  });

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _foodNameController = TextEditingController();
  final _foodAmountController = TextEditingController();
  final _foodCalorieController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  String _selectedMealType = 'Kahvaltı';
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final List<FoodItem> _foodItems = [];
  bool _isLoading = false;
  bool _useManualCalorie = false;

  final List<String> _mealTypes = [
    'Kahvaltı',
    'Öğle Yemeği',
    'Akşam Yemeği',
    'Ara Öğün',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editingMeal != null) {
      // Düzenleme modu - mevcut verileri yükle
      final meal = widget.editingMeal!;
      _nameController.text = meal.name;
      _descriptionController.text = meal.description;
      _selectedDateTime = meal.dateTime;
      _selectedMealType = meal.mealType;
      _foodItems.addAll(meal.foodItems);
      
      if (meal.imagePath != null) {
        _selectedImage = File(meal.imagePath!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _foodNameController.dispose();
    _foodAmountController.dispose();
    _foodCalorieController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _addFoodItem() async {
    if (_foodNameController.text.trim().isEmpty || _foodAmountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen yiyecek adı ve miktarını girin')),
      );
      return;
    }

    // Manuel kalori girişi kontrolü
    if (_useManualCalorie && _foodCalorieController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen kalori değerini girin')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      FoodItem foodItem;

      if (_useManualCalorie) {
        // Manuel kalori girişi
        final manualCalories = double.parse(_foodCalorieController.text.trim());
        foodItem = FoodItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _foodNameController.text.trim(),
          amount: _foodAmountController.text.trim(),
          calories: manualCalories,
          protein: 0.0, // Manuel girişte besin değerleri 0
          carbs: 0.0,
          fat: 0.0,
          addedAt: DateTime.now(),
        );
      } else {
        // AI ile hesaplama
        final nutritionData = await GeminiService.calculateCalories(
          _foodNameController.text.trim(),
          _foodAmountController.text.trim(),
        );

        foodItem = FoodItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _foodNameController.text.trim(),
          amount: _foodAmountController.text.trim(),
          calories: nutritionData['calories'],
          protein: nutritionData['protein'],
          carbs: nutritionData['carbs'],
          fat: nutritionData['fat'],
          addedAt: DateTime.now(),
        );
      }

      setState(() {
        _foodItems.add(foodItem);
        _foodNameController.clear();
        _foodAmountController.clear();
        _foodCalorieController.clear();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${foodItem.name} eklendi (${foodItem.calories.toStringAsFixed(1)} kcal)')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yiyecek eklenirken hata oluştu')),
      );
    }
  }

  void _removeFoodItem(String id) {
    setState(() {
      _foodItems.removeWhere((item) => item.id == id);
    });
  }

  Future<void> _saveMeal() async {
    if (_formKey.currentState!.validate()) {
      if (_foodItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen en az bir yiyecek ekleyin')),
        );
        return;
      }

      final mealProvider = Provider.of<MealProvider>(context, listen: false);
      
      String? imagePath;
      if (_selectedImage != null) {
        // Eğer yeni bir resim seçildiyse kaydet
        if (widget.editingMeal == null || _selectedImage!.path != widget.editingMeal!.imagePath) {
          imagePath = await mealProvider.saveImage(_selectedImage!);
        } else {
          // Mevcut resmi kullan
          imagePath = widget.editingMeal!.imagePath;
        }
      }
      
      final meal = MealEntry(
        id: widget.editingMeal?.id ?? mealProvider.generateId(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        dateTime: _selectedDateTime,
        imagePath: imagePath,
        mealType: _selectedMealType,
        foodItems: _foodItems,
      );
      
      if (widget.editingMeal != null) {
        // Düzenleme modu
        await mealProvider.updateMeal(meal);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Öğün başarıyla güncellendi! (${meal.totalCalories.toStringAsFixed(1)} kcal)')),
          );
        }
      } else {
        // Yeni ekleme modu
        await mealProvider.addMeal(meal);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Öğün başarıyla eklendi! (${meal.totalCalories.toStringAsFixed(1)} kcal)')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editingMeal != null ? 'Öğün Düzenle' : 'Öğün Ekle'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: MediaQuery.of(context).padding.bottom + 16.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Öğün Adı
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Öğün Adı',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.restaurant),
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen öğün adını girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Açıklama
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama (İsteğe bağlı)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // Öğün Türü
              DropdownButtonFormField<String>(
                value: _selectedMealType,
                decoration: const InputDecoration(
                  labelText: 'Öğün Türü',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _mealTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMealType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Tarih ve Saat
              InkWell(
                onTap: _selectDateTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 8),
                      Text(
                        'Tarih ve Saat: ${DateFormat('dd/MM/yyyy HH:mm', 'tr_TR').format(_selectedDateTime)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Yiyecek Ekleme Bölümü
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Yiyecek Ekle',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      // Kalori Hesaplama Seçimi
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Kalori Hesaplama Yöntemi',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Radio<bool>(
                                    value: false,
                                    groupValue: _useManualCalorie,
                                    onChanged: (value) {
                                      setState(() {
                                        _useManualCalorie = false;
                                      });
                                    },
                                  ),
                                  const Expanded(
                                    child: Text(
                                      'AI ile Hesapla',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Radio<bool>(
                                    value: true,
                                    groupValue: _useManualCalorie,
                                    onChanged: (value) {
                                      setState(() {
                                        _useManualCalorie = true;
                                      });
                                    },
                                  ),
                                  const Expanded(
                                    child: Text(
                                      'Manuel Giriş',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Yiyecek Adı
                      TextFormField(
                        controller: _foodNameController,
                        decoration: const InputDecoration(
                          labelText: 'Yiyecek Adı',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.fastfood),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      
                      // Miktar
                      TextFormField(
                        controller: _foodAmountController,
                        decoration: const InputDecoration(
                          labelText: 'Miktar (örn: 1 bardak, 2 yumurta, 100g)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.scale),
                        ),
                        textInputAction: _useManualCalorie ? TextInputAction.next : TextInputAction.done,
                      ),
                      
                      // Manuel Kalori Girişi
                      if (_useManualCalorie) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _foodCalorieController,
                          decoration: const InputDecoration(
                            labelText: 'Kalori (kcal)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.local_fire_department),
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (_useManualCalorie && (value == null || value.isEmpty)) {
                              return 'Lütfen kalori değerini girin';
                            }
                            if (_useManualCalorie && (double.tryParse(value!) ?? 0) <= 0) {
                              return 'Geçerli bir kalori değeri girin';
                            }
                            return null;
                          },
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      
                      // Ekle Butonu
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _addFoodItem,
                        icon: _isLoading 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add),
                        label: Text(_isLoading ? 'Hesaplanıyor...' : 'Yiyecek Ekle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Eklenen Yiyecekler Listesi
              if (_foodItems.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Eklenen Yiyecekler',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Toplam: ${_foodItems.fold(0.0, (sum, item) => sum + item.calories).toStringAsFixed(1)} kcal',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        ..._foodItems.map((food) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(food.name),
                            subtitle: Text('${food.amount} - ${food.calories.toStringAsFixed(1)} kcal'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeFoodItem(food.id),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Fotoğraf Ekleme
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Fotoğraf Ekle (İsteğe bağlı)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      if (_selectedImage != null) ...[
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.camera_alt),
                        label: Text(_selectedImage == null ? 'Fotoğraf Çek' : 'Fotoğrafı Değiştir'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Kaydet Butonu
              ElevatedButton(
                onPressed: _foodItems.isNotEmpty ? _saveMeal : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text(widget.editingMeal != null ? 'Öğünü Güncelle' : 'Öğünü Kaydet'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
} 