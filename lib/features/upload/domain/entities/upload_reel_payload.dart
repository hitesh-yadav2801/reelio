import 'dart:io';

import 'package:equatable/equatable.dart';

class UploadReelPayload extends Equatable {
  const UploadReelPayload({
    required this.videoFile,
    required this.caption,
    required this.userId,
    required this.username,
    this.displayName,
    this.userAvatarUrl,
  });

  final File videoFile;
  final String caption;
  final String userId;
  final String username;
  final String? displayName;
  final String? userAvatarUrl;

  @override
  List<Object?> get props => [
    videoFile.path,
    caption,
    userId,
    username,
    displayName,
    userAvatarUrl,
  ];
}
