///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations implements BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsAuthEn auth = TranslationsAuthEn._(_root);

	/// en: 'Password can not be empty'
	String get password_cant_be_empty => 'Password can not be empty';

	/// en: 'Password'
	String get password => 'Password';

	/// en: 'Login'
	String get login => 'Login';

	/// en: 'Typing'
	String get typing => 'Typing';

	/// en: 'Online'
	String get online => 'Online';

	late final TranslationsNavBarEn nav_bar = TranslationsNavBarEn._(_root);

	/// en: 'Feed'
	String get feed => 'Feed';

	/// en: 'Select any channel'
	String get select_any_channel => 'Select any channel';

	/// en: 'All messages'
	String get all_messages => 'All messages';

	/// en: 'No messages here yet...'
	String get no_messages_here_yet => 'No messages here yet...';

	/// en: 'Copy'
	String get copy => 'Copy';

	/// en: 'was online {time} ago'
	String get was_online => 'was online {time} ago';

	/// en: 'was online just now'
	String get was_online_just_now => 'was online just now';

	late final TranslationsTimeAgoEn time_ago = TranslationsTimeAgoEn._(_root);

	/// en: 'Search'
	String get search => 'Search';

	late final TranslationsSettingsEn settings = TranslationsSettingsEn._(_root);
	late final TranslationsDateLabelsEn date_labels = TranslationsDateLabelsEn._(_root);
	late final TranslationsInboxEn inbox = TranslationsInboxEn._(_root);
	late final TranslationsMentionsEn mentions = TranslationsMentionsEn._(_root);
	late final TranslationsReactionsEn reactions = TranslationsReactionsEn._(_root);
	late final TranslationsStarredEn starred = TranslationsStarredEn._(_root);

	/// en: 'Select any chat'
	String get select_any_chat => 'Select any chat';

	late final TranslationsUnreadMarkerEn unread_marker = TranslationsUnreadMarkerEn._(_root);

	/// en: 'Recent dialogs'
	String get recent_dialogs => 'Recent dialogs';

	/// en: 'Show all users'
	String get show_all_users => 'Show all users';

	/// en: 'Show recent dialogs'
	String get show_recent_dialogs => 'Show recent dialogs';

	/// en: 'No recent dialogs'
	String get no_recent_dialogs => 'No recent dialogs';

	/// en: 'Error'
	String get error => 'Error';

	late final TranslationsGeneralEn general = TranslationsGeneralEn._(_root);
	late final TranslationsMessageActionsEn message_actions = TranslationsMessageActionsEn._(_root);
	late final TranslationsAttachmentButtonEn attachment_button = TranslationsAttachmentButtonEn._(_root);

	/// en: 'Drop files here to upload'
	String get drop_files_to_upload => 'Drop files here to upload';

	/// en: 'Cancel editing'
	String get cancel_editing => 'Cancel editing';

	late final TranslationsFoldersEn folders = TranslationsFoldersEn._(_root);
	late final TranslationsChannelEn channel = TranslationsChannelEn._(_root);
	late final TranslationsChatEn chat = TranslationsChatEn._(_root);
	late final TranslationsGroupEn group = TranslationsGroupEn._(_root);
	late final TranslationsGroupChatEn group_chat = TranslationsGroupChatEn._(_root);

	/// en: 'Nothing found'
	String get nothing_found => 'Nothing found';

	late final TranslationsUpdateViewEn update_view = TranslationsUpdateViewEn._(_root);
	late final TranslationsUpdateWidgetEn update_widget = TranslationsUpdateWidgetEn._(_root);
	late final TranslationsUpdateForceEn update_force = TranslationsUpdateForceEn._(_root);
}

// Path: auth
class TranslationsAuthEn {
	TranslationsAuthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'email@example.com'
	String get email_hint => 'email@example.com';

	/// en: 'Email'
	String get email_label => 'Email';

	/// en: 'cucumber123'
	String get password_hint => 'cucumber123';

	/// en: 'Show password'
	String get show_password => 'Show password';

	/// en: 'Hide password'
	String get hide_password => 'Hide password';

	/// en: 'Login with {realm_name}'
	String get login_with => 'Login with {realm_name}';

	/// en: 'Paste code here'
	String get paste_your_code_here => 'Paste code here';

	/// en: 'Enter or paste your login code'
	String get enter_or_paste_code_title => 'Enter or paste your login code';

	/// en: 'We'll use it to finish signing you in.'
	String get code_usage_hint => 'We\'ll use it to finish signing you in.';

	/// en: 'Token'
	String get token_label => 'Token';

