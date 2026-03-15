import 'user_model.dart';

class GroupMember {
  final UserModel user;
  int weeklyPoints;
  int totalDaysLogged;
  bool achievedGoalThisWeek;

  GroupMember({
    required this.user,
    this.weeklyPoints = 0,
    this.totalDaysLogged = 0,
    this.achievedGoalThisWeek = false,
  });

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'weeklyPoints': weeklyPoints,
    'totalDaysLogged': totalDaysLogged,
    'achievedGoalThisWeek': achievedGoalThisWeek,
  };

  factory GroupMember.fromJson(Map<String, dynamic> json) => GroupMember(
    user: UserModel.fromJson(json['user']),
    weeklyPoints: json['weeklyPoints'] ?? 0,
    totalDaysLogged: json['totalDaysLogged'] ?? 0,
    achievedGoalThisWeek: json['achievedGoalThisWeek'] ?? false,
  );
}

class GroupModel {
  final String id;
  final String name;
  final String objective;
  final String duration;
  final String creatorId;
  final String inviteCode;
  final DateTime createdAt;
  final List<GroupMember> members;

  GroupModel({
    required this.id,
    required this.name,
    required this.objective,
    required this.duration,
    required this.creatorId,
    required this.inviteCode,
    required this.createdAt,
    required this.members,
  });

  List<GroupMember> get rankedMembers {
    final sorted = List<GroupMember>.from(members);
    sorted.sort((a, b) => b.weeklyPoints.compareTo(a.weeklyPoints));
    return sorted;
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'objective': objective,
    'duration': duration, 'creatorId': creatorId,
    'inviteCode': inviteCode,
    'createdAt': createdAt.toIso8601String(),
    'members': members.map((m) => m.toJson()).toList(),
  };

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
    id: json['id'], name: json['name'], objective: json['objective'],
    duration: json['duration'], creatorId: json['creatorId'],
    inviteCode: json['inviteCode'],
    createdAt: DateTime.parse(json['createdAt']),
    members: (json['members'] as List).map((m) => GroupMember.fromJson(m)).toList(),
  );
}
