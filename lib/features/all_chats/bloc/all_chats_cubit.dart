import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/users/entities/channel_entity.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:injectable/injectable.dart';

part 'all_chats_state.dart';

@injectable
class AllChatsCubit extends Cubit<AllChatsState> {
  AllChatsCubit()
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

  void addFolder(FolderItemEntity folder) {
    final updatedFolders = [...state.folders];
    updatedFolders.add(folder);
    emit(state.copyWith(folders: updatedFolders));
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
