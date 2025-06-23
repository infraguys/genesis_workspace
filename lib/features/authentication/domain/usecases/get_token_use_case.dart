import 'package:genesis_workspace/services/token_storage/token_storage.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetTokenUseCase {
  final tokenStorage = TokenStorageFactory.create();

  GetTokenUseCase();

  Future<String?> call({required String email, required String token}) async {
    return tokenStorage.getToken();
  }
}
