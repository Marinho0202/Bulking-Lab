import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/meal_model.dart';
import '../services/auth_service.dart';
import '../services/meal_service.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // IDs das refeições selecionadas para deleção
  final Set<String> _selected = {};
  bool _selectionMode = false;

  void _toggleSelection(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
        if (_selected.isEmpty) _selectionMode = false;
      } else {
        _selected.add(id);
        _selectionMode = true;
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _selected.clear();
      _selectionMode = false;
    });
  }

  Future<void> _deleteSelected(BuildContext context, String userId) async {
    final count = _selected.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Excluir refeições', style: GoogleFonts.syne(color: AppColors.textPrimary)),
        content: Text(
          'Remover $count refeição${count > 1 ? 'ões' : ''} selecionada${count > 1 ? 's' : ''}?\n'
          'A pontuação do dia será recalculada.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final svc = context.read<MealService>();
    for (final id in _selected) {
      await svc.deleteMeal(id, userId);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$count refeição${count > 1 ? 'ões' : ''} removida${count > 1 ? 's' : ''}. Pontuação atualizada.'),
      backgroundColor: AppColors.error,
    ));
    _cancelSelection();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser!;
    final mealSvc = context.watch<MealService>();
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: i)));

    return SafeArea(
      child: Column(
        children: [
          // Header com botão de excluir em modo seleção
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _selectionMode
                    ? Text(
                        '${_selected.length} selecionada${_selected.length > 1 ? 's' : ''}',
                        style: GoogleFonts.syne(
                          fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                      )
                    : const SectionHeader(title: 'Histórico'),
                if (_selectionMode)
                  Row(children: [
                    GestureDetector(
                      onTap: _cancelSelection,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _deleteSelected(context, user.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(children: [
                          const Icon(Icons.delete_outline, color: AppColors.error, size: 16),
                          const SizedBox(width: 4),
                          Text('Excluir (${_selected.length})',
                              style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  ]),
              ],
            ),
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

                // Agrupa refeições pelo nome do alimento + tipo de refeição
                final grouped = _groupMeals(log.meals);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(
                          i == 0 ? 'Hoje' : DateFormat('dd/MM · EEEE', 'pt_BR').format(day),
                          style: GoogleFonts.syne(
                              fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                        ),
                        if (log.meals.isNotEmpty) ScoreBadge(score: score, size: 36),
                      ]),
                    ),
                    if (log.meals.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                        child: const Center(
                            child: Text('Sem registros',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
                      )
                    else
                      ...grouped.map((group) => _MealGroupCard(
                            group: group,
                            selected: _selected,
                            selectionMode: _selectionMode,
                            onToggle: _toggleSelection,
                          )),
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

  // Agrupa refeições com mesmo nome de alimento + mesmo tipo em um único card
  List<_MealGroup> _groupMeals(List<MealEntry> meals) {
    final map = <String, _MealGroup>{};
    for (final meal in meals) {
      final key = '${meal.food.id}_${meal.mealType}';
      if (map.containsKey(key)) {
        map[key]!.meals.add(meal);
      } else {
        map[key] = _MealGroup(meals: [meal]);
      }
    }
    return map.values.toList();
  }
}

// Modelo interno para grupo de refeições agrupadas
class _MealGroup {
  final List<MealEntry> meals;
  _MealGroup({required this.meals});

  MealEntry get first => meals.first;
  double get totalPortions => meals.fold(0, (s, m) => s + m.portions);
  double get totalCalories => meals.fold(0, (s, m) => s + m.calories);
  double get totalProtein => meals.fold(0, (s, m) => s + m.protein);
  double get totalCarbs => meals.fold(0, (s, m) => s + m.carbs);
  bool get isMultiple => meals.length > 1 || meals.first.portions > 1;

  String get portionsLabel {
    if (meals.length == 1) {
      final p = meals.first.portions;
      return p % 1 == 0 ? 'x${p.toInt()}' : 'x$p';
    }
    // Múltiplos registros do mesmo item: soma as porções
    final total = totalPortions;
    return total % 1 == 0 ? 'x${total.toInt()}' : 'x$total';
  }
}

class _MealGroupCard extends StatelessWidget {
  final _MealGroup group;
  final Set<String> selected;
  final bool selectionMode;
  final void Function(String id) onToggle;

  const _MealGroupCard({
    required this.group,
    required this.selected,
    required this.selectionMode,
    required this.onToggle,
  });

  bool get _allSelected => group.meals.every((m) => selected.contains(m.id));
  bool get _someSelected => group.meals.any((m) => selected.contains(m.id));

  void _toggleGroup() {
    for (final meal in group.meals) {
      onToggle(meal.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final meal = group.first;
    final isSelected = selectionMode && _someSelected;

    return GestureDetector(
      onTap: selectionMode ? _toggleGroup : null,
      onLongPress: () => _toggleGroup(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.error.withOpacity(0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: AppColors.error.withOpacity(0.4), width: 1.5) : null,
        ),
        child: Row(children: [
          // Checkbox de seleção (aparece em modo seleção)
          if (selectionMode)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: _allSelected ? AppColors.error : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _allSelected ? AppColors.error : AppColors.textMuted,
                    width: 1.5,
                  ),
                ),
                child: _allSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
            ),

          // Ícone do tipo de refeição
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(
              AppText.mealTypeIcons[meal.mealType] ?? '🍽️',
              style: const TextStyle(fontSize: 16),
            )),
          ),
          const SizedBox(width: 12),

          // Nome + detalhes
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(meal.food.name,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
              // Badge de quantidade quando > 1 porção
              if (group.isMultiple) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(group.portionsLabel,
                      style: const TextStyle(
                          color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ],
            ]),
            Text(
              '${AppText.mealTypeLabels[meal.mealType]} · '
              '${(group.totalPortions * 50).toInt()}g · '
              '${group.totalCalories.toInt()} kcal',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ])),

          // Macros
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('P ${group.totalProtein.toInt()}g',
                style: const TextStyle(color: Color(0xFFE8855A), fontSize: 11)),
            Text('C ${group.totalCarbs.toInt()}g',
                style: const TextStyle(color: Color(0xFF5A9EE8), fontSize: 11)),
          ]),

          // Botão de excluir individual (só fora do modo seleção)
          if (!selectionMode) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _confirmDeleteGroup(context),
              child: Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline, color: AppColors.error, size: 16),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  Future<void> _confirmDeleteGroup(BuildContext context) async {
    final userId = context.read<AuthService>().currentUser!.id;
    final count = group.meals.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Excluir refeição', style: GoogleFonts.syne(color: AppColors.textPrimary)),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(group.first.food.name,
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            count > 1
                ? 'Isso removerá $count registros deste alimento.\nA pontuação do dia será recalculada.'
                : 'Remover esta refeição?\nA pontuação do dia será recalculada.',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final svc = context.read<MealService>();
    for (final meal in group.meals) {
      await svc.deleteMeal(meal.id, userId);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Refeição removida. Pontuação atualizada.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}