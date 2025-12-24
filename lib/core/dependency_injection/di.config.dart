// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i163;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:genesis_workspace/core/dependency_injection/core_module.dart'
    as _i440;
import 'package:genesis_workspace/data/all_chats/dao/folder_dao.dart' as _i483;
import 'package:genesis_workspace/data/all_chats/dao/folder_item_dao.dart'
    as _i909;
import 'package:genesis_workspace/data/all_chats/dao/pinned_chats_dao.dart'
    as _i691;
import 'package:genesis_workspace/data/all_chats/datasources/folder_items_remote_data_source.dart'
    as _i467;
import 'package:genesis_workspace/data/all_chats/datasources/folder_local_data_source.dart'
    as _i277;
import 'package:genesis_workspace/data/all_chats/datasources/folder_membership_local_data_source.dart'
    as _i180;
import 'package:genesis_workspace/data/all_chats/datasources/folders_remote_data_source.dart'
    as _i570;
import 'package:genesis_workspace/data/all_chats/datasources/pinned_chats_local_data_source.dart'
    as _i796;
import 'package:genesis_workspace/data/all_chats/repositories_impl/folder_membership_repository_impl.dart'
    as _i770;
import 'package:genesis_workspace/data/all_chats/repositories_impl/folder_repository_impl.dart'
    as _i957;
import 'package:genesis_workspace/data/all_chats/repositories_impl/pinned_chats_repository_impl.dart'
    as _i835;
import 'package:genesis_workspace/data/database/app_database.dart' as _i606;
import 'package:genesis_workspace/data/messages/datasources/messages_data_source.dart'
    as _i253;
import 'package:genesis_workspace/data/messages/datasources/messages_data_source_impl.dart'
    as _i695;
import 'package:genesis_workspace/data/messages/repositories_impl/messages_repository_impl.dart'
    as _i971;
import 'package:genesis_workspace/data/organizations/dao/organizations_dao.dart'
    as _i500;
import 'package:genesis_workspace/data/organizations/datasources/organizations_data_source.dart'
    as _i419;
import 'package:genesis_workspace/data/organizations/datasources/organizations_local_data_source.dart'
    as _i294;
import 'package:genesis_workspace/data/organizations/repositories_impl/organizations_repository_impl.dart'
    as _i1065;
import 'package:genesis_workspace/data/users/dao/recent_dm_dao.dart' as _i571;
import 'package:genesis_workspace/data/users/datasources/recent_dm_data_source.dart'
    as _i38;
import 'package:genesis_workspace/data/users/datasources/users_remote_data_source.dart'
    as _i451;
import 'package:genesis_workspace/data/users/repositories_impl/recent_dm_repository_impl.dart'
    as _i265;
import 'package:genesis_workspace/data/users/repositories_impl/users_repository_impl.dart'
    as _i675;
import 'package:genesis_workspace/domain/all_chats/repositories/folder_membership_repository.dart'
    as _i915;
import 'package:genesis_workspace/domain/all_chats/repositories/folder_repository.dart'
    as _i48;
import 'package:genesis_workspace/domain/all_chats/repositories/pinned_chats_repository.dart'
    as _i725;
import 'package:genesis_workspace/domain/all_chats/usecases/add_folder_use_case.dart'
    as _i125;
import 'package:genesis_workspace/domain/all_chats/usecases/delete_folder_use_case.dart'
    as _i849;
import 'package:genesis_workspace/domain/all_chats/usecases/get_all_folders_items_use_case.dart'
    as _i293;
import 'package:genesis_workspace/domain/all_chats/usecases/get_folder_ids_for_chat_use_case.dart'
    as _i247;
import 'package:genesis_workspace/domain/all_chats/usecases/get_folders_use_case.dart'
    as _i815;
import 'package:genesis_workspace/domain/all_chats/usecases/get_members_for_folder_use_case.dart'
    as _i438;
import 'package:genesis_workspace/domain/all_chats/usecases/get_pinned_chats_use_case.dart'
    as _i126;
import 'package:genesis_workspace/domain/all_chats/usecases/pin_chat_use_case.dart'
    as _i1012;
import 'package:genesis_workspace/domain/all_chats/usecases/remove_all_memberships_for_folder_use_case.dart'
    as _i744;
import 'package:genesis_workspace/domain/all_chats/usecases/set_folders_for_chat_use_case.dart'
    as _i1004;
import 'package:genesis_workspace/domain/all_chats/usecases/unpin_chat_use_case.dart'
    as _i631;
import 'package:genesis_workspace/domain/all_chats/usecases/update_folder_use_case.dart'
    as _i7;
import 'package:genesis_workspace/domain/all_chats/usecases/update_pinned_chat_order_use_case.dart'
    as _i1057;
import 'package:genesis_workspace/domain/common/usecases/get_version_config_sha_use_case.dart'
    as _i690;
import 'package:genesis_workspace/domain/common/usecases/get_version_config_use_case.dart'
    as _i397;
import 'package:genesis_workspace/domain/messages/repositories/messages_repository.dart'
    as _i857;
import 'package:genesis_workspace/domain/messages/usecases/add_emoji_reaction_use_case.dart'
    as _i276;
import 'package:genesis_workspace/domain/messages/usecases/delete_message_use_case.dart'
    as _i455;
import 'package:genesis_workspace/domain/messages/usecases/get_message_by_id_use_case.dart'
    as _i699;
