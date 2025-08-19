import 'package:genesis_workspace/services/token_storage/token_storage.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetCsrftokenUseCase {
  final _tokenStorage = TokenStorageFactory.create();

  GetCsrftokenUseCase();

  Future<String?> call() async {
    return _tokenStorage.getCsrftoken();
  }
}
