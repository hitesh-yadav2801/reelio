import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/profile/domain/entities/profile_user.dart';

abstract class ProfileRepository {
  FutureEither<ProfileUser> getCurrentProfile();

  FutureEither<ProfileUser> updateProfile({
    required String displayName,
    required String bio,
  });

  FutureEitherVoid changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
