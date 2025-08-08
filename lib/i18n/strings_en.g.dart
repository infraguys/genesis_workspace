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
	String get password_cant_be_empty => 'Password can not be empty';
	String get password => 'Password';
	String get login => 'Login';
	String get typing => 'Typing';
	String get online => 'Online';
	late final TranslationsNavBarEn nav_bar = TranslationsNavBarEn._(_root);
	String get feed => 'Feed';
	String get select_any_channel => 'Select any channel';
	String get all_messages => 'All messages';
	String get no_messages_here_yet => 'No messages here yet...';
	String get copy => 'Copy';
	String get was_online => 'was online {time} ago';
	String get was_online_just_now => 'was online just now';
	late final TranslationsTimeAgoEn time_ago = TranslationsTimeAgoEn._(_root);
	String get search => 'Search';
	late final TranslationsSettingsEn settings = TranslationsSettingsEn._(_root);
	late final TranslationsDateLabelsEn date_labels = TranslationsDateLabelsEn._(_root);
	late final TranslationsInboxEn inbox = TranslationsInboxEn._(_root);
	late final TranslationsMentionsEn mentions = TranslationsMentionsEn._(_root);
	String get select_any_chat => 'Select any chat';
}

// Path: nav_bar
class TranslationsNavBarEn {
	TranslationsNavBarEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get direct_messages => 'Direct Messages';
	String get settings => 'Settings';
	String get menu => 'Menu';
	String get channels => 'Channels';
}

// Path: time_ago
class TranslationsTimeAgoEn {
	TranslationsTimeAgoEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get just_now => 'just now';
	String minutes({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '{n} minute',
		other: '{n} minutes',
	);
	String hours({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '{n} hour',
		other: '{n} hours',
	);
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
	String get language => 'Language';
	String get logout => 'Logout';
}

// Path: date_labels
class TranslationsDateLabelsEn {
	TranslationsDateLabelsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get today => 'Today';
	String get yesterday => 'Yesterday';
}

// Path: inbox
class TranslationsInboxEn {
	TranslationsInboxEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Inbox';
	String get no_messages => 'No unread messages';
	String get dm_tab => 'Direct messages';
	String get channels_tab => 'Channels';
}

// Path: mentions
class TranslationsMentionsEn {
	TranslationsMentionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Mentions';
	String get no_mentions => 'No mentions';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
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
			case 'select_any_chat': return 'Select any chat';
			default: return null;
		}
	}
}

