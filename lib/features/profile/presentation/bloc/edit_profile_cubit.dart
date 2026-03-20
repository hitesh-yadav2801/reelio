import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/features/profile/domain/entities/profile_user.dart';
import 'package:reelio/features/profile/domain/usecases/get_current_profile_usecase.dart';
import 'package:reelio/features/profile/domain/usecases/update_profile_usecase.dart';

part 'edit_profile_state.dart';

@injectable
class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(this._getCurrentProfileUseCase, this._updateProfileUseCase)
    : super(const EditProfileState.initial());

  final GetCurrentProfileUseCase _getCurrentProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  Future<void> initialize({ProfileUser? initialProfile}) async {
    if (initialProfile != null) {
      emit(EditProfileState.ready(initialProfile));
      return;
    }

    emit(state.copyWith(status: EditProfileStatus.loading, clearError: true));
    final result = await _getCurrentProfileUseCase(const NoParams());

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

    final result = await _updateProfileUseCase(
      UpdateProfileParams(
        displayName: state.displayName.trim(),
        bio: state.bio.trim(),
      ),
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
