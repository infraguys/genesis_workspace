import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_target.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/add_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/delete_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_folder_ids_for_target_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_folders_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_members_for_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_pinned_chats_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/pin_chat_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/remove_all_memberships_for_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/set_folders_for_target_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/unpin_chat_use_case.dart';
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
  final GetMembersForFolderUseCase _getMembersForFolderUseCase;
  final GetPinnedChatsUseCase _getPinnedChatsUseCase;
  final PinChatUseCase _pinChatUseCase;
  final UnpinChatUseCase _unpinChatUseCase;

  AllChatsCubit(
    this._addFolderUseCase,
    this._getFoldersUseCase,
    this._updateFolderUseCase,
    this._deleteFolderUseCase,
    this._setFoldersForTargetUseCase,
    this._getFolderIdsForTargetUseCase,
    this._removeAllMembershipsForFolderUseCase,
    this._getMembersForFolderUseCase,
    this._getPinnedChatsUseCase,
    this._pinChatUseCase,
    this._unpinChatUseCase,
  ) : super(
        AllChatsState(
          selectedChannel: null,
          selectedDmChat: null,
          selectedTopic: null,
          folders: [],
          selectedFolderIndex: 0,
        ),
      );

  Future<void> addFolder(FolderItemEntity folder) async {
    try {
      await _addFolderUseCase.call(folder);
      final updatedFolders = [...state.folders];
      updatedFolders.add(folder);
      emit(state.copyWith(folders: updatedFolders));
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> loadFolders() async {
    try {
      final List<FolderItemEntity> dbFolders = await _getFoldersUseCase.call();
      if (dbFolders.isEmpty) {
        final initFolder = FolderItemEntity(
          id: 0,
          title: 'All',
          systemType: SystemFolderType.all,
          iconData: Icons.markunread,
          unreadCount: 0,
          pinnedChats: [],
        );
        await addFolder(initFolder);
        return;
      }
      final List<FolderItemEntity> initialFolders = [...dbFolders];
      emit(state.copyWith(folders: initialFolders, selectedFolderIndex: 0));
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> pinChat({required int chatId}) async {
    try {
      final int folderId = state.folders[state.selectedFolderIndex].id!;
      await _pinChatUseCase.call(folderId: folderId, chatId: chatId);
      List<FolderItemEntity> updatedFolders = [...state.folders];
      FolderItemEntity folder = updatedFolders.firstWhere((folder) => folder.id == folderId);
      final int indexOfFolder = updatedFolders.indexOf(folder);
      final pinnedChats = await _getPinnedChatsUseCase.call(folderId);
      folder = folder.copyWith(pinnedChats: pinnedChats);
      updatedFolders[indexOfFolder] = folder;
      emit(state.copyWith(folders: updatedFolders));
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> unpinChat(int pinnedChatId) async {
    try {
      final int folderId = state.folders[state.selectedFolderIndex].id!;
      await _unpinChatUseCase.call(pinnedChatId);
      List<FolderItemEntity> updatedFolders = [...state.folders];
      FolderItemEntity folder = updatedFolders.firstWhere((folder) => folder.id == folderId);
      final int indexOfFolder = updatedFolders.indexOf(folder);
      final pinnedChats = await _getPinnedChatsUseCase.call(folderId);
      folder = folder.copyWith(pinnedChats: pinnedChats);
      updatedFolders[indexOfFolder] = folder;
      inspect(updatedFolders);
      emit(state.copyWith(folders: updatedFolders));
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> updateFolder(FolderItemEntity folder) async {
    if (folder.systemType != null || folder.id == null) return;
    final updatedFolders = [...state.folders];
    final index = updatedFolders.indexWhere((element) => element.id == folder.id);
    await _updateFolderUseCase(folder);
    updatedFolders[index] = folder;
    emit(state.copyWith(folders: updatedFolders));
  }

  Future<void> deleteFolder(FolderItemEntity folder) async {
    if (folder.systemType != null || folder.id == null) return;
    final updatedFolders = [...state.folders];
    final index = updatedFolders.indexWhere((element) => element.id == folder.id);
    await _removeAllMembershipsForFolderUseCase.call(folder.id!);
    await _deleteFolderUseCase.call(folder.id!);
    updatedFolders.removeAt(index);
    emit(state.copyWith(folders: updatedFolders));
  }

  Future<void> setFoldersForDm(int userId, List<int> folderIds) async {
    await _setFoldersForTargetUseCase.call(FolderTarget.dm(userId), folderIds);
    await _applyFolderFilter();
  }

  Future<void> setFoldersForChannel(int streamId, List<int> folderIds) async {
    await _setFoldersForTargetUseCase.call(FolderTarget.channel(streamId), folderIds);
    await _applyFolderFilter();
  }

  Future<List<int>> getFolderIdsForDm(int userId) async {
    return await _getFolderIdsForTargetUseCase.call(FolderTarget.dm(userId));
  }

  Future<List<int>> getFolderIdsForChannel(int streamId) async {
    return await _getFolderIdsForTargetUseCase.call(FolderTarget.channel(streamId));
  }

  void selectDmChat(DmUserEntity? dmUserEntity) async {
    state.selectedTopic = null;
    state.selectedChannel = null;
    emit(
      state.copyWith(
        selectedDmChat: dmUserEntity,
        selectedTopic: state.selectedTopic,
        selectedChannel: state.selectedChannel,
      ),
    );
  }

  void selectChannel({ChannelEntity? channel, TopicEntity? topic}) async {
    state.selectedDmChat = null;
    emit(
      state.copyWith(
        selectedChannel: channel,
        selectedTopic: topic,
        selectedDmChat: state.selectedDmChat,
      ),
    );
  }

  void selectFolder(int newIndex) async {
    if (state.selectedFolderIndex == newIndex) return;
    emit(state.copyWith(selectedFolderIndex: newIndex));
    FolderItemEntity folder = state.folders[newIndex];
    if (folder.id == null) {
      state.filterChannelIds = null;
      state.filterDmUserIds = null;
      emit(
        state.copyWith(
          filterDmUserIds: state.filterDmUserIds,
          filterChannelIds: state.filterChannelIds,
        ),
      );
      return;
    }
    final members = await _getMembersForFolderUseCase.call(folder.id!);
    emit(
      state.copyWith(
        filterDmUserIds: members.dmUserIds.toSet(),
        filterChannelIds: members.channelIds.toSet(),
      ),
    );
  }

  Future<void> _applyFolderFilter() async {
    final int idx = state.selectedFolderIndex;
    if (idx <= 0 || idx >= state.folders.length) {
      state.filterChannelIds = null;
      state.filterDmUserIds = null;
      emit(
        state.copyWith(
          filterDmUserIds: state.filterDmUserIds,
          filterChannelIds: state.filterChannelIds,
        ),
      );
      return;
    }
    FolderItemEntity folder = state.folders[idx];

    if (folder.id == null) {
      state.filterChannelIds = null;
      state.filterDmUserIds = null;
      emit(
        state.copyWith(
          filterDmUserIds: state.filterDmUserIds,
          filterChannelIds: state.filterChannelIds,
        ),
      );
      return;
    }

    final members = await _getMembersForFolderUseCase.call(folder.id!);
    emit(
      state.copyWith(
        filterDmUserIds: members.dmUserIds.toSet(),
        filterChannelIds: members.channelIds.toSet(),
      ),
    );
  }
}
