import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/group_model.dart';
import '../models/user_model.dart';

class GroupService extends ChangeNotifier {
  final _uuid = const Uuid();
  List<GroupModel> _groups = [];
  bool _loaded = false;

  List<GroupModel> get groups => _groups;

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
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final r = Random();
    return List.generate(6, (_) => chars[r.nextInt(chars.length)]).join();
  }

  List<GroupModel> getGroupsForUser(String userId) {
    return _groups.where((g) => g.members.any((m) => m.user.id == userId)).toList();
  }

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
