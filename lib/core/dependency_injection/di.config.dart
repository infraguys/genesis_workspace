// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:genesis_workspace/features/authentication/data/datasources/auth_remote_data_source.dart'
    as _i672;
import 'package:genesis_workspace/features/authentication/data/repositories_impl/auth_repository_impl.dart'
    as _i44;
import 'package:genesis_workspace/features/authentication/domain/repositories/auth_repository.dart'
    as _i1022;
import 'package:genesis_workspace/features/authentication/domain/usecases/fetch_api_key_use_case.dart'
    as _i799;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i1022.AuthRepository>(
      () => _i44.AuthRepositoryImpl(gh<_i672.AuthRemoteDataSource>()),
    );
    gh.factory<_i799.FetchApiKeyUseCase>(
      () => _i799.FetchApiKeyUseCase(gh<_i1022.AuthRepository>()),
    );
    return this;
  }
}
