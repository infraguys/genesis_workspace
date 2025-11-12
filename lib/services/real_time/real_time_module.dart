import 'package:dio/dio.dart';
import 'package:genesis_workspace/data/real_time_events/api/real_time_events_api_client.dart';
import 'package:genesis_workspace/data/real_time_events/datasources/real_time_events_data_soure.dart';
import 'package:genesis_workspace/data/real_time_events/repositories_impl/real_time_events_repository_impl.dart';
import 'package:genesis_workspace/domain/real_time_events/repositories/real_time_events_repository.dart';
import 'package:genesis_workspace/services/real_time/per_org_dio_factory.dart';
import 'package:injectable/injectable.dart';

abstract class RealTimeRepositoryFactory {
  RealTimeEventsRepository create(Dio dio);
}

class _RealTimeRepositoryFactory implements RealTimeRepositoryFactory {
  @override
  RealTimeEventsRepository create(Dio dio) {
    final RealTimeEventsApiClient apiClient = RealTimeEventsApiClient(dio);
    final RealTimeEventsDataSource dataSource = RealTimeEventsDataSourceImpl(apiClient);
    return RealTimeEventsRepositoryImpl(dataSource);
  }
}

@module
abstract class RealTimeModule {
  @lazySingleton
  RealTimeRepositoryFactory realTimeRepositoryFactory() => _RealTimeRepositoryFactory();

  @lazySingleton
  RealTimeEventsRepository realTimeEventsRepository(
    RealTimeRepositoryFactory repositoryFactory,
    Dio dio,
  ) {
    return repositoryFactory.create(dio);
  }

  @lazySingleton
  PerOrganizationDioFactory perOrganizationDioFactory() => const PerOrganizationDioFactory();
}
