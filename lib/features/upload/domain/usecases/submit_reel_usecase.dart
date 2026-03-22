import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/upload/domain/entities/upload_reel_payload.dart';
import 'package:reelio/features/upload/domain/repositories/upload_repository.dart';

class SubmitReelParams extends Equatable {
  const SubmitReelParams({
    required this.payload,
    this.onProgress,
  });

  final UploadReelPayload payload;
  final void Function(double progress)? onProgress;

  @override
  List<Object?> get props => [payload];
}

@lazySingleton
class SubmitReelUseCase extends UseCase<FutureEitherVoid, SubmitReelParams> {
  SubmitReelUseCase(this._uploadRepository);

  final UploadRepository _uploadRepository;

  @override
  FutureEitherVoid call(SubmitReelParams params) {
    return _uploadRepository.submitReel(
      params.payload,
      onProgress: params.onProgress,
    );
  }
}
