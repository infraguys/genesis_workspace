import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/widgets/app_progress_indicator.dart';
import 'package:genesis_workspace/domain/genesis/entities/genesis_service_entity.dart';
import 'package:genesis_workspace/domain/genesis/usecases/get_service_by_id_use_case.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class LkView extends StatefulWidget {
  const LkView({super.key});

  @override
  State<LkView> createState() => _LkViewState();
}

class _LkViewState extends State<LkView> {
  late final Future<String> _future;
  final GetServiceByIdUseCase _getServiceByIdUseCase = getIt<GetServiceByIdUseCase>();

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
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
