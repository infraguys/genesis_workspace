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
	@override String get recent_dialogs => 'Недавние чаты';
	@override String get show_all_users => 'Показать всех пользователей';
	@override String get show_recent_dialogs => 'Показать недавние чаты';
	@override String get no_recent_dialogs => 'Нет недавних чатов';
	@override String get error => 'Ошибка';
	@override late final _TranslationsMessageActionsRu message_actions = _TranslationsMessageActionsRu._(_root);
	@override late final _TranslationsAttachmentButtonRu attachment_button = _TranslationsAttachmentButtonRu._(_root);
	@override String get drop_files_to_upload => 'Отпустите файлы, чтобы загрузить';
	@override String get cancel_editing => 'Отменить редактирование';
	@override late final _TranslationsFoldersRu folders = _TranslationsFoldersRu._(_root);
	@override late final _TranslationsChannelRu channel = _TranslationsChannelRu._(_root);
	@override late final _TranslationsChatRu chat = _TranslationsChatRu._(_root);
	@override String get nothing_found => 'Ничего не нашли';
}

// Path: auth
class _TranslationsAuthRu implements TranslationsAuthEn {
	_TranslationsAuthRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get email_hint => 'email@example.com';
	@override String get email_label => 'Email';
	@override String get password_hint => 'cucumber123';
	@override String get show_password => 'Показать пароль';
	@override String get hide_password => 'Скрыть пароль';
	@override String get login_with => 'Войти через {realm_name}';
	@override String get paste_your_code_here => 'Вставьте код';
	@override String get enter_or_paste_code_title => 'Введите или вставьте ваш код входа';
	@override String get code_usage_hint => 'Мы используем его, чтобы завершить вход.';
	@override String get token_label => 'Токен';
	@override String get token_hint => 'Ваш код…';
	@override String get paste => 'Вставить';
	@override String get clear => 'Очистить';
	@override String get paste_base_url_here => 'Вставьте Base URL';
	@override String get enter_or_paste_base_url_title => 'Введите или вставьте адрес сервера';
	@override String get base_url_usage_hint => 'Укажите URL вашего сервера (например, https://zulip.example.com). Поддерживаются только http/https.';
	@override String get base_url_label => 'Base URL';
	@override String get base_url_hint => 'https://your-domain.com';
	@override String get base_url_invalid => 'Некорректный адрес. Используйте http или https.';
	@override String get save_and_continue => 'Сохранить и продолжить';
	@override String get logout_from_organization => 'Выйти из организации';
	@override String get current_base_url => 'Текущий сервер';
}

