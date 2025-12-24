import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/utils/platform_info/platform_info.dart';
import 'package:genesis_workspace/features/logs/bloc/logs_cubit.dart';
import 'package:genesis_workspace/services/real_time/multi_polling_service.dart';
import 'package:genesis_workspace/services/real_time/real_time_connection.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
          IconButton(
            onPressed: _showShareLogsSheet,
            icon: const Icon(Icons.ios_share),
            tooltip: 'Поделиться',
          ),
          IconButton(
            onPressed: _saveLogsToDownloads,
            icon: const Icon(Icons.download),
            tooltip: 'Скачать',
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

  Future<void> _saveLogsToDownloads() async {
    if (platformInfo.isWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Скачивание недоступно в веб-версии')),
      );
      return;
    }

    final file = await _getLogFile();
    if (file == null || !mounted) return;

    try {
      final downloadsDir = await _resolveDownloadsDir();
      if (downloadsDir == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось найти системную папку загрузок')),
        );
        return;
      }

      final targetPath = p.join(downloadsDir.path, 'workspace_logs');
      await file.copy(targetPath);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Логи сохранены: $targetPath')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось сохранить лог-файл')),
      );
    }
  }

  Future<void> _showShareLogsSheet() async {
    if (platformInfo.isWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Шаринг недоступен в веб-версии')),
      );
      return;
    }

    final file = await _getLogFile();
    if (file == null || !mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Поделиться логами',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                file.path,
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await Share.shareXFiles([XFile(file.path)], text: 'Workspace logs');
                      } catch (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Не удалось отправить файл логов')),
                        );
                      }
                      if (Navigator.of(ctx).canPop()) {
                        Navigator.of(ctx).pop();
                      }
                    },
                    icon: const Icon(Icons.ios_share),
                    label: const Text('Поделиться'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Закрыть'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<File?> _getLogFile() async {
    final logsCubit = context.read<LogsCubit>();
    final path = await logsCubit.getLogFilePath();
    if (!mounted) return null;

    if (path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Файл логов недоступен')),
      );
      return null;
    }

    final file = File(path);
    if (!await file.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Файл логов не найден')),
      );
      return null;
    }

    return file;
  }

  Future<Directory?> _resolveDownloadsDir() async {
    if (platformInfo.isMobile && Platform.isAndroid) {
      try {
        final dirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
        if (dirs != null && dirs.isNotEmpty) {
          return dirs.first;
        }
      } catch (_) {
        // ignore and fallback below
      }
      final fallback = Directory('/storage/emulated/0/Download');
      if (await fallback.exists()) return fallback;
    }

    if (!platformInfo.isMobile) {
      try {
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) return downloadsDir;
      } catch (_) {
        // ignore and fallback below
      }
      final home = Platform.environment['HOME'] ?? Platform.environment['UserProfile'];
      if (home != null && home.isNotEmpty) {
        final fallback = Directory(p.join(home, 'Downloads'));
        if (await fallback.exists()) return fallback;
      }
    }

    return null;
  }
}
