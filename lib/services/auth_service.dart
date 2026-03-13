import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _initialized = false;
  final _uuid = const Uuid();

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get initialized => _initialized;

  AuthService() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('current_user');
    if (userData != null) {
      try {
        _currentUser = UserModel.fromJson(json.decode(userData));
      } catch (_) {}
    }
    _initialized = true;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activityLevel,
    required String goal,
    required int mealsPerDay,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersRaw = prefs.getString('all_users') ?? '{}';
      final Map<String, dynamic> users = json.decode(usersRaw);

      if (users.containsKey(email)) return false;

      final user = UserModel(
        id: _uuid.v4(),
        name: name,
        email: email,
        weight: weight,
        height: height,
        age: age,
        gender: gender,
        activityLevel: activityLevel,
        goal: goal,
        mealsPerDay: mealsPerDay,
      );

      final userJson = user.toJson();
      userJson['password'] = password;
      users[email] = userJson;

      await prefs.setString('all_users', json.encode(users));
      await _saveCurrentUser(user);
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersRaw = prefs.getString('all_users') ?? '{}';
      final Map<String, dynamic> users = json.decode(usersRaw);

      if (!users.containsKey(email)) return false;
      final userData = users[email] as Map<String, dynamic>;
      if (userData['password'] != password) return false;

      final user = UserModel.fromJson(userData);
      await _saveCurrentUser(user);
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    _currentUser = null;
    notifyListeners();
  }

  Future<void> _saveCurrentUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', json.encode(user.toJson()));
  }

  Future<void> updateWeight(double newWeight) async {
    if (_currentUser == null) return;
    _currentUser!.currentWeight = newWeight;
    await _saveCurrentUser(_currentUser!);
    notifyListeners();
  }
}
