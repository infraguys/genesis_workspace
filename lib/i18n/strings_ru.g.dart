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
	@override late final _TranslationsAuthRu auth = _TranslationsAuthRu._(_root);
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
	@override late final _TranslationsReactionsRu reactions = _TranslationsReactionsRu._(_root);
	@override late final _TranslationsStarredRu starred = _TranslationsStarredRu._(_root);
	@override String get select_any_chat => 'Выберите любой чат';
	@override late final _TranslationsUnreadMarkerRu unread_marker = _TranslationsUnreadMarkerRu._(_root);
}

// Path: auth
class _TranslationsAuthRu implements TranslationsAuthEn {
	_TranslationsAuthRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get emailHint => 'email@example.com';
	@override String get emailLabel => 'Эл. почта';
	@override String get passwordHint => 'cucumber123';
	@override String get showPassword => 'Показать пароль';
	@override String get hidePassword => 'Скрыть пароль';
	@override String get login_with => 'Войти через {realm_name}';
	@override String get paste_your_code_here => 'Вставьте код здесь';
	@override String get enter_or_paste_code_title => 'Введите или вставьте код для входа';
	@override String get code_usage_hint => 'Мы используем его, чтобы завершить вход в систему.';
	@override String get token_label => 'Токен';
	@override String get token_hint => 'Ваш код здесь…';
	@override String get paste => 'Вставить';
	@override String get clear => 'Очистить';
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

// Path: reactions
class _TranslationsReactionsRu implements TranslationsReactionsEn {
	_TranslationsReactionsRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Реакции';
	@override String get no_reactions => 'Нет реакций';
}

// Path: starred
class _TranslationsStarredRu implements TranslationsStarredEn {
	_TranslationsStarredRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Отмеченные сообщения';
	@override String get no_starred => 'Нет отмеченных сообщений';
}

// Path: unread_marker
class _TranslationsUnreadMarkerRu implements TranslationsUnreadMarkerEn {
	_TranslationsUnreadMarkerRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get label => 'Непрочитанные сообщения';
	@override String get label_with_count => 'Непрочитанные сообщения • {count}';
	@override String get a11y_label => 'Маркер непрочитанных сообщений';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on TranslationsRu {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'auth.emailHint': return 'email@example.com';
			case 'auth.emailLabel': return 'Эл. почта';
			case 'auth.passwordHint': return 'cucumber123';
			case 'auth.showPassword': return 'Показать пароль';
			case 'auth.hidePassword': return 'Скрыть пароль';
			case 'auth.login_with': return 'Войти через {realm_name}';
			case 'auth.paste_your_code_here': return 'Вставьте код здесь';
			case 'auth.enter_or_paste_code_title': return 'Введите или вставьте код для входа';
			case 'auth.code_usage_hint': return 'Мы используем его, чтобы завершить вход в систему.';
			case 'auth.token_label': return 'Токен';
			case 'auth.token_hint': return 'Ваш код здесь…';
			case 'auth.paste': return 'Вставить';
			case 'auth.clear': return 'Очистить';
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
			case 'reactions.title': return 'Реакции';
			case 'reactions.no_reactions': return 'Нет реакций';
			case 'starred.title': return 'Отмеченные сообщения';
			case 'starred.no_starred': return 'Нет отмеченных сообщений';
			case 'select_any_chat': return 'Выберите любой чат';
			case 'unread_marker.label': return 'Непрочитанные сообщения';
			case 'unread_marker.label_with_count': return 'Непрочитанные сообщения • {count}';
			case 'unread_marker.a11y_label': return 'Маркер непрочитанных сообщений';
			default: return null;
		}
	}
}

