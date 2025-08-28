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
}

// Path: auth
class TranslationsAuthEn {
	TranslationsAuthEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'email@tokens.team'
	String get emailHint => 'email@tokens.team';

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
}

// Path: navBar
class TranslationsNavBarEn {
	TranslationsNavBarEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

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
