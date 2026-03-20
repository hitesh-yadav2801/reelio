import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reelio/features/search/domain/entities/search_user.dart';

class SearchUserModel extends SearchUser {
  const SearchUserModel({
    required super.uid,
    required super.displayName,
    required super.username,
    super.photoUrl,
    super.isFollowing,
    super.isUpdating,
  });

  factory SearchUserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required bool isFollowing,
  }) {
    final data = doc.data() ?? <String, dynamic>{};
    return SearchUserModel(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? 'Reelio User',
      username: data['username'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      isFollowing: isFollowing,
    );
  }
}
