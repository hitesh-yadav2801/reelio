import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/upload/domain/repositories/upload_repository.dart';

@lazySingleton
class CancelUploadUseCase extends UseCase<FutureEitherVoid, NoParams> {
  CancelUploadUseCase(this._uploadRepository);

  final UploadRepository _uploadRepository;

  @override
  FutureEitherVoid call(NoParams params) {
    return _uploadRepository.cancelActiveUpload();
  }
}
