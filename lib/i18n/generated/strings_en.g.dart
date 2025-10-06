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
		  );

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsAuthEn auth = TranslationsAuthEn.internal(_root);

	/// en: 'Password can not be empty'
	String get passwordCantBeEmpty => 'Password can not be empty';

	/// en: 'Password'
	String get password => 'Password';

	/// en: 'Login'
	String get login => 'Login';

	/// en: 'Typing'
	String get typing => 'Typing';

	/// en: 'Online'
	String get online => 'Online';

	late final TranslationsNavBarEn navBar = TranslationsNavBarEn.internal(_root);

	/// en: 'Feed'
	String get feed => 'Feed';

	/// en: 'Select any channel'
	String get selectAnyChannel => 'Select any channel';

	/// en: 'All messages'
	String get allMessages => 'All messages';

	/// en: 'No messages here yet...'
	String get noMessagesHereYet => 'No messages here yet...';

	/// en: 'Copy'
	String get copy => 'Copy';

	/// en: 'was online {time} ago'
	String wasOnline({required Object time}) => 'was online ${time} ago';

	/// en: 'was online just now'
	String get wasOnlineJustNow => 'was online just now';

	late final TranslationsTimeAgoEn timeAgo = TranslationsTimeAgoEn.internal(_root);

	/// en: 'Search'
	String get search => 'Search';

	late final TranslationsSettingsEn settings = TranslationsSettingsEn.internal(_root);
	late final TranslationsDateLabelsEn dateLabels = TranslationsDateLabelsEn.internal(_root);
	late final TranslationsInboxEn inbox = TranslationsInboxEn.internal(_root);
	late final TranslationsMentionsEn mentions = TranslationsMentionsEn.internal(_root);
	late final TranslationsReactionsEn reactions = TranslationsReactionsEn.internal(_root);
	late final TranslationsStarredEn starred = TranslationsStarredEn.internal(_root);

	/// en: 'Select any chat'
	String get selectAnyChat => 'Select any chat';

	late final TranslationsUnreadMarkerEn unreadMarker = TranslationsUnreadMarkerEn.internal(_root);

	/// en: 'Recent dialogs'
	String get recentDialogs => 'Recent dialogs';

	/// en: 'Show all users'
	String get showAllUsers => 'Show all users';

	/// en: 'Show recent dialogs'
	String get showRecentDialogs => 'Show recent dialogs';

	/// en: 'No recent dialogs'
	String get noRecentDialogs => 'No recent dialogs';

	/// en: 'Error'
	String get error => 'Error';

	late final TranslationsMessageActionsEn messageActions = TranslationsMessageActionsEn.internal(_root);
	late final TranslationsAttachmentButtonEn attachmentButton = TranslationsAttachmentButtonEn.internal(_root);

	/// en: 'Drop files here to upload'
	String get dropFilesToUpload => 'Drop files here to upload';

	/// en: 'Cancel editing'
	String get cancelEditing => 'Cancel editing';

	late final TranslationsFoldersEn folders = TranslationsFoldersEn.internal(_root);
	late final TranslationsChannelEn channel = TranslationsChannelEn.internal(_root);
	late final TranslationsChatEn chat = TranslationsChatEn.internal(_root);

	/// en: 'Nothing found'
	String get nothingFound => 'Nothing found';
}

// Path: auth
class TranslationsAuthEn {
	TranslationsAuthEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'email@example.com'
	String get emailHint => 'email@example.com';

	/// en: 'Email'
	String get emailLabel => 'Email';

	/// en: 'cucumber123'
	String get passwordHint => 'cucumber123';

	/// en: 'Show password'
	String get showPassword => 'Show password';

	/// en: 'Hide password'
	String get hidePassword => 'Hide password';

	/// en: 'Login with {realm_name}'
	String loginWith({required Object realmName}) => 'Login with ${realmName}';

	/// en: 'Paste code here'
	String get pasteYourCodeHere => 'Paste code here';

	/// en: 'Enter or paste your login code'
	String get enterOrPasteCodeTitle => 'Enter or paste your login code';

	/// en: 'We'll use it to finish signing you in.'
	String get codeUsageHint => 'We\'ll use it to finish signing you in.';

	/// en: 'Token'
	String get tokenLabel => 'Token';

	/// en: 'Your code here…'
	String get tokenHint => 'Your code here…';

	/// en: 'Paste'
	String get paste => 'Paste';

	/// en: 'Clear'
	String get clear => 'Clear';

	/// en: 'Paste Base URL'
	String get pasteBaseUrlHere => 'Paste Base URL';

	/// en: 'Enter or paste the server address'
	String get enterOrPasteBaseUrlTitle => 'Enter or paste the server address';

