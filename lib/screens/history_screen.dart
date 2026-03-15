import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/meal_service.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser!;
    final mealSvc = context.watch<MealService>();

    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: i)));

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: SectionHeader(title: 'Histórico'),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: days.length,
              itemBuilder: (_, i) {
                final day = days[i];
                final log = mealSvc.getDailyLog(user.id, day);
                final score = mealSvc.getDailyScore(user, day);
                if (log.meals.isEmpty && i > 0) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            i == 0 ? 'Hoje' : DateFormat('dd/MM · EEEE', 'pt_BR').format(day),
                            style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                          ),
                          if (log.meals.isNotEmpty)
                            ScoreBadge(score: score, size: 36),
                        ],
                      ),
                    ),
                    if (log.meals.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                        child: const Center(child: Text('Sem registros', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
                      )
                    else
                      ...log.meals.map((meal) => _MealCard(meal: meal, userId: user.id)),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final dynamic meal;
  final String userId;

  const _MealCard({required this.meal, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(meal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: AppColors.error.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text('Excluir', style: GoogleFonts.syne(color: AppColors.textPrimary)),
            content: const Text('Remover esta refeição?', style: TextStyle(color: AppColors.textSecondary)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir', style: TextStyle(color: AppColors.error))),
            ],
          ),
        );
      },
      onDismissed: (_) => context.read<MealService>().deleteMeal(meal.id, userId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(AppText.mealTypeIcons[meal.mealType] ?? '🍽️', style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(meal.food.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
            Text('${AppText.mealTypeLabels[meal.mealType]} · ${meal.grams.toInt()}g · ${meal.calories.toInt()} kcal',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('P ${meal.protein.toInt()}g', style: const TextStyle(color: Color(0xFFE8855A), fontSize: 11)),
            Text('C ${meal.carbs.toInt()}g', style: const TextStyle(color: Color(0xFF5A9EE8), fontSize: 11)),
          ]),
        ]),
      ),
    );
  }
}
