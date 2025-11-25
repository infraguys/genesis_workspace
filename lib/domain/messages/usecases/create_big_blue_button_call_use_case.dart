import 'package:genesis_workspace/domain/messages/entities/big_blue_button_call_entity.dart';
import 'package:genesis_workspace/domain/messages/repositories/messages_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreateBigBlueButtonCallUseCase {
  final MessagesRepository _repository;
  CreateBigBlueButtonCallUseCase(this._repository);

  Future<BigBlueButtonCallResponseEntity> call(BigBlueButtonCallRequestEntity body) async {
    final response = await _repository.createBigBlueButtonCall(body);
    return response;
  }
}
