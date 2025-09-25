import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_target.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/folder_membership_repository.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/add_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/delete_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_folder_ids_for_target_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_folders_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/remove_all_memberships_for_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/set_folders_for_target_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/update_folder_use_case.dart';
import 'package:genesis_workspace/domain/users/entities/channel_entity.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:injectable/injectable.dart';

part 'all_chats_state.dart';

@injectable
class AllChatsCubit extends Cubit<AllChatsState> {
  final AddFolderUseCase _addFolderUseCase;
  final GetFoldersUseCase _getFoldersUseCase;
  final UpdateFolderUseCase _updateFolderUseCase;
  final DeleteFolderUseCase _deleteFolderUseCase;
  final SetFoldersForTargetUseCase _setFoldersForTargetUseCase;
  final GetFolderIdsForTargetUseCase _getFolderIdsForTargetUseCase;
  final RemoveAllMembershipsForFolderUseCase _removeAllMembershipsForFolderUseCase;

  AllChatsCubit(
    this._addFolderUseCase,
    this._getFoldersUseCase,
    this._updateFolderUseCase,
    this._deleteFolderUseCase,
    this._setFoldersForTargetUseCase,
    this._getFolderIdsForTargetUseCase,
    this._removeAllMembershipsForFolderUseCase,
  ) : super(
        AllChatsState(
          selectedChannel: null,
          selectedDmChat: null,
          selectedTopic: null,
          folders: [
            FolderItemEntity(
              systemType: SystemFolderType.all,
              iconData: Icons.markunread,
              unreadCount: 0,
            ),
          ],
          selectedFolderIndex: 0,
        ),
      );

  Future<void> addFolder(FolderItemEntity folder) async {
    try {
      await _addFolderUseCase.call(folder);
      await loadFolders();
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> loadFolders() async {
    final List<FolderItemEntity> dbFolders = await _getFoldersUseCase.call();
    final List<FolderItemEntity> withSystem = [
      FolderItemEntity(
        systemType: SystemFolderType.all,
        iconData: Icons.markunread,
        unreadCount: 0,
      ),
      ...dbFolders,
    ];
    final int currentIdx = state.selectedFolderIndex;
    final int clampedIdx = currentIdx.clamp(0, withSystem.length - 1);
    emit(state.copyWith(folders: withSystem, selectedFolderIndex: clampedIdx));
    await _applyFolderFilter();
  }

  Future<void> updateFolder(FolderItemEntity folder) async {
    if (folder.systemType != null || folder.id == null) return;
    await _updateFolderUseCase(folder);
    await loadFolders();
  }

  Future<void> deleteFolder(FolderItemEntity folder) async {
    if (folder.systemType != null || folder.id == null) return;
    await _removeAllMembershipsForFolderUseCase(folder.id!);
    await _deleteFolderUseCase(folder.id!);
    await loadFolders();
  }

  Future<void> setFoldersForDm(int userId, List<int> folderIds) async {
    await _setFoldersForTargetUseCase(FolderTarget.dm(userId), folderIds);
    _applyFolderFilter();
  }

  Future<void> setFoldersForChannel(int streamId, List<int> folderIds) async {
    await _setFoldersForTargetUseCase(FolderTarget.channel(streamId), folderIds);
    _applyFolderFilter();
  }

  Future<List<int>> getFolderIdsForDm(int userId) {
    return _getFolderIdsForTargetUseCase(FolderTarget.dm(userId));
  }

  Future<List<int>> getFolderIdsForChannel(int streamId) {
    return _getFolderIdsForTargetUseCase(FolderTarget.channel(streamId));
  }

  void selectDmChat(DmUserEntity? dmUserEntity) {
    emit(state.copyWith(selectedDmChat: dmUserEntity, selectedTopic: null, selectedChannel: null));
    _applyFolderFilter();
  }

  void selectChannel({ChannelEntity? channel, TopicEntity? topic}) {
    emit(state.copyWith(selectedChannel: channel, selectedTopic: topic, selectedDmChat: null));
    _applyFolderFilter();
  }

  void selectFolder(int newIndex) {
    emit(state.copyWith(selectedFolderIndex: newIndex));
    _applyFolderFilter();
  }

  Future<void> _applyFolderFilter() async {
    final int idx = state.selectedFolderIndex;
    if (idx <= 0 || idx >= state.folders.length) {
      emit(state.copyWith(filterDmUserIds: null, filterChannelIds: null));
      return;
    }
    final FolderItemEntity folder = state.folders[idx];
    if (folder.id == null) {
      emit(state.copyWith(filterDmUserIds: null, filterChannelIds: null));
      return;
    }
    final repo = getIt<FolderMembershipRepository>();
    final members = await repo.getMembersForFolder(folder.id!);
    emit(
      state.copyWith(
        filterDmUserIds: members.dmUserIds.toSet(),
        filterChannelIds: members.channelIds.toSet(),
      ),
    );
  }
}
