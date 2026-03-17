import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/meal_service.dart';
import '../services/group_service.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';
import 'register_meal_screen.dart';
import 'history_screen.dart';
import 'ranking_screen.dart';
import 'stats_screen.dart';
import 'groups_screen.dart';
import 'edit_profile_screen.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndLoad();
    });
  }

  void _checkAuthAndLoad() {
    final auth = context.read<AuthService>();
    if (auth.initialized && auth.currentUser == null) {
      _redirectToLogin();
      return;
    }
    if (auth.currentUser != null) {
      context.read<MealService>().loadForUser(auth.currentUser!.id);
      // Inicia o stream em tempo real de grupos (substitui o load() pontual)
      context.read<GroupService>().startListening();
    }
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
    context.read<GroupService>().stopListening();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    context.read<AuthService>().removeListener(_onAuthChanged);
    super.dispose();
  }

  Future<void> _refresh() async {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;
    // Grupos são atualizados automaticamente via stream.
    // Aqui só recarregamos as refeições do Firestore.
    await context.read<MealService>().reloadForUser(user.id);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    if (!auth.initialized || auth.currentUser == null) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final screens = [
      const _HomeTab(),
      const HistoryScreen(),
      const RankingScreen(),
      const StatsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BLRefreshWrapper(
        onRefresh: _refresh,
        child: IndexedStack(
          index: _tab,
          children: screens,
        ),
      ),
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

// ── Aba principal ──────────────────────────────────────────────────────────

class _HomeTab extends StatefulWidget {
  const _HomeTab({super.key});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Auto-refresh a cada 30 segundos
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      final user = context.read<AuthService>().currentUser;
      if (user != null && mounted) {
        context.read<MealService>().reloadForUser(user.id);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    if (user == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

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
            // ── Header ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'Olá, ${user.name.isNotEmpty ? user.name.split(' ').first : 'Usuário'} 👋',
                    style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
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
                  // Avatar — abre o bottom sheet de perfil
                  GestureDetector(
                    onTap: () => _showProfileSheet(context, user),
                    child: Container(
                      width: 38, height: 38,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: ClipOval(
                        child: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                            ? Image.network(user.photoUrl!, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(
                                    (user.name.isNotEmpty ? user.name[0] : 'U').toUpperCase(),
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppColors.bg, fontSize: 15),
                                  ),
                                ))
                            : Center(
                                child: Text(
                                  (user.name.isNotEmpty ? user.name[0] : 'U').toUpperCase(),
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppColors.bg, fontSize: 15),
                                ),
                              ),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
            const SizedBox(height: 24),

            // ── Score card ──────────────────────────────────────────
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
                          const Text('Pontuação hoje', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text('$score', style: GoogleFonts.inter(fontSize: 42, fontWeight: FontWeight.w800, color: AppColors.primary)),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8, left: 4),
                              child: Text('/100', style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
                            ),
                          ]),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(38),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _scoreLabel(score),
                              style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ]),
                      ),
                      _CircleProgress(value: score / 100),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    _CalStat(label: 'Kcal',     value: log.totalCalories.toInt(), target: user.targetCalories.toInt(), color: AppColors.info),
                    const SizedBox(width: 8),
                    _CalStat(label: 'Proteína', value: log.totalProtein.toInt(),  target: user.targetProtein.toInt(),  color: const Color(0xFFE8855A), suffix: 'g'),
                    const SizedBox(width: 8),
                    _CalStat(label: 'Carbs',    value: log.totalCarbs.toInt(),    target: user.targetCarbs.toInt(),    color: const Color(0xFF5A9EE8), suffix: 'g'),
                    const SizedBox(width: 8),
                    _CalStat(label: 'Gordura',  value: log.totalFat.toInt(),      target: user.targetFat.toInt(),      color: const Color(0xFFE8D05A), suffix: 'g'),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Botão registrar refeição ────────────────────────────
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

            // ── Refeições de hoje ───────────────────────────────────
            const SectionHeader(title: 'Refeições de hoje'),
            const SizedBox(height: 12),
            if (log.meals.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
                child: const Center(
                  child: Text('Nenhuma refeição registrada ainda.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ),
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

  String _goalText(String goal) {
    switch (goal) {
      case 'lose': return 'Objetivo: Emagrecimento';
      case 'gain': return 'Objetivo: Ganho muscular';
      default:     return 'Objetivo: Manutenção';
    }
  }

  String _scoreLabel(int s) {
    if (s >= 85) return 'Excelente';
    if (s >= 70) return 'Ótimo';
    if (s >= 55) return 'Bom';
    if (s >= 40) return 'Regular';
    return 'Continue assim!';
  }

  void _showProfileSheet(BuildContext context, user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ProfileSheet(user: user),
    );
  }
}

// ── Bottom sheet de perfil ─────────────────────────────────────────────────

class _ProfileSheet extends StatelessWidget {
  final dynamic user;
  const _ProfileSheet({required this.user});

  String _goalLabel(String goal) {
    switch (goal) {
      case 'lose': return 'Emagrecimento';
      case 'gain': return 'Ganho muscular';
      default:     return 'Manutenção';
    }
  }

  String _activityLabel(String level) {
    const labels = {
      'sedentary':   'Sedentário',
      'light':       'Levemente ativo',
      'moderate':    'Moderadamente ativo',
      'active':      'Muito ativo',
      'very_active': 'Extremamente ativo',
    };
    return labels[level] ?? level;
  }

  @override
  Widget build(BuildContext context) {
    final initials = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(2)),
          ),

          // Avatar + nome + email
          Row(children: [
            Container(
              width: 56, height: 56,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: ClipOval(
                child: (user.photoUrl != null && (user.photoUrl as String).isNotEmpty)
                    ? Image.network(user.photoUrl as String, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(initials,
                              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.bg)),
                        ))
                    : Center(
                        child: Text(initials,
                            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.bg)),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user.name,
                    style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text(user.email,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ]),
            ),
          ]),

          const SizedBox(height: 20),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          const SizedBox(height: 16),

          // Chips de dados resumidos
          Row(children: [
            _InfoChip(label: 'Peso',   value: '${user.weight.toInt()} kg'),
            const SizedBox(width: 8),
            _InfoChip(label: 'Altura', value: '${user.height.toInt()} cm'),
            const SizedBox(width: 8),
            _InfoChip(label: 'Idade',  value: '${user.age} anos'),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _InfoChip(label: 'Objetivo',  value: _goalLabel(user.goal),              flex: 2),
            const SizedBox(width: 8),
            _InfoChip(label: 'Atividade', value: _activityLabel(user.activityLevel), flex: 3),
          ]),

          const SizedBox(height: 20),

          // Botão editar perfil
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.edit_outlined, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text('Editar perfil',
                    style: GoogleFonts.syne(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
              ]),
            ),
          ),

          const SizedBox(height: 10),

          // Botão logout
          GestureDetector(
            onTap: () {
              // Captura o navigator root ANTES de fechar o sheet
              final nav = Navigator.of(context, rootNavigator: true);
              final authService = context.read<AuthService>();
              Navigator.pop(context); // fecha o sheet
              _confirmLogout(nav, authService);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                const SizedBox(width: 8),
                Text('Sair da conta',
                    style: GoogleFonts.syne(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 14)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(NavigatorState nav, AuthService authService) {
    showDialog(
      context: nav.context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Sair da conta', style: GoogleFonts.syne(color: AppColors.textPrimary)),
        content: const Text('Tem certeza que deseja sair?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              authService.logout();
            },
            child: const Text('Sair', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── Chip de info do perfil ─────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final int flex;

  const _InfoChip({required this.label, required this.value, this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

// ── Widgets internos ───────────────────────────────────────────────────────

class _CircleProgress extends StatelessWidget {
  final double value;
  const _CircleProgress({required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72, height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 6,
            backgroundColor: AppColors.surface2,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
          Text('${(value * 100).round()}%',
              style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
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

  const _CalStat({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
    this.suffix = '',
  });

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
          Text(meal.food.name,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
          Text('${meal.grams.toInt()}g · ${meal.calories.toInt()} kcal',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ])),
        Text('P: ${meal.protein.toInt()}g',
            style: const TextStyle(color: Color(0xFFE8855A), fontSize: 11, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}