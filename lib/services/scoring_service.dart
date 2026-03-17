import '../models/user_model.dart';
import '../models/meal_model.dart';

class ScoringService {
  static const int maxScore = 100;

  static int calculateDailyScore({
    required UserModel user,
    required DailyLog log,
  }) {
    if (log.meals.isEmpty) return 0;

    // Proteção: se os targets forem inválidos, retorna 0
    if (user.targetCalories <= 0 ||
        user.targetProtein <= 0 ||
        user.targetCarbs <= 0 ||
        user.targetFat <= 0) return 0;

    final calorieScore = _calorieScore(user, log);
    final macroScore = _macroScore(user, log);

    // Proteção contra NaN (divisão por zero, etc.)
    if (calorieScore.isNaN || macroScore.isNaN) return 0;

    final total = (calorieScore * 0.6 + macroScore * 0.4).round();
    return total.clamp(0, maxScore);
  }

  // Score de calorias: proporcional ao progresso em direção à meta.
  // Quanto mais perto de 100% da meta, maior o score.
  // Score cresce linearmente até 100%, depois penaliza levemente o excesso.
  static double _calorieScore(UserModel user, DailyLog log) {
    final target = user.targetCalories;
    final actual = log.totalCalories;
    final ratio = actual / target;

    if (ratio <= 0) return 0;

    if (ratio <= 1.0) {
      // Abaixo da meta: score proporcional ao progresso (0% → 0pts, 100% → 60pts)
      return ratio * 60;
    } else {
      // Acima da meta: penaliza gradualmente
      // 110% → 54pts, 130% → 42pts, 150%+ → 30pts
      final excess = ratio - 1.0;
      return (60 - excess * 60).clamp(30, 60);
    }
  }

  // Score de macros: proporcional ao progresso de cada macro.
  static double _macroScore(UserModel user, DailyLog log) {
    final proteinScore = _ratioToScore(log.totalProtein / user.targetProtein);
    final carbsScore   = _ratioToScore(log.totalCarbs   / user.targetCarbs);
    final fatScore     = _ratioToScore(log.totalFat     / user.targetFat);

    final weighted = proteinScore * 0.5 + carbsScore * 0.3 + fatScore * 0.2;
    return weighted * 40;
  }

  // Converte ratio em score 0..1 de forma suave e proporcional
  static double _ratioToScore(double ratio) {
    if (ratio.isNaN || ratio.isInfinite) return 0;
    if (ratio <= 0) return 0;

    if (ratio <= 1.0) {
      // Abaixo: proporcional
      return ratio;
    } else {
      // Acima: penaliza gradualmente
      final excess = ratio - 1.0;
      return (1.0 - excess * 0.5).clamp(0.3, 1.0);
    }
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

  static int calculateWeeklyScore(
    List<int> dailyScores, {
    int daysLogged = 0,
    bool achievedGoal = false,
  }) {
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