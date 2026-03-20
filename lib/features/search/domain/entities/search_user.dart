import 'package:equatable/equatable.dart';

class SearchUser extends Equatable {
  const SearchUser({
    required this.uid,
    required this.displayName,
    required this.username,
    this.photoUrl,
    this.isFollowing = false,
    this.isUpdating = false,
  });

  final String uid;
  final String displayName;
  final String username;
  final String? photoUrl;
  final bool isFollowing;
  final bool isUpdating;

  SearchUser copyWith({
    String? uid,
    String? displayName,
    String? username,
    String? photoUrl,
    bool? isFollowing,
    bool? isUpdating,
  }) {
    return SearchUser(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      isFollowing: isFollowing ?? this.isFollowing,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    displayName,
    username,
    photoUrl,
    isFollowing,
    isUpdating,
  ];
}
