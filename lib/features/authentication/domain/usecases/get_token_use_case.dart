import 'package:genesis_workspace/services/token_storage/token_storage.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetTokenUseCase {
  final TokenStorage tokenStorage;

  GetTokenUseCase(this.tokenStorage);

  Future<String?> call(String baseUrl) async {
    return tokenStorage.getToken(baseUrl);
  }
}
