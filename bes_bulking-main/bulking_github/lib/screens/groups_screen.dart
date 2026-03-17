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
                  Text('Nenhum grupo ainda',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  SizedBox(height: 6),
                  Text('Crie ou entre em um grupo para competir com amigos!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ]),
              )
            else ...[
              Text('Meus grupos',
                  style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              ...myGroups.map((g) => _GroupCard(group: g, currentUserId: user.id)),
            ],
          ],
        ),
      ),
    );
  }

  // ── Criar grupo ────────────────────────────────────────────────────────────

  void _showCreate(BuildContext context) {
    final nameCtrl = TextEditingController();
    String objective = 'muscle_gain';
    String duration = 'weekly';
    bool loading = false;

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
              Text('Criar grupo',
                  style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 20),
              BLTextField(label: 'Nome do grupo', controller: nameCtrl, hint: 'Ex: Turma do Shape'),
              const SizedBox(height: 16),
              const Text('Objetivo',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
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
                      child: Center(child: Text(e.value,
                          style: TextStyle(
                            color: sel ? AppColors.bg : AppColors.textSecondary,
                            fontSize: 11, fontWeight: FontWeight.w600,
                          ), textAlign: TextAlign.center)),
                    ),
                  ),
                ));
              }).toList()),
              const SizedBox(height: 16),
              const Text('Duração',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
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
                      child: Center(child: Text(e.value,
                          style: TextStyle(
                            color: sel ? AppColors.bg : AppColors.textSecondary,
                            fontSize: 12, fontWeight: FontWeight.w600,
                          ))),
                    ),
                  ),
                ));
              }).toList()),
              const SizedBox(height: 24),
              loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : BLButton(
                      label: 'Criar',
                      onTap: () async {
                        if (nameCtrl.text.isEmpty) return;
                        setState(() => loading = true);
                        try {
                          final user = context.read<AuthService>().currentUser!;
                          await context.read<GroupService>().createGroup(
                            creator: user,
                            name: nameCtrl.text.trim(),
                            objective: objective,
                            duration: duration,
                          );
                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          setState(() => loading = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Erro ao criar grupo: $e'),
                              backgroundColor: AppColors.error,
                            ));
                          }
                        }
                      },
                    ),
            ],
          ),
        );
      }),
    );
  }

  // ── Entrar em grupo ────────────────────────────────────────────────────────

  void _showJoin(BuildContext context) {
    final codeCtrl = TextEditingController();
    bool loading = false;

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
              Text('Entrar em grupo',
                  style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 20),
              BLTextField(label: 'Código de convite', controller: codeCtrl, hint: 'Ex: ABC123'),
              const SizedBox(height: 24),
              loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : BLButton(
                      label: 'Entrar',
                      onTap: () async {
                        if (codeCtrl.text.trim().isEmpty) return;
                        setState(() => loading = true);
                        final user = context.read<AuthService>().currentUser!;
                        final ok = await context.read<GroupService>().joinGroup(user, codeCtrl.text.trim());
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(ok ? 'Entrou no grupo!' : 'Código inválido ou grupo não encontrado.'),
                            backgroundColor: ok ? AppColors.success : AppColors.error,
                          ));
                        }
                      },
                    ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Card de grupo ──────────────────────────────────────────────────────────

class _GroupCard extends StatelessWidget {
  final GroupModel group;
  final String currentUserId;

  const _GroupCard({required this.group, required this.currentUserId});

