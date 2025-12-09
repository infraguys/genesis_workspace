part of 'settings_cubit.dart';

class SettingsState {
  const SettingsState({
    this.prioritizePersonalUnread = false,
    this.prioritizeUnmutedUnreadChannels = false,
  });

  final bool prioritizePersonalUnread;
  final bool prioritizeUnmutedUnreadChannels;

  SettingsState copyWith({
    bool? prioritizePersonalUnread,
    bool? prioritizeUnmutedUnreadChannels,
  }) {
    return SettingsState(
      prioritizePersonalUnread: prioritizePersonalUnread ?? this.prioritizePersonalUnread,
      prioritizeUnmutedUnreadChannels: prioritizeUnmutedUnreadChannels ?? this.prioritizeUnmutedUnreadChannels,
    );
  }
}
