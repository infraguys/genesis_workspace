import 'package:dio/dio.dart';
import 'package:genesis_workspace/domain/messages/entities/upload_file_entity.dart';
import 'package:genesis_workspace/domain/messages/repositories/messages_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UploadFileUseCase {
  final MessagesRepository _repository;
  UploadFileUseCase(this._repository);

  Future<UploadFileResponseEntity> call(
    UploadFileRequestEntity body, {
    Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _repository.uploadFile(body, onProgress: onProgress, cancelToken: cancelToken);
    } catch (e) {
      rethrow;
    }
  }
}
