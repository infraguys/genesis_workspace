import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/domain/download_files/entities/download_file_entity.dart';
import 'package:genesis_workspace/features/download_files/bloc/download_files_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class DownloadFilesButton extends StatefulWidget {
  DownloadFilesButton({super.key});

  @override
  State<DownloadFilesButton> createState() => _DownloadFilesButtonState();
}

class _DownloadFilesButtonState extends State<DownloadFilesButton> with SingleTickerProviderStateMixin {
  final GlobalKey<CustomPopupState> _downloadFilesKey = GlobalKey();

  Timer? _downloadFinishedTimer;
  bool _showDownloadFinishedIcon = false;
  bool _lastIsFinished = true;
  int _lastDuplicateRequestTick = 0;

  late final AnimationController _duplicateAnimationController;
  late final Animation<double> _duplicateScaleAnimation;

  @override
  void initState() {
    super.initState();
    _duplicateAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _duplicateScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 1.15).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_duplicateAnimationController);
  }

  @override
  void dispose() {
    _downloadFinishedTimer?.cancel();
    _duplicateAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColors = theme.extension<TextColors>()!;

    return BlocConsumer<DownloadFilesCubit, DownloadFilesState>(
      listenWhen: (prev, current) =>
          prev.isFinished != current.isFinished || prev.duplicateRequestTick != current.duplicateRequestTick,
      listener: (context, state) {
        if (!mounted) return;
        if (_lastDuplicateRequestTick != state.duplicateRequestTick) {
          _lastDuplicateRequestTick = state.duplicateRequestTick;
          _duplicateAnimationController.forward(from: 0);
        }

        if (_lastIsFinished == state.isFinished) return;
        _lastIsFinished = state.isFinished;
        if (!state.isFinished) {
          _downloadFinishedTimer?.cancel();
          if (_showDownloadFinishedIcon) {
            setState(() => _showDownloadFinishedIcon = false);
          }
          return;
        }
        if (state.files.isEmpty) return;
        _downloadFinishedTimer?.cancel();
        setState(() => _showDownloadFinishedIcon = true);
        _downloadFinishedTimer = Timer(const Duration(seconds: 1), () {
          if (!mounted) return;
          setState(() => _showDownloadFinishedIcon = false);
        });
      },
      builder: (context, state) {
        final lastDownloadingFile = state.files.lastWhere(
          (file) => file is DownloadingFileEntity,
          orElse: () => DownloadedFileEntity(
            pathToFile: "-1",
            fileName: '',
            bytes: Uint8List(0),
            localFilePath: '',
          ),
        );
        if (state.files.isNotEmpty) {
          final bool showSuccessIcon = state.isFinished && _showDownloadFinishedIcon;
          return CustomPopup(
            key: _downloadFilesKey,
            rootNavigator: true,
            position: PopupPosition.bottom,
            backgroundColor: theme.colorScheme.surface,
            content: BlocProvider.value(
              value: context.read<DownloadFilesCubit>(),
              child: _DownloadFilesPopupContent(textColors: textColors),
            ),
            child: Stack(
              alignment: AlignmentGeometry.center,
              children: [
                if (!state.isFinished && !showSuccessIcon && lastDownloadingFile is DownloadingFileEntity)
                  CircularProgressIndicator(
                    value: lastDownloadingFile.progress / lastDownloadingFile.total,
                  ),
                ScaleTransition(
                  scale: _duplicateScaleAnimation,
                  child: IconButton(
                    onPressed: () {
                      _downloadFilesKey.currentState?.show();
                    },
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) {
                        final bool isCheck = child.key == const ValueKey('downloadFinished');
                        if (isCheck) {
                          final slideAnimation = Tween<Offset>(
                            begin: const Offset(0, -1),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.bounceInOut)).animate(animation);
                          final bounceScale = CurvedAnimation(parent: animation, curve: Curves.elasticOut);

                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: slideAnimation,
                              child: ScaleTransition(scale: bounceScale, child: child),
                            ),
                          );
                        }

                        final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(scale: curved, child: child),
                        );
                      },
                      child: showSuccessIcon
                          ? Icon(
                              Icons.check,
                              key: const ValueKey('downloadFinished'),
                              color: AppColors.callGreen,
                            )
                          : Icon(
                              Icons.file_download_outlined,
                              key: const ValueKey('downloadInProgress'),
                              color: state.isFinished ? AppColors.callGreen : textColors.text30,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}

class _DownloadFilesPopupContent extends StatelessWidget {
  const _DownloadFilesPopupContent({required this.textColors});

  final TextColors textColors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<DownloadFilesCubit, DownloadFilesState>(
      builder: (context, state) {
        return Container(
          width: 240,
          constraints: const BoxConstraints(maxHeight: 260),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: state.files.isEmpty
              ? Center(
                  child: Text(
                    context.t.downloadFiles.noDownloads,
                    style: theme.textTheme.bodyMedium?.copyWith(color: textColors.text30),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: state.files.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    final file = state.files[index];
                    return ListTile(
                      dense: false,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      leading: _buildLeading(file),
                      onTap: () async {
                        if (file is DownloadedFileEntity && !kIsWeb) {
                          await context.read<DownloadFilesCubit>().openFile(file.localFilePath);
                        }
                      },
                      title: Text(
                        file.fileName,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: _buildSubtitle(context, file, theme),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildLeading(DownloadFileEntity file) {
    if (file is DownloadingFileEntity) {
      final double? value = file.total > 0 ? file.progress / file.total : null;
      return SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          value: value != null ? value.clamp(0, 1) : null,
        ),
      );
    }
    return CircleAvatar(
      radius: 16,
      backgroundColor: AppColors.callGreen.withValues(alpha: 0.15),
      child: Icon(Icons.check, size: 18, color: AppColors.callGreen),
    );
  }

  Widget? _buildSubtitle(BuildContext context, DownloadFileEntity file, ThemeData theme) {
    if (file is! DownloadingFileEntity) {
      return Text(
        context.t.downloadFiles.ready,
        style: theme.textTheme.bodySmall,
      );
    }

    final int progress = file.progress;
    final int total = file.total;
    if (total <= 0) {
      return Text(
        formatFileSize(progress),
        style: theme.textTheme.bodySmall,
      );
    }
    final double percent = (progress / total * 100).clamp(0, 100);
    return Text(
      '${percent.toStringAsFixed(0)}% • ${formatFileSize(progress)} / ${formatFileSize(total)}',
      style: theme.textTheme.bodySmall,
    );
  }
}