	/// en: 'Your code here…'
	String get token_hint => 'Your code here…';

	/// en: 'Paste'
	String get paste => 'Paste';

	/// en: 'Clear'
	String get clear => 'Clear';

	/// en: 'Paste Base URL'
	String get paste_base_url_here => 'Paste Base URL';

	/// en: 'Enter or paste the server address'
	String get enter_or_paste_base_url_title => 'Enter or paste the server address';

	/// en: 'Specify your server URL (for example, https://zulip.example.com). Only http/https are supported.'
	String get base_url_usage_hint => 'Specify your server URL (for example, https://zulip.example.com). Only http/https are supported.';

	/// en: 'Base URL'
	String get base_url_label => 'Base URL';

	/// en: 'https://your-domain.com'
	String get base_url_hint => 'https://your-domain.com';

	/// en: 'Invalid address. Use http or https.'
	String get base_url_invalid => 'Invalid address. Use http or https.';

	/// en: 'Save and continue'
	String get save_and_continue => 'Save and continue';

	/// en: 'Logout from organization'
	String get logout_from_organization => 'Logout from organization';

	/// en: 'Current server'
	String get current_base_url => 'Current server';
}

// Path: nav_bar
class TranslationsNavBarEn {
	TranslationsNavBarEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'All chats'
	String get all_chats => 'All chats';

	/// en: 'Direct Messages'
	String get direct_messages => 'Direct Messages';

	/// en: 'Settings'
	String get settings => 'Settings';

	/// en: 'Menu'
	String get menu => 'Menu';

	/// en: 'Channels'
	String get channels => 'Channels';

	/// en: 'Group chats'
	String get group_chats => 'Group chats';
}

// Path: time_ago
class TranslationsTimeAgoEn {
	TranslationsTimeAgoEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'just now'
	String get just_now => 'just now';

