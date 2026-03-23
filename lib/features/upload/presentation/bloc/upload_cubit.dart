import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/features/profile/domain/usecases/get_current_profile_usecase.dart';
import 'package:reelio/features/upload/domain/entities/upload_reel_payload.dart';
import 'package:reelio/features/upload/domain/usecases/cancel_upload_usecase.dart';
import 'package:reelio/features/upload/domain/usecases/submit_reel_usecase.dart';
import 'package:reelio/shared/services/reel_upload_remote_config_service.dart';
import 'package:reelio/shared/services/video_thumbnail_service.dart';
import 'package:video_player/video_player.dart';

part 'upload_state.dart';

@injectable
class UploadCubit extends Cubit<UploadState> {
  UploadCubit(
    this._submitReelUseCase,
    this._cancelUploadUseCase,
    this._getCurrentProfileUseCase,
    this._thumbnailService,
    this._reelUploadRemoteConfigService,
    this._firebaseAuth,
  ) : super(const UploadState.initial());

  final SubmitReelUseCase _submitReelUseCase;
  final CancelUploadUseCase _cancelUploadUseCase;
  final GetCurrentProfileUseCase _getCurrentProfileUseCase;
  final VideoThumbnailService _thumbnailService;
  final ReelUploadRemoteConfigService _reelUploadRemoteConfigService;
  final FirebaseAuth _firebaseAuth;

  final ImagePicker _picker = ImagePicker();
  static const int _maxCaptionLength = 150;
  static const Duration _maxVideoDuration = Duration(seconds: 60);
  bool _canceledByUser = false;

  Future<void> pickVideo() async {
    if (state.status == UploadStatus.uploading ||
        state.status == UploadStatus.picking) {
      return;
    }

    emit(state.copyWith(status: UploadStatus.picking, clearError: true));

    try {
      final picked = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 60),
      );

      if (picked == null) {
        emit(state.copyWith(status: UploadStatus.initial, clearError: true));
        return;
      }

      final videoFile = File(picked.path);
      final fileSizeBytes = await videoFile.length();
      final maxFileSizeBytes =
          _reelUploadRemoteConfigService.maxReelFileSizeBytes;
      if (fileSizeBytes > maxFileSizeBytes) {
        emit(
          state.copyWith(
            status: UploadStatus.error,
            errorMessage:
                'Video is too large. Max allowed size is '
                '${_reelUploadRemoteConfigService.maxReelFileSizeMb} MB.',
          ),
        );
        return;
      }

      final duration = await _readDuration(videoFile);
      if (duration > _maxVideoDuration) {
        emit(
          state.copyWith(
            status: UploadStatus.error,
            errorMessage: 'Videos must be 60 seconds or shorter.',
          ),
        );
        return;
      }

      final thumbnail = await _thumbnailService.generateThumbnail(
        videoFile: videoFile,
      );

      emit(
        state.copyWith(
          status: UploadStatus.picked,
          videoFile: videoFile,
          thumbnailFile: thumbnail,
          videoDuration: duration,
          caption: '',
          progress: 0,
          clearError: true,
        ),
      );
    } on Exception catch (error) {
      emit(
        state.copyWith(
          status: UploadStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void captionChanged(String value) {
    final trimmed = value.length > _maxCaptionLength
        ? value.substring(0, _maxCaptionLength)
        : value;
    emit(state.copyWith(caption: trimmed));
  }

  Future<void> submit() async {
    if (!state.canSubmit || state.status == UploadStatus.uploading) {
      return;
    }

    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      emit(
        state.copyWith(
          status: UploadStatus.error,
          errorMessage: 'You need to sign in before uploading.',
        ),
      );
      return;
    }

    final profileResult = await _getCurrentProfileUseCase(const NoParams());
    final profile = profileResult.fold((_) => null, (profile) => profile);
    final username = profile?.username.trim() ?? '';

    if (username.isEmpty) {
      emit(
        state.copyWith(
          status: UploadStatus.error,
          errorMessage: 'Username is required before posting a reel.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: UploadStatus.uploading,
        progress: 0,
        clearError: true,
      ),
    );
    _canceledByUser = false;

    final payload = UploadReelPayload(
      videoFile: state.videoFile!,
      caption: state.caption.trim(),
      userId: currentUser.uid,
      username: username,
      displayName: profile?.displayName ?? currentUser.displayName,
      userAvatarUrl: profile?.photoUrl ?? currentUser.photoURL,
    );

    final result = await _submitReelUseCase(
      SubmitReelParams(
        payload: payload,
        onProgress: (progress) =>
            emit(state.copyWith(progress: progress.clamp(0, 1).toDouble())),
      ),
    );

    result.fold(
      (failure) {
        if (_canceledByUser) {
          emit(
            state.copyWith(
              status: UploadStatus.canceled,
              progress: 0,
              clearError: true,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: UploadStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (_) => emit(
        state.copyWith(
          status: UploadStatus.success,
          progress: 1,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> cancelUpload() async {
    if (state.status != UploadStatus.uploading) {
      return;
    }

    _canceledByUser = true;
    final result = await _cancelUploadUseCase(const NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: UploadStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: UploadStatus.canceled,
          progress: 0,
          clearError: true,
        ),
      ),
    );
  }

  void clearSelection() {
    _canceledByUser = false;
    emit(const UploadState.initial());
  }

  Future<Duration> _readDuration(File file) async {
    final controller = VideoPlayerController.file(file);
    try {
      await controller.initialize();
      return controller.value.duration;
    } finally {
      await controller.dispose();
    }
  }
}
