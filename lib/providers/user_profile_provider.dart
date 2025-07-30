import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserProfileProvider with ChangeNotifier {
  UserProfile? _userProfile;
  static const String _storageKey = 'user_profile';

  UserProfile? get userProfile => _userProfile;

  bool get hasProfile => _userProfile != null;

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_storageKey);
    
    if (profileJson != null) {
      _userProfile = UserProfile.fromJson(jsonDecode(profileJson));
      notifyListeners();
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(profile.toJson()));
    
    _userProfile = profile;
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile profile) async {
    await saveProfile(profile);
  }

  Future<void> deleteProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    
    _userProfile = null;
    notifyListeners();
  }

  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
} 