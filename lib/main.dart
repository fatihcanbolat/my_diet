import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/meal_provider.dart';
import 'screens/add_meal_screen.dart';
import 'screens/share_screen.dart';
import 'widgets/meal_list_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MealProvider()..loadMeals(),
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
        home: const MyHomePage(),
      ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Diet'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
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
