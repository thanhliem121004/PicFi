import 'package:equatable/equatable.dart';

enum SplitType { equal, percentage, custom }

class GroupEntity extends Equatable {
  final String id;
  final String name;
  final List<GroupMember> members;
  final String? createdBy;
  final DateTime createdAt;
  final double totalAmount;
  final int totalExpenses;
  final String? emoji;
  final SplitType splitType;

  const GroupEntity({
    required this.id,
    required this.name,
    this.members = const [],
    this.createdBy,
    required this.createdAt,
    this.totalAmount = 0,
    this.totalExpenses = 0,
    this.emoji,
    this.splitType = SplitType.equal,
  });

  GroupEntity copyWith({
    String? id,
    String? name,
    List<GroupMember>? members,
    String? createdBy,
    DateTime? createdAt,
    double? totalAmount,
    int? totalExpenses,
    String? emoji,
    SplitType? splitType,
  }) {
    return GroupEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      members: members ?? this.members,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      totalAmount: totalAmount ?? this.totalAmount,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      emoji: emoji ?? this.emoji,
      splitType: splitType ?? this.splitType,
    );
  }

  factory GroupEntity.fromMap(Map<String, dynamic> data, String docId) {
    final membersData = (data['members'] as List<dynamic>?) ?? [];
    return GroupEntity(
      id: docId,
      name: data['name'] ?? '',
      members: membersData.map((m) => GroupMember.fromMap(m as Map<String, dynamic>)).toList(),
      createdBy: data['createdBy'] as String?,
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0,
      totalExpenses: (data['totalExpenses'] as num?)?.toInt() ?? 0,
      emoji: data['emoji'] as String?,
      splitType: SplitType.values.firstWhere(
        (e) => e.name == data['splitType'],
        orElse: () => SplitType.equal,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'members': members.map((m) => m.toMap()).toList(),
      'createdBy': createdBy,
      'createdAt': createdAt,
      'totalAmount': totalAmount,
      'totalExpenses': totalExpenses,
      'emoji': emoji,
      'splitType': splitType.name,
    };
  }

  @override
  List<Object?> get props => [id, name, members, createdBy, createdAt, totalAmount, totalExpenses, emoji, splitType];
}

class GroupExpenseEntity extends Equatable {
  final String id;
  final String groupId;
  final String expenseId;
  final String addedBy;
  final String paidBy;
  final double shareAmount;
  final DateTime createdAt;

  const GroupExpenseEntity({
    required this.id,
    required this.groupId,
    required this.expenseId,
    required this.addedBy,
    required this.paidBy,
    this.shareAmount = 0,
    required this.createdAt,
  });

  GroupExpenseEntity copyWith({
    String? id,
    String? groupId,
    String? expenseId,
    String? addedBy,
    String? paidBy,
    double? shareAmount,
    DateTime? createdAt,
  }) {
    return GroupExpenseEntity(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      expenseId: expenseId ?? this.expenseId,
      addedBy: addedBy ?? this.addedBy,
      paidBy: paidBy ?? this.paidBy,
      shareAmount: shareAmount ?? this.shareAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, groupId, expenseId, addedBy, paidBy, shareAmount, createdAt];
}

class GroupMember extends Equatable {
  final String uid;
  final String userId;
  final String picfiId;
  final String? displayName;
  final String? photoUrl;
  final double contribution;
  final double totalPaid;
  final double totalOwed;

  const GroupMember({
    this.uid = '',
    this.userId = '',
    this.picfiId = '',
    this.displayName,
    this.photoUrl,
    this.contribution = 0,
    this.totalPaid = 0,
    this.totalOwed = 0,
  });

  double get balance => totalPaid - totalOwed;

  GroupMember copyWith({
    String? uid,
    String? userId,
    String? picfiId,
    String? displayName,
    String? photoUrl,
    double? contribution,
    double? totalPaid,
    double? totalOwed,
  }) {
    return GroupMember(
      uid: uid ?? this.uid,
      userId: userId ?? this.userId,
      picfiId: picfiId ?? this.picfiId,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      contribution: contribution ?? this.contribution,
      totalPaid: totalPaid ?? this.totalPaid,
      totalOwed: totalOwed ?? this.totalOwed,
    );
  }

  factory GroupMember.fromMap(Map<String, dynamic> data) {
    return GroupMember(
      uid: data['uid'] ?? data['userId'] ?? '',
      userId: data['userId'] ?? data['uid'] ?? '',
      picfiId: data['picfiId'] ?? '',
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      contribution: (data['contribution'] as num?)?.toDouble() ?? 0,
      totalPaid: (data['totalPaid'] as num?)?.toDouble() ?? 0,
      totalOwed: (data['totalOwed'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userId': userId,
      'picfiId': picfiId,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'contribution': contribution,
      'totalPaid': totalPaid,
      'totalOwed': totalOwed,
    };
  }

  @override
  List<Object?> get props => [uid, userId, picfiId, displayName, photoUrl, contribution, totalPaid, totalOwed];
}