import 'package:genesis_workspace/domain/messages/usecases/get_message_readers.dart'
    as _i90;
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart'
    as _i207;
import 'package:genesis_workspace/domain/messages/usecases/mark_stream_as_read_use_case.dart'
    as _i300;
import 'package:genesis_workspace/domain/messages/usecases/mark_topic_as_read_use_case.dart'
    as _i657;
import 'package:genesis_workspace/domain/messages/usecases/remove_emoji_reaction_use_case.dart'
    as _i513;
import 'package:genesis_workspace/domain/messages/usecases/send_message_use_case.dart'
    as _i116;
import 'package:genesis_workspace/domain/messages/usecases/update_message_use_case.dart'
    as _i1005;
import 'package:genesis_workspace/domain/messages/usecases/update_messages_flags_use_case.dart'
    as _i664;
import 'package:genesis_workspace/domain/messages/usecases/upload_file_use_case.dart'
    as _i42;
import 'package:genesis_workspace/domain/organizations/repositories/organizations_repository.dart'
    as _i654;
import 'package:genesis_workspace/domain/organizations/usecases/add_organization_use_case.dart'
    as _i183;
import 'package:genesis_workspace/domain/organizations/usecases/get_all_organizations_use_case.dart'
    as _i535;
import 'package:genesis_workspace/domain/organizations/usecases/get_organization_by_id_use_case.dart'
    as _i401;
import 'package:genesis_workspace/domain/organizations/usecases/get_organization_settings_use_case.dart'
    as _i286;
import 'package:genesis_workspace/domain/organizations/usecases/remove_organization_use_case.dart'
    as _i240;
import 'package:genesis_workspace/domain/organizations/usecases/update_organization_meeting_url_use_case.dart'
    as _i282;
import 'package:genesis_workspace/domain/organizations/usecases/watch_organizations_use_case.dart'
    as _i724;
import 'package:genesis_workspace/domain/real_time_events/repositories/real_time_events_repository.dart'
    as _i703;
import 'package:genesis_workspace/domain/real_time_events/usecases/delete_queue_use_case.dart'
    as _i435;
import 'package:genesis_workspace/domain/real_time_events/usecases/get_events_by_queue_id_use_case.dart'
    as _i1039;
import 'package:genesis_workspace/domain/real_time_events/usecases/register_queue_use_case.dart'
    as _i477;
import 'package:genesis_workspace/domain/users/repositories/recent_dm_repository.dart'
    as _i911;
import 'package:genesis_workspace/domain/users/repositories/users_repository.dart'
    as _i125;
import 'package:genesis_workspace/domain/users/usecases/add_recent_dm_use_case.dart'
    as _i812;
import 'package:genesis_workspace/domain/users/usecases/get_all_presences_use_case.dart'
    as _i837;
import 'package:genesis_workspace/domain/users/usecases/get_channel_by_id_use_case.dart'
    as _i720;
import 'package:genesis_workspace/domain/users/usecases/get_channel_members_use_case.dart'
    as _i771;
import 'package:genesis_workspace/domain/users/usecases/get_own_user_use_case.dart'
    as _i547;
import 'package:genesis_workspace/domain/users/usecases/get_recent_dms_use_case.dart'
    as _i445;
import 'package:genesis_workspace/domain/users/usecases/get_subscribed_channels_use_case.dart'
    as _i988;
import 'package:genesis_workspace/domain/users/usecases/get_topics_use_case.dart'
    as _i699;
import 'package:genesis_workspace/domain/users/usecases/get_user_by_id_use_case.dart'
    as _i773;
import 'package:genesis_workspace/domain/users/usecases/get_user_presence_use_case.dart'
    as _i394;
import 'package:genesis_workspace/domain/users/usecases/get_users_use_case.dart'
    as _i194;
import 'package:genesis_workspace/domain/users/usecases/set_typing_use_case.dart'
    as _i487;
import 'package:genesis_workspace/domain/users/usecases/update_presence_use_case.dart'
    as _i832;
import 'package:genesis_workspace/domain/users/usecases/update_subscription_settings_use_case.dart'
    as _i541;
import 'package:genesis_workspace/features/all_chats/bloc/all_chats_cubit.dart'
    as _i404;
import 'package:genesis_workspace/features/authentication/data/datasources/auth_remote_data_source.dart'
    as _i672;
import 'package:genesis_workspace/features/authentication/data/repositories_impl/auth_repository_impl.dart'
    as _i44;
import 'package:genesis_workspace/features/authentication/domain/repositories/auth_repository.dart'
    as _i1022;
import 'package:genesis_workspace/features/authentication/domain/usecases/delete_csrftoken_use_case.dart'
    as _i819;
import 'package:genesis_workspace/features/authentication/domain/usecases/delete_session_id_use_case.dart'
    as _i361;
import 'package:genesis_workspace/features/authentication/domain/usecases/delete_token_use_case.dart'
    as _i433;
import 'package:genesis_workspace/features/authentication/domain/usecases/fetch_api_key_use_case.dart'
    as _i799;
import 'package:genesis_workspace/features/authentication/domain/usecases/get_csrftoken_use_case.dart'
    as _i862;
import 'package:genesis_workspace/features/authentication/domain/usecases/get_server_settings_use_case.dart'
    as _i848;