	/// en: '(one) {{n} minute} (other) {{n} minutes}'
	String minutes({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '{n} minute',
		other: '{n} minutes',
	);

	/// en: '(one) {{n} hour} (other) {{n} hours}'
	String hours({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '{n} hour',
		other: '{n} hours',
	);

	/// en: '(one) {{n} day} (other) {{n} days}'
	String days({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '{n} day',
		other: '{n} days',
	);
}

// Path: settings
class TranslationsSettingsEn {
	TranslationsSettingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'Logout'
	String get logout => 'Logout';

	/// en: 'App version'
	String get app_version => 'App version';

	/// en: 'Notification sound'
	String get notification_sound => 'Notification sound';
}

// Path: date_labels
class TranslationsDateLabelsEn {
	TranslationsDateLabelsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Today'
	String get today => 'Today';

	/// en: 'Yesterday'
	String get yesterday => 'Yesterday';
}

// Path: inbox
class TranslationsInboxEn {
	TranslationsInboxEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Inbox'
	String get title => 'Inbox';

	/// en: 'No unread messages'
	String get no_messages => 'No unread messages';

	/// en: 'Direct messages'
	String get dm_tab => 'Direct messages';

	/// en: 'Channels'
	String get channels_tab => 'Channels';
}

// Path: mentions
class TranslationsMentionsEn {
	TranslationsMentionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Mentions'
	String get title => 'Mentions';

	/// en: 'No mentions'
	String get no_mentions => 'No mentions';
}

// Path: reactions
class TranslationsReactionsEn {
	TranslationsReactionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Reactions'
	String get title => 'Reactions';

	/// en: 'No reactions'
	String get no_reactions => 'No reactions';
}

// Path: starred
class TranslationsStarredEn {
	TranslationsStarredEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Starred Messages'
	String get title => 'Starred Messages';

	/// en: 'No starred messages'
	String get no_starred => 'No starred messages';
}

// Path: unread_marker
class TranslationsUnreadMarkerEn {
	TranslationsUnreadMarkerEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Unread messages'
	String get label => 'Unread messages';

	/// en: 'Unread messages • {count}'
	String get label_with_count => 'Unread messages • {count}';

	/// en: 'Unread messages marker'
	String get a11y_label => 'Unread messages marker';
}

// Path: general
class TranslationsGeneralEn {
	TranslationsGeneralEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Something went wrong'
	String get something_went_wrong => 'Something went wrong';

	/// en: 'Nothing here yet'
	String get nothing_here_yet => 'Nothing here yet';

	/// en: 'Find'
	String get find => 'Find';
}

// Path: message_actions
class TranslationsMessageActionsEn {
	TranslationsMessageActionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Quote this message'
	String get quote => 'Quote this message';

	/// en: 'Delete this message'
	String get delete => 'Delete this message';

	/// en: 'Star this message'
	String get star => 'Star this message';

	/// en: 'Edit this message'
	String get edit => 'Edit this message';
}

// Path: attachment_button
class TranslationsAttachmentButtonEn {
	TranslationsAttachmentButtonEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Pick a file'
	String get file => 'Pick a file';

	/// en: 'Pick an image'
	String get image => 'Pick an image';
}

// Path: folders
class TranslationsFoldersEn {
	TranslationsFoldersEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'All'
	String get all => 'All';

	/// en: 'Folders'
	String get title => 'Folders';

	/// en: 'New folder'
	String get newFolderTitle => 'New folder';

	/// en: 'Folder name'
	String get nameLabel => 'Folder name';

	/// en: 'Folder color'
	String get colorLabel => 'Folder color';

	/// en: 'Icon'
	String get iconLabel => 'Icon';

	/// en: 'Preview'
	String get preview => 'Preview';

	/// en: 'Create'
	String get create => 'Create';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Add to folder'
	String get addToFolder => 'Add to folder';

	/// en: 'Select folders'
	String get selectFolders => 'Select folders';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Edit folder'
	String get edit => 'Edit folder';

	/// en: 'Order pinning'
	String get orderPinning => 'Order pinning';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Delete folder?'
	String get deleteConfirmTitle => 'Delete folder?';

	/// en: 'Are you sure you want to delete "{folderName}"?'
	String get deleteConfirmText => 'Are you sure you want to delete "{folderName}"?';

	/// en: 'Folder is empty'
	String get folder_is_empty => 'Folder is empty';
}

// Path: channel
class TranslationsChannelEn {
	TranslationsChannelEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Mute channel'
	String get muteChannel => 'Mute channel';

	/// en: 'Unmute channel'
	String get unmuteChannel => 'Unmute channel';
}

// Path: chat
class TranslationsChatEn {
	TranslationsChatEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Pin chat'
	String get pinChat => 'Pin chat';

	/// en: 'Unpin chat'
	String get unpinChat => 'Unpin chat';
}

// Path: group
class TranslationsGroupEn {
	TranslationsGroupEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Members: {count}'
	String get members_count => 'Members: {count}';
}

// Path: group_chat
class TranslationsGroupChatEn {
	TranslationsGroupChatEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create new group chat'
	String get create_tooltip => 'Create new group chat';

	late final TranslationsGroupChatCreateDialogEn create_dialog = TranslationsGroupChatCreateDialogEn._(_root);
}

// Path: update_view
class TranslationsUpdateViewEn {
	TranslationsUpdateViewEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Choose version'
	String get title => 'Choose version';

	/// en: 'Downloading update...'
	String get downloading => 'Downloading update...';

	/// en: 'Installing update...'
	String get installing => 'Installing update...';

	/// en: '{size} downloaded'
	String get downloaded_bytes => '{size} downloaded';

	/// en: '{downloaded} / {total}'
	String get progress_with_total => '{downloaded} / {total}';

	/// en: 'Update installed'
	String get installed => 'Update installed';

	/// en: 'Version {version} is ready to use.'
	String get installed_message => 'Version {version} is ready to use.';

	/// en: 'Browse builds'
	String get open_selector_cta => 'Browse builds';

	/// en: 'Pick a version to install or downgrade.'
	String get open_selector_subtitle => 'Pick a version to install or downgrade.';

	/// en: 'Latest'
	String get latest_badge => 'Latest';

	/// en: 'Recommended build'
	String get latest_hint => 'Recommended build';
}

// Path: update_widget
class TranslationsUpdateWidgetEn {
	TranslationsUpdateWidgetEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Update available'
	String get update_available => 'Update available';

	/// en: '{version} is available'
	String get new_version_available => '{version} is available';

	/// en: 'New version is ready to download, click the button below to start downloading. This will download {size} of data.'
	String get new_version_long => 'New version is ready to download, click the button below to start downloading. This will download {size} of data.';

	/// en: 'Restart to update'
	String get restart => 'Restart to update';

	/// en: 'Are you sure?'
	String get warning_title => 'Are you sure?';

	/// en: 'A restart is required to complete the update installation. Any unsaved changes will be lost. Would you like to restart now?'
	String get restart_warning => 'A restart is required to complete the update installation.\nAny unsaved changes will be lost. Would you like to restart now?';

	/// en: 'Not now'
	String get warning_cancel => 'Not now';

	/// en: 'Restart'
	String get warning_confirm => 'Restart';
}

// Path: update_force
class TranslationsUpdateForceEn {
	TranslationsUpdateForceEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Update required'
	String get title => 'Update required';

	/// en: 'Current app version is {current}. Latest is {latest}.'
	String get description => 'Current app version is {current}. Latest is {latest}.';

	/// en: 'Loading…'
	String get loading => 'Loading…';

	/// en: 'Update'
	String get update => 'Update';

	/// en: 'Updates are not supported on this platform yet.'
	String get unsupported_platform => 'Updates are not supported on this platform yet.';

	/// en: 'Failed to start update: {error}'
	String get failed_to_start => 'Failed to start update: {error}';
}

// Path: group_chat.create_dialog
class TranslationsGroupChatCreateDialogEn {
	TranslationsGroupChatCreateDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'New group chat'
	String get title => 'New group chat';

	/// en: 'Search users'
	String get search_hint => 'Search users';

	/// en: 'No users found'
	String get no_users => 'No users found';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Create'
	String get create => 'Create';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'auth.email_hint': return 'email@example.com';
			case 'auth.email_label': return 'Email';
			case 'auth.password_hint': return 'cucumber123';
			case 'auth.show_password': return 'Show password';
			case 'auth.hide_password': return 'Hide password';
			case 'auth.login_with': return 'Login with {realm_name}';
			case 'auth.paste_your_code_here': return 'Paste code here';
			case 'auth.enter_or_paste_code_title': return 'Enter or paste your login code';
			case 'auth.code_usage_hint': return 'We\'ll use it to finish signing you in.';
			case 'auth.token_label': return 'Token';
			case 'auth.token_hint': return 'Your code here…';
			case 'auth.paste': return 'Paste';
			case 'auth.clear': return 'Clear';
			case 'auth.paste_base_url_here': return 'Paste Base URL';
			case 'auth.enter_or_paste_base_url_title': return 'Enter or paste the server address';
			case 'auth.base_url_usage_hint': return 'Specify your server URL (for example, https://zulip.example.com). Only http/https are supported.';
			case 'auth.base_url_label': return 'Base URL';
			case 'auth.base_url_hint': return 'https://your-domain.com';
			case 'auth.base_url_invalid': return 'Invalid address. Use http or https.';
			case 'auth.save_and_continue': return 'Save and continue';
			case 'auth.logout_from_organization': return 'Logout from organization';
			case 'auth.current_base_url': return 'Current server';
			case 'password_cant_be_empty': return 'Password can not be empty';
			case 'password': return 'Password';
			case 'login': return 'Login';
			case 'typing': return 'Typing';
			case 'online': return 'Online';
			case 'nav_bar.all_chats': return 'All chats';
			case 'nav_bar.direct_messages': return 'Direct Messages';
			case 'nav_bar.settings': return 'Settings';
			case 'nav_bar.menu': return 'Menu';
			case 'nav_bar.channels': return 'Channels';
			case 'nav_bar.group_chats': return 'Group chats';
			case 'feed': return 'Feed';
			case 'select_any_channel': return 'Select any channel';
			case 'all_messages': return 'All messages';
			case 'no_messages_here_yet': return 'No messages here yet...';
			case 'copy': return 'Copy';
			case 'was_online': return 'was online {time} ago';
			case 'was_online_just_now': return 'was online just now';
			case 'time_ago.just_now': return 'just now';
			case 'time_ago.minutes': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: '{n} minute',
				other: '{n} minutes',
			);
			case 'time_ago.hours': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: '{n} hour',
				other: '{n} hours',
			);
			case 'time_ago.days': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: '{n} day',
				other: '{n} days',
			);
			case 'search': return 'Search';
			case 'settings.language': return 'Language';
			case 'settings.logout': return 'Logout';
			case 'settings.app_version': return 'App version';
			case 'settings.notification_sound': return 'Notification sound';
			case 'date_labels.today': return 'Today';
			case 'date_labels.yesterday': return 'Yesterday';
			case 'inbox.title': return 'Inbox';
			case 'inbox.no_messages': return 'No unread messages';
			case 'inbox.dm_tab': return 'Direct messages';
			case 'inbox.channels_tab': return 'Channels';
			case 'mentions.title': return 'Mentions';
			case 'mentions.no_mentions': return 'No mentions';
			case 'reactions.title': return 'Reactions';
			case 'reactions.no_reactions': return 'No reactions';
			case 'starred.title': return 'Starred Messages';
			case 'starred.no_starred': return 'No starred messages';
			case 'select_any_chat': return 'Select any chat';
			case 'unread_marker.label': return 'Unread messages';
			case 'unread_marker.label_with_count': return 'Unread messages • {count}';
			case 'unread_marker.a11y_label': return 'Unread messages marker';
			case 'recent_dialogs': return 'Recent dialogs';
			case 'show_all_users': return 'Show all users';
			case 'show_recent_dialogs': return 'Show recent dialogs';
			case 'no_recent_dialogs': return 'No recent dialogs';
			case 'error': return 'Error';
			case 'general.something_went_wrong': return 'Something went wrong';
			case 'general.nothing_here_yet': return 'Nothing here yet';
			case 'general.find': return 'Find';
			case 'message_actions.quote': return 'Quote this message';
			case 'message_actions.delete': return 'Delete this message';
			case 'message_actions.star': return 'Star this message';
			case 'message_actions.edit': return 'Edit this message';
			case 'attachment_button.file': return 'Pick a file';
			case 'attachment_button.image': return 'Pick an image';
			case 'drop_files_to_upload': return 'Drop files here to upload';
			case 'cancel_editing': return 'Cancel editing';
			case 'folders.all': return 'All';
			case 'folders.title': return 'Folders';
			case 'folders.newFolderTitle': return 'New folder';
			case 'folders.nameLabel': return 'Folder name';
			case 'folders.colorLabel': return 'Folder color';
			case 'folders.iconLabel': return 'Icon';
			case 'folders.preview': return 'Preview';
			case 'folders.create': return 'Create';
			case 'folders.cancel': return 'Cancel';
			case 'folders.addToFolder': return 'Add to folder';
			case 'folders.selectFolders': return 'Select folders';
			case 'folders.save': return 'Save';
			case 'folders.edit': return 'Edit folder';
			case 'folders.orderPinning': return 'Order pinning';
			case 'folders.delete': return 'Delete';
			case 'folders.deleteConfirmTitle': return 'Delete folder?';
			case 'folders.deleteConfirmText': return 'Are you sure you want to delete "{folderName}"?';
			case 'folders.folder_is_empty': return 'Folder is empty';
			case 'channel.muteChannel': return 'Mute channel';
			case 'channel.unmuteChannel': return 'Unmute channel';
			case 'chat.pinChat': return 'Pin chat';
			case 'chat.unpinChat': return 'Unpin chat';
			case 'group.members_count': return 'Members: {count}';
			case 'group_chat.create_tooltip': return 'Create new group chat';
			case 'group_chat.create_dialog.title': return 'New group chat';
			case 'group_chat.create_dialog.search_hint': return 'Search users';
			case 'group_chat.create_dialog.no_users': return 'No users found';
			case 'group_chat.create_dialog.cancel': return 'Cancel';
			case 'group_chat.create_dialog.create': return 'Create';
			case 'nothing_found': return 'Nothing found';
			case 'update_view.title': return 'Choose version';
			case 'update_view.downloading': return 'Downloading update...';
			case 'update_view.installing': return 'Installing update...';
			case 'update_view.downloaded_bytes': return '{size} downloaded';
			case 'update_view.progress_with_total': return '{downloaded} / {total}';
			case 'update_view.installed': return 'Update installed';
			case 'update_view.installed_message': return 'Version {version} is ready to use.';
			case 'update_view.open_selector_cta': return 'Browse builds';
			case 'update_view.open_selector_subtitle': return 'Pick a version to install or downgrade.';
			case 'update_view.latest_badge': return 'Latest';
			case 'update_view.latest_hint': return 'Recommended build';
			case 'update_widget.update_available': return 'Update available';
			case 'update_widget.new_version_available': return '{version} is available';
			case 'update_widget.new_version_long': return 'New version is ready to download, click the button below to start downloading. This will download {size} of data.';
			case 'update_widget.restart': return 'Restart to update';
			case 'update_widget.warning_title': return 'Are you sure?';
			case 'update_widget.restart_warning': return 'A restart is required to complete the update installation.\nAny unsaved changes will be lost. Would you like to restart now?';
			case 'update_widget.warning_cancel': return 'Not now';
			case 'update_widget.warning_confirm': return 'Restart';
			case 'update_force.title': return 'Update required';
			case 'update_force.description': return 'Current app version is {current}. Latest is {latest}.';
			case 'update_force.loading': return 'Loading…';
			case 'update_force.update': return 'Update';
			case 'update_force.unsupported_platform': return 'Updates are not supported on this platform yet.';
			case 'update_force.failed_to_start': return 'Failed to start update: {error}';
			default: return null;
		}
	}
}

