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
	late final TranslationsNavBarEn navBar = TranslationsNavBarEn._(_root);
	String get selectAnyChannel => 'Select any channel';
}

// Path: navBar
class TranslationsNavBarEn {
	TranslationsNavBarEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get directMessages => 'Direct Messages';
	String get settings => 'Settings';
	String get profile => 'Profile';
	String get channels => 'Channels';
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
			case 'navBar.directMessages': return 'Direct Messages';
			case 'navBar.settings': return 'Settings';
			case 'navBar.profile': return 'Profile';
			case 'navBar.channels': return 'Channels';
			case 'selectAnyChannel': return 'Select any channel';
			default: return null;
		}
	}
}

