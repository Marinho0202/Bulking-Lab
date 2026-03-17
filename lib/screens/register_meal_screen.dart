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
  // food.id → FoodItem
  final Map<String, FoodItem> _selectedFoods = {};
  // food.id → porções
  final Map<String, double> _selectedPortions = {};

  String _mealType = 'lunch';
  String _search = '';
  String _category = 'Todos';
  bool _loading = false;

  List<FoodItem> get _filtered {
    var list = _search.isNotEmpty ? FoodDatabase.search(_search) : FoodDatabase.items;
    if (_category != 'Todos') list = list.where((f) => f.category == _category).toList();
    return list;
  }

  bool _isSelected(FoodItem food) => _selectedFoods.containsKey(food.id);
  double _getPortions(FoodItem food) => _selectedPortions[food.id] ?? 1.0;

  void _toggleFood(FoodItem food) {
    setState(() {
      if (_isSelected(food)) {
        _selectedFoods.remove(food.id);
        _selectedPortions.remove(food.id);
      } else {
        _selectedFoods[food.id] = food;
        _selectedPortions[food.id] = 1.0;
      }
    });
  }

  void _changePortions(FoodItem food, double delta) {
    final next = _getPortions(food) + delta;
    if (next < 0.5) return;
    setState(() => _selectedPortions[food.id] = next);
  }

  double get _totalCalories => _selectedFoods.entries.fold(0.0, (sum, e) {
    final portions = _selectedPortions[e.key] ?? 1.0;
    return sum + e.value.calories(portions);
  });

  Future<void> _save() async {
    if (_selectedFoods.isEmpty) return;
    setState(() => _loading = true);
    final user = context.read<AuthService>().currentUser!;

    for (final entry in _selectedFoods.entries) {
      final portions = _selectedPortions[entry.key] ?? 1.0;
      await context.read<MealService>().addMeal(
        userId: user.id,
        food: entry.value,
        portions: portions,
        mealType: _mealType,
      );
    }

    if (!mounted) return;
    setState(() => _loading = false);
    final count = _selectedFoods.length;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(count == 1 ? 'Refeição registrada!' : '$count refeições registradas!'),
      backgroundColor: AppColors.success,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cats = ['Todos', ...FoodDatabase.categories];
    final hasSelection = _selectedFoods.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text(
          hasSelection
              ? '${_selectedFoods.length} selecionado${_selectedFoods.length > 1 ? 's' : ''}'
              : 'Registrar Refeição',
          style: GoogleFonts.syne(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (hasSelection)
            TextButton(
              onPressed: () => setState(() {
                _selectedFoods.clear();
                _selectedPortions.clear();
              }),
              child: const Text('Limpar', style: TextStyle(color: AppColors.textMuted)),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Tipo de refeição
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
                // Busca
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
                // Categorias
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

          // Lista de alimentos
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final food = _filtered[i];
                final sel = _isSelected(food);
                final portions = _getPortions(food);
                final portionsLabel = portions % 1 == 0
                    ? '${portions.toInt()}x'
                    : '${portions}x';

                return GestureDetector(
                  onTap: () => _toggleFood(food),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary.withOpacity(0.10) : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: sel ? Border.all(color: AppColors.primary, width: 1.5) : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Linha principal
                        Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(food.name, style: TextStyle(
                              color: sel ? AppColors.primary : AppColors.textPrimary,
                              fontWeight: FontWeight.w600, fontSize: 13,
                            )),
                            Text(
                              'Por 50g: ${food.caloriesPer50g.toInt()} kcal · '
                              'P:${food.proteinPer50g.toInt()}g '
                              'C:${food.carbsPer50g.toInt()}g '
                              'G:${food.fatPer50g.toInt()}g',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                            ),
                          ])),
                          if (sel)
                            const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
                          else
                            const Icon(Icons.add_circle_outline, color: AppColors.textMuted, size: 20),
                        ]),

                        // Controle de quantidade — só aparece quando selecionado
                        if (sel) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surface2,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(children: [
                              const Text('Porções (50g):', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              const Spacer(),
                              // Botão −
                              GestureDetector(
                                onTap: () => _changePortions(food, -0.5),
                                child: Container(
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(
                                    color: portions <= 0.5 ? AppColors.surface : AppColors.bg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.remove, size: 16,
                                    color: portions <= 0.5 ? AppColors.textMuted : AppColors.textPrimary),
                                ),
                              ),
                              // Valor central
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Column(children: [
                                  Text(portionsLabel, style: GoogleFonts.inter(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  )),
                                  Text(
                                    '${(portions * 50).toInt()}g · ${food.calories(portions).toInt()} kcal',
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                                  ),
                                ]),
                              ),
                              // Botão +
                              GestureDetector(
                                onTap: () => _changePortions(food, 0.5),
                                child: Container(
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.add, size: 16, color: AppColors.primary),
                                ),
                              ),
                            ]),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Painel inferior — aparece com seleção
          if (hasSelection)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(
                      '${_selectedFoods.length} item${_selectedFoods.length > 1 ? 'ns' : ''}',
                      style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    Text(
                      'Total: ${_totalCalories.toInt()} kcal',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  // Chips resumo (toque para remover)
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _selectedFoods.values.map((food) {
                        final p = _selectedPortions[food.id] ?? 1.0;
                        final label = p % 1 == 0 ? '${p.toInt()}x' : '${p}x';
                        return GestureDetector(
                          onTap: () => _toggleFood(food),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Text('$label ${food.name}',
                                style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w500)),
                              const SizedBox(width: 4),
                              const Icon(Icons.close, color: AppColors.primary, size: 12),
                            ]),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _loading
                      ? const CircularProgressIndicator(color: AppColors.primary)
                      : BLButton(
                          label: _selectedFoods.length == 1
                              ? 'Adicionar refeição'
                              : 'Adicionar ${_selectedFoods.length} refeições',
                          onTap: _save,
                        ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}