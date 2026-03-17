import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFE8FF45);
  static const bg = Color(0xFF0F0F0F);
  static const surface = Color(0xFF1A1A1A);
  static const surface2 = Color(0xFF252525);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF888888);
  static const textMuted = Color(0xFF555555);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFEF5350);
  static const info = Color(0xFF2196F3);
}

class AppText {
  static const goalLabels = {
    'lose': 'Emagrecimento',
    'maintain': 'Manutenção',
    'gain': 'Ganho muscular',
  };

  static const activityLabels = {
    'sedentary': 'Sedentário',
    'light': 'Levemente ativo',
    'moderate': 'Moderadamente ativo',
    'active': 'Muito ativo',
    'very_active': 'Extremamente ativo',
  };

  static const mealTypeLabels = {
    'breakfast': 'Café da manhã',
    'lunch': 'Almoço',
    'dinner': 'Jantar',
    'snack': 'Lanche',
  };

  static const mealTypeIcons = {
    'breakfast': '🌅',
    'lunch': '☀️',
    'dinner': '🌙',
    'snack': '🥪',
  };

  static const objectiveLabels = {
    'weight_loss': 'Emagrecimento',
    'muscle_gain': 'Ganho de massa',
    'mixed': 'Misto',
  };

  static const durationLabels = {
    'weekly': 'Semanal',
    'monthly': 'Mensal',
  };
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}
