import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/users/entities/channel_entity.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:injectable/injectable.dart';

part 'all_chats_state.dart';

@injectable
class AllChatsCubit extends Cubit<AllChatsState> {
  AllChatsCubit()
    : super(AllChatsState(selectedChannel: null, selectedDmChat: null, selectedTopic: null));

  void selectDmChat(DmUserEntity? dmUserEntity) {
    emit(state.copyWith(selectedDmChat: dmUserEntity, selectedTopic: null, selectedChannel: null));
  }

  void selectChannel({ChannelEntity? channel, TopicEntity? topic}) {
    emit(state.copyWith(selectedChannel: channel, selectedTopic: topic, selectedDmChat: null));
  }
}
