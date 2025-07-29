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
	String get passwordCantBeEmpty => 'Password can not be empty';
	String get password => 'Password';
	String get login => 'Login';
	String get typing => 'Typing';
	String get online => 'Online';
	late final TranslationsNavBarEn navBar = TranslationsNavBarEn.internal(_root);
	String get selectAnyChannel => 'Select any channel';
	String get allMessages => 'All messages';
	String get noMessagesHereYet => 'No messages here yet...';
	String get copy => 'Copy';
	String wasOnline({required Object time}) => 'was online ${time} ago';
	String get wasOnlineJustNow => 'was online just now';
	late final TranslationsTimeAgoEn timeAgo = TranslationsTimeAgoEn.internal(_root);
}

// Path: navBar
class TranslationsNavBarEn {
	TranslationsNavBarEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get directMessages => 'Direct Messages';
	String get settings => 'Settings';
	String get profile => 'Profile';
	String get channels => 'Channels';
}

// Path: timeAgo
class TranslationsTimeAgoEn {
	TranslationsTimeAgoEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get justNow => 'just now';
	String minutes({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} minute',
		other: '${n} minutes',
	);
	String hours({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} hour',
		other: '${n} hours',
	);
	String days({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} day',
		other: '${n} days',
	);
}
