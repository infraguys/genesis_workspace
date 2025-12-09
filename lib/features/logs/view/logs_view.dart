import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/services/real_time/multi_polling_service.dart';
import 'package:genesis_workspace/services/real_time/real_time_connection.dart';

class LogsView extends StatefulWidget {
  const LogsView({super.key});

  @override
  State<LogsView> createState() => _LogsViewState();
}

class _LogsViewState extends State<LogsView> {
  final MultiPollingService _multiPollingService = getIt<MultiPollingService>();

  Map<int, RealTimeConnection> connections = {};
  List<RealTimeConnection> activeConnections = [];

  @override
  void initState() {
    super.initState();
  }

  void getConnections() {
    setState(() {
      connections = _multiPollingService.activeConnections;
      activeConnections = connections.values.map((connection) => connection).toList();
    });
    inspect(connections);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
        actions: [
          TextButton(
            onPressed: () {
              getConnections();
            },
            child: Text("Get connections"),
          ),
        ],
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 12),
        itemCount: activeConnections.length,
        separatorBuilder: (_, _) => SizedBox(
          height: 12,
        ),
        itemBuilder: (BuildContext context, int index) {
          final connection = activeConnections[index];
          return Row(
            children: [
              Column(
                crossAxisAlignment: .start,
                spacing: 4,
                children: [
                  Text("Base url: ${connection.baseUrl}"),
                  Text("org id: ${connection.organizationId}"),
                  Text("lastEventId: ${connection.lastEventId}"),
                  Text("queueId: ${connection.queueId}"),
                  Text("isActive: ${connection.isActive}"),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  connection.stop();
                },
                child: Text("Disconnect"),
              ),
            ],
          );
        },
      ),
    );
  }
}
