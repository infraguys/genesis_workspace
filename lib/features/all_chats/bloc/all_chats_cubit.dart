import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/add_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_folders_use_case.dart';
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

  AllChatsCubit(this._addFolderUseCase, this._getFoldersUseCase)
    : super(
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
      await _addFolderUseCase(folder);
      await loadFolders();
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> loadFolders() async {
    final List<FolderItemEntity> dbFolders = await _getFoldersUseCase();
    final List<FolderItemEntity> withSystem = [
      FolderItemEntity(
        systemType: SystemFolderType.all,
        iconData: Icons.markunread,
        unreadCount: 0,
      ),
      ...dbFolders,
    ];
    emit(state.copyWith(folders: withSystem));
  }

  void deleteFolder(FolderItemEntity folder) {
    final updatedFolders = [...state.folders];
    updatedFolders.remove(folder);
    emit(state.copyWith(folders: updatedFolders));
  }

  void selectDmChat(DmUserEntity? dmUserEntity) {
    emit(state.copyWith(selectedDmChat: dmUserEntity, selectedTopic: null, selectedChannel: null));
  }

  void selectChannel({ChannelEntity? channel, TopicEntity? topic}) {
    emit(state.copyWith(selectedChannel: channel, selectedTopic: topic, selectedDmChat: null));
  }

  void selectFolder(int newIndex) {
    if (state.selectedFolderIndex == newIndex) return;
    emit(state.copyWith(selectedFolderIndex: newIndex));
  }
}