import 'package:genesis_workspace/features/authentication/domain/usecases/get_session_id_use_case.dart'
    as _i350;
import 'package:genesis_workspace/features/authentication/domain/usecases/get_token_use_case.dart'
    as _i75;
import 'package:genesis_workspace/features/authentication/domain/usecases/save_csrftoken_use_case.dart'
    as _i352;
import 'package:genesis_workspace/features/authentication/domain/usecases/save_session_id_use_case.dart'
    as _i721;
import 'package:genesis_workspace/features/authentication/domain/usecases/save_token_use_case.dart'
    as _i643;
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart'
    as _i862;
import 'package:genesis_workspace/features/call/bloc/call_cubit.dart' as _i274;
import 'package:genesis_workspace/features/channel_chat/bloc/channel_chat_cubit.dart'
    as _i739;
import 'package:genesis_workspace/features/channel_chat/bloc/channel_members_info_cubit.dart'
    as _i325;
import 'package:genesis_workspace/features/channels/bloc/channels_cubit.dart'
    as _i201;
import 'package:genesis_workspace/features/chat/bloc/chat_cubit.dart' as _i277;
import 'package:genesis_workspace/features/direct_messages/bloc/direct_messages_cubit.dart'
    as _i852;
import 'package:genesis_workspace/features/download_files/bloc/download_files_cubit.dart'
    as _i1004;
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart'
    as _i144;
import 'package:genesis_workspace/features/mentions/bloc/mentions_cubit.dart'
    as _i758;
import 'package:genesis_workspace/features/messages/bloc/message_readers_cubit.dart'
    as _i311;
import 'package:genesis_workspace/features/messages/bloc/messages_cubit.dart'
    as _i592;
import 'package:genesis_workspace/features/messenger/bloc/info_panel_cubit.dart'
    as _i398;
import 'package:genesis_workspace/features/messenger/bloc/messenger_cubit.dart'
    as _i49;
import 'package:genesis_workspace/features/notifications/bloc/notifications_cubit.dart'
    as _i388;
import 'package:genesis_workspace/features/organizations/bloc/organizations_cubit.dart'
    as _i214;
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart'
    as _i766;
import 'package:genesis_workspace/features/reactions/bloc/reactions_cubit.dart'
    as _i656;
import 'package:genesis_workspace/features/real_time/bloc/real_time_cubit.dart'
    as _i573;
import 'package:genesis_workspace/features/settings/bloc/settings_cubit.dart'
    as _i155;
import 'package:genesis_workspace/features/starred/bloc/starred_cubit.dart'
    as _i1068;
import 'package:genesis_workspace/features/update/bloc/update_cubit.dart'
    as _i326;
import 'package:genesis_workspace/navigation/app_shell_controller.dart'
    as _i188;
import 'package:genesis_workspace/services/download_files/download_files_service.dart'
    as _i124;
import 'package:genesis_workspace/services/localization/localization_service.dart'
    as _i435;
import 'package:genesis_workspace/services/notifications/local_notifications_service.dart'
    as _i1031;
import 'package:genesis_workspace/services/organizations/organization_switcher_service.dart'
    as _i377;
import 'package:genesis_workspace/services/paste/paste_capture_service.dart'
    as _i113;
import 'package:genesis_workspace/services/real_time/multi_polling_service.dart'
    as _i823;
import 'package:genesis_workspace/services/real_time/per_org_dio_factory.dart'
    as _i215;
import 'package:genesis_workspace/services/real_time/real_time_connection_factory.dart'
    as _i951;
import 'package:genesis_workspace/services/real_time/real_time_module.dart'
    as _i733;
import 'package:genesis_workspace/services/real_time/real_time_service.dart'
    as _i82;
import 'package:genesis_workspace/services/real_time/real_time_service_backup.dart'
    as _i570;
