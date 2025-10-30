import 'package:dio/dio.dart';
import 'package:genesis_workspace/domain/real_time_events/repositories/real_time_events_repository.dart';
import 'package:genesis_workspace/domain/real_time_events/usecases/get_events_by_queue_id_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/usecases/register_queue_use_case.dart';
import 'package:genesis_workspace/services/real_time/per_org_dio_factory.dart';
import 'package:genesis_workspace/services/real_time/real_time_module.dart';
import 'package:genesis_workspace/services/token_storage/token_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class OrganizationAuthResolver {
  OrganizationAuthResolver(this.tokenStorage);
  final TokenStorage tokenStorage;

  Future<bool> hasBasicToken(String baseUrl) async {
    final String? token = await tokenStorage.getToken(baseUrl);
    return token != null && token.contains(':');
  }

  Future<bool> hasSessionCookies(String baseUrl) async {
    final String? sid = await tokenStorage.getSessionId(baseUrl);
    final String? csrf = await tokenStorage.getCsrftoken(baseUrl);
    return (sid != null && sid.isNotEmpty) && (csrf != null && csrf.isNotEmpty);
  }
}

abstract class RealTimeConnectionFactory {
  RegisterQueueUseCase createRegisterQueueUseCase({
    required int organizationId,
    required String baseUrl,
  });

  GetEventsByQueueIdUseCase createGetEventsByQueueIdUseCase({
    required int organizationId,
    required String baseUrl,
  });
}

@LazySingleton(as: RealTimeConnectionFactory)
class RealTimeConnectionFactoryImpl implements RealTimeConnectionFactory {
  RealTimeConnectionFactoryImpl(
    this.tokenStorage,
    this._dioFactory,
    RealTimeRepositoryFactory repositoryFactory,
  ) : _repositoryFactory = repositoryFactory;

  final TokenStorage tokenStorage;
  final PerOrganizationDioFactory _dioFactory;
  final RealTimeRepositoryFactory _repositoryFactory;

  final Map<String, RealTimeEventsRepository> _repositoryByBaseUrl =
      <String, RealTimeEventsRepository>{};

  @override
  RegisterQueueUseCase createRegisterQueueUseCase({
    required int organizationId,
    required String baseUrl,
  }) {
    final RealTimeEventsRepository repository = _getOrCreateRepository(baseUrl);
    return RegisterQueueUseCase(repository);
  }

  @override
  GetEventsByQueueIdUseCase createGetEventsByQueueIdUseCase({
    required int organizationId,
    required String baseUrl,
  }) {
    final RealTimeEventsRepository repository = _getOrCreateRepository(baseUrl);
    return GetEventsByQueueIdUseCase(repository);
  }

  RealTimeEventsRepository _getOrCreateRepository(String baseUrl) {
    return _repositoryByBaseUrl.putIfAbsent(baseUrl, () => _buildRepository(baseUrl));
  }

  RealTimeEventsRepository _buildRepository(String baseUrl) {
    final Dio dio = _dioFactory.build(originBaseUrl: baseUrl, tokenStorage: tokenStorage);
    return _repositoryFactory.create(dio);
  }
}
