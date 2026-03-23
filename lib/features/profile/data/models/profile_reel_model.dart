import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reelio/features/profile/domain/entities/profile_reel.dart';

class ProfileReelModel extends ProfileReel {
  const ProfileReelModel({
    required super.id,
    required super.videoUrl,
    required super.caption,
    required super.likesCount,
    required super.commentsCount,
    required super.createdAt,
    super.thumbnailUrl,
  });

  factory ProfileReelModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    return ProfileReelModel(
      id: doc.id,
      videoUrl: (data['videoUrl'] as String? ?? '').trim(),
      thumbnailUrl: _nullableText(data['thumbnailUrl'] as String?),
      caption: (data['caption'] as String? ?? '').trim(),
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

  static String? _nullableText(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }
}
