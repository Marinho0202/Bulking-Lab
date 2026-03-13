import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/auth_service.dart';
import '../services/meal_service.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser!;
    final mealSvc = context.watch<MealService>();

    final weeklyScores = mealSvc.getWeeklyScores(user);
    final daysLogged = mealSvc.getDaysLoggedThisWeek(user.id);
    final weekTotal = weeklyScores.fold(0, (s, d) => s + d);
    final avgScore = weeklyScores.where((s) => s > 0).isEmpty
        ? 0
        : weeklyScores.where((s) => s > 0).fold(0, (s, d) => s + d) ~/ weeklyScores.where((s) => s > 0).length;

    final now = DateTime.now();
    final days7 = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final dayLabels = ['D-6', 'D-5', 'D-4', 'D-3', 'D-2', 'Ont', 'Hj'];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'Estatísticas'),
            const SizedBox(height: 20),

            // Summary cards
            Row(children: [
              _StatCard(label: 'Pontos semana', value: '$weekTotal', color: AppColors.primary),
              const SizedBox(width: 12),
              _StatCard(label: 'Média diária', value: '$avgScore', color: AppColors.info),
              const SizedBox(width: 12),
              _StatCard(label: 'Dias ativos', value: '$daysLogged/7', color: AppColors.success),
            ]),
            const SizedBox(height: 24),

            // Score chart
            Text('Pontuação diária', style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Container(
              height: 180,
              padding: const EdgeInsets.fromLTRB(8, 12, 12, 8),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barGroups: weeklyScores.asMap().entries.map((e) => BarChartGroupData(
                    x: e.key,
                    barRods: [BarChartRodData(
                      toY: e.value.toDouble(),
                      color: e.value >= 70 ? AppColors.primary : e.value >= 40 ? AppColors.warning : AppColors.surface2,
                      width: 20,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    )],
                  )).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 25,
                      getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                    )),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(dayLabels[v.toInt()], style: const TextStyle(color: AppColors.textMuted, fontSize: 9)),
                      ),
                    )),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFF2A2A2A), strokeWidth: 0.5),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Macros last 7 days
            Text('Média de macros (7 dias)', style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            _MacroAverages(user: user, mealSvc: mealSvc, days: days7),
            const SizedBox(height: 24),

            // Meta info
            Text('Sua meta diária', style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                _MetaRow('Calorias', '${user.targetCalories.toInt()} kcal', AppColors.info),
                const SizedBox(height: 10),
                _MetaRow('Proteína', '${user.targetProtein.toInt()}g', const Color(0xFFE8855A)),
                const SizedBox(height: 10),
                _MetaRow('Carboidratos', '${user.targetCarbs.toInt()}g', const Color(0xFF5A9EE8)),
                const SizedBox(height: 10),
                _MetaRow('Gorduras', '${user.targetFat.toInt()}g', const Color(0xFFE8D05A)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        ]),
      ),
    );
  }
}

class _MacroAverages extends StatelessWidget {
  final dynamic user;
  final MealService mealSvc;
  final List<DateTime> days;

  const _MacroAverages({required this.user, required this.mealSvc, required this.days});

  @override
  Widget build(BuildContext context) {
    double totalCal = 0, totalProt = 0, totalCarbs = 0, totalFat = 0;
    int counted = 0;
    for (final d in days) {
      final log = mealSvc.getDailyLog(user.id, d);
      if (log.meals.isNotEmpty) {
        totalCal += log.totalCalories;
        totalProt += log.totalProtein;
        totalCarbs += log.totalCarbs;
        totalFat += log.totalFat;
        counted++;
      }
    }
    if (counted == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text('Sem dados ainda.', style: TextStyle(color: AppColors.textMuted, fontSize: 13))),
      );
    }
    final avgCal = totalCal / counted;
    final avgProt = totalProt / counted;
    final avgCarbs = totalCarbs / counted;
    final avgFat = totalFat / counted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        MacroBar(label: 'Proteína', current: avgProt, target: user.targetProtein, color: const Color(0xFFE8855A)),
        const SizedBox(height: 12),
        MacroBar(label: 'Carboidratos', current: avgCarbs, target: user.targetCarbs, color: const Color(0xFF5A9EE8)),
        const SizedBox(height: 12),
        MacroBar(label: 'Gorduras', current: avgFat, target: user.targetFat, color: const Color(0xFFE8D05A)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Média calórica', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          Text('${avgCal.toInt()} / ${user.targetCalories.toInt()} kcal',
            style: const TextStyle(color: AppColors.info, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }
}

Widget _MetaRow(String label, String value, Color color) => Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
    Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
  ],
);
