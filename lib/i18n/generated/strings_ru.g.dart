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
	@override String get selectAnyChat => 'Выберите любой чат';
}

// Path: auth
class TranslationsAuthRu extends TranslationsAuthEn {
	TranslationsAuthRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get emailHint => 'email@genesis.team';
	@override String get emailLabel => 'Почта';
	@override String get passwordHint => 'cucumber123';
	@override String get showPassword => 'Показать пароль';
	@override String get hidePassword => 'Скрыть пароль';
}

// Path: navBar
class TranslationsNavBarRu extends TranslationsNavBarEn {
	TranslationsNavBarRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get directMessages => 'Личные сообщения';
	@override String get settings => 'Настройки';
	@override String get menu => 'Меню';
	@override String get channels => 'Каналы';
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
