import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/meal_provider.dart';
import 'providers/user_profile_provider.dart';
import 'models/user_profile.dart';
import 'screens/add_meal_screen.dart';
import 'screens/share_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'widgets/meal_list_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Warning: .env file not found. Using default configuration.');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MealProvider()..loadMeals()),
        ChangeNotifierProvider(create: (context) => UserProfileProvider()..loadProfile()),
      ],
      child: MaterialApp(
        title: 'My Diet',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 206, 112, 6)),
          useMaterial3: true,
        ),
        locale: const Locale('tr', 'TR'),
        supportedLocales: const [
          Locale('tr', 'TR'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const ProfileCheckScreen(),
      ),
    );
  }
}

class ProfileCheckScreen extends StatelessWidget {
  const ProfileCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, child) {
        if (profileProvider.hasProfile) {
          return const MyHomePage();
        } else {
          return const ProfileSetupScreen();
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, child) {
        final userProfile = profileProvider.userProfile;
        if (userProfile == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Hoş geldin, ${userProfile.name}'),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.person),
                tooltip: 'Profil',
                onSelected: (value) {
                  if (value == 'info') {
                    _showProfileInfo();
                  } else if (value == 'edit') {
                    _editProfile();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'info',
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Profil Bilgileri'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Profili Düzenle'),
                      ],
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _selectDate,
                tooltip: 'Tarih Seç',
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _openShareScreen,
                tooltip: 'Paylaş',
              ),
            ],
          ),
          body: Column(
            children: [
              // Kalori özeti
              _buildCalorieSummary(userProfile),
              
              // Tarih seçici
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                        });
                      },
                      icon: const Icon(Icons.chevron_left),
                    ),
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(_selectedDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.add(const Duration(days: 1));
                        });
                      },
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
              
              // Yemek listesi
              Expanded(
                child: MealListWidget(selectedDate: _selectedDate),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _addMeal,
            backgroundColor: const Color.fromARGB(255, 226, 157, 8),
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildCalorieSummary(UserProfile userProfile) {
    return Consumer<MealProvider>(
      builder: (context, mealProvider, child) {
        final todayMeals = mealProvider.getMealsForDate(_selectedDate);
        final totalCalories = todayMeals.fold(0.0, (sum, meal) => sum + meal.totalCalories);
        final dailyGoal = userProfile.dailyCalorieNeed;
        final remaining = dailyGoal - totalCalories;
        final percentage = (totalCalories / dailyGoal * 100).clamp(0.0, 100.0);

        Color progressColor = Colors.green;
        if (percentage > 90) {
          progressColor = Colors.orange;
        }
        if (percentage > 100) {
          progressColor = Colors.red;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.green.shade50,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Günlük Kalori',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  Text(
                    '${totalCalories.toStringAsFixed(0)} / ${dailyGoal.toStringAsFixed(0)} kcal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: progressColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kalan: ${remaining > 0 ? remaining.toStringAsFixed(0) : 0} kcal',
                    style: TextStyle(
                      color: remaining > 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: progressColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (percentage > 100) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    '⚠️ Günlük kalori limitini aştınız!',
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showProfileInfo() {
    final userProfile = Provider.of<UserProfileProvider>(context, listen: false).userProfile;
    if (userProfile != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Profil Bilgileri'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ad: ${userProfile.name}'),
              Text('E-posta: ${userProfile.email}'),
              Text('Yaş: ${userProfile.age}'),
              Text('Boy: ${userProfile.height} cm'),
              Text('Kilo: ${userProfile.weight} kg'),
              Text('Cinsiyet: ${userProfile.gender == 'male' ? 'Erkek' : 'Kadın'}'),
              Text('Hedef: ${_getGoalText(userProfile.goal)}'),
              Text('Aktivite: ${_getActivityText(userProfile.activityLevel)}'),
              const SizedBox(height: 16),
              Text(
                'Günlük Kalori Hedefi: ${userProfile.dailyCalorieNeed.toStringAsFixed(0)} kcal',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              if (userProfile.customCalorieTarget != null) ...[
                const SizedBox(height: 4),
                Text(
                  '(Özel hedef belirlenmiş)',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _editProfile();
              },
              child: const Text('Düzenle'),
            ),
          ],
        ),
      );
    }
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

  String _getActivityText(String activity) {
    switch (activity) {
      case 'sedentary':
        return 'Hareketsiz';
      case 'lightly_active':
        return 'Hafif Aktif';
      case 'moderately_active':
        return 'Orta Aktif';
      case 'very_active':
        return 'Çok Aktif';
      case 'extremely_active':
        return 'Aşırı Aktif';
      default:
        return activity;
    }
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileSetupScreen(isEditing: true),
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addMeal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddMealScreen(),
      ),
    );
  }

  void _openShareScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShareScreen(selectedDate: _selectedDate),
      ),
    );
  }
}