	/// en: 'Specify your server URL (for example, https://zulip.example.com). Only http/https are supported.'
	String get baseUrlUsageHint => 'Specify your server URL (for example, https://zulip.example.com). Only http/https are supported.';

	/// en: 'Base URL'
	String get baseUrlLabel => 'Base URL';

	/// en: 'https://your-domain.com'
	String get baseUrlHint => 'https://your-domain.com';

	/// en: 'Invalid address. Use http or https.'
	String get baseUrlInvalid => 'Invalid address. Use http or https.';

	/// en: 'Save and continue'
	String get saveAndContinue => 'Save and continue';

	/// en: 'Logout from organization'
	String get logoutFromOrganization => 'Logout from organization';

	/// en: 'Current server'
	String get currentBaseUrl => 'Current server';
}

// Path: navBar
class TranslationsNavBarEn {
	TranslationsNavBarEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'All chats'
	String get allChats => 'All chats';

	/// en: 'Direct Messages'
	String get directMessages => 'Direct Messages';

	/// en: 'Settings'
	String get settings => 'Settings';

	/// en: 'Menu'
	String get menu => 'Menu';

	/// en: 'Channels'
	String get channels => 'Channels';
}

// Path: timeAgo
class TranslationsTimeAgoEn {
	TranslationsTimeAgoEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'just now'
	String get justNow => 'just now';

	/// en: '(one) {{n} minute} (other) {{n} minutes}'
	String minutes({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} minute',
		other: '${n} minutes',
	);

	/// en: '(one) {{n} hour} (other) {{n} hours}'
	String hours({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} hour',
		other: '${n} hours',
	);

	/// en: '(one) {{n} day} (other) {{n} days}'
	String days({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} day',
		other: '${n} days',
	);
}

// Path: settings
class TranslationsSettingsEn {
	TranslationsSettingsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'Logout'
	String get logout => 'Logout';
}

// Path: dateLabels
class TranslationsDateLabelsEn {
	TranslationsDateLabelsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Today'
	String get today => 'Today';

	/// en: 'Yesterday'
	String get yesterday => 'Yesterday';
}

// Path: inbox
class TranslationsInboxEn {
	TranslationsInboxEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Inbox'
	String get title => 'Inbox';

	/// en: 'No unread messages'
	String get noMessages => 'No unread messages';

	/// en: 'Direct messages'
	String get dmTab => 'Direct messages';

	/// en: 'Channels'
	String get channelsTab => 'Channels';
}

// Path: mentions
class TranslationsMentionsEn {
	TranslationsMentionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Mentions'
	String get title => 'Mentions';

	/// en: 'No mentions'
	String get noMentions => 'No mentions';
}

// Path: reactions
class TranslationsReactionsEn {
	TranslationsReactionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Reactions'
	String get title => 'Reactions';

	/// en: 'No reactions'
	String get noReactions => 'No reactions';
}

// Path: starred
class TranslationsStarredEn {
	TranslationsStarredEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Starred Messages'
	String get title => 'Starred Messages';

	/// en: 'No starred messages'
	String get noStarred => 'No starred messages';
}

// Path: unreadMarker
class TranslationsUnreadMarkerEn {
	TranslationsUnreadMarkerEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Unread messages'
	String get label => 'Unread messages';

	/// en: 'Unread messages • {count}'
	String labelWithCount({required Object count}) => 'Unread messages • ${count}';

	/// en: 'Unread messages marker'
	String get a11yLabel => 'Unread messages marker';
}

// Path: messageActions
class TranslationsMessageActionsEn {
	TranslationsMessageActionsEn.internal(this._root);

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

// Path: attachmentButton
class TranslationsAttachmentButtonEn {
	TranslationsAttachmentButtonEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Pick a file'
	String get file => 'Pick a file';

	/// en: 'Pick an image'
	String get image => 'Pick an image';
}

// Path: folders
class TranslationsFoldersEn {
	TranslationsFoldersEn.internal(this._root);

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
	String deleteConfirmText({required Object folderName}) => 'Are you sure you want to delete "${folderName}"?';

	/// en: 'Folder is empty'
	String get folderIsEmpty => 'Folder is empty';
}

// Path: channel
class TranslationsChannelEn {
	TranslationsChannelEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Mute channel'
	String get muteChannel => 'Mute channel';

	/// en: 'Unmute channel'
	String get unmuteChannel => 'Unmute channel';
}

// Path: chat
class TranslationsChatEn {
	TranslationsChatEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Pin chat'
	String get pinChat => 'Pin chat';

	/// en: 'Unpin chat'
	String get unpinChat => 'Unpin chat';
}
