import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/meal_service.dart';
import '../services/group_service.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';
<<<<<<< HEAD
import 'login_screen.dart'; // Certifique-se que o caminho está correto
=======
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
import 'register_meal_screen.dart';
import 'history_screen.dart';
import 'ranking_screen.dart';
import 'stats_screen.dart';
import 'groups_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    // Usamos o addPostFrameCallback para interagir com o Provider após a montagem do frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndLoad();
    });
  }

  void _checkAuthAndLoad() {
    final auth = context.read<AuthService>();
    
    // Se o serviço já inicializou e não tem usuário, manda para o Login
    if (auth.initialized && auth.currentUser == null) {
      _redirectToLogin();
      return;
    }

    // Se houver usuário, carrega os dados
    if (auth.currentUser != null) {
      context.read<MealService>().loadForUser(auth.currentUser!.id);
      context.read<GroupService>().load();
    }

    // Caso o AuthService ainda esteja carregando, ouvimos a mudança
    auth.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    final auth = context.read<AuthService>();
    if (auth.initialized && auth.currentUser == null) {
      auth.removeListener(_onAuthChanged);
      _redirectToLogin();
    }
  }

  void _redirectToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    // É importante remover o listener para evitar vazamento de memória
    context.read<AuthService>().removeListener(_onAuthChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    // Enquanto o Firebase não decide se tem usuário ou não, mostra um loading limpo
    if (!auth.initialized || auth.currentUser == null) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

=======
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthService>().currentUser;
      if (user != null) {
        context.read<MealService>().loadForUser(user.id);
        context.read<GroupService>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
    final screens = [
      const _HomeTab(),
      const HistoryScreen(),
      const RankingScreen(),
      const StatsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: screens[_tab],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: Color(0xFF2A2A2A), width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) => setState(() => _tab = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500),
          unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Início'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Histórico'),
            BottomNavigationBarItem(icon: Icon(Icons.leaderboard_rounded), label: 'Ranking'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Stats'),
          ],
        ),
      ),
    );
  }
}
<<<<<<< HEAD
class _HomeTab extends StatelessWidget {
  const _HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;
    
    // Proteção contra Null Check ao deslogar
    if (user == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

=======

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser!;
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
    final mealSvc = context.watch<MealService>();
    final now = DateTime.now();
    final log = mealSvc.getDailyLog(user.id, now);
    final score = mealSvc.getDailyScore(user, now);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
<<<<<<< HEAD
                  Text(
                    'Olá, ${user.name.isNotEmpty ? user.name.split(' ').first : 'Usuário'} 👋', 
                    style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)
                  ),
=======
                  Text('Olá, ${user.name.split(' ').first} 👋', style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
                  Text(_goalText(user.goal), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ]),
                Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupsScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.group_rounded, color: AppColors.textSecondary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showLogoutDialog(context),
                    child: Container(
                      width: 38, height: 38,
<<<<<<< HEAD
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          (user.name.isNotEmpty ? user.name[0] : 'U').toUpperCase(), 
                          style: GoogleFonts.syne(fontWeight: FontWeight.w800, color: AppColors.bg, fontSize: 15)
                        )
                      ),
=======
                      decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: Center(child: Text(user.name[0].toUpperCase(), style: GoogleFonts.syne(fontWeight: FontWeight.w800, color: AppColors.bg, fontSize: 15))),
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
                    ),
                  ),
                ]),
              ],
            ),
            const SizedBox(height: 24),

            // Score card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
<<<<<<< HEAD
                          const Text('Pontuação hoje', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
=======
                          Text('Pontuação hoje', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
                          const SizedBox(height: 4),
                          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text('$score', style: GoogleFonts.syne(fontSize: 42, fontWeight: FontWeight.w800, color: AppColors.primary)),
                            const Padding(padding: EdgeInsets.only(bottom: 8, left: 4), child: Text('/100', style: TextStyle(color: AppColors.textMuted, fontSize: 16))),
                          ]),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
<<<<<<< HEAD
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(38), // Substituído withOpacity (38/255 = ~0.15)
                              borderRadius: BorderRadius.circular(8)
                            ),
                            child: Text(
                              _scoreLabel(score), 
                              style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)
                            ),
