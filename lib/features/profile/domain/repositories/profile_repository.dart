import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/profile/domain/entities/profile_reel.dart';
import 'package:reelio/features/profile/domain/entities/profile_user.dart';
import 'package:reelio/features/profile/domain/entities/public_profile_user.dart';

abstract class ProfileRepository {
  Stream<ProfileUser> observeCurrentProfile();

  FutureEither<ProfileUser> getCurrentProfile();

  FutureEither<ProfileUser> updateProfile({
    required String displayName,
    required String bio,
  });

  FutureEitherVoid changePassword({
    required String currentPassword,
    required String newPassword,
  });

  FutureEither<PublicProfileUser> getProfileByUsername(String username);

  FutureEither<List<ProfileReel>> getReelsByUserId({
    required String userId,
    int limit = 60,
  });

  FutureEither<bool> toggleFollowUser({
    required String targetUserId,
    required bool currentlyFollowing,
  });
}
