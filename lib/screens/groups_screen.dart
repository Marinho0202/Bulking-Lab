import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/group_service.dart';
import '../models/group_model.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser!;
    final groupSvc = context.watch<GroupService>();
    final myGroups = groupSvc.getGroupsForUser(user.id);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text('Grupos', style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: BLButton(label: 'Criar grupo', icon: Icons.add, onTap: () => _showCreate(context))),
              const SizedBox(width: 12),
              Expanded(child: BLButton(label: 'Entrar com código', outlined: true, onTap: () => _showJoin(context))),
            ]),
            const SizedBox(height: 24),
            if (myGroups.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
                child: const Column(children: [
                  Text('👥', style: TextStyle(fontSize: 40)),
                  SizedBox(height: 12),
                  Text('Nenhum grupo ainda', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  SizedBox(height: 6),
                  Text('Crie ou entre em um grupo para competir com amigos!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ]),
              )
            else ...[
              Text('Meus grupos', style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              ...myGroups.map((g) => _GroupCard(group: g, currentUserId: user.id)),
            ],
          ],
        ),
      ),
    );
  }

  void _showCreate(BuildContext context) {
    final nameCtrl = TextEditingController();
    String objective = 'muscle_gain';
    String duration = 'weekly';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(builder: (ctx, setState) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Criar grupo', style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 20),
              BLTextField(label: 'Nome do grupo', controller: nameCtrl, hint: 'Ex: Turma do Shape'),
              const SizedBox(height: 16),
              Text('Objetivo', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(children: AppText.objectiveLabels.entries.map((e) {
                final sel = objective == e.key;
                return Expanded(child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => setState(() => objective = e.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : AppColors.surface2,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text(e.value, style: TextStyle(
                        color: sel ? AppColors.bg : AppColors.textSecondary,
                        fontSize: 11, fontWeight: FontWeight.w600,
                      ), textAlign: TextAlign.center)),
                    ),
                  ),
                ));
              }).toList()),
              const SizedBox(height: 16),
              Text('Duração', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(children: AppText.durationLabels.entries.map((e) {
                final sel = duration == e.key;
                return Expanded(child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => setState(() => duration = e.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : AppColors.surface2,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text(e.value, style: TextStyle(
                        color: sel ? AppColors.bg : AppColors.textSecondary,
                        fontSize: 12, fontWeight: FontWeight.w600,
                      ))),
                    ),
                  ),
                ));
              }).toList()),
              const SizedBox(height: 24),
              BLButton(
                label: 'Criar',
                onTap: () async {
                  if (nameCtrl.text.isEmpty) return;
                  final user = context.read<AuthService>().currentUser!;
                  await context.read<GroupService>().createGroup(
                    creator: user,
                    name: nameCtrl.text.trim(),
                    objective: objective,
                    duration: duration,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showJoin(BuildContext context) {
    final codeCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(_).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Entrar em grupo', style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            BLTextField(label: 'Código de convite', controller: codeCtrl, hint: 'Ex: ABC123'),
            const SizedBox(height: 24),
            BLButton(
              label: 'Entrar',
              onTap: () async {
                final user = context.read<AuthService>().currentUser!;
                final ok = await context.read<GroupService>().joinGroup(user, codeCtrl.text.trim());
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ok ? 'Entrou no grupo!' : 'Código inválido.'),
                    backgroundColor: ok ? AppColors.success : AppColors.error,
                  ));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupModel group;
  final String currentUserId;

  const _GroupCard({required this.group, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(group.name, style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Text('${group.members.length} membros · ${AppText.objectiveLabels[group.objective] ?? group.objective}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ])),
          ]),
          const SizedBox(height: 12),
          // invite code
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              const Icon(Icons.vpn_key_rounded, color: AppColors.textMuted, size: 14),
              const SizedBox(width: 8),
              Text('Código: ', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              Text(group.inviteCode, style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: group.inviteCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Código copiado!'), backgroundColor: AppColors.success),
                  );
                },
                child: const Icon(Icons.copy_rounded, color: AppColors.textMuted, size: 16),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          // top 3 avatars
          Row(children: [
            ...group.rankedMembers.take(3).map((m) => Container(
              margin: const EdgeInsets.only(right: 6),
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.15),
              ),
              child: Center(child: Text(m.user.name[0].toUpperCase(),
                style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700))),
            )),
            if (group.members.length > 3)
              Text('+${group.members.length - 3}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ]),
        ],
      ),
    );
  }
}
