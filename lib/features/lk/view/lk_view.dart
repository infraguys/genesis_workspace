import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/widgets/app_progress_indicator.dart';
import 'package:genesis_workspace/domain/genesis/entities/genesis_service_entity.dart';
import 'package:genesis_workspace/domain/genesis/usecases/get_service_by_id_use_case.dart';
import 'package:genesis_workspace/features/call/bloc/call_cubit.dart';
import 'package:genesis_workspace/features/organizations/bloc/organizations_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class LkView extends StatefulWidget {
  const LkView({super.key});

  @override
  State<LkView> createState() => _LkViewState();
}

class _LkViewState extends State<LkView> {
  late final Future<String> _future;
  final GetServiceByIdUseCase _getServiceByIdUseCase = getIt<GetServiceByIdUseCase>();
  InAppWebViewController? webViewController;
  bool _isProcessingMeetingNavigation = false;

  Future<String> getLkUrl() async {
    try {
      final response = await _getServiceByIdUseCase.call(
        GenesisServiceRequestEntity(uuid: AppConstants.mailCalendarUuid),
      );
      return response.serviceUrl;
    } catch (e) {
      rethrow;
    }
  }

  @override
  void initState() {
    _future = getLkUrl();
    super.initState();
  }

  String? _getMeetingBaseUrl() {
    OrganizationsCubit organizationsCubit;
    try {
      organizationsCubit = context.read<OrganizationsCubit>();
    } catch (_) {
      return null;
    }

    String? meetingBaseUrl;
    final selectedId = organizationsCubit.state.selectedOrganizationId;
    for (final organization in organizationsCubit.state.organizations) {
      if (organization.id == selectedId) {
        meetingBaseUrl = organization.meetingUrl;
        break;
      }
    }

    final String normalizedMeetingBaseUrl = (meetingBaseUrl ?? '').trim().replaceAll(RegExp(r'/+$'), '');
    if (normalizedMeetingBaseUrl.isEmpty) {
      return null;
    }

    return normalizedMeetingBaseUrl;
  }

  bool _isMeetingLink(Uri uri, String meetingBaseUrl) {
    final String normalizedUri = uri.toString().trim().replaceAll(RegExp(r'/+$'), '');
    return normalizedUri == meetingBaseUrl || normalizedUri.startsWith('$meetingBaseUrl/');
  }

  String _extractMeetingLocationName(Uri meetingUri) {
    if (meetingUri.pathSegments.isEmpty) {
      return '';
    }
    return Uri.decodeComponent(meetingUri.pathSegments.last);
  }

  Future<bool> _showSwitchCallDialog() async {
    final bool? shouldSwitch = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final switchCallDialogT = dialogContext.t.call.switchCallDialog;
        return AlertDialog(
          title: Text(switchCallDialogT.title),
          content: Text(switchCallDialogT.description),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(switchCallDialogT.stayInCurrent),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(switchCallDialogT.endAndJoin),
            ),
          ],
        );
      },
    );

    return shouldSwitch ?? false;
  }

  void _openMeetingCall({
    required Uri meetingUri,
    required CallCubit callCubit,
  }) {
    final meetingLink = "${meetingUri.toString()}#";

    if (currentSize(context) <= .tablet) {
      context.pushNamed(Routes.call, extra: meetingLink);
      return;
    }

    callCubit.openCall(
      meetUrl: meetingLink,
      meetLocationName: _extractMeetingLocationName(meetingUri),
    );
  }

  Future<void> _handleMeetingNavigation({
    required InAppWebViewController controller,
    required Uri uri,
  }) async {
    if (_isProcessingMeetingNavigation) {
      return;
    }

    final String? meetingBaseUrl = _getMeetingBaseUrl();
    if (meetingBaseUrl == null || !_isMeetingLink(uri, meetingBaseUrl)) {
      return;
    }

    _isProcessingMeetingNavigation = true;
    final CallCubit callCubit = context.read<CallCubit>();

    try {
      await controller.stopLoading();

      if (callCubit.state.isCallActive) {
        final bool shouldSwitchCall = await _showSwitchCallDialog();
        if (!mounted || !shouldSwitchCall) {
          return;
        }
        callCubit.closeCall();
      }

      if (!mounted) {
        return;
      }
      _openMeetingCall(meetingUri: uri, callCubit: callCubit);
    } finally {
      _isProcessingMeetingNavigation = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () async {
              final url = await getLkUrl();
              webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri.uri(Uri.parse(url))));
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _future,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == .waiting) {
            return AppProgressIndicator();
          }
          if (snapshot.connectionState == .done) {
            if (snapshot.hasData) {
              return SafeArea(
                child: InAppWebView(
                  onWebViewCreated: (InAppWebViewController controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, uri) async {
                    final parsedUri = Uri.tryParse(uri.toString());
                    if (parsedUri == null) {
                      return;
                    }
                    await _handleMeetingNavigation(controller: controller, uri: parsedUri);
                  },
                  initialUrlRequest: URLRequest(
                    url: WebUri.uri(
                      Uri.parse(snapshot.data ?? ''),
                    ),
                  ),
                ),
              );
            }
          }
          return Center(
            child: Column(
              spacing: 16,
              children: [
                Text(
                  context.t.error,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: .w500,
                  ),
                ),
                OutlinedButton(
                  onPressed: () async {
                    await getLkUrl();
                  },
                  child: Text(context.t.tryAgain, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
