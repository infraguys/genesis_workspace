import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/enums/folder_system_type.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class SelectFoldersDialog extends StatefulWidget {
  final Future<List<int>> Function() loadSelectedFolderIds;
  final Future<void> Function(List<int> folderIds) onSave;
  final List<FolderEntity> folders;

  const SelectFoldersDialog({
    super.key,
    required this.loadSelectedFolderIds,
    required this.onSave,
    required this.folders,
  });

  @override
  State<SelectFoldersDialog> createState() => _SelectFoldersDialogState();
}

class _SelectFoldersDialogState extends State<SelectFoldersDialog> {
  List<int> _selectedIds = [];
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _load();
  }

  Future<void> _load() async {
    final ids = await widget.loadSelectedFolderIds();
    if (!mounted) return;
    setState(() => _selectedIds = List<int>.from(ids));
  }

  @override
  Widget build(BuildContext context) {
    final List<FolderEntity> userFolders = widget.folders
        .where((f) => f.systemType != FolderSystemType.all && f.id != null)
        .toList();
    return Dialog(
      child: SizedBox(
        width: 420,
        child: FutureBuilder(
          future: _initFuture,
          builder: (_, snapshot) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.t.folders.selectFolders,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: userFolders.length,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return SizedBox.shrink();
                      }
                      final f = userFolders[index];
                      final id = f.id!;
                      final selected = _selectedIds.contains(id);
                      return CheckboxListTile(
                        value: selected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              if (!_selectedIds.contains(id)) {
                                _selectedIds.add(id);
                              }
                            } else {
                              _selectedIds.remove(id);
                            }
                          });
                        },
                        dense: true,
                        title: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: f.backgroundColor?.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black12),
                              ),
                              // child: Icon(f.iconData, size: 16, color: f.backgroundColor),
                            ),
                            const SizedBox(width: 8),
                            Text(f.title ?? ''),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(context.t.folders.cancel),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          await widget.onSave(_selectedIds);
                          if (mounted) Navigator.of(context).pop();
                        },
                        child: Text(context.t.folders.save),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
