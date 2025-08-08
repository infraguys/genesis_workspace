import 'package:genesis_workspace/domain/messages/entities/emoji_reaction_entity.dart';
import 'package:genesis_workspace/domain/messages/repositories/messages_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class AddEmojiReactionUseCase {
  final MessagesRepository _repository;

  AddEmojiReactionUseCase(this._repository);

  Future<EmojiReactionResponseEntity> call(EmojiReactionRequestEntity body) async {
    try {
      return await _repository.addEmojiReaction(body);
    } catch (e) {
      rethrow;
    }
  }
}
