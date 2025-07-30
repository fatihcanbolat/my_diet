import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../models/user_profile.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isEditing;

  const ProfileSetupScreen({
    super.key,
    this.isEditing = false,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _customCalorieController = TextEditingController();
  
  String _selectedGender = 'male';
  String _selectedGoal = 'maintain_weight';
  String _selectedActivityLevel = 'moderately_active';
  bool _useCustomCalorie = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadExistingProfile();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _customCalorieController.dispose();
    super.dispose();
  }

  void _loadExistingProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      final existingProfile = profileProvider.userProfile;
      
      if (existingProfile != null) {
        setState(() {
          _nameController.text = existingProfile.name;
          _emailController.text = existingProfile.email;
          _heightController.text = existingProfile.height.toString();
          _weightController.text = existingProfile.weight.toString();
          _ageController.text = existingProfile.age.toString();
          _selectedGender = existingProfile.gender;
          _selectedGoal = existingProfile.goal;
          _selectedActivityLevel = existingProfile.activityLevel;
          
          // Özel kalori hedefi varsa yükle
          if (existingProfile.customCalorieTarget != null) {
            _useCustomCalorie = true;
            _customCalorieController.text = existingProfile.customCalorieTarget!.toString();
          }
        });
      }
    });
  }

  double _calculateCalories() {
    try {
      final height = double.tryParse(_heightController.text) ?? 0;
      final weight = double.tryParse(_weightController.text) ?? 0;
      final age = int.tryParse(_ageController.text) ?? 0;
      
      if (height <= 0 || weight <= 0 || age <= 0) {
        return 0;
      }

      // Harris-Benedict formülü
      double bmr;
      if (_selectedGender == 'male') {
        bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
      } else {
        bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
      }

      // Aktivite seviyesine göre çarpan
      double activityMultiplier;
      switch (_selectedActivityLevel) {
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
      switch (_selectedGoal) {
        case 'lose_weight':
          return maintenanceCalories - 500;
        case 'gain_weight':
          return maintenanceCalories + 500;
        case 'maintain_weight':
        default:
          return maintenanceCalories;
      }
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Profil Düzenle' : 'Profil Oluştur'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Kişisel Bilgilerinizi Girin',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Ad
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen adınızı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen e-posta adresinizi girin';
                  }
                  if (!value.contains('@')) {
                    return 'Geçerli bir e-posta adresi girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Cinsiyet
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Cinsiyet',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Erkek')),
                  DropdownMenuItem(value: 'female', child: Text('Kadın')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Yaş
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Yaş',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen yaşınızı girin';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 10 || age > 120) {
                    return 'Geçerli bir yaş girin (10-120)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Boy
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: 'Boy (cm)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.height),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen boyunuzu girin';
                  }
                  final height = double.tryParse(value);
                  if (height == null || height < 100 || height > 250) {
                    return 'Geçerli bir boy girin (100-250 cm)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Kilo
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Kilo (kg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen kilonuzu girin';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight < 30 || weight > 300) {
                    return 'Geçerli bir kilo girin (30-300 kg)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Hedefinizi Seçin',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              
              // Hedef seçimi
              DropdownButtonFormField<String>(
                value: _selectedGoal,
                decoration: const InputDecoration(
                  labelText: 'Diyet Hedefi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.track_changes),
                ),
                items: const [
                  DropdownMenuItem(value: 'lose_weight', child: Text('Kilo Vermek')),
                  DropdownMenuItem(value: 'maintain_weight', child: Text('Kilo Korumak')),
                  DropdownMenuItem(value: 'gain_weight', child: Text('Kilo Almak')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGoal = value!;
                  });
                },
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Aktivite Seviyenizi Seçin',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              
              // Aktivite seviyesi
              DropdownButtonFormField<String>(
                value: _selectedActivityLevel,
                decoration: const InputDecoration(
                  labelText: 'Aktivite Seviyesi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                items: const [
                  DropdownMenuItem(value: 'sedentary', child: Text('Hareketsiz (Günlük aktivite yok)')),
                  DropdownMenuItem(value: 'lightly_active', child: Text('Hafif Aktif (Haftada 1-3 gün egzersiz)')),
                  DropdownMenuItem(value: 'moderately_active', child: Text('Orta Aktif (Haftada 3-5 gün egzersiz)')),
                  DropdownMenuItem(value: 'very_active', child: Text('Çok Aktif (Haftada 6-7 gün egzersiz)')),
                  DropdownMenuItem(value: 'extremely_active', child: Text('Aşırı Aktif (Günde 2 kez egzersiz)')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedActivityLevel = value!;
                  });
                },
              ),
              const SizedBox(height: 32),
              
              // Kalori Hedefi Seçimi
              const Text(
                'Günlük Kalori Hedefi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              
              // Kalori hedefi seçenekleri
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Radio<bool>(
                            value: false,
                            groupValue: _useCustomCalorie,
                            onChanged: (value) {
                              setState(() {
                                _useCustomCalorie = false;
                              });
                            },
                          ),
                          const Expanded(
                            child: Text(
                              'Otomatik Hesapla',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      if (!_useCustomCalorie) ...[
                        const SizedBox(height: 8),
                        Consumer<UserProfileProvider>(
                          builder: (context, profileProvider, child) {
                            final calculatedCalories = _calculateCalories();
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calculate, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Hesaplanan Kalori: ${calculatedCalories.toStringAsFixed(0)} kcal/gün',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: _useCustomCalorie,
                            onChanged: (value) {
                              setState(() {
                                _useCustomCalorie = true;
                              });
                            },
                          ),
                          const Expanded(
                            child: Text(
                              'Kendi Hedefimi Belirle',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      if (_useCustomCalorie) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _customCalorieController,
                          decoration: const InputDecoration(
                            labelText: 'Günlük Kalori Hedefi (kcal)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.track_changes),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (_useCustomCalorie && (value == null || value.isEmpty)) {
                              return 'Lütfen kalori hedefini girin';
                            }
                            if (_useCustomCalorie && (int.tryParse(value!) ?? 0) <= 0) {
                              return 'Geçerli bir kalori değeri girin';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Kaydet butonu
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Profili Kaydet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      
      // Kalori hedefini belirle
      double? customCalorieTarget;
      if (_useCustomCalorie) {
        customCalorieTarget = double.parse(_customCalorieController.text);
      }
      
      final profile = UserProfile(
        id: widget.isEditing ? profileProvider.userProfile!.id : profileProvider.generateId(),
        name: _nameController.text,
        email: _emailController.text,
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        age: int.parse(_ageController.text),
        goal: _selectedGoal,
        gender: _selectedGender,
        activityLevel: _selectedActivityLevel,
        createdAt: widget.isEditing ? profileProvider.userProfile!.createdAt : DateTime.now(),
        customCalorieTarget: customCalorieTarget,
      );
      
      if (widget.isEditing) {
        await profileProvider.updateProfile(profile);
      } else {
        await profileProvider.saveProfile(profile);
      }
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
} 