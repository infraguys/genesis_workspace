import 'package:genesis_workspace/services/token_storage/token_storage.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetSessionIdUseCase {
  final TokenStorage _tokenStorage;

  GetSessionIdUseCase(this._tokenStorage);

  Future<String?> call(String baseUrl) async {
    return _tokenStorage.getSessionId(baseUrl);
  }
}
