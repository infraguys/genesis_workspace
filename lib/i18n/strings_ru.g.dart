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
	@override late final _TranslationsNavBarRu nav_bar = _TranslationsNavBarRu._(_root);
	@override String get feed => 'Лента';
	@override String get select_any_channel => 'Выберите любой канал';
	@override String get all_messages => 'Все сообщения';
	@override String get no_messages_here_yet => 'Здесь пока нет сообщений...';
	@override String get copy => 'Копировать';
	@override String get was_online => 'был(а) онлайн {time} назад';
	@override String get was_online_just_now => 'был(а) онлайн только что';
	@override late final _TranslationsTimeAgoRu time_ago = _TranslationsTimeAgoRu._(_root);
	@override String get search => 'Поиск';
	@override late final _TranslationsSettingsRu settings = _TranslationsSettingsRu._(_root);
	@override late final _TranslationsDateLabelsRu date_labels = _TranslationsDateLabelsRu._(_root);
	@override late final _TranslationsInboxRu inbox = _TranslationsInboxRu._(_root);
	@override late final _TranslationsMentionsRu mentions = _TranslationsMentionsRu._(_root);
}

// Path: nav_bar
class _TranslationsNavBarRu implements TranslationsNavBarEn {
	_TranslationsNavBarRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get direct_messages => 'Личные сообщения';
	@override String get settings => 'Настройки';
	@override String get menu => 'Меню';
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
		other: '{n} минуты',
	);
	@override String hours({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n,
		one: '{n} час',
		few: '{n} часа',
		many: '{n} часов',
		other: '{n} часа',
	);
	@override String days({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n,
		one: '{n} день',
		few: '{n} дня',
		many: '{n} дней',
		other: '{n} дня',
	);
}

// Path: settings
class _TranslationsSettingsRu implements TranslationsSettingsEn {
	_TranslationsSettingsRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get language => 'Язык';
	@override String get logout => 'Выйти';
}

// Path: date_labels
class _TranslationsDateLabelsRu implements TranslationsDateLabelsEn {
	_TranslationsDateLabelsRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get today => 'Сегодня';
	@override String get yesterday => 'Вчера';
}

// Path: inbox
class _TranslationsInboxRu implements TranslationsInboxEn {
	_TranslationsInboxRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Входящие';
	@override String get no_messages => 'Все сообщения прочитаны';
	@override String get dm_tab => 'Личные сообщения';
	@override String get channels_tab => 'Каналы';
}

// Path: mentions
class _TranslationsMentionsRu implements TranslationsMentionsEn {
	_TranslationsMentionsRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Упоминания';
	@override String get no_mentions => 'Нет упоминаний';
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
			case 'nav_bar.direct_messages': return 'Личные сообщения';
			case 'nav_bar.settings': return 'Настройки';
			case 'nav_bar.menu': return 'Меню';
			case 'nav_bar.channels': return 'Каналы';
			case 'feed': return 'Лента';
			case 'select_any_channel': return 'Выберите любой канал';
			case 'all_messages': return 'Все сообщения';
			case 'no_messages_here_yet': return 'Здесь пока нет сообщений...';
			case 'copy': return 'Копировать';
			case 'was_online': return 'был(а) онлайн {time} назад';
			case 'was_online_just_now': return 'был(а) онлайн только что';
			case 'time_ago.just_now': return 'только что';
			case 'time_ago.minutes': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n,
				one: '{n} минуту',
				few: '{n} минуты',
				many: '{n} минут',
				other: '{n} минуты',
			);
			case 'time_ago.hours': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n,
				one: '{n} час',
				few: '{n} часа',
				many: '{n} часов',
				other: '{n} часа',
			);
			case 'time_ago.days': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n,
				one: '{n} день',
				few: '{n} дня',
				many: '{n} дней',
				other: '{n} дня',
			);
			case 'search': return 'Поиск';
			case 'settings.language': return 'Язык';
			case 'settings.logout': return 'Выйти';
			case 'date_labels.today': return 'Сегодня';
			case 'date_labels.yesterday': return 'Вчера';
			case 'inbox.title': return 'Входящие';
			case 'inbox.no_messages': return 'Все сообщения прочитаны';
			case 'inbox.dm_tab': return 'Личные сообщения';
			case 'inbox.channels_tab': return 'Каналы';
			case 'mentions.title': return 'Упоминания';
			case 'mentions.no_mentions': return 'Нет упоминаний';
			default: return null;
		}
	}
}

