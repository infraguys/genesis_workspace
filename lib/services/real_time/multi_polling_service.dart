import 'dart:async';
import 'dart:developer';

import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/domain/organizations/entities/organization_entity.dart';
import 'package:genesis_workspace/domain/organizations/usecases/get_all_organizations_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/delete_message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/presence_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/reaction_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/subscription_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/typing_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/usecases/delete_queue_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/usecases/get_events_by_queue_id_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/usecases/register_queue_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/get_csrftoken_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/get_session_id_use_case.dart';
import 'package:genesis_workspace/features/authentication/domain/usecases/get_token_use_case.dart';
import 'package:genesis_workspace/services/real_time/real_time_connection.dart';
import 'package:genesis_workspace/services/real_time/real_time_connection_factory.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class MultiPollingService {
  final GetAllOrganizationsUseCase _getAllOrganizationsUseCase;
  final GetTokenUseCase _getTokenUseCase;
  final GetCsrftokenUseCase _getCsrftokenUseCase;
  final GetSessionIdUseCase _getSessionIdUseCase;
  final RealTimeConnectionFactory _connectionFactory;

  MultiPollingService(
    this._getAllOrganizationsUseCase,
    this._getTokenUseCase,
    this._getCsrftokenUseCase,
    this._getSessionIdUseCase,
    this._connectionFactory,
  );

  Map<int, RealTimeConnection> get activeConnections => _activeConnections;

  final Map<int, RealTimeConnection> _activeConnections = {};

  final StreamController<TypingEventEntity> _typingEventsController = StreamController<TypingEventEntity>.broadcast();
  final StreamController<MessageEventEntity> _messageEventsController =
      StreamController<MessageEventEntity>.broadcast();
  final StreamController<UpdateMessageFlagsEventEntity> _messageFlagsEventsController =
      StreamController<UpdateMessageFlagsEventEntity>.broadcast();
  final StreamController<ReactionEventEntity> _reactionEventsController =
      StreamController<ReactionEventEntity>.broadcast();
  final StreamController<PresenceEventEntity> _presenceEventsController =
      StreamController<PresenceEventEntity>.broadcast();
  final StreamController<DeleteMessageEventEntity> _deleteMessageEventsController =
      StreamController<DeleteMessageEventEntity>.broadcast();
  final StreamController<UpdateMessageEventEntity> _updateMessageEventsController =
      StreamController<UpdateMessageEventEntity>.broadcast();
  final StreamController<SubscriptionEventEntity> _subscriptionEventsController =
      StreamController<SubscriptionEventEntity>.broadcast();

  Stream<TypingEventEntity> get typingEventsStream => _typingEventsController.stream;

  Stream<MessageEventEntity> get messageEventsStream => _messageEventsController.stream;

  Stream<UpdateMessageFlagsEventEntity> get messageFlagsEventsStream => _messageFlagsEventsController.stream;

  Stream<ReactionEventEntity> get reactionEventsStream => _reactionEventsController.stream;

  Stream<PresenceEventEntity> get presenceEventsStream => _presenceEventsController.stream;

  Stream<DeleteMessageEventEntity> get deleteMessageEventsStream => _deleteMessageEventsController.stream;

  Stream<UpdateMessageEventEntity> get updateMessageEventsStream => _updateMessageEventsController.stream;

  Stream<SubscriptionEventEntity> get subscriptionEventsStream => _subscriptionEventsController.stream;

  Future<void> init() async {
    final List<OrganizationEntity> authorizedOrganizations = await _fetchAuthorizedOrganizations();
    for (final OrganizationEntity organization in authorizedOrganizations) {
      await addConnection(organization.id, organization.baseUrl);
    }
  }

  Future<void> ensureConnection(int organizationId, String baseUrl) async {
    final RealTimeConnection? connection = _activeConnections[organizationId];
    final bool connectionActive = await connection?.checkConnection() ?? false;
    if (connectionActive) {
      return;
    }

    final String resolvedBaseUrl = connection?.baseUrl ?? baseUrl;
    if (connection != null) {
      await closeConnection(organizationId);
    }
    await addConnection(organizationId, resolvedBaseUrl);
  }

  Future<void> ensureAllConnections() async {
    final List<OrganizationEntity> authorizedOrganizations = await _fetchAuthorizedOrganizations();
    for (final OrganizationEntity organization in authorizedOrganizations) {
      await ensureConnection(organization.id, organization.baseUrl);
    }
  }

  Future<void> addConnection(int organizationId, String baseUrl) async {
    if (_activeConnections.containsKey(organizationId) && (_activeConnections[organizationId]?.isActive ?? false)) {
      return;
    }

    final RegisterQueueUseCase registerQueueUseCase = _connectionFactory.createRegisterQueueUseCase(
      organizationId: organizationId,
      baseUrl: baseUrl,
    );
    final GetEventsByQueueIdUseCase getEventsByQueueIdUseCase = _connectionFactory.createGetEventsByQueueIdUseCase(
      organizationId: organizationId,
      baseUrl: baseUrl,
    );

    final DeleteQueueUseCase deleteQueueUseCase = _connectionFactory.createDeleteQueueUseCase(
      organizationId: organizationId,
      baseUrl: baseUrl,
    );

    final RealTimeConnection connection = RealTimeConnection(
      organizationId: organizationId,
      baseUrl: baseUrl,
      registerQueueUseCase: registerQueueUseCase,
      getEventsByQueueIdUseCase: getEventsByQueueIdUseCase,
      deleteQueueUseCase: deleteQueueUseCase,
    );

    connection.typingEventsStream.listen(_typingEventsController.add, onError: (_) {});
    connection.messageEventsStream.listen(_messageEventsController.add, onError: (_) {});
    connection.messageFlagsEventsStream.listen(_messageFlagsEventsController.add, onError: (_) {});
    connection.reactionEventsStream.listen(_reactionEventsController.add, onError: (_) {});
    connection.presenceEventsStream.listen(_presenceEventsController.add, onError: (_) {});
    connection.deleteMessageEventsStream.listen(
      _deleteMessageEventsController.add,
      onError: (_) {},
    );
    connection.updateMessageEventsStream.listen(
      _updateMessageEventsController.add,
      onError: (_) {},
    );
    connection.subscriptionEventsStream.listen(_subscriptionEventsController.add, onError: (_) {});

    _activeConnections[organizationId] = connection;
    await connection.start();
  }

  Future<void> closeConnection(int organizationId) async {
    final RealTimeConnection? connection = _activeConnections.remove(organizationId);
    if (connection == null) return;
    await connection.stop();
  }

  Future<void> closeAllConnections() async {
    final List<Future<void>> tasks = [];
    for (final RealTimeConnection connection in _activeConnections.values) {
      tasks.add(connection.stop());
    }
    _activeConnections.clear();
    await Future.wait(tasks);
    await _closeAggregatedControllers();
  }

  void setUnvalidQueueId() {
    final selectedOrganizationId = AppConstants.selectedOrganizationId;
    if (selectedOrganizationId != null) {
      RealTimeConnection? connection = _activeConnections[selectedOrganizationId];
      connection?.setQueueId('123123');
    }
    inspect(activeConnections);
  }

  Future<void> _closeAggregatedControllers() async {
    // Обычно мультисервис живёт дольше всего, но если нужно полностью уничтожить — закрываем.
    await Future.wait([
      _typingEventsController.close(),
      _messageEventsController.close(),
      _messageFlagsEventsController.close(),
      _reactionEventsController.close(),
      _presenceEventsController.close(),
      _deleteMessageEventsController.close(),
      _updateMessageEventsController.close(),
      _subscriptionEventsController.close(),
    ]);
  }

  Future<List<OrganizationEntity>> _fetchAuthorizedOrganizations() async {
    final List<OrganizationEntity> organizations = await _getAllOrganizationsUseCase.call();
    final List<OrganizationEntity> authorizedOrganizations = [];
    for (final OrganizationEntity organization in organizations) {
      if (await _isAuthorized(organization.baseUrl)) {
        authorizedOrganizations.add(organization);
      }
    }
    return authorizedOrganizations;
  }

  Future<bool> _isAuthorized(String baseUrl) async {
    final String? token = await _getTokenUseCase.call(baseUrl);
    final String? csrfToken = await _getCsrftokenUseCase.call(baseUrl);
    final String? sessionId = await _getSessionIdUseCase.call(baseUrl);

    final bool hasToken = token != null && token.trim().isNotEmpty;
    final bool hasSessionCookies =
        (csrfToken != null && csrfToken.isNotEmpty) && (sessionId != null && sessionId.isNotEmpty);
    return hasToken || hasSessionCookies;
  }
}
