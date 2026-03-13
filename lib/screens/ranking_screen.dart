import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/group_service.dart';
import '../services/meal_service.dart';
import '../models/group_model.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';
import 'groups_screen.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser!;
    final groupSvc = context.watch<GroupService>();
    final mealSvc = context.watch<MealService>();

    final myGroups = groupSvc.getGroupsForUser(user.id);

    // Sync points
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scores = mealSvc.getWeeklyScores(user);
      final weekTotal = scores.fold(0, (s, d) => s + d);
      final days = mealSvc.getDaysLoggedThisWeek(user.id);
      for (final g in myGroups) {
        groupSvc.updateMemberPoints(g.id, user.id, weekTotal, days);
      }
    });

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Ranking Semanal',
              action: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupsScreen())),
                child: const Row(children: [
                  Text('Grupos', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 12),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            if (myGroups.isEmpty)
              _EmptyState()
            else
              ...myGroups.map((g) => _GroupRanking(group: g, currentUserId: user.id)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        const Text('🏆', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text('Sem grupos ainda', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        const Text('Crie ou entre em um grupo para competir com amigos!',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 20),
        BLButton(
          label: 'Ir para Grupos',
          fullWidth: false,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupsScreen())),
        ),
      ]),
    );
  }
}

class _GroupRanking extends StatelessWidget {
  final GroupModel group;
  final String currentUserId;

  const _GroupRanking({required this.group, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final ranked = group.rankedMembers;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(group.name, style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text('${AppText.objectiveLabels[group.objective] ?? group.objective} · ${AppText.durationLabels[group.duration] ?? group.duration}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const Icon(Icons.people, color: AppColors.primary, size: 14),
                  const SizedBox(width: 4),
                  Text('${group.members.length}', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          if (ranked.length >= 3) _Podium(members: ranked.take(3).toList()),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          ...ranked.asMap().entries.map((e) {
            final idx = e.key;
            final member = e.value;
            final isMe = member.user.id == currentUserId;
            return _RankRow(rank: idx + 1, member: member, isMe: isMe);
          }),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              '★ +15 pts por ≥5 dias registrados  ·  +20 pts por atingir meta',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  final List<GroupMember> members;
  const _Podium({required this.members});

  @override
  Widget build(BuildContext context) {
    final order = [members[1], members[0], members.length > 2 ? members[2] : members[0]];
    final heights = [60.0, 80.0, 45.0];
    final medals = ['🥈', '🥇', '🥉'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (i) {
          final m = i < order.length ? order[i] : null;
          if (m == null) return const Expanded(child: SizedBox());
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(medals[i], style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 4),
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.2),
                    border: i == 1 ? Border.all(color: AppColors.primary, width: 2) : null,
                  ),
                  child: Center(child: Text(m.user.name[0].toUpperCase(),
                    style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary))),
                ),
                const SizedBox(height: 4),
                Text(m.user.name.split(' ').first,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                  overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Container(
                  height: heights[i],
                  decoration: BoxDecoration(
                    color: i == 1 ? AppColors.primary.withOpacity(0.2) : AppColors.surface2,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: Center(
                    child: Text('${m.weeklyPoints}', style: GoogleFonts.syne(
                      fontSize: 13, fontWeight: FontWeight.w800,
                      color: i == 1 ? AppColors.primary : AppColors.textSecondary,
                    )),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final int rank;
  final GroupMember member;
  final bool isMe;

  const _RankRow({required this.rank, required this.member, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: isMe ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
      child: Row(children: [
        SizedBox(
          width: 24,
          child: Text('$rank', style: GoogleFonts.syne(
            fontSize: 13, fontWeight: FontWeight.w800,
            color: rank <= 3 ? AppColors.primary : AppColors.textMuted,
          )),
        ),
        const SizedBox(width: 10),
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMe ? AppColors.primary.withOpacity(0.2) : AppColors.surface2,
          ),
          child: Center(child: Text(member.user.name[0].toUpperCase(),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
              color: isMe ? AppColors.primary : AppColors.textSecondary))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(member.user.name.split(' ').first,
              style: TextStyle(color: isMe ? AppColors.primary : AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
            if (isMe) const Text('  (você)', style: TextStyle(color: AppColors.primary, fontSize: 11)),
          ]),
          Text('${member.totalDaysLogged} dias · ${AppText.goalLabels[member.user.goal] ?? member.user.goal}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${member.weeklyPoints}', style: GoogleFonts.syne(
            fontSize: 15, fontWeight: FontWeight.w800,
            color: isMe ? AppColors.primary : AppColors.textPrimary,
          )),
          const Text('pts', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ]),
      ]),
    );
  }
}
