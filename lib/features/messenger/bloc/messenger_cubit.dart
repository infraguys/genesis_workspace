import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_members.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/add_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/delete_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_folders_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_members_for_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/remove_all_memberships_for_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/update_folder_use_case.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_topics_use_case.dart';
import 'package:injectable/injectable.dart';

part 'messenger_state.dart';

@injectable
class MessengerCubit extends Cubit<MessengerState> {
  final AddFolderUseCase _addFolderUseCase;
  final GetFoldersUseCase _getFoldersUseCase;
  final UpdateFolderUseCase _updateFolderUseCase;
  final DeleteFolderUseCase _deleteFolderUseCase;
  final RemoveAllMembershipsForFolderUseCase _removeAllMembershipsForFolderUseCase;
  final GetMembersForFolderUseCase _getMembersForFolderUseCase;
  final GetMessagesUseCase _getMessagesUseCase;
  final GetTopicsUseCase _getTopicsUseCase;

  MessengerCubit(
    this._addFolderUseCase,
    this._getFoldersUseCase,
    this._updateFolderUseCase,
    this._deleteFolderUseCase,
    this._removeAllMembershipsForFolderUseCase,
    this._getMembersForFolderUseCase,
    this._getMessagesUseCase,
    this._getTopicsUseCase,
  ) : super(
        MessengerState(
          selfUser: null,
          folders: [],
          selectedFolderIndex: 0,
          folderMembersById: const {},
          messages: [],
          chats: [],
        ),
      );

  Future<void> getMessages() async {
    try {
      final messagesBody = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        narrow: [
          // MessageNarrowEntity(operator: NarrowOperator.isFilter, operand: "dm"),
        ],
        numBefore: 1000,
        numAfter: 0,
        applyMarkdown: false,
        clientGravatar: false,
      );
      final response = await _getMessagesUseCase.call(messagesBody);
      final messages = response.messages;
      final chats = [...state.chats];
      for (var message in messages.reversed) {
        final recipientId = message.recipientId;
        final isMyMessage = message.isMyMessage(state.selfUser?.userId);
        final bool isChatExist = chats.any((chat) => chat.id == message.recipientId);
        if (isChatExist) {
          ChatEntity chat = chats.firstWhere((chat) => chat.id == recipientId);
          final indexOfChat = chats.indexOf(chat);
          chat = chat.updateLastMessage(message, isMyMessage: isMyMessage);
          chats[indexOfChat] = chat;
        } else {
          final chat = ChatEntity.createChatFromMessage(
            message.copyWith(avatarUrl: isMyMessage ? null : message.avatarUrl),
            isMyMessage: isMyMessage,
          );
          chats.add(chat);
        }
      }
      emit(state.copyWith(messages: messages, chats: chats));
    } catch (e) {
      inspect(e);
    }
  }

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
    await _removeAllMembershipsForFolderUseCase.call(folder.id!, organizationId: organizationId);
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
      final members = await _getMembersForFolderUseCase.call(id, organizationId: organizationId);
      return MapEntry(id, members);
    });

    final newEntries = await Future.wait(futures);
    final updatedMap = Map<int, FolderMembers>.from(state.folderMembersById)
      ..addEntries(newEntries);

    emit(state.copyWith(folderMembersById: updatedMap));
  }

  Future<void> _refreshAllFolderMembers() async {
    final int? organizationId = AppConstants.selectedOrganizationId;
    if (organizationId == null) return;
    final foldersToRefresh = state.folders.where((f) => f.id != null && f.id != 0);
    final futures = foldersToRefresh.map((f) async {
      final members = await _getMembersForFolderUseCase.call(f.id!, organizationId: organizationId);
      return MapEntry(f.id!, members);
    });
    final entries = await Future.wait(futures);
    emit(state.copyWith(folderMembersById: Map.fromEntries(entries)));
  }

  void setSelfUser(UserEntity user) {
    emit(state.copyWith(selfUser: user));
  }

  Future<void> getChannelTopics(int streamId) async {
    try {
      final response = await _getTopicsUseCase.call(streamId);
      List<ChatEntity> updatedChats = [...state.chats];
      ChatEntity chat = updatedChats.firstWhere((chat) => chat.streamId == streamId);
      int indexOfChat = updatedChats.indexOf(chat);
      chat = chat.copyWith(topics: response);
      updatedChats[indexOfChat] = chat;
      emit(state.copyWith(chats: updatedChats));
    } catch (e) {
      inspect(e);
    }
  }

  void resetState() {
    emit(
      state.copyWith(
        folders: [],
        selectedFolderIndex: 0,
        folderMembersById: const {},
        messages: [],
        chats: [],
      ),
    );
  }
}
