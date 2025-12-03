import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/data/all_chats/tables/pinned_chats_table.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_members.dart';
import 'package:genesis_workspace/domain/all_chats/entities/pinned_chat_entity.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/add_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/delete_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_folder_ids_for_chat_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_folders_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_members_for_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_pinned_chats_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/pin_chat_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/remove_all_memberships_for_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/set_folders_for_chat_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/unpin_chat_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/update_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/update_pinned_chat_order_use_case.dart';
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
  final SetFoldersForChatUseCase _setFoldersForChatUseCase;
  final GetFolderIdsForChatUseCase _getFolderIdsForChatUseCase;
  final RemoveAllMembershipsForFolderUseCase _removeAllMembershipsForFolderUseCase;
  final GetMembersForFolderUseCase _getMembersForFolderUseCase;
  final GetPinnedChatsUseCase _getPinnedChatsUseCase;
  final PinChatUseCase _pinChatUseCase;
  final UnpinChatUseCase _unpinChatUseCase;
  final UpdatePinnedChatOrderUseCase _updatePinnedChatOrderUseCase;

  AllChatsCubit(
    this._addFolderUseCase,
    this._getFoldersUseCase,
    this._updateFolderUseCase,
    this._deleteFolderUseCase,
    this._setFoldersForChatUseCase,
    this._getFolderIdsForChatUseCase,
    this._removeAllMembershipsForFolderUseCase,
    this._getMembersForFolderUseCase,
    this._getPinnedChatsUseCase,
    this._pinChatUseCase,
    this._unpinChatUseCase,
    this._updatePinnedChatOrderUseCase,
  ) : super(
        AllChatsState(
          selectedChannel: null,
          selectedDmChat: null,
          selectedTopic: null,
          folders: [],
          selectedFolderIndex: 0,
          folderMembersById: const {},
          selectedGroupChat: null,
          filterChatIds: null,
          isInitialDataPending: false,
        ),
      );

  Future<void> addFolder(CreateFolderEntity folder) async {
    try {
      await _addFolderUseCase.call(folder);
      // final updatedFolders = [...state.folders];
      // updatedFolders.add(folder.copyWith(id: updatedFolders.length));
      // emit(state.copyWith(folders: updatedFolders));
      // await _refreshAllFolderMembers();
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

      // final List<FolderItemEntity> dbFolders = await _getFoldersUseCase.call(organizationId);
      // if (dbFolders.isEmpty) {
      // final initFolder = FolderItemEntity(
      //   id: 0,
      //   title: 'All',
      //   systemType: SystemFolderType.all,
      //   iconData: Icons.markunread,
      //   unreadMessages: const <int>{},
      //   pinnedChats: [],
      //   organizationId: organizationId,
      // );
      // await addFolder(initFolder);
      // return;
      // }
      // final List<FolderItemEntity> initialFolders = [...dbFolders];
      // emit(state.copyWith(folders: initialFolders, selectedFolderIndex: 0));
      await _refreshAllFolderMembers();
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> pinChat({required int chatId, required PinnedChatType type}) async {
    // try {
    //   final int? organizationId = AppConstants.selectedOrganizationId;
    //   if (organizationId == null) return;
    //
    //   final int folderId = state.folders[state.selectedFolderIndex].id!;
    //   List<FolderItemEntity> updatedFolders = [...state.folders];
    //   FolderItemEntity folder = updatedFolders.firstWhere((folder) => folder.id == folderId);
    //   await _pinChatUseCase.call(
    //     folderId: folderId,
    //     chatId: chatId,
    //     orderIndex: folder.pinnedChats.length,
    //     // type: type,
    //     organizationId: organizationId,
    //   );
    //   final int indexOfFolder = updatedFolders.indexOf(folder);
    //   final pinnedChats = await _getPinnedChatsUseCase.call(
    //     folderId: folderId,
    //     organizationId: organizationId,
    //   );
    //   folder = folder.copyWith(pinnedChats: pinnedChats);
    //   updatedFolders[indexOfFolder] = folder;
    //   emit(state.copyWith(folders: updatedFolders));
    //   // No membership change here; only pin order. No need to refresh members.
    // } catch (e) {
    //   inspect(e);
    // }
  }

  Future<void> unpinChat(int pinnedChatId) async {
    // try {
    //   final int? organizationId = AppConstants.selectedOrganizationId;
    //   if (organizationId == null) return;
    //
    //   final int folderId = state.folders[state.selectedFolderIndex].id!;
    //   await _unpinChatUseCase.call(pinnedChatId);
    //   List<FolderItemEntity> updatedFolders = [...state.folders];
    //   FolderItemEntity folder = updatedFolders.firstWhere((folder) => folder.id == folderId);
    //   final int indexOfFolder = updatedFolders.indexOf(folder);
    //   final pinnedChats = await _getPinnedChatsUseCase.call(folderId.toString());
    //   folder = folder.copyWith(pinnedChats: pinnedChats);
    //   updatedFolders[indexOfFolder] = folder;
    //   emit(state.copyWith(folders: updatedFolders));
    // } catch (e) {
    //   inspect(e);
    // }
  }

  Future<void> reorderPinnedChats({
    required int folderId,
    required int movedChatId,
    int? previousChatId,
    int? nextChatId,
  }) async {
    try {
      final folder = state.folders.firstWhere((f) => f.id == folderId);
      final pinnedMeta = folder.pinnedChats.firstWhere(
        (p) => p.chatId == movedChatId,
        orElse: () => PinnedChatEntity(
          folderItemUuid: '',
          folderUuid: folderId.toString(),
          chatId: movedChatId,
        ),
      );
      if (pinnedMeta.folderItemUuid.isEmpty) return;
      await _updatePinnedChatOrderUseCase.call(
        folderUuid: folderId.toString(),
        folderItemUuid: pinnedMeta.folderItemUuid,
        orderIndex: null,
      );

      // перезагрузим пины для этой папки и переиздадим state
      final List<PinnedChatEntity> refreshedPins = await _getPinnedChatsUseCase.call(folderId.toString());

      final List<FolderItemEntity> updatedFolders = [...state.folders];
      final int folderIndex = updatedFolders.indexWhere((f) => f.id == folderId);
      if (folderIndex != -1) {
        final FolderItemEntity updatedFolder = updatedFolders[folderIndex].copyWith(
          pinnedChats: refreshedPins,
        );
        updatedFolders[folderIndex] = updatedFolder;
        emit(state.copyWith(folders: updatedFolders));
      }
    } catch (e, s) {
      // обработка/логирование
    }
  }

  Future<void> _refreshAllFolderMembers() async {
    final foldersToRefresh = state.folders.where((f) => f.id != null && f.id != 0);
    if (foldersToRefresh.isEmpty) return;
    final futures = foldersToRefresh.map((f) async {
      final members = await _getMembersForFolderUseCase.call(f.id!.toString());
      return MapEntry(f.id!, members);
    });
    final entries = await Future.wait(futures);
    emit(state.copyWith(folderMembersById: Map.fromEntries(entries)));
  }

  Future<void> _refreshMembersForFolders(Iterable<int> folderIds) async {
    final idsToRefresh = folderIds.where((id) => id != 0);
    if (idsToRefresh.isEmpty) return;

    final futures = idsToRefresh.map((id) async {
      final members = await _getMembersForFolderUseCase.call(id.toString());
      return MapEntry(id, members);
    });

    final newEntries = await Future.wait(futures);
    final updatedMap = Map<int, FolderMembers>.from(state.folderMembersById)..addEntries(newEntries);

    emit(state.copyWith(folderMembersById: updatedMap));
  }

  Future<FolderMembers> membersForFolder(int folderId) {
    if (folderId == 0) {
      return Future.value(const FolderMembers(chatIds: []));
    }
    return _getMembersForFolderUseCase.call(folderId.toString());
  }

  Future<void> updateFolder(FolderItemEntity folder) async {
    if (folder.systemType != null || folder.id == null) return;
    final updatedFolders = [...state.folders];
    final index = updatedFolders.indexWhere((element) => element.id == folder.id);
    // await _updateFolderUseCase.call(folder);
    updatedFolders[index] = folder;
    emit(state.copyWith(folders: updatedFolders));
    await _refreshMembersForFolders([folder.id!]);
  }

  Future<void> deleteFolder(FolderItemEntity folder) async {
    if (folder.id == 0) return;
    if (folder.systemType != null || folder.id == null) return;
    final updatedFolders = [...state.folders];
    final index = updatedFolders.indexWhere((element) => element.id == folder.id);
    await _removeAllMembershipsForFolderUseCase.call(folder.id!.toString());
    await _deleteFolderUseCase.call(DeleteFolderEntity(folderId: folder.id!.toString()));
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

  Future<List<String>> getFolderIdsForDm(int userId) async {
    return await _getFolderIdsForChatUseCase.call(userId);
  }

  Future<List<String>> getFolderIdsForChannel(int streamId) async {
    return await _getFolderIdsForChatUseCase.call(streamId);
  }

  Future<List<String>> getFolderIdsForGroupChat(int groupChatId) async {
    return await _getFolderIdsForChatUseCase.call(groupChatId);
  }

  void selectDmChat(DmUserEntity? dmChats) async {
    state.selectedTopic = null;
    state.selectedChannel = null;
    state.selectedGroupChat = null;

    emit(
      state.copyWith(
        selectedDmChat: dmChats,
        selectedTopic: state.selectedTopic,
        selectedChannel: state.selectedChannel,
        selectedGroupChat: state.selectedGroupChat,
      ),
    );
  }

  void selectGroupChat(Set<int>? ids) {
    state.selectedDmChat = null;
    state.selectedTopic = null;
    state.selectedChannel = null;
    emit(
      state.copyWith(
        selectedGroupChat: ids,
        selectedTopic: state.selectedTopic,
        selectedChannel: state.selectedChannel,
      ),
    );
  }

  void selectChannel({ChannelEntity? channel, TopicEntity? topic}) async {
    state.selectedDmChat = null;
    state.selectedGroupChat = null;
    emit(
      state.copyWith(
        selectedChannel: channel,
        selectedTopic: topic,
        selectedDmChat: state.selectedDmChat,
        selectedGroupChat: state.selectedGroupChat,
      ),
    );
  }

  void selectFolder(int newIndex) async {
    if (state.selectedFolderIndex == newIndex) return;
    emit(state.copyWith(selectedFolderIndex: newIndex));
    FolderItemEntity folder = state.folders[newIndex];
    if (folder.id == null) {
      emit(state.copyWith(filterChatIds: null));
      return;
    }
    final int? organizationId = AppConstants.selectedOrganizationId;
    if (organizationId == null) {
      return;
    }
    // final members = await _getMembersForFolderUseCase.call(
    //   folder.id!,
    //   organizationId: organizationId,
    // );
    // emit(state.copyWith(filterChatIds: members.chatIds.toSet()));
  }

  Future<void> _applyFolderFilter() async {
    // final int idx = state.selectedFolderIndex;
    // if (idx <= 0 || idx >= state.folders.length) {
    //   emit(state.copyWith(filterChatIds: null));
    //   return;
    // }
    // FolderItemEntity folder = state.folders[idx];
    //
    // if (folder.id == null) {
    //   emit(state.copyWith(filterChatIds: null));
    //   return;
    // }
    //
    // final int? organizationId = AppConstants.selectedOrganizationId;
    // if (organizationId == null) {
    //   emit(state.copyWith(filterChatIds: null));
    //   return;
    // }
    // final members = await _getMembersForFolderUseCase.call(
    //   folder.id!,
    //   organizationId: organizationId,
    // );
    // emit(state.copyWith(filterChatIds: members.chatIds.toSet()));
  }
}
