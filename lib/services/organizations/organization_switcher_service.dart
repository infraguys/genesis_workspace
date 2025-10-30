import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/core_module.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/domain/organizations/entities/organization_entity.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:genesis_workspace/services/token_storage/token_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class OrganizationSwitcherService {
  OrganizationSwitcherService(this._sharedPreferences, this._tokenStorage, this._dioFactory);

  final SharedPreferences _sharedPreferences;
  final TokenStorage _tokenStorage;
  final DioFactory _dioFactory;

  Future<void> selectOrganization(OrganizationEntity organization) async {
    final String normalizedBaseUrl = organization.baseUrl.trim();

    AppConstants.setBaseUrl(normalizedBaseUrl);
    AppConstants.setSelectedOrganizationId(organization.id);

    await _sharedPreferences.setString(SharedPrefsKeys.baseUrl, normalizedBaseUrl);
    await _sharedPreferences.setInt(SharedPrefsKeys.selectedOrganizationId, organization.id);

    // final Dio dio = _dioFactory.build(
    //   baseUrl: normalizedBaseUrl,
    //   sharedPreferences: _sharedPreferences,
    //   tokenStorage: _tokenStorage,
    // );

    // if (getIt.isRegistered<Dio>()) {
    //   getIt.resetLazySingleton<Dio>(
    //     instance: dio,
    //     disposingFunction: (previous) => previous.close(force: true),
    //   );
    // } else {
    //   getIt.registerSingleton(dio);
    // }

    final AuthCubit authCubit = getIt<AuthCubit>();
    await authCubit.refreshAuthorizationForCurrentOrganization();
  }
}