import 'package:genesis_workspace/services/token_storage/token_storage.dart'
    as _i958;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final coreModule = _$CoreModule();
    final realTimeModule = _$RealTimeModule();
    gh.factory<_i440.DioFactory>(() => _i440.DioFactory());
    gh.factory<_i467.FolderItemsRemoteDataSource>(
      () => _i467.FolderItemsRemoteDataSource(),
    );
    gh.factory<_i570.FoldersRemoteDataSource>(
      () => _i570.FoldersRemoteDataSource(),
    );
    gh.factory<_i419.OrganizationsDataSource>(
      () => _i419.OrganizationsDataSource(),
    );
    gh.factory<_i690.GetVersionConfigShaUseCase>(
      () => _i690.GetVersionConfigShaUseCase(),
    );
    gh.factory<_i397.GetVersionConfigUseCase>(
      () => _i397.GetVersionConfigUseCase(),
    );
    gh.factory<_i274.CallCubit>(() => _i274.CallCubit());
    gh.factory<_i398.InfoPanelCubit>(() => _i398.InfoPanelCubit());
    gh.lazySingleton<_i188.AppShellController>(
      () => coreModule.provideAppShellController(),
    );
    gh.lazySingleton<_i606.AppDatabase>(
      () => coreModule.appDatabase(),
      dispose: (i) => i.dispose(),
    );
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => coreModule.sharedPreferences(),
      preResolve: true,
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => coreModule.secureStorage(),
    );
    gh.lazySingleton<_i163.FlutterLocalNotificationsPlugin>(
      () => coreModule.flutterLocalNotificationsPlugin(),
    );
    gh.lazySingleton<_i144.EmojiKeyboardCubit>(
      () => _i144.EmojiKeyboardCubit(),
    );
    gh.lazySingleton<_i435.LocalizationService>(
      () => _i435.LocalizationService(),
    );
    gh.lazySingleton<_i113.PasteCaptureService>(
      () => _i113.PasteCaptureService(),
    );
    gh.lazySingleton<_i733.RealTimeRepositoryFactory>(
      () => realTimeModule.realTimeRepositoryFactory(),
    );
    gh.lazySingleton<_i215.PerOrganizationDioFactory>(
      () => realTimeModule.perOrganizationDioFactory(),
    );
    gh.factory<_i451.UsersRemoteDataSource>(
      () => _i451.UsersRemoteDataSourceImpl(),
    );
    gh.factory<_i857.MessagesRepository>(() => _i971.MessagesRepositoryImpl());
    gh.factory<_i253.MessagesDataSource>(() => _i695.MessagesDataSourceImpl());
    gh.factory<_i672.AuthRemoteDataSource>(
      () => _i672.AuthRemoteDataSourceImpl(),
    );
    gh.factory<_i571.RecentDmDao>(
      () => _i571.RecentDmDao(gh<_i606.AppDatabase>()),
    );
    gh.lazySingleton<_i958.TokenStorage>(
      () => coreModule.tokenStorage(gh<_i558.FlutterSecureStorage>()),
    );
    gh.factory<_i125.UsersRepository>(
      () => _i675.UsersRepositoryImpl(gh<_i451.UsersRemoteDataSource>()),
    );
    gh.factory<_i276.AddEmojiReactionUseCase>(
      () => _i276.AddEmojiReactionUseCase(gh<_i857.MessagesRepository>()),
    );
    gh.factory<_i455.DeleteMessageUseCase>(
      () => _i455.DeleteMessageUseCase(gh<_i857.MessagesRepository>()),
    );
    gh.factory<_i699.GetMessageByIdUseCase>(
      () => _i699.GetMessageByIdUseCase(gh<_i857.MessagesRepository>()),
    );
    gh.factory<_i90.GetMessageReadersUseCase>(
      () => _i90.GetMessageReadersUseCase(gh<_i857.MessagesRepository>()),
    );
    gh.factory<_i207.GetMessagesUseCase>(
      () => _i207.GetMessagesUseCase(gh<_i857.MessagesRepository>()),
    );
    gh.factory<_i300.MarkStreamAsReadUseCase>(
      () => _i300.MarkStreamAsReadUseCase(gh<_i857.MessagesRepository>()),
    );
    gh.factory<_i657.MarkTopicAsReadUseCase>(
      () => _i657.MarkTopicAsReadUseCase(gh<_i857.MessagesRepository>()),
    );
    gh.factory<_i513.RemoveEmojiReactionUseCase>(
      () => _i513.RemoveEmojiReactionUseCase(gh<_i857.MessagesRepository>()),
    );
    gh.factory<_i116.SendMessageUseCase>(
      () => _i116.SendMessageUseCase(gh<_i857.MessagesRepository>()),
    );
    gh.factory<_i1005.UpdateMessageUseCase>(
      () => _i1005.UpdateMessageUseCase(gh<_i857.MessagesRepository>()),
    );
    gh.factory<_i664.UpdateMessagesFlagsUseCase>(
      () => _i664.UpdateMessagesFlagsUseCase(gh<_i857.MessagesRepository>()),
    );
    gh.factory<_i42.UploadFileUseCase>(
      () => _i42.UploadFileUseCase(gh<_i857.MessagesRepository>()),
    );
    gh.lazySingleton<_i326.UpdateCubit>(
      () => _i326.UpdateCubit(
        gh<_i397.GetVersionConfigUseCase>(),
        gh<_i690.GetVersionConfigShaUseCase>(),
      ),
      dispose: _i326.disposeUpdateCubit,
    );
    gh.factory<_i483.FolderDao>(() => _i483.FolderDao(gh<_i606.AppDatabase>()));
    gh.factory<_i909.FolderItemDao>(
      () => _i909.FolderItemDao(gh<_i606.AppDatabase>()),
    );
    gh.factory<_i691.PinnedChatsDao>(
      () => _i691.PinnedChatsDao(gh<_i606.AppDatabase>()),
    );
    gh.factory<_i500.OrganizationsDao>(
      () => _i500.OrganizationsDao(gh<_i606.AppDatabase>()),
    );
    gh.factory<_i862.GetCsrftokenUseCase>(
      () => _i862.GetCsrftokenUseCase(gh<_i958.TokenStorage>()),
    );
    gh.factory<_i350.GetSessionIdUseCase>(
      () => _i350.GetSessionIdUseCase(gh<_i958.TokenStorage>()),
    );
    gh.factory<_i294.OrganizationsLocalDataSource>(
      () => _i294.OrganizationsLocalDataSource(gh<_i500.OrganizationsDao>()),
    );
    gh.lazySingleton<_i377.OrganizationSwitcherService>(
      () => _i377.OrganizationSwitcherService(
        gh<_i460.SharedPreferences>(),
        gh<_i958.TokenStorage>(),
        gh<_i440.DioFactory>(),
      ),
    );
    gh.factory<_i277.FolderLocalDataSource>(
      () => _i277.FolderLocalDataSource(gh<_i483.FolderDao>()),
    );
    gh.factory<_i75.GetTokenUseCase>(
      () => _i75.GetTokenUseCase(gh<_i958.TokenStorage>()),
    );
    gh.lazySingleton<_i951.OrganizationAuthResolver>(
      () => _i951.OrganizationAuthResolver(gh<_i958.TokenStorage>()),
    );
    gh.lazySingleton<_i951.RealTimeConnectionFactory>(
      () => _i951.RealTimeConnectionFactoryImpl(
        gh<_i958.TokenStorage>(),
        gh<_i215.PerOrganizationDioFactory>(),
        gh<_i733.RealTimeRepositoryFactory>(),
      ),
    );
    gh.factory<_i654.OrganizationsRepository>(
      () => _i1065.OrganizationsRepositoryImpl(
        gh<_i294.OrganizationsLocalDataSource>(),
        gh<_i419.OrganizationsDataSource>(),
      ),
    );
    gh.factory<_i837.GetAllPresencesUseCase>(
      () => _i837.GetAllPresencesUseCase(gh<_i125.UsersRepository>()),
    );
    gh.factory<_i720.GetChannelByIdUseCase>(
      () => _i720.GetChannelByIdUseCase(gh<_i125.UsersRepository>()),
    );
    gh.factory<_i771.GetChannelMembersUseCase>(
      () => _i771.GetChannelMembersUseCase(gh<_i125.UsersRepository>()),
    );
    gh.factory<_i547.GetOwnUserUseCase>(
      () => _i547.GetOwnUserUseCase(gh<_i125.UsersRepository>()),
    );
    gh.factory<_i988.GetSubscribedChannelsUseCase>(
      () => _i988.GetSubscribedChannelsUseCase(gh<_i125.UsersRepository>()),
    );
    gh.factory<_i699.GetTopicsUseCase>(
      () => _i699.GetTopicsUseCase(gh<_i125.UsersRepository>()),
    );
    gh.factory<_i773.GetUserByIdUseCase>(
      () => _i773.GetUserByIdUseCase(gh<_i125.UsersRepository>()),
    );
    gh.factory<_i394.GetUserPresenceUseCase>(
      () => _i394.GetUserPresenceUseCase(gh<_i125.UsersRepository>()),
    );
    gh.factory<_i194.GetUsersUseCase>(
      () => _i194.GetUsersUseCase(gh<_i125.UsersRepository>()),
    );
    gh.factory<_i487.SetTypingUseCase>(
      () => _i487.SetTypingUseCase(gh<_i125.UsersRepository>()),
    );
    gh.factory<_i832.UpdatePresenceUseCase>(
      () => _i832.UpdatePresenceUseCase(gh<_i125.UsersRepository>()),
    );
    gh.factory<_i541.UpdateSubscriptionSettingsUseCase>(
      () =>
          _i541.UpdateSubscriptionSettingsUseCase(gh<_i125.UsersRepository>()),
    );
    gh.factory<_i311.MessageReadersCubit>(
      () => _i311.MessageReadersCubit(
        getMessageReadersUseCase: gh<_i90.GetMessageReadersUseCase>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => coreModule.dio(
        gh<_i460.SharedPreferences>(),
        gh<_i958.TokenStorage>(),
        gh<_i440.DioFactory>(),
      ),
    );
    gh.factory<_i38.RecentDmLocalDataSource>(
      () => _i38.RecentDmLocalDataSource(gh<_i571.RecentDmDao>()),
    );
    gh.factory<_i325.ChannelMembersInfoCubit>(
      () => _i325.ChannelMembersInfoCubit(
        getUsersUseCase: gh<_i194.GetUsersUseCase>(),
      ),
    );
    gh.factory<_i48.FolderRepository>(
      () => _i957.FolderRepositoryImpl(
        gh<_i277.FolderLocalDataSource>(),
        gh<_i570.FoldersRemoteDataSource>(),
      ),
    );
    gh.factory<_i758.MentionsCubit>(
      () => _i758.MentionsCubit(gh<_i207.GetMessagesUseCase>()),
    );
    gh.factory<_i180.FolderMembershipLocalDataSource>(
      () => _i180.FolderMembershipLocalDataSource(gh<_i909.FolderItemDao>()),
    );
    gh.lazySingleton<_i1022.AuthRepository>(
      () => _i44.AuthRepositoryImpl(
        gh<_i672.AuthRemoteDataSource>(),
        gh<_i958.TokenStorage>(),
      ),
    );
    gh.lazySingleton<_i703.RealTimeEventsRepository>(
      () => realTimeModule.realTimeEventsRepository(
        gh<_i733.RealTimeRepositoryFactory>(),
        gh<_i361.Dio>(),
      ),
    );
    gh.factory<_i435.DeleteQueueUseCase>(
      () => _i435.DeleteQueueUseCase(gh<_i703.RealTimeEventsRepository>()),
    );
    gh.factory<_i1039.GetEventsByQueueIdUseCase>(
      () => _i1039.GetEventsByQueueIdUseCase(
        gh<_i703.RealTimeEventsRepository>(),
      ),
    );
    gh.factory<_i477.RegisterQueueUseCase>(
      () => _i477.RegisterQueueUseCase(gh<_i703.RealTimeEventsRepository>()),
    );
    gh.factory<_i796.PinnedChatsLocalDataSource>(
      () => _i796.PinnedChatsLocalDataSource(gh<_i691.PinnedChatsDao>()),
    );
    gh.factory<_i911.RecentDmRepository>(
      () => _i265.RecentDmRepositoryImpl(gh<_i38.RecentDmLocalDataSource>()),
    );
    gh.lazySingleton<_i766.ProfileCubit>(
      () => _i766.ProfileCubit(
        gh<_i547.GetOwnUserUseCase>(),
        gh<_i832.UpdatePresenceUseCase>(),
      ),
    );
    gh.factory<_i812.AddRecentDmUseCase>(
      () => _i812.AddRecentDmUseCase(gh<_i911.RecentDmRepository>()),
    );
    gh.factory<_i445.GetRecentDmsUseCase>(
      () => _i445.GetRecentDmsUseCase(gh<_i911.RecentDmRepository>()),
    );
    gh.factory<_i915.FolderMembershipRepository>(
      () => _i770.FolderMembershipRepositoryImpl(
        gh<_i467.FolderItemsRemoteDataSource>(),
        gh<_i570.FoldersRemoteDataSource>(),
        gh<_i180.FolderMembershipLocalDataSource>(),
      ),
    );
    gh.factory<_i183.AddOrganizationUseCase>(
      () => _i183.AddOrganizationUseCase(gh<_i654.OrganizationsRepository>()),
    );
    gh.factory<_i535.GetAllOrganizationsUseCase>(
      () =>
          _i535.GetAllOrganizationsUseCase(gh<_i654.OrganizationsRepository>()),
    );
    gh.factory<_i401.GetOrganizationByIdUseCase>(
      () =>
          _i401.GetOrganizationByIdUseCase(gh<_i654.OrganizationsRepository>()),
    );
    gh.factory<_i286.GetOrganizationSettingsUseCase>(
      () => _i286.GetOrganizationSettingsUseCase(
        gh<_i654.OrganizationsRepository>(),
      ),
    );
    gh.factory<_i240.RemoveOrganizationUseCase>(
      () =>
          _i240.RemoveOrganizationUseCase(gh<_i654.OrganizationsRepository>()),
    );
    gh.factory<_i282.UpdateOrganizationMeetingUrlUseCase>(
      () => _i282.UpdateOrganizationMeetingUrlUseCase(
        gh<_i654.OrganizationsRepository>(),
      ),
    );
    gh.factory<_i724.WatchOrganizationsUseCase>(
      () =>
          _i724.WatchOrganizationsUseCase(gh<_i654.OrganizationsRepository>()),
    );
    gh.factory<_i125.AddFolderUseCase>(
      () => _i125.AddFolderUseCase(gh<_i48.FolderRepository>()),
    );
    gh.factory<_i849.DeleteFolderUseCase>(
      () => _i849.DeleteFolderUseCase(gh<_i48.FolderRepository>()),
    );
    gh.factory<_i815.GetFoldersUseCase>(
      () => _i815.GetFoldersUseCase(gh<_i48.FolderRepository>()),
    );
    gh.factory<_i7.UpdateFolderUseCase>(
      () => _i7.UpdateFolderUseCase(gh<_i48.FolderRepository>()),
    );
    gh.factory<_i155.SettingsCubit>(
      () => _i155.SettingsCubit(
        gh<_i812.AddRecentDmUseCase>(),
        gh<_i445.GetRecentDmsUseCase>(),
        gh<_i606.AppDatabase>(),
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i124.DownloadFilesService>(
      () => _i124.DownloadFilesService(
        gh<_i361.Dio>(),
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i823.MultiPollingService>(
      () => _i823.MultiPollingService(
        gh<_i535.GetAllOrganizationsUseCase>(),
        gh<_i75.GetTokenUseCase>(),
        gh<_i862.GetCsrftokenUseCase>(),
        gh<_i350.GetSessionIdUseCase>(),
        gh<_i951.RealTimeConnectionFactory>(),
        gh<_i282.UpdateOrganizationMeetingUrlUseCase>(),
      ),
    );
    gh.factory<_i293.GetAllFoldersItemsUseCase>(
      () => _i293.GetAllFoldersItemsUseCase(
        gh<_i915.FolderMembershipRepository>(),
      ),
    );
    gh.factory<_i247.GetFolderIdsForChatUseCase>(
      () => _i247.GetFolderIdsForChatUseCase(
        gh<_i915.FolderMembershipRepository>(),
      ),
    );
    gh.factory<_i438.GetMembersForFolderUseCase>(
      () => _i438.GetMembersForFolderUseCase(
        gh<_i915.FolderMembershipRepository>(),
      ),
    );
    gh.factory<_i744.RemoveAllMembershipsForFolderUseCase>(
      () => _i744.RemoveAllMembershipsForFolderUseCase(
        gh<_i915.FolderMembershipRepository>(),
      ),
    );
    gh.factory<_i1004.SetFoldersForChatUseCase>(
      () => _i1004.SetFoldersForChatUseCase(
        gh<_i915.FolderMembershipRepository>(),
      ),
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
    gh.factory<_i277.ChatCubit>(
      () => _i277.ChatCubit(
        gh<_i823.MultiPollingService>(),
        gh<_i207.GetMessagesUseCase>(),
        gh<_i116.SendMessageUseCase>(),
        gh<_i487.SetTypingUseCase>(),
        gh<_i664.UpdateMessagesFlagsUseCase>(),
        gh<_i773.GetUserByIdUseCase>(),
        gh<_i394.GetUserPresenceUseCase>(),
        gh<_i42.UploadFileUseCase>(),
        gh<_i1005.UpdateMessageUseCase>(),
        gh<_i194.GetUsersUseCase>(),
      ),
    );
    gh.lazySingleton<_i725.PinnedChatsRepository>(
      () => _i835.PinnedChatsRepositoryImpl(
        gh<_i467.FolderItemsRemoteDataSource>(),
        gh<_i796.PinnedChatsLocalDataSource>(),
      ),
    );
    gh.factory<_i819.DeleteCsrftokenUseCase>(
      () => _i819.DeleteCsrftokenUseCase(gh<_i1022.AuthRepository>()),
    );
    gh.factory<_i361.DeleteSessionIdUseCase>(
      () => _i361.DeleteSessionIdUseCase(gh<_i1022.AuthRepository>()),
    );
    gh.factory<_i848.GetServerSettingsUseCase>(
      () => _i848.GetServerSettingsUseCase(gh<_i1022.AuthRepository>()),
    );
    gh.factory<_i352.SaveCsrftokenUseCase>(
      () => _i352.SaveCsrftokenUseCase(gh<_i1022.AuthRepository>()),
    );
    gh.factory<_i721.SaveSessionIdUseCase>(
      () => _i721.SaveSessionIdUseCase(gh<_i1022.AuthRepository>()),
    );
    gh.lazySingleton<_i82.RealTimeService>(
      () => _i82.RealTimeService(
        gh<_i477.RegisterQueueUseCase>(),
        gh<_i1039.GetEventsByQueueIdUseCase>(),
      ),
    );
    gh.lazySingleton<_i570.RealTimeServiceBackup>(
      () => _i570.RealTimeServiceBackup(
        gh<_i477.RegisterQueueUseCase>(),
        gh<_i1039.GetEventsByQueueIdUseCase>(),
      ),
    );
    gh.lazySingleton<_i214.OrganizationsCubit>(
      () => _i214.OrganizationsCubit(
        gh<_i724.WatchOrganizationsUseCase>(),
        gh<_i183.AddOrganizationUseCase>(),
        gh<_i286.GetOrganizationSettingsUseCase>(),
        gh<_i240.RemoveOrganizationUseCase>(),
        gh<_i377.OrganizationSwitcherService>(),
        gh<_i823.MultiPollingService>(),
        gh<_i766.ProfileCubit>(),
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i862.AuthCubit>(
      () => _i862.AuthCubit(
        gh<_i460.SharedPreferences>(),
        gh<_i440.DioFactory>(),
        gh<_i799.FetchApiKeyUseCase>(),
        gh<_i643.SaveTokenUseCase>(),
        gh<_i75.GetTokenUseCase>(),
        gh<_i433.DeleteTokenUseCase>(),
        gh<_i823.MultiPollingService>(),
        gh<_i832.UpdatePresenceUseCase>(),
        gh<_i848.GetServerSettingsUseCase>(),
        gh<_i286.GetOrganizationSettingsUseCase>(),
        gh<_i721.SaveSessionIdUseCase>(),
        gh<_i361.DeleteSessionIdUseCase>(),
        gh<_i352.SaveCsrftokenUseCase>(),
        gh<_i862.GetCsrftokenUseCase>(),
        gh<_i350.GetSessionIdUseCase>(),
        gh<_i819.DeleteCsrftokenUseCase>(),
        gh<_i183.AddOrganizationUseCase>(),
        gh<_i401.GetOrganizationByIdUseCase>(),
        gh<_i535.GetAllOrganizationsUseCase>(),
        gh<_i377.OrganizationSwitcherService>(),
      ),
      dispose: _i862.disposeAuthCubit,
    );
    gh.factory<_i1004.DownloadFilesCubit>(
      () => _i1004.DownloadFilesCubit(gh<_i124.DownloadFilesService>()),
    );
    gh.factory<_i852.DirectMessagesCubit>(
      () => _i852.DirectMessagesCubit(
        gh<_i82.RealTimeService>(),
        gh<_i837.GetAllPresencesUseCase>(),
        gh<_i194.GetUsersUseCase>(),
        gh<_i207.GetMessagesUseCase>(),
      ),
    );
    gh.lazySingleton<_i573.RealTimeCubit>(
      () => _i573.RealTimeCubit(
        gh<_i823.MultiPollingService>(),
        gh<_i214.OrganizationsCubit>(),
      ),
    );
    gh.factory<_i739.ChannelChatCubit>(
      () => _i739.ChannelChatCubit(
        gh<_i823.MultiPollingService>(),
        gh<_i207.GetMessagesUseCase>(),
        gh<_i487.SetTypingUseCase>(),
        gh<_i664.UpdateMessagesFlagsUseCase>(),
        gh<_i116.SendMessageUseCase>(),
        gh<_i720.GetChannelByIdUseCase>(),
        gh<_i699.GetTopicsUseCase>(),
        gh<_i42.UploadFileUseCase>(),
        gh<_i1005.UpdateMessageUseCase>(),
        gh<_i194.GetUsersUseCase>(),
        gh<_i771.GetChannelMembersUseCase>(),
      ),
    );
    gh.factory<_i656.ReactionsCubit>(
      () => _i656.ReactionsCubit(
        gh<_i82.RealTimeService>(),
        gh<_i207.GetMessagesUseCase>(),
      ),
    );
    gh.factory<_i1068.StarredCubit>(
      () => _i1068.StarredCubit(
        gh<_i82.RealTimeService>(),
        gh<_i207.GetMessagesUseCase>(),
      ),
    );
    gh.factory<_i126.GetPinnedChatsUseCase>(
      () => _i126.GetPinnedChatsUseCase(gh<_i725.PinnedChatsRepository>()),
    );
    gh.factory<_i1012.PinChatUseCase>(
      () => _i1012.PinChatUseCase(gh<_i725.PinnedChatsRepository>()),
    );
    gh.factory<_i631.UnpinChatUseCase>(
      () => _i631.UnpinChatUseCase(gh<_i725.PinnedChatsRepository>()),
    );
    gh.factory<_i1057.UpdatePinnedChatOrderUseCase>(
      () => _i1057.UpdatePinnedChatOrderUseCase(
        gh<_i725.PinnedChatsRepository>(),
      ),
    );
    gh.lazySingleton<_i592.MessagesCubit>(
      () => _i592.MessagesCubit(
        gh<_i82.RealTimeService>(),
        gh<_i207.GetMessagesUseCase>(),
        gh<_i276.AddEmojiReactionUseCase>(),
        gh<_i513.RemoveEmojiReactionUseCase>(),
        gh<_i664.UpdateMessagesFlagsUseCase>(),
        gh<_i455.DeleteMessageUseCase>(),
        gh<_i699.GetMessageByIdUseCase>(),
        gh<_i1005.UpdateMessageUseCase>(),
      ),
      dispose: _i592.disposeMessagesCubit,
    );
    gh.factory<_i201.ChannelsCubit>(
      () => _i201.ChannelsCubit(
        gh<_i82.RealTimeService>(),
        gh<_i699.GetTopicsUseCase>(),
        gh<_i207.GetMessagesUseCase>(),
        gh<_i988.GetSubscribedChannelsUseCase>(),
        gh<_i541.UpdateSubscriptionSettingsUseCase>(),
      ),
    );
    gh.factory<_i404.AllChatsCubit>(
      () => _i404.AllChatsCubit(
        gh<_i125.AddFolderUseCase>(),
        gh<_i815.GetFoldersUseCase>(),
        gh<_i7.UpdateFolderUseCase>(),
        gh<_i849.DeleteFolderUseCase>(),
        gh<_i1004.SetFoldersForChatUseCase>(),
        gh<_i247.GetFolderIdsForChatUseCase>(),
        gh<_i744.RemoveAllMembershipsForFolderUseCase>(),
        gh<_i438.GetMembersForFolderUseCase>(),
        gh<_i126.GetPinnedChatsUseCase>(),
        gh<_i1012.PinChatUseCase>(),
        gh<_i631.UnpinChatUseCase>(),
        gh<_i1057.UpdatePinnedChatOrderUseCase>(),
      ),
    );
    gh.lazySingleton<_i49.MessengerCubit>(
      () => _i49.MessengerCubit(
        gh<_i125.AddFolderUseCase>(),
        gh<_i815.GetFoldersUseCase>(),
        gh<_i7.UpdateFolderUseCase>(),
        gh<_i849.DeleteFolderUseCase>(),
        gh<_i438.GetMembersForFolderUseCase>(),
        gh<_i207.GetMessagesUseCase>(),
        gh<_i699.GetTopicsUseCase>(),
        gh<_i823.MultiPollingService>(),
        gh<_i1012.PinChatUseCase>(),
        gh<_i631.UnpinChatUseCase>(),
        gh<_i126.GetPinnedChatsUseCase>(),
        gh<_i1004.SetFoldersForChatUseCase>(),
        gh<_i247.GetFolderIdsForChatUseCase>(),
        gh<_i1057.UpdatePinnedChatOrderUseCase>(),
        gh<_i766.ProfileCubit>(),
        gh<_i988.GetSubscribedChannelsUseCase>(),
        gh<_i541.UpdateSubscriptionSettingsUseCase>(),
        gh<_i300.MarkStreamAsReadUseCase>(),
        gh<_i657.MarkTopicAsReadUseCase>(),
        gh<_i293.GetAllFoldersItemsUseCase>(),
      ),
    );
    gh.factory<_i1031.LocalNotificationsService>(
      () => _i1031.LocalNotificationsService(
        gh<_i163.FlutterLocalNotificationsPlugin>(),
        gh<_i49.MessengerCubit>(),
        gh<_i214.OrganizationsCubit>(),
      ),
    );
    gh.singleton<_i388.NotificationsCubit>(
      () => _i388.NotificationsCubit(
        gh<_i823.MultiPollingService>(),
        gh<_i766.ProfileCubit>(),
        gh<_i49.MessengerCubit>(),
        gh<_i460.SharedPreferences>(),
        gh<_i1031.LocalNotificationsService>(),
      ),
    );
    return this;
  }
}

class _$CoreModule extends _i440.CoreModule {}

class _$RealTimeModule extends _i733.RealTimeModule {}
