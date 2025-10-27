import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/data/all_chats/tables/pinned_chats_table.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_members.dart';
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
import 'package:genesis_workspace/domain/all_chats/usecases/update_pinned_chat_order_use_case.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:injectable/injectable.dart';

part 'messenger_state.dart';

@injectable
class MessengerCubit extends Cubit<MessengerState> {
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
  final UpdatePinnedChatOrderUseCase _updatePinnedChatOrderUseCase;

  MessengerCubit(
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
    this._updatePinnedChatOrderUseCase,
  ) : super(MessengerState(folders: [], selectedFolderIndex: 0, folderMembersById: const {}));

  Future<void> addFolder(FolderItemEntity folder) async {
    try {
      await _addFolderUseCase.call(folder);
      final updatedFolders = [...state.folders];
      updatedFolders.add(folder.copyWith(id: updatedFolders.length));
      emit(state.copyWith(folders: updatedFolders));
      await _refreshAllFolderMembers();
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> loadFolders() async {
    try {
      final int? organizationId = AppConstants.selectedOrganizationId;
      if (organizationId == null) {
        return;
      }

      final List<FolderItemEntity> dbFolders = await _getFoldersUseCase.call(organizationId);
      if (dbFolders.isEmpty) {
        final initFolder = FolderItemEntity(
          id: 0,
          title: 'All',
          systemType: SystemFolderType.all,
          iconData: Icons.markunread,
          unreadCount: 0,
          pinnedChats: [],
          organizationId: organizationId,
        );
        await addFolder(initFolder);
        return;
      }
      final List<FolderItemEntity> initialFolders = [...dbFolders];
      emit(state.copyWith(folders: initialFolders, selectedFolderIndex: 0));
      await _refreshAllFolderMembers();
    } catch (e) {
      inspect(e);
    }
  }

  void selectFolder(int newIndex) async {
    if (state.selectedFolderIndex == newIndex) return;
    emit(state.copyWith(selectedFolderIndex: newIndex));
    // FolderItemEntity folder = state.folders[newIndex];
    // if (folder.id == null) {
    //   state.filterChannelIds = null;
    //   state.filterDmUserIds = null;
    //   state.filterGroupChatIds = null;
    //   emit(
    //     state.copyWith(
    //       filterDmUserIds: state.filterDmUserIds,
    //       filterChannelIds: state.filterChannelIds,
    //       filterGroupChatIds: state.filterGroupChatIds,
    //     ),
    //   );
    //   return;
    // }
    // final members = await _getMembersForFolderUseCase.call(folder.id!);
    // emit(
    // state.copyWith(
    // filterDmUserIds: members.dmUserIds.toSet(),
    // filterChannelIds: members.channelIds.toSet(),
    // filterGroupChatIds: members.groupChatIds.toSet(),
    // ),
    // );
  }

  Future<void> updateFolder(FolderItemEntity folder) async {
    if (folder.systemType != null || folder.id == null) return;
    final updatedFolders = [...state.folders];
    final index = updatedFolders.indexWhere((element) => element.id == folder.id);
    await _updateFolderUseCase.call(folder);
    updatedFolders[index] = folder;
    emit(state.copyWith(folders: updatedFolders));
    await _refreshMembersForFolders([folder.id!]);
  }

  Future<void> deleteFolder(FolderItemEntity folder) async {
    if (folder.id == 0) return;
    if (folder.systemType != null || folder.id == null) return;
    final int? organizationId = AppConstants.selectedOrganizationId;
    if (organizationId == null) return;
    final updatedFolders = [...state.folders];
    final index = updatedFolders.indexWhere((element) => element.id == folder.id);
    await _removeAllMembershipsForFolderUseCase.call(
      folder.id!,
      organizationId: organizationId,
    );
    await _deleteFolderUseCase.call(folder.id!);
    updatedFolders.removeAt(index);
    final updatedMap = Map<int, FolderMembers>.from(state.folderMembersById);
    updatedMap.remove(folder.id!);
    emit(
      state.copyWith(
        folders: updatedFolders,
        folderMembersById: updatedMap,
        selectedFolderIndex: 0,
      ),
    );
  }

  Future<void> _refreshMembersForFolders(Iterable<int> folderIds) async {
    final int? organizationId = AppConstants.selectedOrganizationId;
    if (organizationId == null) return;
    final idsToRefresh = folderIds.where((id) => id != 0);
    if (idsToRefresh.isEmpty) return;

    final futures = idsToRefresh.map((id) async {
      final members = await _getMembersForFolderUseCase.call(
        id,
        organizationId: organizationId,
      );
      return MapEntry(id, members);
    });

    final newEntries = await Future.wait(futures);
    final updatedMap = Map<int, FolderMembers>.from(state.folderMembersById)
      ..addEntries(newEntries);

    emit(state.copyWith(folderMembersById: updatedMap));
  }

  Future<void> pinChat({required int chatId, required PinnedChatType type}) async {
    try {
      final int? organizationId = AppConstants.selectedOrganizationId;
      if (organizationId == null) return;
      final int folderId = state.folders[state.selectedFolderIndex].id!;
      List<FolderItemEntity> updatedFolders = [...state.folders];
      FolderItemEntity folder = updatedFolders.firstWhere((folder) => folder.id == folderId);
      await _pinChatUseCase.call(
        folderId: folderId,
        chatId: chatId,
        orderIndex: folder.pinnedChats.length,
        type: type,
        organizationId: organizationId,
      );
      final int indexOfFolder = updatedFolders.indexOf(folder);
      final pinnedChats = await _getPinnedChatsUseCase.call(
        folderId: folderId,
        organizationId: organizationId,
      );
      folder = folder.copyWith(pinnedChats: pinnedChats);
      updatedFolders[indexOfFolder] = folder;
      emit(state.copyWith(folders: updatedFolders));
      // No membership change here; only pin order. No need to refresh members.
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> unpinChat(int pinnedChatId) async {
    try {
      final int? organizationId = AppConstants.selectedOrganizationId;
      if (organizationId == null) return;
      final int folderId = state.folders[state.selectedFolderIndex].id!;
      await _unpinChatUseCase.call(pinnedChatId);
      List<FolderItemEntity> updatedFolders = [...state.folders];
      FolderItemEntity folder = updatedFolders.firstWhere((folder) => folder.id == folderId);
      final int indexOfFolder = updatedFolders.indexOf(folder);
      final pinnedChats = await _getPinnedChatsUseCase.call(
        folderId: folderId,
        organizationId: organizationId,
      );
      folder = folder.copyWith(pinnedChats: pinnedChats);
      updatedFolders[indexOfFolder] = folder;
      emit(state.copyWith(folders: updatedFolders));
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> _refreshAllFolderMembers() async {
    final int? organizationId = AppConstants.selectedOrganizationId;
    if (organizationId == null) return;
    final foldersToRefresh = state.folders.where((f) => f.id != null && f.id != 0);
    final futures = foldersToRefresh.map((f) async {
      final members = await _getMembersForFolderUseCase.call(
        f.id!,
        organizationId: organizationId,
      );
      return MapEntry(f.id!, members);
    });
    final entries = await Future.wait(futures);
    emit(state.copyWith(folderMembersById: Map.fromEntries(entries)));
  }
}
