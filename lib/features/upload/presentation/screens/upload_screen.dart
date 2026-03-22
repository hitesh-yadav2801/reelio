import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reelio/core/di/injection.dart';
import 'package:reelio/core/theme/app_colors.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:reelio/core/theme/app_typography.dart';
import 'package:reelio/features/upload/presentation/bloc/upload_cubit.dart';
import 'package:reelio/features/upload/presentation/widgets/upload_progress_overlay.dart';
import 'package:video_player/video_player.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UploadCubit>(),
      child: const _UploadView(),
    );
  }
}

class _UploadView extends StatefulWidget {
  const _UploadView();

  @override
  State<_UploadView> createState() => _UploadViewState();
}

class _UploadViewState extends State<_UploadView> {
  late final TextEditingController _captionController;
  VideoPlayerController? _videoController;
  String? _currentVideoPath;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController();
  }

  @override
  void dispose() {
    _captionController.dispose();
    _disposeVideoController();
    super.dispose();
  }

  Future<void> _syncVideo(File? videoFile) async {
    final path = videoFile?.path;
    if (path == _currentVideoPath) {
      return;
    }

    _disposeVideoController();
    _currentVideoPath = path;

    if (path == null) {
      return;
    }

    final controller = VideoPlayerController.file(videoFile!);
    _videoController = controller;

    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      if (mounted) {
        setState(() {});
      }
    } on Exception {
      _disposeVideoController();
    }
  }

  void _disposeVideoController() {
    _videoController?.dispose();
    _videoController = null;
    _currentVideoPath = null;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorSurfaceWarm,
      appBar: AppBar(title: const Text('Upload Reel')),
      body: BlocConsumer<UploadCubit, UploadState>(
        listener: (context, state) {
          _syncVideo(state.videoFile);

          if (_captionController.text != state.caption) {
            _captionController.value = TextEditingValue(
              text: state.caption,
              selection: TextSelection.collapsed(offset: state.caption.length),
            );
          }

          if (state.status == UploadStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }

          if (state.status == UploadStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reel posted successfully.')),
            );
            context.read<UploadCubit>().clearSelection();
          }
        },
        builder: (context, state) {
          final isUploading = state.status == UploadStatus.uploading;

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space16,
                  AppSpacing.space16,
                  AppSpacing.space16,
                  AppSpacing.space24,
                ),
                children: [
                  if (state.videoFile == null)
                    _EmptyPickerCard(
                      isPicking: state.status == UploadStatus.picking,
                      onPick: () => context.read<UploadCubit>().pickVideo(),
                    )
                  else
                    _VideoPreviewCard(
                      controller: _videoController,
                      thumbnailFile: state.thumbnailFile,
                      durationLabel: _formatDuration(state.videoDuration),
                      onPickAnother: isUploading
                          ? null
                          : () => context.read<UploadCubit>().pickVideo(),
                    ),
                  const SizedBox(height: AppSpacing.space16),
                  Text(
                    'Caption',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  TextField(
                    controller: _captionController,
                    onChanged: context.read<UploadCubit>().captionChanged,
                    enabled: !isUploading,
                    maxLength: 150,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Share something about this reel...',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    'Video max: 60s',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.colorTextSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isUploading
                              ? null
                              : () => context.read<UploadCubit>().pickVideo(),
                          child: const Text('Choose Video'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: state.canSubmit && !isUploading
                              ? () => context.read<UploadCubit>().submit()
                              : null,
                          child: const Text('Post Reel'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (isUploading)
                UploadProgressOverlay(
                  progress: state.progress,
                  onCancel: () => context.read<UploadCubit>().cancelUpload(),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyPickerCard extends StatelessWidget {
  const _EmptyPickerCard({required this.isPicking, required this.onPick});

  final bool isPicking;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space20),
      decoration: BoxDecoration(
        color: AppColors.colorSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.colorDivider),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.video_collection_rounded,
            size: 48,
            color: AppColors.colorAccentPrimary,
          ),
          const SizedBox(height: AppSpacing.space12),
          Text(
            'Choose a video to upload',
            style: AppTypography.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(
            'We support clips up to 60 seconds from your gallery.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.colorTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space16),
          ElevatedButton.icon(
            onPressed: isPicking ? null : onPick,
            icon: const Icon(Icons.photo_library_rounded),
            label: Text(isPicking ? 'Opening gallery...' : 'Pick Video'),
          ),
        ],
      ),
    );
  }
}

class _VideoPreviewCard extends StatelessWidget {
  const _VideoPreviewCard({
    required this.controller,
    required this.thumbnailFile,
    required this.durationLabel,
    required this.onPickAnother,
  });

  final VideoPlayerController? controller;
  final File? thumbnailFile;
  final String durationLabel;
  final VoidCallback? onPickAnother;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.colorSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.colorDivider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 9 / 16,
              child: controller != null && controller!.value.isInitialized
                  ? VideoPlayer(controller!)
                  : thumbnailFile != null
                  ? Image.file(thumbnailFile!, fit: BoxFit.cover)
                  : const ColoredBox(color: AppColors.colorSurfaceElevated),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space12,
                AppSpacing.space8,
                AppSpacing.space12,
                AppSpacing.space12,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 18,
                    color: AppColors.colorTextSecondary,
                  ),
                  const SizedBox(width: AppSpacing.space4),
                  Text(
                    durationLabel,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.colorTextSecondary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onPickAnother,
                    child: const Text('Choose another'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
