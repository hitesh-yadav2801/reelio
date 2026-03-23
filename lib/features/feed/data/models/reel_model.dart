import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reelio/features/feed/domain/entities/reel.dart';

class ReelModel extends Reel {
  const ReelModel({
    required super.id,
    required super.userId,
    required super.username,
    required super.videoUrl,
    required super.createdAt,
    super.userAvatarUrl,
    super.thumbnailUrl,
    super.caption,
    super.likesCount,
    super.commentsCount,
  });

  factory ReelModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};

    return ReelModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      username: _safeUsername(data['username'] as String?),
      userAvatarUrl: _safeNullableText(data['userAvatarUrl'] as String?),
      videoUrl: _safeText(data['videoUrl'] as String?),
      thumbnailUrl: _safeNullableText(data['thumbnailUrl'] as String?),
      caption: _safeText(data['caption'] as String?),
      likesCount: _toInt(data['likesCount']),
      commentsCount: _toInt(data['commentsCount']),
      createdAt: _toDateTime(data['createdAt']),
    );
  }

  static int _toInt(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
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

  static String _safeText(String? value) => (value ?? '').trim();

  static String? _safeNullableText(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }

  static String _safeUsername(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? 'reelio_user' : normalized;
  }
}
