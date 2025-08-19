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
}

// Path: auth
class TranslationsAuthEn {
	TranslationsAuthEn._(this._root);

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
}

// Path: nav_bar
class TranslationsNavBarEn {
	TranslationsNavBarEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Direct Messages'
	String get direct_messages => 'Direct Messages';

	/// en: 'Settings'
	String get settings => 'Settings';

	/// en: 'Menu'
	String get menu => 'Menu';

	/// en: 'Channels'
	String get channels => 'Channels';
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

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'auth.emailHint': return 'email@tokens.team';
			case 'auth.emailLabel': return 'Email';
			case 'auth.passwordHint': return 'cucumber123';
			case 'auth.showPassword': return 'Show password';
			case 'auth.hidePassword': return 'Hide password';
			case 'auth.login_with': return 'Login with {realm_name}';
			case 'auth.paste_your_code_here': return 'Paste code here';
			case 'auth.enter_or_paste_code_title': return 'Enter or paste your login code';
			case 'auth.code_usage_hint': return 'We\'ll use it to finish signing you in.';
			case 'auth.token_label': return 'Token';
			case 'auth.token_hint': return 'Your code here…';
			case 'auth.paste': return 'Paste';
			case 'auth.clear': return 'Clear';
			case 'password_cant_be_empty': return 'Password can not be empty';
			case 'password': return 'Password';
			case 'login': return 'Login';
			case 'typing': return 'Typing';
			case 'online': return 'Online';
			case 'nav_bar.direct_messages': return 'Direct Messages';
			case 'nav_bar.settings': return 'Settings';
			case 'nav_bar.menu': return 'Menu';
			case 'nav_bar.channels': return 'Channels';
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
			default: return null;
		}
	}
}

