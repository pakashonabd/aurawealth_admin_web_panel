import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import '../models/message_thread.dart';

/// Firestore-backed admin chat transport.
class FirestoreAdminChatService {
  FirestoreAdminChatService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _messagesRef(String userId) =>
      _firestore.collection('chat').doc(userId).collection('messages');

  CollectionReference<Map<String, dynamic>> _mailsRef(String userId) =>
      _firestore.collection('chat').doc(userId).collection('mails');

  DocumentReference<Map<String, dynamic>> _chatRef(String userId) =>
      _firestore.collection('chat').doc(userId);

  Stream<List<MessageThread>> watchThreads() {
    return _firestore
        .collection('chat')
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_threadFromDoc).toList());
  }

  Future<List<MessageThread>> loadThreads() async {
    final snapshot = await _firestore
        .collection('chat')
        .orderBy('lastMessageAt', descending: true)
        .get();
    return snapshot.docs.map(_threadFromDoc).toList();
  }

  Stream<List<Message>> watchMessages(String userId) {
    return _messagesRef(userId).limit(1000).snapshots().map((snapshot) {
      // ignore: avoid_print
      print(
        '[FirestoreAdminChatService] watchMessages chat/$userId/messages '
        'returned ${snapshot.docs.length} docs',
      );
      final messages =
          snapshot.docs
              .map((doc) => messageFromFirestore(doc.id, doc.data()))
              .toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return messages;
    });
  }

  Stream<List<Message>> watchMails(String userId) {
    return _mailsRef(userId).limit(1000).snapshots().map((snapshot) {
      // ignore: avoid_print
      print(
        '[FirestoreAdminChatService] watchMails chat/$userId/mails '
        'returned ${snapshot.docs.length} docs',
      );
      final mails =
          snapshot.docs
              .map((doc) => mailFromFirestore(doc.id, doc.data()))
              .toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return mails;
    });
  }

  Future<List<Message>> loadRecentMessages(
    String userId, {
    int limit = 1000,
  }) async {
    final snapshot = await _messagesRef(userId).limit(limit).get();
    // ignore: avoid_print
    print(
      '[FirestoreAdminChatService] loadRecentMessages chat/$userId/messages '
      'returned ${snapshot.docs.length} docs',
    );
    final messages =
        snapshot.docs
            .map((doc) => messageFromFirestore(doc.id, doc.data()))
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return messages;
  }

  Future<List<Message>> loadMailHistory(
    String userId, {
    int limit = 1000,
  }) async {
    final snapshot = await _mailsRef(userId).limit(limit).get();
    // ignore: avoid_print
    print(
      '[FirestoreAdminChatService] loadMailHistory chat/$userId/mails '
      'returned ${snapshot.docs.length} docs',
    );
    final mails =
        snapshot.docs
            .map((doc) => mailFromFirestore(doc.id, doc.data()))
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return mails;
  }

  Future<Message> sendAdminMessage({
    required String userId,
    required String content,
    String messageType = 'live',
    String? subject,
    String? attachmentUrl,
  }) async {
    final docRef = _messagesRef(userId).doc();
    final now = FieldValue.serverTimestamp();
    final payload = <String, dynamic>{
      'id': docRef.id,
      'chatId': userId,
      'userId': userId,
      'senderId': 'admin',
      'senderRole': 'admin',
      'type': messageType,
      'subject': subject,
      'content': content,
      'attachmentUrl': attachmentUrl,
      'readByAdmin': true,
      'readByUser': false,
      'createdAt': now,
      'updatedAt': now,
    };

    await _chatRef(userId).set({
      'userId': userId,
      'lastMessage': content,
      'lastMessageAt': now,
      'lastSenderRole': 'admin',
      'updatedAt': now,
    }, SetOptions(merge: true));
    await docRef.set(payload);

    return Message(
      id: docRef.id,
      direction: 'admin_to_user',
      messageType: messageType,
      subject: subject,
      body: content,
      attachmentUrl: attachmentUrl,
      isRead: false,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
  }

  Future<Message> sendMail({
    required String userId,
    required String subject,
    required String content,
  }) async {
    final docRef = _mailsRef(userId).doc();
    final now = FieldValue.serverTimestamp();
    final payload = <String, dynamic>{
      'id': docRef.id,
      'senderId': 'admin',
      'senderRole': 'admin',
      'subject': subject,
      'content': content,
      'timestamp': now,
      'read': false,
    };

    await docRef.set(payload);

    return Message(
      id: docRef.id,
      direction: 'admin_to_user',
      messageType: 'static',
      subject: subject,
      body: content,
      isRead: false,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
  }

  Future<void> markUserMessagesRead(String userId) async {
    final snapshot = await _messagesRef(userId)
        .where('senderRole', isEqualTo: 'user')
        .where('readByAdmin', isEqualTo: false)
        .limit(100)
        .get();
    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'readByAdmin': true});
    }
    batch.set(_chatRef(userId), {'unreadCount': 0}, SetOptions(merge: true));
    await batch.commit();
  }

  MessageThread _threadFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final timestamp = data['lastMessageAt'];
    final lastMessageAt = timestamp is Timestamp
        ? timestamp.toDate()
        : DateTime.tryParse(data['last_message_at']?.toString() ?? '') ??
              DateTime.now();

    return MessageThread(
      // The parent chat document id is the path segment used for
      // chat/{userId}/messages and chat/{userId}/mails. Do not prefer a
      // stored userId field here because older documents may contain a backend
      // id and that makes the UI subscribe to the wrong subcollections.
      userId: doc.id,
      userName: (data['userName'] as String?) ?? 'User',
      userEmail: data['userEmail'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      photoUrl: data['photoUrl'] as String?,
      lastMessage: (data['lastMessage'] as String?) ?? '',
      lastMessageAt: lastMessageAt,
      unreadCount: (data['unreadCount'] as int?) ?? 0,
    );
  }

  String? _timestampToIso(dynamic timestamp, {String? fallback}) {
    if (timestamp is Timestamp) {
      return timestamp.toDate().toUtc().toIso8601String();
    }
    final parsed = DateTime.tryParse(timestamp?.toString() ?? '');
    if (parsed != null) return parsed.toUtc().toIso8601String();
    final fallbackParsed = DateTime.tryParse(fallback ?? '');
    if (fallbackParsed != null) return fallbackParsed.toUtc().toIso8601String();
    return null;
  }

  Message messageFromFirestore(String id, Map<String, dynamic> data) {
    final senderRole = data['senderRole'] as String? ?? 'user';
    final rawType =
        (data['type'] ?? data['messageType'] ?? data['message_type'])
            ?.toString()
            .trim();
    final messageType = rawType == 'static' ? 'static' : 'live';
    final createdAt =
        _timestampToIso(
          // Android image messages use `timestamp`; older/admin docs may use
          // `createdAt`. Prefer timestamp so sorting matches the mobile app.
          data['timestamp'] ?? data['createdAt'] ?? data['created_at'],
          fallback: data['updatedAt']?.toString(),
        ) ??
        DateTime.now().toUtc().toIso8601String();
    final attachmentUrl = data['imageUrl']?.toString().trim().isNotEmpty == true
        ? data['imageUrl']?.toString().trim()
        : data['attachmentUrl']?.toString().trim().isNotEmpty == true
        ? data['attachmentUrl']?.toString().trim()
        : data['attachment_url']?.toString().trim().isNotEmpty == true
        ? data['attachment_url']?.toString().trim()
        : null;

    return Message(
      id: (data['id'] as String?) ?? id,
      direction: senderRole == 'admin' ? 'admin_to_user' : 'user_to_admin',
      // Android sends image messages as `type: image`; those are still live
      // chat messages and must not be filtered out by the admin live tab.
      messageType: messageType,
      subject: data['subject'] as String?,
      body:
          data['content']?.toString() ??
          data['body']?.toString() ??
          data['message']?.toString() ??
          data['text']?.toString() ??
          '',
      attachmentUrl: attachmentUrl,
      isRead: senderRole == 'admin'
          ? (data['readByUser'] as bool? ?? false)
          : (data['readByAdmin'] as bool? ?? false),
      createdAt: createdAt,
    );
  }

  Message mailFromFirestore(String id, Map<String, dynamic> data) {
    final senderRole = data['senderRole'] as String? ?? 'user';
    final createdAt =
        _timestampToIso(data['timestamp'] ?? data['createdAt']) ??
        DateTime.now().toUtc().toIso8601String();

    return Message(
      id: (data['id'] as String?) ?? id,
      direction: senderRole == 'admin' ? 'admin_to_user' : 'user_to_admin',
      messageType: 'static',
      subject: data['subject'] as String?,
      body: (data['content'] as String?) ?? (data['body'] as String? ?? ''),
      isRead: data['read'] as bool? ?? false,
      createdAt: createdAt,
    );
  }
}
