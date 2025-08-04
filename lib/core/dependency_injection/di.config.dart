// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:genesis_workspace/core/dependency_injection/core_module.dart'
    as _i440;
import 'package:genesis_workspace/data/messages/datasources/messages_data_source.dart'
    as _i253;
import 'package:genesis_workspace/data/messages/datasources/messages_data_source_impl.dart'
    as _i695;
import 'package:genesis_workspace/data/messages/repositories_impl/messages_repository_impl.dart'
    as _i971;
import 'package:genesis_workspace/data/real_time_events/datasources/real_time_events_data_soure.dart'
    as _i735;
import 'package:genesis_workspace/data/real_time_events/repositories_impl/real_time_events_repository_impl.dart'
    as _i506;
import 'package:genesis_workspace/data/users/datasources/users_remote_data_source.dart'
    as _i451;
import 'package:genesis_workspace/data/users/repositories_impl/users_repository_impl.dart'
    as _i675;
import 'package:genesis_workspace/domain/messages/repositories/messages_repository.dart'
    as _i857;
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart'
    as _i207;
import 'package:genesis_workspace/domain/messages/usecases/send_message_use_case.dart'
    as _i116;
import 'package:genesis_workspace/domain/messages/usecases/update_messages_flags_use_case.dart'
    as _i664;
import 'package:genesis_workspace/domain/real_time_events/repositories/real_time_events_repository.dart'
    as _i703;
import 'package:genesis_workspace/domain/real_time_events/usecases/delete_queue_use_case.dart'
    as _i435;
import 'package:genesis_workspace/domain/real_time_events/usecases/get_events_by_queue_id_use_case.dart'
    as _i1039;
import 'package:genesis_workspace/domain/real_time_events/usecases/register_queue_use_case.dart'
    as _i477;
import 'package:genesis_workspace/domain/users/repositories/users_repository.dart'
    as _i125;
import 'package:genesis_workspace/domain/users/usecases/get_all_presences_use_case.dart'
    as _i837;
import 'package:genesis_workspace/domain/users/usecases/get_own_user_use_case.dart'
    as _i547;
import 'package:genesis_workspace/domain/users/usecases/get_subscribed_channels_use_case.dart'
    as _i988;
import 'package:genesis_workspace/domain/users/usecases/get_topics_use_case.dart'
    as _i699;
import 'package:genesis_workspace/domain/users/usecases/get_user_by_id_use_case.dart'
    as _i773;
import 'package:genesis_workspace/domain/users/usecases/get_users_use_case.dart'
    as _i194;
import 'package:genesis_workspace/domain/users/usecases/set_typing_use_case.dart'
    as _i487;
import 'package:genesis_workspace/domain/users/usecases/update_presence_use_case.dart'
    as _i832;
import 'package:genesis_workspace/features/authentication/data/datasources/auth_remote_data_source.dart'
    as _i672;
import 'package:genesis_workspace/features/authentication/data/repositories_impl/auth_repository_impl.dart'
    as _i44;
import 'package:genesis_workspace/features/authentication/domain/repositories/auth_repository.dart'
    as _i1022;
import 'package:genesis_workspace/features/authentication/domain/usecases/delete_token_use_case.dart'
    as _i433;
import 'package:genesis_workspace/features/authentication/domain/usecases/fetch_api_key_use_case.dart'
    as _i799;
import 'package:genesis_workspace/features/authentication/domain/usecases/get_token_use_case.dart'
    as _i75;
import 'package:genesis_workspace/features/authentication/domain/usecases/save_token_use_case.dart'
    as _i643;
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart'
    as _i862;
import 'package:genesis_workspace/features/messages/bloc/messages_cubit.dart'
    as _i592;
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart'
    as _i766;
import 'package:genesis_workspace/features/real_time/bloc/real_time_cubit.dart'
    as _i573;
import 'package:genesis_workspace/services/localization/localization_service.dart'
    as _i435;
