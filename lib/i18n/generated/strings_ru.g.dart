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
class TranslationsRu extends Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsRu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ru,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver);

	/// Metadata for the translations of <ru>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	late final TranslationsRu _root = this; // ignore: unused_field

	@override 
	TranslationsRu $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsRu(meta: meta ?? this.$meta);

	// Translations
	@override late final TranslationsAuthRu auth = TranslationsAuthRu._(_root);
	@override String get passwordCantBeEmpty => 'Пароль не может быть пустым';
	@override String get password => 'Пароль';
	@override String get login => 'Войти';
	@override String get typing => 'Печатает';
	@override String get online => 'В сети';
	@override late final TranslationsNavBarRu navBar = TranslationsNavBarRu._(_root);
	@override String get feed => 'Лента';
	@override String get selectAnyChannel => 'Выберите любой канал';
	@override String get allMessages => 'Все сообщения';
	@override String get noMessagesHereYet => 'Здесь пока нет сообщений...';
	@override String get copy => 'Копировать';
	@override String wasOnline({required Object time}) => 'был(а) онлайн ${time} назад';
	@override String get wasOnlineJustNow => 'был(а) онлайн только что';
	@override late final TranslationsTimeAgoRu timeAgo = TranslationsTimeAgoRu._(_root);
	@override String get search => 'Поиск';
	@override late final TranslationsSettingsRu settings = TranslationsSettingsRu._(_root);
	@override late final TranslationsDateLabelsRu dateLabels = TranslationsDateLabelsRu._(_root);
	@override late final TranslationsInboxRu inbox = TranslationsInboxRu._(_root);
	@override late final TranslationsMentionsRu mentions = TranslationsMentionsRu._(_root);
	@override late final TranslationsReactionsRu reactions = TranslationsReactionsRu._(_root);
	@override late final TranslationsStarredRu starred = TranslationsStarredRu._(_root);
	@override String get selectAnyChat => 'Выберите любой чат';
	@override late final TranslationsUnreadMarkerRu unreadMarker = TranslationsUnreadMarkerRu._(_root);
	@override String get recentDialogs => 'Недавние чаты';
	@override String get showAllUsers => 'Показать всех пользователей';
	@override String get showRecentDialogs => 'Показать недавние чаты';
	@override String get noRecentDialogs => 'Нет недавних чатов';
	@override String get error => 'Ошибка';
	@override late final TranslationsMessageActionsRu messageActions = TranslationsMessageActionsRu._(_root);
	@override late final TranslationsAttachmentButtonRu attachmentButton = TranslationsAttachmentButtonRu._(_root);
	@override String get dropFilesToUpload => 'Отпустите файлы, чтобы загрузить';
	@override String get cancelEditing => 'Отменить редактирование';
	@override late final TranslationsFoldersRu folders = TranslationsFoldersRu._(_root);
	@override late final TranslationsChannelRu channel = TranslationsChannelRu._(_root);
	@override late final TranslationsChatRu chat = TranslationsChatRu._(_root);
	@override late final TranslationsGroupRu group = TranslationsGroupRu._(_root);
	@override late final TranslationsGroupChatRu groupChat = TranslationsGroupChatRu._(_root);
	@override String get nothingFound => 'Ничего не нашли';
	@override late final TranslationsUpdateWidgetRu updateWidget = TranslationsUpdateWidgetRu._(_root);
	@override late final TranslationsUpdateForceRu updateForce = TranslationsUpdateForceRu._(_root);
}

// Path: auth
class TranslationsAuthRu extends TranslationsAuthEn {
	TranslationsAuthRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get emailHint => 'email@example.com';
	@override String get emailLabel => 'Email';
	@override String get passwordHint => 'cucumber123';
	@override String get showPassword => 'Показать пароль';
	@override String get hidePassword => 'Скрыть пароль';
	@override String loginWith({required Object realmName}) => 'Войти через ${realmName}';
	@override String get pasteYourCodeHere => 'Вставьте код';
	@override String get enterOrPasteCodeTitle => 'Введите или вставьте ваш код входа';
	@override String get codeUsageHint => 'Мы используем его, чтобы завершить вход.';
	@override String get tokenLabel => 'Токен';
	@override String get tokenHint => 'Ваш код…';
	@override String get paste => 'Вставить';
	@override String get clear => 'Очистить';
	@override String get pasteBaseUrlHere => 'Вставьте Base URL';
	@override String get enterOrPasteBaseUrlTitle => 'Введите или вставьте адрес сервера';
	@override String get baseUrlUsageHint => 'Укажите URL вашего сервера (например, https://zulip.example.com). Поддерживаются только http/https.';
	@override String get baseUrlLabel => 'Base URL';
	@override String get baseUrlHint => 'https://your-domain.com';
	@override String get baseUrlInvalid => 'Некорректный адрес. Используйте http или https.';
	@override String get saveAndContinue => 'Сохранить и продолжить';
	@override String get logoutFromOrganization => 'Выйти из организации';
	@override String get currentBaseUrl => 'Текущий сервер';
}

// Path: navBar
class TranslationsNavBarRu extends TranslationsNavBarEn {
	TranslationsNavBarRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get allChats => 'Все чаты';
	@override String get directMessages => 'Личные сообщения';
	@override String get settings => 'Настройки';
	@override String get menu => 'Меню';
	@override String get channels => 'Каналы';
	@override String get groupChats => 'Групповые чаты';
}

