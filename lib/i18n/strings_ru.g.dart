///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsRu implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsRu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ru,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ru>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsRu _root = this; // ignore: unused_field

	@override 
	TranslationsRu $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsRu(meta: meta ?? this.$meta);

	// Translations
	@override String get password_cant_be_empty => 'Пароль не может быть пустым';
	@override String get password => 'Пароль';
	@override String get login => 'Войти';
	@override String get typing => 'Печатает';
	@override String get online => 'В сети';
	@override late final _TranslationsNavBarRu navBar = _TranslationsNavBarRu._(_root);
	@override String get selectAnyChannel => 'Выберите любой канал';
}

// Path: navBar
class _TranslationsNavBarRu implements TranslationsNavBarEn {
	_TranslationsNavBarRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get directMessages => 'Личные сообщения';
	@override String get settings => 'Настройки';
	@override String get profile => 'Профиль';
	@override String get channels => 'Каналы';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on TranslationsRu {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'password_cant_be_empty': return 'Пароль не может быть пустым';
			case 'password': return 'Пароль';
			case 'login': return 'Войти';
			case 'typing': return 'Печатает';
			case 'online': return 'В сети';
			case 'navBar.directMessages': return 'Личные сообщения';
			case 'navBar.settings': return 'Настройки';
			case 'navBar.profile': return 'Профиль';
			case 'navBar.channels': return 'Каналы';
			case 'selectAnyChannel': return 'Выберите любой канал';
			default: return null;
		}
	}
}

