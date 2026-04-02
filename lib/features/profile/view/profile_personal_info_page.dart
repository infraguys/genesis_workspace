import 'package:dio/dio.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_emoji/flutter_emoji.dart' as flutter_emoji;
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/config/emoji_picker_config.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/core/widgets/emoji.dart';
import 'package:genesis_workspace/core/widgets/profile_info_tile.dart';
import 'package:genesis_workspace/core/widgets/snackbar.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/domain/common/entities/exception_entity.dart';
import 'package:genesis_workspace/domain/users/entities/update_my_status_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_status_entity.dart';
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class ProfilePersonalInfoPage extends StatelessWidget {
  const ProfilePersonalInfoPage({super.key, required this.onBack, this.onClose});

  final VoidCallback onBack;
  final VoidCallback? onClose;

  Future<void> shareProfile(
    BuildContext context, {
    required int userId,
  }) async {
    final theme = Theme.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final linkCopiedText = context.t.profilePersonalInfo.linkCopied;
    final url = "${AppConstants.baseUrl}/#user/$userId";
    await Clipboard.setData(ClipboardData(text: url));
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          linkCopiedText,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _onEditStatusTap(
    BuildContext context, {
    required UserStatusEntity? currentStatus,
  }) async {
    final profileCubit = context.read<ProfileCubit>();
    final dialogResult = await _showEditStatusDialog(context, currentStatus: currentStatus);
    if (!context.mounted) {
      return;
    }

    if (dialogResult == null) {
      return;
    }

    try {
      await profileCubit.updateStatus(
        UpdateMyStatusRequestEntity(
          statusText: dialogResult.statusText,
          emojiName: dialogResult.emojiName,
          emojiCode: dialogResult.emojiCode,
        ),
      );
    } on DioException catch (e) {
      if (!context.mounted) {
        return;
      }
      showErrorSnackBar(context, exception: e);
    } on ServerExceptionEntity catch (e) {
      if (!context.mounted) {
        return;
      }
      showErrorSnackBar(context, exception: e);
    }
  }

  Future<_StatusDialogResult?> _showEditStatusDialog(
    BuildContext context, {
    required UserStatusEntity? currentStatus,
  }) async {
    return await showDialog<_StatusDialogResult>(
      context: context,
      builder: (_) => _EditStatusDialog(currentStatus: currentStatus),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColors = theme.extension<IconColors>()!;
    final isMobile = currentSize(context) <= .tablet;

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final user = state.user;

        return Scaffold(
          backgroundColor: isMobile ? theme.scaffoldBackgroundColor : theme.colorScheme.surface,
          appBar: AppBar(
            leading: IconButton(
              onPressed: onBack,
              icon: Assets.icons.arrowLeft.svg(
                colorFilter: ColorFilter.mode(iconColors.base, .srcIn),
              ),
            ),
            backgroundColor: isMobile ? theme.scaffoldBackgroundColor : theme.colorScheme.surface,
            centerTitle: isMobile,
            title: Text(
              context.t.profilePersonalInfo.title,
              style: theme.textTheme.labelLarge,
            ),
            actions: [
              if (!isMobile)
                IconButton(
                  onPressed: onClose,
                  icon: Assets.icons.close.svg(
                    colorFilter: ColorFilter.mode(iconColors.base, .srcIn),
                  ),
                ),
              if (isMobile) ...[
                IconButton(
                  onPressed: state.user != null
                      ? () async {
                          await shareProfile(context, userId: user!.userId);
                        }
                      : null,
                  icon: Assets.icons.link.svg(
                    width: 24,
                    colorFilter: ColorFilter.mode(iconColors.base, .srcIn),
                  ),
                ),
              ],
            ],
          ),
          body: Builder(
            builder: (context) {
              if (user == null) {
                return const Center(child: CircularProgressIndicator());
              }
              final statusText = user.status?.statusText?.trim();
              final resolvedStatusText = (statusText != null && statusText.isNotEmpty)
                  ? statusText
                  : context.t.profilePersonalInfo.noStatusText;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      UserAvatar(avatarUrl: user.avatarUrl, size: 56),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.t.online,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (!isMobile) ...[
                    ListTile(
                      leading: Assets.icons.link.svg(),
                      contentPadding: .zero,
                      onTap: () async {
                        await shareProfile(context, userId: user.userId);
                      },
                      title: Text(
                        context.t.profilePersonalInfo.shareProfile,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Divider(
                      color: theme.dividerColor.withValues(alpha: 0.1),
                    ),
                  ],
                  ProfileInfoTile(
                    label: context.t.status,
                    value: resolvedStatusText,
                    icon: SizedBox(
                      width: 32,
                      child: Center(
                        child: _buildStatusEmojiWidget(
                          context,
                          emojiName: user.status?.emojiName,
                          emojiCode: user.status?.emojiCode,
                          size: 20,
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      splashRadius: 18,
                      onPressed: () async {
                        await _onEditStatusTap(context, currentStatus: user.status);
                      },
                      icon: Assets.icons.editIcon.svg(
                        width: 18,
                        height: 18,
                        colorFilter: ColorFilter.mode(iconColors.base, .srcIn),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ProfileInfoTile(
                    label: context.t.email,
                    value: user.email,
                    icon: SizedBox(
                      width: 32,
                      child: Assets.icons.mail.svg(
                        width: 24,
                        colorFilter: ColorFilter.mode(iconColors.base, .srcIn),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  ProfileInfoTile(
                    label: context.t.profilePersonalInfo.userId,
                    value: user.userId.toString(),
                    icon: Assets.icons.alternateEmail.svg(
                      colorFilter: ColorFilter.mode(iconColors.base, .srcIn),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  ProfileInfoTile(
                    label: context.t.profilePersonalInfo.timezone,
                    value: user.timezone,
                    icon: Assets.icons.schedule.svg(
                      colorFilter: ColorFilter.mode(iconColors.base, .srcIn),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  ProfileInfoTile(
                    label: context.t.profilePersonalInfo.teamAndPosition,
                    value: user.jobTitle,
                    icon: Assets.icons.businessCenter.svg(
                      colorFilter: ColorFilter.mode(iconColors.base, .srcIn),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  ProfileInfoTile(
                    label: context.t.profilePersonalInfo.manager,
                    value: user.bossName,
                    icon: Assets.icons.handshake.svg(
                      colorFilter: ColorFilter.mode(iconColors.base, .srcIn),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

Widget _buildStatusEmojiWidget(
  BuildContext context, {
  required String? emojiName,
  required String? emojiCode,
  required double size,
}) {
  final theme = Theme.of(context);
  final iconColors = theme.extension<IconColors>()!;
  final normalizedEmojiCode = _normalizeStatusValue(emojiCode);
  final normalizedEmojiName = _normalizeStatusValue(emojiName);

  if (normalizedEmojiCode != null) {
    return UnicodeEmojiWidget(
      emojiDisplay: UserStatusEntity(
        emojiName: normalizedEmojiName,
        emojiCode: normalizedEmojiCode,
      ).emojiDisplay,
      size: size,
    );
  }

  return Assets.icons.smile.svg(
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(iconColors.base, .srcIn),
  );
}

String? _normalizeStatusValue(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

class _EditStatusDialog extends StatefulWidget {
  const _EditStatusDialog({required this.currentStatus});

  final UserStatusEntity? currentStatus;

  @override
  State<_EditStatusDialog> createState() => _EditStatusDialogState();
}

class _EditStatusDialogState extends State<_EditStatusDialog> {
  final flutter_emoji.EmojiParser _parser = flutter_emoji.EmojiParser();
  late final TextEditingController _textController;

  String? _selectedEmojiName;
  String? _selectedEmojiCode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.currentStatus?.statusText ?? '');
    _selectedEmojiName = _normalizeStatusValue(widget.currentStatus?.emojiName);
    _selectedEmojiCode = _normalizeStatusValue(widget.currentStatus?.emojiCode);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _openEmojiPicker() async {
    final pickedEmoji = await showModalBottomSheet<_StatusEmojiSelection>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(context);
        final sheetTheme = Theme.of(sheetContext);
        return SizedBox(
          height: 360,
          child: BlocBuilder<EmojiKeyboardCubit, EmojiKeyboardState>(
            builder: (context, state) {
              return EmojiPicker(
                onEmojiSelected: (_, emoji) {
                  final selected = _parser.getEmoji(emoji.emoji);
                  final emojiCode = emojiToCode(emoji.emoji);
                  final name = state.emojiMap[emojiCode]?.first ?? selected.name;
                  Navigator.of(sheetContext).pop(
                    _StatusEmojiSelection(
                      emojiName: name,
                      emojiCode: emojiCode,
                    ),
                  );
                },
                config: emojiPickerConfig(context, theme: theme, allowedCodes: state.organizationEmojiCodes),
              );
            },
          ),
        );
      },
    );

    if (!mounted || pickedEmoji == null) {
      return;
    }

    setState(() {
      _selectedEmojiName = _normalizeStatusValue(pickedEmoji.emojiName);
      _selectedEmojiCode = _normalizeStatusValue(pickedEmoji.emojiCode);
    });
  }

  void _applyPreset(_DefaultStatusPreset preset) {
    _textController.text = preset.statusText;
    _textController.selection = TextSelection.collapsed(offset: _textController.text.length);
    setState(() {
      _selectedEmojiName = preset.emojiName;
      _selectedEmojiCode = preset.emojiCode;
    });
  }

  void _save() {
    Navigator.of(context).pop(
      _StatusDialogResult(
        statusText: _textController.text.trim(),
        emojiName: _selectedEmojiName ?? '',
        emojiCode: _selectedEmojiCode ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final presets = _defaultStatusPresets(context);

    return AlertDialog(
      title: Text(context.t.status),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: presets.map((preset) {
                  final isSelected =
                      _textController.text.trim() == preset.statusText && _selectedEmojiCode == preset.emojiCode;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      mouseCursor: SystemMouseCursors.click,
                      onSelected: (_) => _applyPreset(preset),
                      avatar: UnicodeEmojiWidget(
                        emojiDisplay: UserStatusEntity(
                          emojiName: preset.emojiName,
                          emojiCode: preset.emojiCode,
                        ).emojiDisplay,
                        size: 16,
                      ),
                      label: Text(preset.statusText),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _openEmojiPicker,
                    mouseCursor: SystemMouseCursors.click,
                    child: Ink(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                      ),
                      child: Center(
                        child: _buildStatusEmojiWidget(
                          context,
                          emojiName: _selectedEmojiName,
                          emojiCode: _selectedEmojiCode,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: context.t.profilePersonalInfo.statusDialog.hint,
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _save(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.t.profilePersonalInfo.statusDialog.cancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(context.t.profilePersonalInfo.statusDialog.save),
        ),
      ],
    );
  }
}

class _StatusDialogResult {
  const _StatusDialogResult({
    required this.statusText,
    required this.emojiName,
    required this.emojiCode,
  });

  final String statusText;
  final String emojiName;
  final String emojiCode;
}

class _StatusEmojiSelection {
  const _StatusEmojiSelection({
    required this.emojiName,
    required this.emojiCode,
  });

  final String emojiName;
  final String emojiCode;
}

class _DefaultStatusPreset {
  const _DefaultStatusPreset({
    required this.statusText,
    required this.emojiName,
    required this.emojiCode,
  });

  final String statusText;
  final String emojiName;
  final String emojiCode;
}

List<_DefaultStatusPreset> _defaultStatusPresets(BuildContext context) => [
  _DefaultStatusPreset(
    statusText: context.t.profilePersonalInfo.statusDialog.presets.busy,
    emojiName: 'working_on_it',
    emojiCode: '1f6e0',
  ),
  _DefaultStatusPreset(
    statusText: context.t.profilePersonalInfo.statusDialog.presets.inMeeting,
    emojiName: 'calendar',
    emojiCode: '1f4c5',
  ),
  _DefaultStatusPreset(
    statusText: context.t.profilePersonalInfo.statusDialog.presets.onTheRoad,
    emojiName: 'bus',
    emojiCode: '1f68c',
  ),
  _DefaultStatusPreset(
    statusText: context.t.profilePersonalInfo.statusDialog.presets.sick,
    emojiName: 'hurt',
    emojiCode: '1f915',
  ),
  _DefaultStatusPreset(
    statusText: context.t.profilePersonalInfo.statusDialog.presets.onVacation,
    emojiName: 'palm_tree',
    emojiCode: '1f334',
  ),
  _DefaultStatusPreset(
    statusText: context.t.profilePersonalInfo.statusDialog.presets.workingRemotely,
    emojiName: 'house',
    emojiCode: '1f3e0',
  ),
  _DefaultStatusPreset(
    statusText: context.t.profilePersonalInfo.statusDialog.presets.inOffice,
    emojiName: 'office',
    emojiCode: '1f3e2',
  ),
];