// Path: timeAgo
class TranslationsTimeAgoRu extends TranslationsTimeAgoEn {
	TranslationsTimeAgoRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get justNow => 'только что';
	@override String minutes({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n,
		one: '${n} минуту',
		few: '${n} минуты',
		many: '${n} минут',
		other: '${n} минуты',
	);
	@override String hours({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n,
		one: '${n} час',
		few: '${n} часа',
		many: '${n} часов',
		other: '${n} часа',
	);
	@override String days({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n,
		one: '${n} день',
		few: '${n} дня',
		many: '${n} дней',
		other: '${n} дня',
	);
}

// Path: settings
class TranslationsSettingsRu extends TranslationsSettingsEn {
	TranslationsSettingsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get language => 'Язык';
	@override String get logout => 'Выйти';
	@override String get appVersion => 'Версия приложения';
	@override String get notificationSound => 'Звук уведомлений';
}

// Path: dateLabels
class TranslationsDateLabelsRu extends TranslationsDateLabelsEn {
	TranslationsDateLabelsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get today => 'Сегодня';
	@override String get yesterday => 'Вчера';
}

// Path: inbox
class TranslationsInboxRu extends TranslationsInboxEn {
	TranslationsInboxRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Входящие';
	@override String get noMessages => 'Все сообщения прочитаны';
	@override String get dmTab => 'Личные сообщения';
	@override String get channelsTab => 'Каналы';
}

// Path: mentions
class TranslationsMentionsRu extends TranslationsMentionsEn {
	TranslationsMentionsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Упоминания';
	@override String get noMentions => 'Нет упоминаний';
}

// Path: reactions
class TranslationsReactionsRu extends TranslationsReactionsEn {
	TranslationsReactionsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Реакции';
	@override String get noReactions => 'Нет реакций';
}

// Path: starred
class TranslationsStarredRu extends TranslationsStarredEn {
	TranslationsStarredRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Отмеченные сообщения';
	@override String get noStarred => 'Нет отмеченных сообщений';
}

// Path: unreadMarker
class TranslationsUnreadMarkerRu extends TranslationsUnreadMarkerEn {
	TranslationsUnreadMarkerRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get label => 'Непрочитанные сообщения';
	@override String labelWithCount({required Object count}) => 'Непрочитанные сообщения • ${count}';
	@override String get a11yLabel => 'Маркер непрочитанных сообщений';
}

// Path: messageActions
class TranslationsMessageActionsRu extends TranslationsMessageActionsEn {
	TranslationsMessageActionsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get quote => 'Цитировать это сообщение';
	@override String get delete => 'Удалить это сообщение';
	@override String get star => 'Отметить это сообщение';
	@override String get edit => 'Редактировать это сообщение';
}

// Path: attachmentButton
class TranslationsAttachmentButtonRu extends TranslationsAttachmentButtonEn {
	TranslationsAttachmentButtonRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get file => 'Выбрать файл';
	@override String get image => 'Выбрать изображение';
}

// Path: folders
class TranslationsFoldersRu extends TranslationsFoldersEn {
	TranslationsFoldersRu._(TranslationsRu root) : this._root = root, super.internal(root);

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
	@override String deleteConfirmText({required Object folderName}) => 'Вы уверены, что хотите удалить "${folderName}"?';
	@override String get folderIsEmpty => 'Папка пустая';
}

// Path: channel
class TranslationsChannelRu extends TranslationsChannelEn {
	TranslationsChannelRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get muteChannel => 'Заглушить канал';
	@override String get unmuteChannel => 'Включить уведомления канала';
}

// Path: chat
class TranslationsChatRu extends TranslationsChatEn {
	TranslationsChatRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get pinChat => 'Закрепить чат';
	@override String get unpinChat => 'Открепить чат';
}

// Path: group
class TranslationsGroupRu extends TranslationsGroupEn {
	TranslationsGroupRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String membersCount({required Object count}) => 'Участников: ${count}';
}

// Path: groupChat
class TranslationsGroupChatRu extends TranslationsGroupChatEn {
	TranslationsGroupChatRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get createTooltip => 'Создать групповой чат';
	@override late final TranslationsGroupChatCreateDialogRu createDialog = TranslationsGroupChatCreateDialogRu._(_root);
}

// Path: updateWidget
class TranslationsUpdateWidgetRu extends TranslationsUpdateWidgetEn {
	TranslationsUpdateWidgetRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get updateAvailable => 'Доступно обновление';
	@override String newVersionAvailable({required Object version}) => 'Доступна ${version}';
	@override String newVersionLong({required Object size}) => 'Новая версия готова к загрузке, нажмите кнопку ниже, чтобы начать загрузку. Это загрузит ${size} данных.';
	@override String get restart => 'Перезапустить для обновления';
	@override String get warningTitle => 'Вы уверены?';
	@override String get restartWarning => 'Для завершения установки обновления требуется перезапуск.\nВсе несохраненные изменения будут потеряны. Перезапустить сейчас?';
	@override String get warningCancel => 'Не сейчас';
	@override String get warningConfirm => 'Перезапустить';
}

// Path: updateForce
class TranslationsUpdateForceRu extends TranslationsUpdateForceEn {
	TranslationsUpdateForceRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Требуется обновление';
	@override String description({required Object current, required Object latest}) => 'Текущая версия приложения — ${current}. Актуальная — ${latest}.';
	@override String get loading => 'Загрузка…';
	@override String get update => 'Обновить';
	@override String get unsupportedPlatform => 'Обновления на этой платформе пока не поддержаны.';
	@override String failedToStart({required Object error}) => 'Не удалось запустить обновление: ${error}';
}

// Path: groupChat.createDialog
class TranslationsGroupChatCreateDialogRu extends TranslationsGroupChatCreateDialogEn {
	TranslationsGroupChatCreateDialogRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Новый групповой чат';
	@override String get searchHint => 'Поиск пользователей';
	@override String get noUsers => 'Пользователи не найдены';
	@override String get cancel => 'Отмена';
	@override String get create => 'Создать';
}
