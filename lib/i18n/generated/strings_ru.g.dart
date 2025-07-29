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
	@override String get passwordCantBeEmpty => 'Пароль не может быть пустым';
	@override String get password => 'Пароль';
	@override String get login => 'Вход';
	@override String get typing => 'Печатает';
	@override String get online => 'В сети';
	@override late final TranslationsNavBarRu navBar = TranslationsNavBarRu._(_root);
	@override String get selectAnyChannel => 'Выберите любой канал';
	@override String get allMessages => 'Все сообщения';
	@override String get noMessagesHereYet => 'Здесь пока нет сообщений...';
	@override String get copy => 'Копировать';
	@override String wasOnline({required Object time}) => 'Был(а) в сети ${time} назад';
	@override String get wasOnlineJustNow => 'Был(а) в сети только что';
	@override late final TranslationsTimeAgoRu timeAgo = TranslationsTimeAgoRu._(_root);
}

// Path: navBar
class TranslationsNavBarRu extends TranslationsNavBarEn {
	TranslationsNavBarRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get directMessages => 'Личные сообщения';
	@override String get settings => 'Настройки';
	@override String get profile => 'Профиль';
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
		other: '${n} минут',
	);
	@override String hours({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n,
		one: '${n} час',
		few: '${n} часа',
		many: '${n} часов',
		other: '${n} часов',
	);
	@override String days({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n,
		one: '${n} день',
		few: '${n} дня',
		many: '${n} дней',
		other: '${n} дней',
	);
}
