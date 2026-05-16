import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/group_entity.dart';
import '../../../domain/entities/friend_entity.dart';

class GroupState extends Equatable {
  final List<GroupEntity> groups;
  final List<GroupExpenseEntity> groupExpenses;
  final bool isLoading;
  final String? error;

  const GroupState({
    this.groups = const [],
    this.groupExpenses = const [],
    this.isLoading = false,
    this.error,
  });

  GroupState copyWith({
    List<GroupEntity>? groups,
    List<GroupExpenseEntity>? groupExpenses,
    bool? isLoading,
    String? error,
  }) {
    return GroupState(
      groups: groups ?? this.groups,
      groupExpenses: groupExpenses ?? this.groupExpenses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [groups, groupExpenses, isLoading, error];
}

class GroupCubit extends Cubit<GroupState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _groupsSub;
  StreamSubscription? _groupExpensesSub;

  GroupCubit() : super(const GroupState()) {
    _listenToGroups();
  }

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference get _groupsRef =>
      _firestore.collection('users').doc(_uid).collection('groups');

  CollectionReference _groupExpensesRef(String groupId) =>
      _firestore.collection('users').doc(_uid).collection('groups').doc(groupId).collection('expenses');

  void _listenToGroups() {
    _auth.authStateChanges().listen((user) {
      _groupsSub?.cancel();
      _groupExpensesSub?.cancel();
      if (user != null) {
        _groupsSub = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('groups')
            .orderBy('createdAt', descending: true)
            .snapshots()
            .listen((snapshot) {
          final groups = snapshot.docs.map((doc) {
            final data = doc.data();
            final membersData = (data['members'] as List<dynamic>?) ?? [];
            return GroupEntity(
              id: doc.id,
              name: data['name'] ?? '',
              emoji: data['emoji'],
              members: membersData.map((m) => GroupMember.fromMap(m as Map<String, dynamic>)).toList(),
              totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0,
              totalExpenses: (data['totalExpenses'] as num?)?.toInt() ?? 0,
              createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          }).toList();
          emit(state.copyWith(groups: groups, isLoading: false));
        });
      } else {
        emit(const GroupState());
      }
    });
  }

  Future<void> createGroup(String name, String? emoji, List<FriendEntity> friends) async {
    if (_uid == null) return;
    emit(state.copyWith(isLoading: true));
    try {
      final members = friends.map((f) => GroupMember(
        userId: f.friendId,
        picfiId: f.friendId,
        displayName: f.friendName,
        photoUrl: f.friendPhotoUrl,
      )).toList();
      members.insert(0, GroupMember(
        userId: _uid!,
        picfiId: '',
        displayName: _auth.currentUser?.displayName ?? 'Me',
        photoUrl: _auth.currentUser?.photoURL,
      ));
      await _groupsRef.add({
        'name': name,
        'emoji': emoji,
        'members': members.map((m) => m.toMap()).toList(),
        'totalAmount': 0,
        'totalExpenses': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Lỗi tạo nhóm: $e'));
    }
  }

  Future<void> deleteGroup(String groupId) async {
    if (_uid == null) return;
    try {
      final expenses = await _groupExpensesRef(groupId).get();
      for (final doc in expenses.docs) {
        await doc.reference.delete();
      }
      await _groupsRef.doc(groupId).delete();
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi xóa nhóm: $e'));
    }
  }

  Future<void> addGroupExpense({
    required String groupId,
    required String description,
    required double amount,
    required String paidBy,
    required SplitType splitType,
    required List<String> memberIds,
  }) async {
    if (_uid == null) return;
    emit(state.copyWith(isLoading: true));
    try {
      final shares = <String, double>{};
      switch (splitType) {
        case SplitType.equal:
          final share = amount / memberIds.length;
          for (final id in memberIds) {
            shares[id] = share;
          }
          break;
        case SplitType.percentage:
        case SplitType.custom:
          for (final id in memberIds) {
            shares[id] = amount / memberIds.length;
          }
      }

      await _groupExpensesRef(groupId).add({
        'description': description,
        'amount': amount,
        'paidBy': paidBy,
        'splitType': splitType.name,
        'shares': shares,
        'date': Timestamp.fromDate(DateTime.now()),
        'createdAt': FieldValue.serverTimestamp(),
      });

      final groupDoc = await _groupsRef.doc(groupId).get();
      if (groupDoc.exists) {
        final data = groupDoc.data() as Map<String, dynamic>;
        final currentTotal = (data['totalAmount'] as num?)?.toDouble() ?? 0;
        final currentCount = (data['totalExpenses'] as num?)?.toInt() ?? 0;
        final membersData = (data['members'] as List<dynamic>?) ?? [];
        final updatedMembers = membersData.map((m) {
          final member = GroupMember.fromMap(m as Map<String, dynamic>);
          double newPaid = member.totalPaid;
          double newOwed = member.totalOwed;
          if (member.userId == paidBy) {
            newPaid += amount;
          }
          if (shares.containsKey(member.userId)) {
            newOwed += shares[member.userId]!;
          }
          return member.copyWith(totalPaid: newPaid, totalOwed: newOwed);
        }).toList();

        await _groupsRef.doc(groupId).update({
          'totalAmount': currentTotal + amount,
          'totalExpenses': currentCount + 1,
          'members': updatedMembers.map((m) => m.toMap()).toList(),
        });
      }

      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Lỗi thêm chi tiêu nhóm: $e'));
    }
  }

  Future<void> settleUp(String groupId, String fromUserId, String toUserId, double amount) async {
    if (_uid == null) return;
    try {
      final groupDoc = await _groupsRef.doc(groupId).get();
      if (!groupDoc.exists) return;
      final data = groupDoc.data() as Map<String, dynamic>;
      final membersData = (data['members'] as List<dynamic>?) ?? [];
      final updatedMembers = membersData.map((m) {
        final member = GroupMember.fromMap(m as Map<String, dynamic>);
        double newPaid = member.totalPaid;
        double newOwed = member.totalOwed;
        if (member.userId == fromUserId) {
          newOwed -= amount;
        }
        if (member.userId == toUserId) {
          newPaid -= amount;
        }
        return member.copyWith(totalPaid: newPaid, totalOwed: newOwed);
      }).toList();

      await _groupsRef.doc(groupId).update({
        'members': updatedMembers.map((m) => m.toMap()).toList(),
      });
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi thanh toán: $e'));
    }
  }

  @override
  Future<void> close() {
    _groupsSub?.cancel();
    _groupExpensesSub?.cancel();
    return super.close();
  }
}