  bool get _isAdmin => group.creatorId == currentUserId;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome + badge ADM + botão de opções
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(group.name,
                    style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                if (_isAdmin) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('ADM',
                        style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
                ],
              ]),
              Text('${group.members.length} membros · ${AppText.objectiveLabels[group.objective] ?? group.objective}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ])),
            // Botão de opções só para o ADM
            if (_isAdmin)
              GestureDetector(
                onTap: () => _showAdminOptions(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.settings_outlined, color: AppColors.textSecondary, size: 18),
                ),
              ),
          ]),
          const SizedBox(height: 12),

          // Código de convite
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              const Icon(Icons.vpn_key_rounded, color: AppColors.textMuted, size: 14),
              const SizedBox(width: 8),
              const Text('Código: ', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              Text(group.inviteCode,
                  style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
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

          // Membros com opção de remover (só ADM)
          ...group.members.map((m) => _MemberRow(
            member: m,
            isAdmin: _isAdmin,
            isCreator: m.user.id == group.creatorId,
            onRemove: _isAdmin && m.user.id != currentUserId
                ? () => _confirmRemove(context, m)
                : null,
          )),
        ],
      ),
    );
  }

  // ── Opções de ADM ──────────────────────────────────────────────────────────

  void _showAdminOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(2)),
            ),
            Text('Administrar grupo',
                style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            _OptionTile(
              icon: Icons.edit_outlined,
              label: 'Editar grupo',
              onTap: () {
                Navigator.pop(context);
                _showEditGroup(context);
              },
            ),
            const SizedBox(height: 10),
            _OptionTile(
              icon: Icons.delete_outline,
              label: 'Excluir grupo',
              color: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteGroup(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditGroup(BuildContext context) {
    final nameCtrl = TextEditingController(text: group.name);
    String objective = group.objective;
    String duration = group.duration;
    bool loading = false;

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
              Text('Editar grupo',
                  style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 20),
              BLTextField(label: 'Nome do grupo', controller: nameCtrl, hint: 'Ex: Turma do Shape'),
              const SizedBox(height: 16),
              const Text('Objetivo',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
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
                      child: Center(child: Text(e.value,
                          style: TextStyle(
                            color: sel ? AppColors.bg : AppColors.textSecondary,
                            fontSize: 11, fontWeight: FontWeight.w600,
                          ), textAlign: TextAlign.center)),
                    ),
                  ),
                ));
              }).toList()),
              const SizedBox(height: 16),
              const Text('Duração',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
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
                      child: Center(child: Text(e.value,
                          style: TextStyle(
                            color: sel ? AppColors.bg : AppColors.textSecondary,
                            fontSize: 12, fontWeight: FontWeight.w600,
                          ))),
                    ),
                  ),
                ));
              }).toList()),
              const SizedBox(height: 24),
              loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : BLButton(
                      label: 'Salvar alterações',
                      onTap: () async {
                        setState(() => loading = true);
                        try {
                          await context.read<GroupService>().updateGroup(
                            groupId: group.id,
                            requestingUserId: currentUserId,
                            name: nameCtrl.text.trim(),
                            objective: objective,
                            duration: duration,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Grupo atualizado!'), backgroundColor: AppColors.success),
                            );
                          }
                        } catch (e) {
                          setState(() => loading = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Erro: $e'),
                              backgroundColor: AppColors.error,
                            ));
                          }
                        }
                      },
                    ),
            ],
          ),
        );
      }),
    );
  }

  void _confirmDeleteGroup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Excluir grupo', style: GoogleFonts.syne(color: AppColors.textPrimary)),
        content: Text(
          'Tem certeza que deseja excluir "${group.name}"? Esta ação não pode ser desfeita.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<GroupService>().deleteGroup(
                  groupId: group.id,
                  requestingUserId: currentUserId,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Grupo excluído.'), backgroundColor: AppColors.error),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Erro: $e'),
                    backgroundColor: AppColors.error,
                  ));
                }
              }
            },
            child: const Text('Excluir', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _confirmRemove(BuildContext context, GroupMember member) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Remover membro', style: GoogleFonts.syne(color: AppColors.textPrimary)),
        content: Text(
          'Remover ${member.user.name} do grupo?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<GroupService>().removeMember(
                  groupId: group.id,
                  requestingUserId: currentUserId,
                  targetUserId: member.user.id,
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Erro: $e'),
                    backgroundColor: AppColors.error,
                  ));
                }
              }
            },
            child: const Text('Remover', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── Row de membro ──────────────────────────────────────────────────────────

class _MemberRow extends StatelessWidget {
  final GroupMember member;
  final bool isAdmin;
  final bool isCreator;
  final VoidCallback? onRemove;

  const _MemberRow({
    required this.member,
    required this.isAdmin,
    required this.isCreator,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: Center(
            child: Text(
              member.user.name.isNotEmpty ? member.user.name[0].toUpperCase() : '?',
              style: const TextStyle(color: AppColors.bg, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(member.user.name.split(' ').first,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
            if (isCreator) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('ADM',
                    style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700)),
              ),
            ],
          ]),
          Text('${member.weeklyPoints} pts · ${member.totalDaysLogged} dias',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ])),
        if (onRemove != null)
          GestureDetector(
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.remove_circle_outline, color: AppColors.error, size: 18),
            ),
          ),
      ]),
    );
  }
}

// ── Tile de opção ADM ──────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color == AppColors.error
              ? AppColors.error.withOpacity(0.08)
              : AppColors.surface2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label,
              style: GoogleFonts.syne(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
        ]),
      ),
    );
  }
}