// Path: nav_bar
class _TranslationsNavBarRu implements TranslationsNavBarEn {
	_TranslationsNavBarRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get all_chats => 'Все чаты';
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
	@override String get appVersion => 'Версия приложения';
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

// Path: message_actions
class _TranslationsMessageActionsRu implements TranslationsMessageActionsEn {
	_TranslationsMessageActionsRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get quote => 'Цитировать это сообщение';
	@override String get delete => 'Удалить это сообщение';
	@override String get star => 'Отметить это сообщение';
	@override String get edit => 'Редактировать это сообщение';
}

// Path: attachment_button
class _TranslationsAttachmentButtonRu implements TranslationsAttachmentButtonEn {
	_TranslationsAttachmentButtonRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get file => 'Выбрать файл';
	@override String get image => 'Выбрать изображение';
}

// Path: folders
class _TranslationsFoldersRu implements TranslationsFoldersEn {
	_TranslationsFoldersRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get all => 'Все';
	@override String get title => 'Папки';
	@override String get newFolderTitle => 'Новая папка';
	@override String get nameLabel => 'Название папки';
	@override String get colorLabel => 'Цвет папки';
	@override String get iconLabel => 'Иконка';
	@override String get preview => 'Предпросмотр';
	@override String get create => 'Создать';
	@override String get cancel => 'Отмена';
	@override String get addToFolder => 'Добавить в папку';
	@override String get selectFolders => 'Выберите папки';
	@override String get save => 'Сохранить';
	@override String get edit => 'Редактировать папку';
	@override String get orderPinning => 'Порядок закрепления';
	@override String get delete => 'Удалить';
	@override String get deleteConfirmTitle => 'Удалить папку?';
	@override String get deleteConfirmText => 'Вы уверены, что хотите удалить "{folderName}"?';
	@override String get folder_is_empty => 'Папка пустая';
}

// Path: channel
class _TranslationsChannelRu implements TranslationsChannelEn {
	_TranslationsChannelRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get muteChannel => 'Заглушить канал';
	@override String get unmuteChannel => 'Включить уведомления канала';
}

// Path: chat
class _TranslationsChatRu implements TranslationsChatEn {
	_TranslationsChatRu._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get pinChat => 'Закрепить чат';
	@override String get unpinChat => 'Открепить чат';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on TranslationsRu {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'auth.email_hint': return 'email@example.com';
			case 'auth.email_label': return 'Email';
			case 'auth.password_hint': return 'cucumber123';
			case 'auth.show_password': return 'Показать пароль';
			case 'auth.hide_password': return 'Скрыть пароль';
			case 'auth.login_with': return 'Войти через {realm_name}';
			case 'auth.paste_your_code_here': return 'Вставьте код';
			case 'auth.enter_or_paste_code_title': return 'Введите или вставьте ваш код входа';
			case 'auth.code_usage_hint': return 'Мы используем его, чтобы завершить вход.';
			case 'auth.token_label': return 'Токен';
			case 'auth.token_hint': return 'Ваш код…';
			case 'auth.paste': return 'Вставить';
			case 'auth.clear': return 'Очистить';
			case 'auth.paste_base_url_here': return 'Вставьте Base URL';
			case 'auth.enter_or_paste_base_url_title': return 'Введите или вставьте адрес сервера';
			case 'auth.base_url_usage_hint': return 'Укажите URL вашего сервера (например, https://zulip.example.com). Поддерживаются только http/https.';
			case 'auth.base_url_label': return 'Base URL';
			case 'auth.base_url_hint': return 'https://your-domain.com';
			case 'auth.base_url_invalid': return 'Некорректный адрес. Используйте http или https.';
			case 'auth.save_and_continue': return 'Сохранить и продолжить';
			case 'auth.logout_from_organization': return 'Выйти из организации';
			case 'auth.current_base_url': return 'Текущий сервер';
			case 'password_cant_be_empty': return 'Пароль не может быть пустым';
			case 'password': return 'Пароль';
			case 'login': return 'Войти';
			case 'typing': return 'Печатает';
			case 'online': return 'В сети';
			case 'nav_bar.all_chats': return 'Все чаты';
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
			case 'settings.appVersion': return 'Версия приложения';
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
			case 'recent_dialogs': return 'Недавние чаты';
			case 'show_all_users': return 'Показать всех пользователей';
			case 'show_recent_dialogs': return 'Показать недавние чаты';
			case 'no_recent_dialogs': return 'Нет недавних чатов';
			case 'error': return 'Ошибка';
			case 'message_actions.quote': return 'Цитировать это сообщение';
			case 'message_actions.delete': return 'Удалить это сообщение';
			case 'message_actions.star': return 'Отметить это сообщение';
			case 'message_actions.edit': return 'Редактировать это сообщение';
			case 'attachment_button.file': return 'Выбрать файл';
			case 'attachment_button.image': return 'Выбрать изображение';
			case 'drop_files_to_upload': return 'Отпустите файлы, чтобы загрузить';
			case 'cancel_editing': return 'Отменить редактирование';
			case 'folders.all': return 'Все';
			case 'folders.title': return 'Папки';
			case 'folders.newFolderTitle': return 'Новая папка';
			case 'folders.nameLabel': return 'Название папки';
			case 'folders.colorLabel': return 'Цвет папки';
			case 'folders.iconLabel': return 'Иконка';
			case 'folders.preview': return 'Предпросмотр';
			case 'folders.create': return 'Создать';
			case 'folders.cancel': return 'Отмена';
			case 'folders.addToFolder': return 'Добавить в папку';
			case 'folders.selectFolders': return 'Выберите папки';
			case 'folders.save': return 'Сохранить';
			case 'folders.edit': return 'Редактировать папку';
			case 'folders.orderPinning': return 'Порядок закрепления';
			case 'folders.delete': return 'Удалить';
			case 'folders.deleteConfirmTitle': return 'Удалить папку?';
			case 'folders.deleteConfirmText': return 'Вы уверены, что хотите удалить "{folderName}"?';
			case 'folders.folder_is_empty': return 'Папка пустая';
			case 'channel.muteChannel': return 'Заглушить канал';
			case 'channel.unmuteChannel': return 'Включить уведомления канала';
			case 'chat.pinChat': return 'Закрепить чат';
			case 'chat.unpinChat': return 'Открепить чат';
			case 'nothing_found': return 'Ничего не нашли';
			default: return null;
		}
	}
}

