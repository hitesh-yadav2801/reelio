import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reelio/features/comments/domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.userId,
    required super.username,
    required super.text,
    required super.createdAt,
    super.userAvatarUrl,
  });

  factory CommentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    return CommentModel(
      id: doc.id,
      userId: (data['userId'] as String? ?? '').trim(),
      username: _safeUsername(data['username'] as String?),
      userAvatarUrl: _safeNullableText(data['userAvatarUrl'] as String?),
      text: (data['text'] as String? ?? '').trim(),
      createdAt: _toDateTime(data['createdAt']),
    );
  }

  static DateTime _toDateTime(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static String _safeUsername(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? 'reelio_user' : normalized;
  }

  static String? _safeNullableText(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }
}
