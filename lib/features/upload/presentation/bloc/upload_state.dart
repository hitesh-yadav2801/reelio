part of 'upload_cubit.dart';

enum UploadStatus {
  initial,
  picking,
  picked,
  uploading,
  success,
  canceled,
  error,
}

class UploadState extends Equatable {
  const UploadState({
    required this.status,
    required this.progress,
    required this.caption,
    this.videoFile,
    this.thumbnailFile,
    this.videoDuration = Duration.zero,
    this.errorMessage,
  });

  const UploadState.initial()
    : status = UploadStatus.initial,
      progress = 0,
      caption = '',
      videoFile = null,
      thumbnailFile = null,
      videoDuration = Duration.zero,
      errorMessage = null;

  final UploadStatus status;
  final double progress;
  final String caption;
  final File? videoFile;
  final File? thumbnailFile;
  final Duration videoDuration;
  final String? errorMessage;

  bool get canSubmit =>
      videoFile != null &&
      thumbnailFile != null &&
      status != UploadStatus.uploading;

  UploadState copyWith({
    UploadStatus? status,
    double? progress,
    String? caption,
    File? videoFile,
    File? thumbnailFile,
    Duration? videoDuration,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UploadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      caption: caption ?? this.caption,
      videoFile: videoFile ?? this.videoFile,
      thumbnailFile: thumbnailFile ?? this.thumbnailFile,
      videoDuration: videoDuration ?? this.videoDuration,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    progress,
    caption,
    videoFile?.path,
    thumbnailFile?.path,
    videoDuration,
    errorMessage,
  ];
}
