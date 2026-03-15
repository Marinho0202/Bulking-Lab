import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/food_database.dart';
import '../models/meal_model.dart';
import '../services/auth_service.dart';
import '../services/meal_service.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';

class RegisterMealScreen extends StatefulWidget {
  const RegisterMealScreen({super.key});

  @override
  State<RegisterMealScreen> createState() => _RegisterMealScreenState();
}

class _RegisterMealScreenState extends State<RegisterMealScreen> {
  FoodItem? _selected;
  double _portions = 1;
  String _mealType = 'lunch';
  String _search = '';
  String _category = 'Todos';
  bool _loading = false;

  List<FoodItem> get _filtered {
    var list = _search.isNotEmpty ? FoodDatabase.search(_search) : FoodDatabase.items;
    if (_category != 'Todos') list = list.where((f) => f.category == _category).toList();
    return list;
  }

  Future<void> _save() async {
    if (_selected == null) return;
    setState(() => _loading = true);
    final user = context.read<AuthService>().currentUser!;
    await context.read<MealService>().addMeal(
      userId: user.id,
      food: _selected!,
      portions: _portions,
      mealType: _mealType,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refeição registrada!'), backgroundColor: AppColors.success),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cats = ['Todos', ...FoodDatabase.categories];
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text('Registrar Refeição', style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Meal type
                Row(
                  children: AppText.mealTypeLabels.entries.map((e) {
                    final selected = _mealType == e.key;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _mealType = e.key),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(children: [
                            Text(AppText.mealTypeIcons[e.key]!, style: const TextStyle(fontSize: 14)),
                            Text(e.value.split(' ').first, style: TextStyle(
                              color: selected ? AppColors.bg : AppColors.textMuted,
                              fontSize: 9, fontWeight: FontWeight.w600,
                            )),
                          ]),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                // Search
                TextField(
                  onChanged: (v) => setState(() => _search = v),
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Buscar alimento...',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                // Categories
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: cats.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final c = cats[i];
                      final sel = _category == c;
                      return GestureDetector(
                        onTap: () => setState(() => _category = c),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.primary : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(c, style: TextStyle(
                            color: sel ? AppColors.bg : AppColors.textSecondary,
                            fontSize: 12, fontWeight: FontWeight.w500,
                          )),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Food list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final food = _filtered[i];
                final sel = _selected?.id == food.id;
                return GestureDetector(
                  onTap: () => setState(() => _selected = food),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary.withOpacity(0.12) : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: sel ? Border.all(color: AppColors.primary, width: 1.5) : null,
                    ),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(food.name, style: TextStyle(
                          color: sel ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: FontWeight.w500, fontSize: 13,
                        )),
                        Text('Por 50g: ${food.caloriesPer50g.toInt()} kcal · P:${food.proteinPer50g.toInt()}g C:${food.carbsPer50g.toInt()}g G:${food.fatPer50g.toInt()}g',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      ])),
                      if (sel) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                    ]),
                  ),
                );
              },
            ),
          ),

          // Bottom panel when food is selected
          if (_selected != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(_selected!.name, style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text('${(_portions * _selected!.calories(_portions)).toInt()} kcal',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Text('Porções (50g cada):', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _portions > 0.5 ? () => setState(() => _portions -= 0.5) : null,
                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.textSecondary),
                    ),
                    Text('${_portions}x = ${(_portions * 50).toInt()}g',
                      style: GoogleFonts.syne(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                    IconButton(
                      onPressed: () => setState(() => _portions += 0.5),
                      icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  _loading
                      ? const CircularProgressIndicator(color: AppColors.primary)
                      : BLButton(label: 'Adicionar refeição', onTap: _save),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
