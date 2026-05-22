import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/friend_entity.dart';
import '../../../domain/entities/chat_message.dart';

class FriendsState extends Equatable {
  final List<FriendEntity> friends;
  final List<FriendEntity> requests;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final String? successMessage;

  const FriendsState({
    this.friends = const [],
    this.requests = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.successMessage,
  });

  FriendsState copyWith({
    List<FriendEntity>? friends,
    List<FriendEntity>? requests,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    String? successMessage,
  }) {
    return FriendsState(
      friends: friends ?? this.friends,
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [friends, requests, isLoading, isLoadingMore, hasMore, error, successMessage];
}

const int _friendsPageSize = 20;

class FriendsCubit extends Cubit<FriendsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _friendsSub;
  StreamSubscription? _requestsSub;
  StreamSubscription? _authSub;
  DocumentSnapshot? _lastFriendDoc;
  bool _hasMoreFriends = true;

  FriendsCubit() : super(const FriendsState()) {
    _authSub = _auth.authStateChanges().listen((user) {
      _friendsSub?.cancel();
      _requestsSub?.cancel();
      _lastFriendDoc = null;
      _hasMoreFriends = true;
      if (user != null) {
        _listenToFriends(user.uid);
        _listenToRequests(user.uid);
      } else {
        emit(const FriendsState());
      }
    });
  }

  String? get _uid => _auth.currentUser?.uid;

  void _listenToFriends(String uid) {
    _friendsSub = _firestore
        .collection('users')
        .doc(uid)
        .collection('friends')
        .where('status', isEqualTo: 'accepted')
        .orderBy('createdAt', descending: true)
        .limit(_friendsPageSize)
        .snapshots()
        .listen((snapshot) {
      final docs = snapshot.docs;
      _lastFriendDoc = docs.isNotEmpty ? docs.last : null;
      _hasMoreFriends = docs.length >= _friendsPageSize;
      final friends = docs.map((doc) {
        final d = doc.data();
        return FriendEntity(
          id: doc.id,
          friendId: d['friendId'] ?? '',
          friendName: d['friendName'] ?? 'Không rõ',
          friendEmail: d['friendEmail'],
          friendPhotoUrl: d['friendPhotoUrl'],
          streak: d['streak'] ?? 0,
          lastInteraction: (d['lastInteraction'] as Timestamp?)?.toDate(),
          status: FriendStatus.accepted,
          createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
      emit(state.copyWith(friends: friends, hasMore: _hasMoreFriends));
    });
  }

  Future<void> loadMoreFriends() async {
    if (_uid == null || !_hasMoreFriends || state.isLoadingMore || _lastFriendDoc == null) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('friends')
          .where('status', isEqualTo: 'accepted')
          .orderBy('createdAt', descending: true)
          .startAfterDocument(_lastFriendDoc!)
          .limit(_friendsPageSize)
          .get();
      final docs = snapshot.docs;
      _lastFriendDoc = docs.isNotEmpty ? docs.last : null;
      _hasMoreFriends = docs.length >= _friendsPageSize;
      final newFriends = docs.map((doc) {
        final d = doc.data();
        return FriendEntity(
          id: doc.id,
          friendId: d['friendId'] ?? '',
          friendName: d['friendName'] ?? 'Không rõ',
          friendEmail: d['friendEmail'],
          friendPhotoUrl: d['friendPhotoUrl'],
          streak: d['streak'] ?? 0,
          lastInteraction: (d['lastInteraction'] as Timestamp?)?.toDate(),
          status: FriendStatus.accepted,
          createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
      emit(state.copyWith(
        friends: [...state.friends, ...newFriends],
        isLoadingMore: false,
        hasMore: _hasMoreFriends,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, error: 'Lỗi tải thêm bạn bè: $e'));
    }
  }

  void _listenToRequests(String uid) {
    _requestsSub = _firestore
        .collection('users')
        .doc(uid)
        .collection('friends')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      final requests = snapshot.docs.map((doc) {
        final d = doc.data();
        return FriendEntity(
          id: doc.id,
          friendId: d['friendId'] ?? '',
          friendName: d['friendName'] ?? 'Không rõ',
          friendEmail: d['friendEmail'],
          friendPhotoUrl: d['friendPhotoUrl'],
          streak: 0,
          status: FriendStatus.pending,
          createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
      emit(state.copyWith(requests: requests));
    });
  }

  /// Hủy kết bạn
  Future<void> unfriend(String friendId) async {
    if (_uid == null) return;
    try {
      final myDocs = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('friends')
          .where('friendId', isEqualTo: friendId)
          .limit(1)
          .get();
      for (final doc in myDocs.docs) {
        await doc.reference.delete();
      }
      final friendDocs = await _firestore
          .collection('users')
          .doc(friendId)
          .collection('friends')
          .where('friendId', isEqualTo: _uid)
          .limit(1)
          .get();
      for (final doc in friendDocs.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi hủy kết bạn: $e'));
    }
  }

  /// Gửi lời mời kết bạn bằng PicFi ID (VD: PF-A3B7K9)
  Future<void> sendFriendRequestByPicfiId(String picfiId) async {
    if (_uid == null) return;
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));

    // Rate limiting: max 10 requests per hour
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      final requestTimestamps = prefs.getStringList('friendRequestTimestamps') ?? [];
      final oneHourAgo = now - 3600000;
      requestTimestamps.removeWhere((t) => int.tryParse(t) == null || int.parse(t) < oneHourAgo);
      if (requestTimestamps.length >= 10) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Bạn đã gửi quá nhiều lời mời kết bạn trong giờ này',
        ));
        return;
      }
      requestTimestamps.add(now.toString());
      await prefs.setStringList('friendRequestTimestamps', requestTimestamps);
    } catch (_) {}

    try {
      final trimmedId = picfiId.trim();

      // Tìm user theo PicFi ID
      final query = await _firestore
          .collection('users')
          .where('picfiId', isEqualTo: trimmedId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Không tìm thấy người dùng với ID "$trimmedId"',
        ));
        return;
      }

      final targetDoc = query.docs.first;
      final targetUid = targetDoc.id;
      final targetData = targetDoc.data();

      // Không thể kết bạn với chính mình
      if (targetUid == _uid) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Bạn không thể kết bạn với chính mình 😅',
        ));
        return;
      }

      // Kiểm tra đã kết bạn chưa
      final existing = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('friends')
          .where('friendId', isEqualTo: targetUid)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        final status = existing.docs.first.data()['status'];
        if (status == 'accepted') {
          emit(state.copyWith(isLoading: false, error: 'Hai bạn đã là bạn bè rồi!'));
        } else {
          emit(state.copyWith(isLoading: false, error: 'Lời mời kết bạn đã được gửi trước đó'));
        }
        return;
      }

      final myUser = _auth.currentUser!;
      final myDoc = await _firestore.collection('users').doc(_uid).get();
      final myData = myDoc.data() ?? {};

      // Tạo request ở phía người nhận (pending)
      await _firestore
          .collection('users')
          .doc(targetUid)
          .collection('friends')
          .add({
        'friendId': _uid,
        'friendName': myData['displayName'] ?? myUser.displayName ?? 'Người dùng PicFi',
        'friendEmail': myUser.email,
        'friendPhotoUrl': myUser.photoURL,
        'status': 'pending',
        'streak': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Tạo record ở phía người gửi (waiting)
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('friends')
          .add({
        'friendId': targetUid,
        'friendName': targetData['displayName'] ?? 'Không rõ',
        'friendEmail': targetData['email'],
        'friendPhotoUrl': targetData['photoUrl'],
        'status': 'waiting', // Đang chờ đối phương accept
        'streak': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Đã gửi lời mời kết bạn đến ${targetData['displayName'] ?? trimmedId}! 🎉',
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Lỗi gửi lời mời: $e'));
    }
  }

  /// Chấp nhận lời mời kết bạn (2 chiều)
  Future<void> acceptRequest(String requestId) async {
    if (_uid == null) return;
    try {
      // 1. Lấy thông tin request
      final requestDoc = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('friends')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) return;
      final requestData = requestDoc.data()!;
      final senderId = requestData['friendId'] as String;

      // 2. Update request thành accepted (phía người nhận)
      await requestDoc.reference.update({
        'status': 'accepted',
        'lastInteraction': FieldValue.serverTimestamp(),
      });

      // 3. Update hoặc tạo friendship ở phía người gửi (sender → accepted)
      final senderFriends = await _firestore
          .collection('users')
          .doc(senderId)
          .collection('friends')
          .where('friendId', isEqualTo: _uid)
          .limit(1)
          .get();

      final myUser = _auth.currentUser!;
      final myDoc = await _firestore.collection('users').doc(_uid).get();
      final myData = myDoc.data() ?? {};

      if (senderFriends.docs.isNotEmpty) {
        // Update existing record
        await senderFriends.docs.first.reference.update({
          'status': 'accepted',
          'lastInteraction': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new friendship doc for sender
        await _firestore
            .collection('users')
            .doc(senderId)
            .collection('friends')
            .add({
          'friendId': _uid,
          'friendName': myData['displayName'] ?? myUser.displayName ?? 'Người dùng PicFi',
          'friendEmail': myUser.email,
          'friendPhotoUrl': myUser.photoURL,
          'status': 'accepted',
          'streak': 0,
          'lastInteraction': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi chấp nhận: $e'));
    }
  }

  // ═══ CHAT ═══

  /// Gửi tin nhắn realtime
  Future<void> sendMessage(String friendId, String message, {String? imageUrl}) async {
    if (_uid == null) return;
    final chatId = _getChatId(_uid!, friendId);

    try {
      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderId': _uid,
        'receiverId': friendId,
        'message': message,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Update streak on both sides
      await _updateStreak(friendId);
    } catch (e) {
      // Silently fail for now
    }
  }

  /// Stream tin nhắn realtime
  Stream<List<ChatMessage>> getChatStream(String friendId) {
    if (_uid == null) return const Stream.empty();
    final chatId = _getChatId(_uid!, friendId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final d = doc.data();
              return ChatMessage(
                id: doc.id,
                senderId: d['senderId'] ?? '',
                receiverId: d['receiverId'] ?? '',
                message: d['message'] ?? '',
                imageUrl: d['imageUrl'],
                timestamp: (d['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
                isRead: d['isRead'] ?? false,
              );
            }).toList());
  }

  String _getChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Future<void> _updateStreak(String friendId) async {
    if (_uid == null) return;
    try {
      // Update my side
      final myDocs = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('friends')
          .where('friendId', isEqualTo: friendId)
          .limit(1)
          .get();

      if (myDocs.docs.isNotEmpty) {
        final doc = myDocs.docs.first;
        final lastInteraction = (doc.data()['lastInteraction'] as Timestamp?)?.toDate();
        final now = DateTime.now();
        int currentStreak = (doc.data()['streak'] ?? 0) as int;

        // Only increment streak if last interaction was a different day
        if (lastInteraction == null ||
            lastInteraction.day != now.day ||
            lastInteraction.month != now.month ||
            lastInteraction.year != now.year) {
          currentStreak++;
        }

        await doc.reference.update({
          'lastInteraction': FieldValue.serverTimestamp(),
          'streak': currentStreak,
        });
      }

      // Update friend's side too
      final friendDocs = await _firestore
          .collection('users')
          .doc(friendId)
          .collection('friends')
          .where('friendId', isEqualTo: _uid)
          .limit(1)
          .get();

      if (friendDocs.docs.isNotEmpty) {
        final doc = friendDocs.docs.first;
        final lastInteraction = (doc.data()['lastInteraction'] as Timestamp?)?.toDate();
        final now = DateTime.now();
        int currentStreak = (doc.data()['streak'] ?? 0) as int;

        if (lastInteraction == null ||
            lastInteraction.day != now.day ||
            lastInteraction.month != now.month ||
            lastInteraction.year != now.year) {
          currentStreak++;
        }

        await doc.reference.update({
          'lastInteraction': FieldValue.serverTimestamp(),
          'streak': currentStreak,
        });
      }
    } catch (_) {}
  }

  void clearMessages() {
    emit(state.copyWith(error: null, successMessage: null));
  }

  @override
  Future<void> close() {
    _friendsSub?.cancel();
    _requestsSub?.cancel();
    _authSub?.cancel();
    return super.close();
  }
}