=======
                            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                            child: Text(_scoreLabel(score), style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
                          ),
                        ]),
                      ),
                      _CircleProgress(value: score / 100),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    _CalStat(label: 'Kcal', value: log.totalCalories.toInt(), target: user.targetCalories.toInt(), color: AppColors.info),
                    const SizedBox(width: 8),
                    _CalStat(label: 'Proteína', value: log.totalProtein.toInt(), target: user.targetProtein.toInt(), color: const Color(0xFFE8855A), suffix: 'g'),
                    const SizedBox(width: 8),
                    _CalStat(label: 'Carbs', value: log.totalCarbs.toInt(), target: user.targetCarbs.toInt(), color: const Color(0xFF5A9EE8), suffix: 'g'),
                    const SizedBox(width: 8),
                    _CalStat(label: 'Gordura', value: log.totalFat.toInt(), target: user.targetFat.toInt(), color: const Color(0xFFE8D05A), suffix: 'g'),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Register meal button
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterMealScreen())),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle_rounded, color: AppColors.bg, size: 22),
                    const SizedBox(width: 10),
                    Text('Registrar Refeição', style: GoogleFonts.syne(color: AppColors.bg, fontWeight: FontWeight.w700, fontSize: 15)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recent meals
<<<<<<< HEAD
            const SectionHeader(title: 'Refeições de hoje'),
=======
            SectionHeader(title: 'Refeições de hoje'),
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
            const SizedBox(height: 12),
            if (log.meals.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
                child: const Center(child: Text('Nenhuma refeição registrada ainda.', style: TextStyle(color: AppColors.textMuted, fontSize: 13))),
              )
            else
              ...log.meals.take(4).map((meal) => _MealTile(meal: meal, userId: user.id)),
            if (log.meals.length > 4)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(child: Text('+ ${log.meals.length - 4} mais', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
              ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  // Métodos movidos para dentro da _HomeTab
=======
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
  String _goalText(String goal) {
    switch (goal) {
      case 'lose': return 'Objetivo: Emagrecimento';
      case 'gain': return 'Objetivo: Ganho muscular';
      default: return 'Objetivo: Manutenção';
    }
  }

  String _scoreLabel(int s) {
    if (s >= 85) return 'Excelente';
    if (s >= 70) return 'Ótimo';
    if (s >= 55) return 'Bom';
    if (s >= 40) return 'Regular';
    return 'Continue assim!';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text('Sair', style: GoogleFonts.syne(color: AppColors.textPrimary)),
      content: const Text('Deseja sair da sua conta?', style: TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary))),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<AuthService>().logout();
          },
          child: const Text('Sair', style: TextStyle(color: AppColors.error)),
        ),
      ],
    ));
  }
}

<<<<<<< HEAD
// O restante dos widgets secundários (_CircleProgress, _CalStat, _MealTile) continua igual...
=======
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
class _CircleProgress extends StatelessWidget {
  final double value;
  const _CircleProgress({required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 6,
            backgroundColor: AppColors.surface2,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
          Text('${(value * 100).round()}%', style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _CalStat extends StatelessWidget {
  final String label;
  final int value;
  final int target;
  final Color color;
  final String suffix;

  const _CalStat({required this.label, required this.value, required this.target, required this.color, this.suffix = ''});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          const SizedBox(height: 4),
          Text('$value$suffix', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
          Text('/$target$suffix', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ]),
      ),
    );
  }
}

class _MealTile extends StatelessWidget {
  final dynamic meal;
  final String userId;

  const _MealTile({required this.meal, required this.userId});

  @override
  Widget build(BuildContext context) {
    final icon = AppText.mealTypeIcons[meal.mealType] ?? '🍽️';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 16))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(meal.food.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
          Text('${meal.grams.toInt()}g · ${meal.calories.toInt()} kcal', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ])),
        Text('P: ${meal.protein.toInt()}g', style: const TextStyle(color: Color(0xFFE8855A), fontSize: 11, fontWeight: FontWeight.w500)),
      ]),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
