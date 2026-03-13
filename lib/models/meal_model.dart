class FoodItem {
  final String id;
  final String name;
  final String category;
  final double caloriesPer50g;
  final double proteinPer50g;
  final double carbsPer50g;
  final double fatPer50g;

  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.caloriesPer50g,
    required this.proteinPer50g,
    required this.carbsPer50g,
    required this.fatPer50g,
  });

  double calories(double portions) => caloriesPer50g * portions;
  double protein(double portions) => proteinPer50g * portions;
  double carbs(double portions) => carbsPer50g * portions;
  double fat(double portions) => fatPer50g * portions;

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'category': category,
    'caloriesPer50g': caloriesPer50g, 'proteinPer50g': proteinPer50g,
    'carbsPer50g': carbsPer50g, 'fatPer50g': fatPer50g,
  };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
    id: json['id'], name: json['name'], category: json['category'],
    caloriesPer50g: (json['caloriesPer50g'] as num).toDouble(),
    proteinPer50g: (json['proteinPer50g'] as num).toDouble(),
    carbsPer50g: (json['carbsPer50g'] as num).toDouble(),
    fatPer50g: (json['fatPer50g'] as num).toDouble(),
  );
}

class MealEntry {
  final String id;
  final String userId;
  final FoodItem food;
  final double portions;
  final String mealType;
  final DateTime registeredAt;

  MealEntry({
    required this.id,
    required this.userId,
    required this.food,
    required this.portions,
    required this.mealType,
    required this.registeredAt,
  });

  double get calories => food.calories(portions);
  double get protein => food.protein(portions);
  double get carbs => food.carbs(portions);
  double get fat => food.fat(portions);
  double get grams => portions * 50;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'food': food.toJson(),
    'portions': portions,
    'mealType': mealType,
    'registeredAt': registeredAt.toIso8601String(),
  };

  factory MealEntry.fromJson(Map<String, dynamic> json) => MealEntry(
    id: json['id'],
    userId: json['userId'],
    food: FoodItem.fromJson(json['food']),
    portions: (json['portions'] as num).toDouble(),
    mealType: json['mealType'],
    registeredAt: DateTime.parse(json['registeredAt']),
  );
}

class DailyLog {
  final String userId;
  final DateTime date;
  final List<MealEntry> meals;

  DailyLog({required this.userId, required this.date, required this.meals});

  double get totalCalories => meals.fold(0, (s, m) => s + m.calories);
  double get totalProtein => meals.fold(0, (s, m) => s + m.protein);
  double get totalCarbs => meals.fold(0, (s, m) => s + m.carbs);
  double get totalFat => meals.fold(0, (s, m) => s + m.fat);

  List<MealEntry> get breakfast => meals.where((m) => m.mealType == 'breakfast').toList();
  List<MealEntry> get lunch => meals.where((m) => m.mealType == 'lunch').toList();
  List<MealEntry> get dinner => meals.where((m) => m.mealType == 'dinner').toList();
  List<MealEntry> get snack => meals.where((m) => m.mealType == 'snack').toList();
}
