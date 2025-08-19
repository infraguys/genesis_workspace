import 'package:genesis_workspace/services/token_storage/token_storage.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetSessionIdUseCase {
  final _tokenStorage = TokenStorageFactory.create();

  GetSessionIdUseCase();

  Future<String?> call() async {
    return _tokenStorage.getSessionId();
  }
}
