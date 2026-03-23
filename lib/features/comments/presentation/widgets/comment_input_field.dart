import 'package:flutter/material.dart';
import 'package:reelio/core/theme/app_spacing.dart';

class CommentInputField extends StatelessWidget {
  const CommentInputField({
    required this.controller,
    required this.isPosting,
    required this.onSubmit,
    super.key,
  });

  final TextEditingController controller;
  final bool isPosting;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space12,
          AppSpacing.space8,
          AppSpacing.space12,
          AppSpacing.space8,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                maxLength: 220,
                enabled: !isPosting,
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: 'Add a comment...',
                ),
                onSubmitted: (_) => onSubmit(),
              ),
            ),
            const SizedBox(width: AppSpacing.space8),
            IconButton(
              onPressed: isPosting ? null : onSubmit,
              icon: isPosting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              tooltip: 'Post comment',
            ),
          ],
        ),
      ),
    );
  }
}
