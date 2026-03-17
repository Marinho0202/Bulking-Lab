import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/group_model.dart';
import '../models/user_model.dart';

class GroupService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  List<GroupModel> _groups = [];
  StreamSubscription<QuerySnapshot>? _subscription;

  List<GroupModel> get groups => _groups;

  // ── Stream em tempo real ───────────────────────────────────────────────────
  // Substitui o .get() pontual. Qualquer alteração no Firestore (outro membro
  // entrando, pontos atualizados, grupo editado) reflete automaticamente na UI.
  void startListening() {
    _subscription?.cancel();
    _subscription = _db.collection('groups').snapshots().listen(
      (snapshot) {
        _groups = snapshot.docs
            .map((doc) => GroupModel.fromJson(doc.data()))
            .toList();
        notifyListeners();
      },
      onError: (e) => debugPrint('GroupService stream error: $e'),
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _groups = [];
  }

  // Mantido para compatibilidade com o pull-to-refresh (já tem o stream,
  // mas o home_screen chama reload() — aqui apenas força um re-fetch pontual).
  Future<void> load() async {
    try {
      final snapshot = await _db.collection('groups').get();
      _groups = snapshot.docs
          .map((doc) => GroupModel.fromJson(doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar grupos: $e');
    }
  }

  Future<void> reload() async => load();

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<GroupModel> getGroupsForUser(String userId) =>
      _groups.where((g) => g.members.any((m) => m.user.id == userId)).toList();

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final r = Random();
    return List.generate(6, (_) => chars[r.nextInt(chars.length)]).join();
  }

  // ── CRUD ───────────────────────────────────────────────────────────────────

  Future<GroupModel> createGroup({
    required UserModel creator,
    required String name,
    required String objective,
    required String duration,
  }) async {
    final group = GroupModel(
      id: _uuid.v4(),
      name: name,
      objective: objective,
      duration: duration,
      creatorId: creator.id,
      inviteCode: _generateCode(),
      createdAt: DateTime.now(),
      members: [GroupMember(user: creator)],
    );

    await _db.collection('groups').doc(group.id).set(group.toJson());
    // O stream já vai atualizar _groups automaticamente
    return group;
  }

  Future<bool> joinGroup(UserModel user, String code) async {
    try {
      final query = await _db
          .collection('groups')
          .where('inviteCode', isEqualTo: code.toUpperCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) return false;

      final doc = query.docs.first;
      final group = GroupModel.fromJson(doc.data());

      if (group.members.any((m) => m.user.id == user.id)) return true;

      final newMember = GroupMember(user: user);
      final updatedMembers = [...group.members, newMember]
          .map((m) => m.toJson())
          .toList();

      // Grava o array inteiro — FieldValue.arrayUnion não funciona com objetos
      await _db.collection('groups').doc(group.id).update({
        'members': updatedMembers,
      });

      // O stream atualiza a UI automaticamente
      return true;
    } catch (e) {
      debugPrint('Erro ao entrar no grupo: $e');
      return false;
    }
  }

  // ── ADM: editar grupo ──────────────────────────────────────────────────────

  Future<void> updateGroup({
    required String groupId,
    required String requestingUserId,
    String? name,
    String? objective,
    String? duration,
  }) async {
    final group = _groups.firstWhere((g) => g.id == groupId);
    if (group.creatorId != requestingUserId) {
      throw Exception('Apenas o administrador pode editar o grupo.');
    }

    final updates = <String, dynamic>{};
    if (name != null && name.isNotEmpty) updates['name'] = name;
    if (objective != null) updates['objective'] = objective;
    if (duration != null) updates['duration'] = duration;

    await _db.collection('groups').doc(groupId).update(updates);
  }

  // ── ADM: remover membro ────────────────────────────────────────────────────

  Future<void> removeMember({
    required String groupId,
    required String requestingUserId,
    required String targetUserId,
  }) async {
    final group = _groups.firstWhere((g) => g.id == groupId);
    if (group.creatorId != requestingUserId) {
      throw Exception('Apenas o administrador pode remover membros.');
    }
    if (targetUserId == requestingUserId) {
      throw Exception('O administrador não pode se remover do grupo.');
    }

    final updatedMembers = group.members
        .where((m) => m.user.id != targetUserId)
        .map((m) => m.toJson())
        .toList();

    await _db.collection('groups').doc(groupId).update({
      'members': updatedMembers,
    });
  }

  // ── ADM: excluir grupo ─────────────────────────────────────────────────────

  Future<void> deleteGroup({
    required String groupId,
    required String requestingUserId,
  }) async {
    final group = _groups.firstWhere((g) => g.id == groupId);
    if (group.creatorId != requestingUserId) {
      throw Exception('Apenas o administrador pode excluir o grupo.');
    }
    await _db.collection('groups').doc(groupId).delete();
  }

  // ── Pontuação ──────────────────────────────────────────────────────────────
  // Agora faz uma transação atômica: lê o estado atual do Firestore,
  // atualiza apenas o membro relevante, e grava de volta.
  // Isso evita sobrescrever dados mais novos de outros membros.
  Future<void> updateMemberPoints(
    String groupId,
    String userId,
    int points,
    int daysLogged,
  ) async {
    try {
      final docRef = _db.collection('groups').doc(groupId);

      await _db.runTransaction((tx) async {
        final snap = await tx.get(docRef);
        if (!snap.exists) return;

        final group = GroupModel.fromJson(snap.data()!);
        final updatedMembers = group.members.map((m) {
          if (m.user.id == userId) {
            return GroupMember(
              user: m.user,
              weeklyPoints: points,
              totalDaysLogged: daysLogged,
              achievedGoalThisWeek: m.achievedGoalThisWeek,
            );
          }
          return m;
        }).map((m) => m.toJson()).toList();

        tx.update(docRef, {'members': updatedMembers});
      });
    } catch (e) {
      debugPrint('Erro ao atualizar pontos: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}