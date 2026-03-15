<<<<<<< HEAD
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // MUDANÇA AQUI
=======
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
import 'package:uuid/uuid.dart';
import '../models/group_model.dart';
import '../models/user_model.dart';

class GroupService extends ChangeNotifier {
<<<<<<< HEAD
  final FirebaseFirestore _db = FirebaseFirestore.instance; // INSTÂNCIA DO BANCO
=======
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
  final _uuid = const Uuid();
  List<GroupModel> _groups = [];
  bool _loaded = false;

  List<GroupModel> get groups => _groups;

<<<<<<< HEAD
  // CARREGA TODOS OS GRUPOS DO FIREBASE
  Future<void> load() async {
    try {
      final snapshot = await _db.collection('groups').get();
      _groups = snapshot.docs.map((doc) => GroupModel.fromJson(doc.data())).toList();
      _loaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao carregar grupos: $e");
    }
=======
  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('groups');
    if (raw != null) {
      final list = json.decode(raw) as List;
      _groups = list.map((e) => GroupModel.fromJson(e)).toList();
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('groups', json.encode(_groups.map((g) => g.toJson()).toList()));
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final r = Random();
    return List.generate(6, (_) => chars[r.nextInt(chars.length)]).join();
  }

  List<GroupModel> getGroupsForUser(String userId) {
    return _groups.where((g) => g.members.any((m) => m.user.id == userId)).toList();
  }

<<<<<<< HEAD
  // CRIA O GRUPO NA NUVEM
=======
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
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
<<<<<<< HEAD

    try {
      // Salva na coleção global de grupos
      await _db.collection('groups').doc(group.id).set(group.toJson());
      
      _groups.add(group);
      notifyListeners();
      return group;
    } catch (e) {
      debugPrint("Erro ao criar grupo no Firebase: $e");
      rethrow;
    }
  }

  // ENTRA EM UM GRUPO EXISTENTE VIA CÓDIGO
  Future<bool> joinGroup(UserModel user, String code) async {
    try {
      // Busca o grupo pelo código de convite no Firebase
      final query = await _db
          .collection('groups')
          .where('inviteCode', isEqualTo: code.toUpperCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) return false;

      final doc = query.docs.first;
      final group = GroupModel.fromJson(doc.data());

      // Verifica se já é membro
      if (group.members.any((m) => m.user.id == user.id)) return true;

      // Adiciona o novo membro
      final newMember = GroupMember(user: user);
      
      await _db.collection('groups').doc(group.id).update({
        'members': FieldValue.arrayUnion([newMember.toJson()])
      });

      // Atualiza a lista local
      await load(); 
      return true;
    } catch (e) {
      debugPrint("Erro ao entrar no grupo: $e");
      return false;
    }
  }

  // ATUALIZA PONTOS PARA O RANKING
  Future<void> updateMemberPoints(String groupId, String userId, int points, int daysLogged) async {
    try {
      final gIdx = _groups.indexWhere((g) => g.id == groupId);
      if (gIdx == -1) return;

      final membersJson = _groups[gIdx].members.map((m) {
        if (m.user.id == userId) {
          m.weeklyPoints = points;
          m.totalDaysLogged = daysLogged;
        }
        return m.toJson();
      }).toList();

      await _db.collection('groups').doc(groupId).update({
        'members': membersJson,
      });

      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao atualizar ranking: $e");
    }
  }
}
=======
    _groups.add(group);
    await _save();
    notifyListeners();
    return group;
  }

  Future<bool> joinGroup(UserModel user, String code) async {
    final idx = _groups.indexWhere((g) => g.inviteCode == code.toUpperCase());
    if (idx == -1) return false;
    final group = _groups[idx];
    if (group.members.any((m) => m.user.id == user.id)) return true;
    group.members.add(GroupMember(user: user));
    await _save();
    notifyListeners();
    return true;
  }

  Future<void> updateMemberPoints(String groupId, String userId, int points, int daysLogged) async {
    final gIdx = _groups.indexWhere((g) => g.id == groupId);
    if (gIdx == -1) return;
    final mIdx = _groups[gIdx].members.indexWhere((m) => m.user.id == userId);
    if (mIdx == -1) return;
    _groups[gIdx].members[mIdx].weeklyPoints = points;
    _groups[gIdx].members[mIdx].totalDaysLogged = daysLogged;
    await _save();
    notifyListeners();
  }
}
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
