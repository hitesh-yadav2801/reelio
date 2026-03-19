import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/features/profile/domain/entities/profile_user.dart';
import 'package:reelio/features/profile/domain/repositories/profile_repository.dart';

part 'edit_profile_state.dart';

@injectable
class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(this._profileRepository)
    : super(const EditProfileState.initial());

  final ProfileRepository _profileRepository;

  Future<void> initialize({ProfileUser? initialProfile}) async {
    if (initialProfile != null) {
      emit(EditProfileState.ready(initialProfile));
      return;
    }

    emit(state.copyWith(status: EditProfileStatus.loading, clearError: true));
    final result = await _profileRepository.getCurrentProfile();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: EditProfileStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (profile) => emit(EditProfileState.ready(profile)),
    );
  }

  void displayNameChanged(String value) {
    emit(
      state.copyWith(
        status: EditProfileStatus.ready,
        displayName: value,
        clearError: true,
      ),
    );
  }

  void bioChanged(String value) {
    emit(
      state.copyWith(
        status: EditProfileStatus.ready,
        bio: value,
        clearError: true,
      ),
    );
  }

  Future<void> saveChanges() async {
    if (!state.canSave) {
      emit(
        state.copyWith(
          status: EditProfileStatus.error,
          errorMessage: 'Display name is required.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: EditProfileStatus.saving, clearError: true));

    final result = await _profileRepository.updateProfile(
      displayName: state.displayName.trim(),
      bio: state.bio.trim(),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: EditProfileStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (profile) => emit(EditProfileState.success(profile)),
    );
  }
}