import 'package:genesis_workspace/services/real_time/real_time_service.dart'
    as _i82;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final coreModule = _$CoreModule();
    gh.factory<_i75.GetTokenUseCase>(() => _i75.GetTokenUseCase());
    gh.factory<_i207.GetMessagesUseCase>(() => _i207.GetMessagesUseCase());
    gh.factory<_i1039.GetEventsByQueueIdUseCase>(
      () => _i1039.GetEventsByQueueIdUseCase(),
    );
    gh.factory<_i477.RegisterQueueUseCase>(() => _i477.RegisterQueueUseCase());
    gh.lazySingleton<_i361.Dio>(() => coreModule.dio());
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => coreModule.secureStorage(),
    );
    gh.lazySingleton<_i573.RealTimeCubit>(() => _i573.RealTimeCubit());
    gh.lazySingleton<_i592.MessagesCubit>(() => _i592.MessagesCubit());
    gh.lazySingleton<_i766.ProfileCubit>(() => _i766.ProfileCubit());
    gh.lazySingleton<_i862.AuthCubit>(() => _i862.AuthCubit());
    gh.lazySingleton<_i82.RealTimeService>(() => _i82.RealTimeService());
    gh.lazySingleton<_i435.LocalizationService>(
      () => _i435.LocalizationService(),
    );
    gh.factory<_i451.UsersRemoteDataSource>(
      () => _i451.UsersRemoteDataSourceImpl(),
    );
    gh.factory<_i857.MessagesRepository>(() => _i971.MessagesRepositoryImpl());
    gh.factory<_i253.MessagesDataSource>(() => _i695.MessagesDataSourceImpl());
    gh.factory<_i703.RealTimeEventsRepository>(
      () => _i506.RealTimeEventsRepositoryImpl(),
    );
    gh.factory<_i672.AuthRemoteDataSource>(
      () => _i672.AuthRemoteDataSourceImpl(),
    );
    gh.factory<_i735.RealTimeEventsDataSource>(
      () => _i735.RealTimeEventsDataSourceImpl(),
    );
    gh.factory<_i125.UsersRepository>(
      () => _i675.UsersRepositoryImpl(gh<_i451.UsersRemoteDataSource>()),
    );
    gh.factory<_i435.DeleteQueueUseCase>(
      () => _i435.DeleteQueueUseCase(gh<_i703.RealTimeEventsRepository>()),
    );
    gh.factory<_i664.UpdateMessagesFlagsUseCase>(
      () => _i664.UpdateMessagesFlagsUseCase(gh<_i857.MessagesRepository>()),
    );
    gh.factory<_i116.SendMessageUseCase>(
      () => _i116.SendMessageUseCase(gh<_i857.MessagesRepository>()),
    );
    gh.factory<_i487.SetTypingUseCase>(
      () => _i487.SetTypingUseCase(gh<_i125.UsersRepository>()),
    );
    gh.factory<_i547.GetOwnUserUseCase>(
      () => _i547.GetOwnUserUseCase(gh<_i125.UsersRepository>()),
    );
    gh.factory<_i699.GetTopicsUseCase>(
      () => _i699.GetTopicsUseCase(gh<_i125.UsersRepository>()),
    );
    gh.factory<_i773.GetUserByIdUseCase>(
      () => _i773.GetUserByIdUseCase(gh<_i125.UsersRepository>()),
    );
    gh.factory<_i194.GetUsersUseCase>(
      () => _i194.GetUsersUseCase(gh<_i125.UsersRepository>()),
    );
    gh.factory<_i832.UpdatePresenceUseCase>(
      () => _i832.UpdatePresenceUseCase(gh<_i125.UsersRepository>()),
    );
    gh.factory<_i988.GetSubscribedChannelsUseCase>(
      () => _i988.GetSubscribedChannelsUseCase(gh<_i125.UsersRepository>()),
    );
    gh.factory<_i837.GetAllPresencesUseCase>(
      () => _i837.GetAllPresencesUseCase(gh<_i125.UsersRepository>()),
    );
    gh.lazySingleton<_i1022.AuthRepository>(
      () => _i44.AuthRepositoryImpl(gh<_i672.AuthRemoteDataSource>()),
    );
    gh.factory<_i433.DeleteTokenUseCase>(
      () => _i433.DeleteTokenUseCase(gh<_i1022.AuthRepository>()),
    );
    gh.factory<_i799.FetchApiKeyUseCase>(
      () => _i799.FetchApiKeyUseCase(gh<_i1022.AuthRepository>()),
    );
    gh.factory<_i643.SaveTokenUseCase>(
      () => _i643.SaveTokenUseCase(gh<_i1022.AuthRepository>()),
    );
    return this;
  }
}

class _$CoreModule extends _i440.CoreModule {}
