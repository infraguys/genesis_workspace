import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/data/messages/datasources/messages_data_source.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_response_entity.dart';
import 'package:genesis_workspace/domain/messages/repositories/messages_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: MessagesRepository)
class MessagesRepositoryImpl implements MessagesRepository {
  final MessagesDataSource dataSource = getIt<MessagesDataSource>();

  @override
  Future<MessagesResponseEntity> getMessages(MessagesRequestEntity body) async {
    try {
      final dto = await dataSource.getMessages(body.toDto());
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
