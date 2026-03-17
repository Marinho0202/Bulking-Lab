class UserModel {
  final String id;
  final String name;
  final String email;
  final double weight;
  final double height;
  final int age;
  final String gender;
  final String activityLevel;
  final String goal;
  final int mealsPerDay;
  double currentWeight;
  String? photoUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.weight,
    required this.height,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.goal,
    required this.mealsPerDay,
    double? currentWeight,
    this.photoUrl,
  }) : currentWeight = currentWeight ?? weight;

  double get bmr {
    if (gender == 'male') {
      return 88.36 + (13.4 * weight) + (4.8 * height) - (5.7 * age);
    } else {
      return 447.6 + (9.2 * weight) + (3.1 * height) - (4.3 * age);
    }
  }

  double get activityMultiplier {
    switch (activityLevel) {
      case 'sedentary': return 1.2;
      case 'light': return 1.375;
      case 'moderate': return 1.55;
      case 'active': return 1.725;
      case 'very_active': return 1.9;
      default: return 1.55;
    }
  }

  double get tdee => bmr * activityMultiplier;

  double get targetCalories {
    switch (goal) {
      case 'lose': return tdee - 400;
      case 'gain': return tdee + 400;
      default: return tdee;
    }
  }

  double get targetProtein {
    switch (goal) {
      case 'gain': return weight * 2.2;
      case 'lose': return weight * 2.0;
      default: return weight * 1.8;
    }
  }

  double get targetCarbs {
    double calsFromProtein = targetProtein * 4;
    double calsFromFat = targetFat * 9;
    return (targetCalories - calsFromProtein - calsFromFat) / 4;
  }

  double get targetFat {
    switch (goal) {
      case 'gain': return (targetCalories * 0.25) / 9;
      case 'lose': return (targetCalories * 0.30) / 9;
      default: return (targetCalories * 0.28) / 9;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'weight': weight,
    'height': height,
    'age': age,
    'gender': gender,
    'activityLevel': activityLevel,
    'goal': goal,
    'mealsPerDay': mealsPerDay,
    'currentWeight': currentWeight,
    if (photoUrl != null) 'photoUrl': photoUrl,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    weight: (json['weight'] as num?)?.toDouble() ?? 70,
    height: (json['height'] as num?)?.toDouble() ?? 170,
    age: (json['age'] as num?)?.toInt() ?? 25,
    gender: json['gender'] ?? 'male',
    activityLevel: json['activityLevel'] ?? 'moderate',
    goal: json['goal'] ?? 'maintain',
    mealsPerDay: (json['mealsPerDay'] as num?)?.toInt() ?? 3,
    currentWeight: (json['currentWeight'] as num?)?.toDouble(),
    photoUrl: json['photoUrl'] as String?,
  );
}