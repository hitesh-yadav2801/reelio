import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/features/profile/domain/entities/profile_user.dart';
import 'package:reelio/features/profile/domain/repositories/profile_repository.dart';

part 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._profileRepository) : super(const ProfileState.initial());

  final ProfileRepository _profileRepository;

  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading, clearError: true));
    final result = await _profileRepository.getCurrentProfile();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (profile) => emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          user: profile,
          clearError: true,
        ),
      ),
    );
  }

  void profileUpdated(ProfileUser user) {
    emit(
      state.copyWith(
        status: ProfileStatus.loaded,
        user: user,
        clearError: true,
      ),
    );
  }
}
