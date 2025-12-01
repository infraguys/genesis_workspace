import 'package:genesis_workspace/services/token_storage/token_storage.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetCsrftokenUseCase {
  final TokenStorage _tokenStorage;

  GetCsrftokenUseCase(this._tokenStorage);

  Future<String?> call(String baseUrl) async {
    return _tokenStorage.getCsrftoken(baseUrl);
  }
}
