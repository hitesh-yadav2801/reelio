import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reelio/core/di/injection.dart';
import 'package:reelio/core/theme/app_colors.dart';
import 'package:reelio/core/theme/app_spacing.dart';
import 'package:reelio/core/theme/app_typography.dart';
import 'package:reelio/features/comments/presentation/bloc/comments_cubit.dart';
import 'package:reelio/features/comments/presentation/widgets/comment_input_field.dart';
import 'package:reelio/features/comments/presentation/widgets/comment_tile.dart';

class CommentsBottomSheet extends StatelessWidget {
  const CommentsBottomSheet({
    required this.reelId,
    required this.onCommentPosted,
    super.key,
  });

  final String reelId;
  final VoidCallback onCommentPosted;

  static Future<void> show(
    BuildContext context, {
    required String reelId,
    required VoidCallback onCommentPosted,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.colorSurfaceElevated,
      builder: (_) =>
          CommentsBottomSheet(reelId: reelId, onCommentPosted: onCommentPosted),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CommentsCubit>()..loadInitial(reelId),
      child: _CommentsSheetContent(onCommentPosted: onCommentPosted),
    );
  }
}

class _CommentsSheetContent extends StatefulWidget {
  const _CommentsSheetContent({required this.onCommentPosted});

  final VoidCallback onCommentPosted;

  @override
  State<_CommentsSheetContent> createState() => _CommentsSheetContentState();
}

class _CommentsSheetContentState extends State<_CommentsSheetContent> {
  late final ScrollController _scrollController;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    if (_scrollController.position.extentAfter < 240) {
      context.read<CommentsCubit>().loadMore();
    }
  }

  Future<void> _submitComment() async {
    final posted = await context.read<CommentsCubit>().postComment(
      _textController.text,
    );

    if (!posted || !mounted) {
      return;
    }

    _textController.clear();
    widget.onCommentPosted();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommentsCubit, CommentsState>(
      listener: (context, state) {
        if (state.actionErrorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.actionErrorMessage!)));
          context.read<CommentsCubit>().clearActionError();
        }
      },
      builder: (context, state) {
        return SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.72,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space16,
                  AppSpacing.space8,
                  AppSpacing.space16,
                  AppSpacing.space12,
                ),
                child: Row(
                  children: [
                    Text('Comments', style: AppTypography.heading2),
                    const Spacer(),
                    Text(
                      '${state.comments.length}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.colorTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(child: _buildBody(state)),
              const Divider(height: 1),
              CommentInputField(
                controller: _textController,
                isPosting: state.isPosting,
                onSubmit: _submitComment,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(CommentsState state) {
    if ((state.status == CommentsStatus.initial ||
            state.status == CommentsStatus.loading) &&
        state.comments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == CommentsStatus.error && state.comments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.errorMessage ?? 'Unable to load comments.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.space12),
              ElevatedButton(
                onPressed: () {
                  final reelId = state.reelId;
                  if (reelId != null) {
                    context.read<CommentsCubit>().loadInitial(reelId);
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.comments.isEmpty) {
      return Center(
        child: Text(
          'No comments yet. Be the first one.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.colorTextSecondary,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.comments.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.comments.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.space12),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        return CommentTile(comment: state.comments[index]);
      },
    );
  }
}
