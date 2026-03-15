import '../models/user_model.dart';
import '../models/meal_model.dart';

class ScoringService {
  static const int maxScore = 100;

  static int calculateDailyScore({
    required UserModel user,
    required DailyLog log,
  }) {
    if (log.meals.isEmpty) return 0;

    final calorieScore = _calorieScore(user, log);
    final macroScore = _macroScore(user, log);

    final total = (calorieScore * 0.6 + macroScore * 0.4).round();
    return total.clamp(0, maxScore);
  }

  static double _calorieScore(UserModel user, DailyLog log) {
    final target = user.targetCalories;
    final actual = log.totalCalories;
    if (target <= 0) return 0;

    final ratio = actual / target;
    if (ratio >= 0.90 && ratio <= 1.10) return 60;
    if (ratio >= 0.80 && ratio < 0.90) return 45;
    if (ratio > 1.10 && ratio <= 1.20) return 45;
    if (ratio >= 0.70 && ratio < 0.80) return 30;
    if (ratio > 1.20 && ratio <= 1.30) return 30;
    return 10;
  }

  static double _macroScore(UserModel user, DailyLog log) {
    final proteinRatio = log.totalProtein / user.targetProtein;
    final carbsRatio = log.totalCarbs / user.targetCarbs;
    final fatRatio = log.totalFat / user.targetFat;

    double score = 0;
    score += _ratioToScore(proteinRatio) * 0.5;
    score += _ratioToScore(carbsRatio) * 0.3;
    score += _ratioToScore(fatRatio) * 0.2;
    return score * 40;
  }

  static double _ratioToScore(double ratio) {
    if (ratio >= 0.85 && ratio <= 1.15) return 1.0;
    if (ratio >= 0.70 && ratio <= 1.30) return 0.7;
    if (ratio >= 0.50 && ratio <= 1.50) return 0.4;
    return 0.1;
  }

  static int weeklyBonusPoints({
    required int daysLogged,
    required bool achievedGoal,
  }) {
    int bonus = 0;
    if (daysLogged >= 5) bonus += 15;
    if (achievedGoal) bonus += 20;
    return bonus;
  }

  static int calculateWeeklyScore(List<int> dailyScores, {int daysLogged = 0, bool achievedGoal = false}) {
    final base = dailyScores.fold(0, (s, d) => s + d);
    final bonus = weeklyBonusPoints(daysLogged: daysLogged, achievedGoal: achievedGoal);
    return base + bonus;
  }

  static String scoreLabel(int score) {
    if (score >= 85) return 'Excelente';
    if (score >= 70) return 'Ótimo';
    if (score >= 55) return 'Bom';
    if (score >= 40) return 'Regular';
    return 'Iniciando';
  }
}
