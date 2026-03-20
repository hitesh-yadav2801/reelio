import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reelio/features/auth/domain/entities/reelio_user.dart';

class UserModel extends ReelioUser {
  const UserModel({
    required super.uid,
    required super.email,
    super.username,
    super.displayName,
    super.photoUrl,
    super.bio,
    super.followerCount,
    super.followingCount,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc, {User? firebaseUser}) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? firebaseUser?.email ?? '',
      username: data['username'] as String? ?? '',
      displayName: data['displayName'] as String? ?? firebaseUser?.displayName,
      photoUrl: data['photoUrl'] as String? ?? firebaseUser?.photoURL,
      bio: data['bio'] as String?,
      followerCount: (data['followerCount'] as num?)?.toInt() ?? 0,
      followingCount: (data['followingCount'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'displayName': displayName,
      'displayNameLower': displayName?.toLowerCase(),
      'photoUrl': photoUrl,
      'bio': bio,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
