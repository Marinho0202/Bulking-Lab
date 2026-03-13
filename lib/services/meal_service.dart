import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/meal_model.dart';
import '../models/user_model.dart';
import 'scoring_service.dart';

class MealService extends ChangeNotifier {
  final _uuid = const Uuid();
  List<MealEntry> _meals = [];
  bool _loaded = false;
  String? _loadedUserId;

  List<MealEntry> get meals => _meals;

  Future<void> loadForUser(String userId) async {
    if (_loadedUserId == userId && _loaded) return;
    _loadedUserId = userId;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('meals_$userId');
    if (raw != null) {
      final list = json.decode(raw) as List;
      _meals = list.map((e) => MealEntry.fromJson(e)).toList();
    } else {
      _meals = [];
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('meals_$userId', json.encode(_meals.map((m) => m.toJson()).toList()));
  }

  DailyLog getDailyLog(String userId, DateTime date) {
    final dayMeals = _meals.where((m) {
      return m.userId == userId &&
          m.registeredAt.year == date.year &&
          m.registeredAt.month == date.month &&
          m.registeredAt.day == date.day;
    }).toList();
    return DailyLog(userId: userId, date: date, meals: dayMeals);
  }

  int getDailyScore(UserModel user, DateTime date) {
    final log = getDailyLog(user.id, date);
    return ScoringService.calculateDailyScore(user: user, log: log);
  }

  List<int> getWeeklyScores(UserModel user) {
    final now = DateTime.now();
    final scores = <int>[];
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      scores.add(getDailyScore(user, day));
    }
    return scores;
  }

  int getDaysLoggedThisWeek(String userId) {
    final now = DateTime.now();
    int count = 0;
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      final log = getDailyLog(userId, day);
      if (log.meals.isNotEmpty) count++;
    }
    return count;
  }

  Future<void> addMeal({
    required String userId,
    required FoodItem food,
    required double portions,
    required String mealType,
  }) async {
    final entry = MealEntry(
      id: _uuid.v4(),
      userId: userId,
      food: food,
      portions: portions,
      mealType: mealType,
      registeredAt: DateTime.now(),
    );
    _meals.add(entry);
    await _save(userId);
    notifyListeners();
  }

  Future<void> deleteMeal(String mealId, String userId) async {
    _meals.removeWhere((m) => m.id == mealId);
    await _save(userId);
    notifyListeners();
  }

  Future<void> updateMeal(String mealId, String userId, double newPortions) async {
    final idx = _meals.indexWhere((m) => m.id == mealId);
    if (idx == -1) return;
    final old = _meals[idx];
    _meals[idx] = MealEntry(
      id: old.id,
      userId: old.userId,
      food: old.food,
      portions: newPortions,
      mealType: old.mealType,
      registeredAt: old.registeredAt,
    );
    await _save(userId);
    notifyListeners();
  }
}
