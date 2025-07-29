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
	@override String get login => 'Вход';
	@override String get typing => 'Печатает';
	@override String get online => 'В сети';
	@override late final _TranslationsNavBarRu nav_bar = _TranslationsNavBarRu._(_root);
	@override String get select_any_channel => 'Выберите любой канал';
	@override String get all_messages => 'Все сообщения';
	@override String get no_messages_here_yet => 'Здесь пока нет сообщений...';
	@override String get copy => 'Копировать';
	@override String get was_online => 'Был(а) в сети {time} назад';
	@override String get was_online_just_now => 'Был(а) в сети только что';
	@override late final _TranslationsTimeAgoRu time_ago = _TranslationsTimeAgoRu._(_root);
}

// Path: nav_bar
class _TranslationsNavBarRu implements TranslationsNavBarEn {
	_TranslationsNavBarRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get direct_messages => 'Личные сообщения';
	@override String get settings => 'Настройки';
	@override String get profile => 'Профиль';
	@override String get channels => 'Каналы';
}

// Path: time_ago
class _TranslationsTimeAgoRu implements TranslationsTimeAgoEn {
	_TranslationsTimeAgoRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get just_now => 'только что';
	@override String minutes({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n,
		one: '{n} минуту',
		few: '{n} минуты',
		many: '{n} минут',
		other: '{n} минут',
	);
	@override String hours({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n,
		one: '{n} час',
		few: '{n} часа',
		many: '{n} часов',
		other: '{n} часов',
	);
	@override String days({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n,
		one: '{n} день',
		few: '{n} дня',
		many: '{n} дней',
		other: '{n} дней',
	);
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on TranslationsRu {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'password_cant_be_empty': return 'Пароль не может быть пустым';
			case 'password': return 'Пароль';
			case 'login': return 'Вход';
			case 'typing': return 'Печатает';
			case 'online': return 'В сети';
			case 'nav_bar.direct_messages': return 'Личные сообщения';
			case 'nav_bar.settings': return 'Настройки';
			case 'nav_bar.profile': return 'Профиль';
			case 'nav_bar.channels': return 'Каналы';
			case 'select_any_channel': return 'Выберите любой канал';
			case 'all_messages': return 'Все сообщения';
			case 'no_messages_here_yet': return 'Здесь пока нет сообщений...';
			case 'copy': return 'Копировать';
			case 'was_online': return 'Был(а) в сети {time} назад';
			case 'was_online_just_now': return 'Был(а) в сети только что';
			case 'time_ago.just_now': return 'только что';
			case 'time_ago.minutes': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n,
				one: '{n} минуту',
				few: '{n} минуты',
				many: '{n} минут',
				other: '{n} минут',
			);
			case 'time_ago.hours': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n,
				one: '{n} час',
				few: '{n} часа',
				many: '{n} часов',
				other: '{n} часов',
			);
			case 'time_ago.days': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n,
				one: '{n} день',
				few: '{n} дня',
				many: '{n} дней',
				other: '{n} дней',
			);
			default: return null;
		}
	}
}

