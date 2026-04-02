import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/organizations/usecases/get_organization_emoji_list_use_case.dart';
import 'package:genesis_workspace/features/organizations/bloc/organizations_cubit.dart';
import 'package:injectable/injectable.dart';

part 'emoji_keyboard_state.dart';

@LazySingleton()
class EmojiKeyboardCubit extends Cubit<EmojiKeyboardState> {
  EmojiKeyboardCubit(
    this._organizationsCubit,
    this._getOrganizationEmojiListUseCase,
  ) : super(
        EmojiKeyboardState(showEmojiKeyboard: false, keyboardHeight: 0, organizationEmojiCodes: {}, emojiMap: {}),
      );

  final OrganizationsCubit _organizationsCubit;

  final GetOrganizationEmojiListUseCase _getOrganizationEmojiListUseCase;

  void setHeight(double height) {
    emit(state.copyWith(keyboardHeight: height));
  }

  void setShowEmojiKeyboard(bool show, {bool? closeKeyboard = false}) {
    double updatedHeight = state.keyboardHeight;
    if (closeKeyboard == true) {
      updatedHeight = 0;
    }
    emit(
      state.copyWith(
        showEmojiKeyboard: show,
        keyboardHeight: updatedHeight,
      ),
    );
  }

  Future<void> getEmojiForOrganization() async {
    final selectedOrganizationId = _organizationsCubit.state.selectedOrganizationId;
    if (selectedOrganizationId == null) {
      emit(state.copyWith(organizationEmojiCodes: {}));
      return;
    }

    final organizations = _organizationsCubit.state.organizations;
    String? emojiServerUrl;
    for (final organization in organizations) {
      if (organization.id == selectedOrganizationId) {
        emojiServerUrl = organization.emojiServerUrl;
        break;
      }
    }

    if (emojiServerUrl == null || emojiServerUrl.trim().isEmpty) {
      emit(state.copyWith(organizationEmojiCodes: {}));
      return;
    }

    try {
      final emojiList = await _getOrganizationEmojiListUseCase(emojiServerUrl);
      final emojiMap = <String, List<String>>{};
      final organizationEmojiCodes = emojiList.emojiList
          .map((emoji) {
            emojiMap[emoji.emojiCode] = emoji.emojiNames;
            return _normalizeEmojiCode(emoji.emojiCode);
          })
          .where((code) => code.isNotEmpty)
          .toSet();

      emit(state.copyWith(organizationEmojiCodes: organizationEmojiCodes, emojiMap: emojiMap));
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }

  String _normalizeEmojiCode(String rawCode) {
    final parts = rawCode.trim().toLowerCase().split('-').where((part) => part.isNotEmpty);

    final normalizedParts = <String>[];
    for (final part in parts) {
      final parsedValue = int.tryParse(part, radix: 16);
      if (parsedValue == null) {
        return '';
      }
      final normalizedPart = parsedValue.toRadixString(16);
      if (normalizedPart == 'fe0f' || normalizedPart == 'fe0e') {
        continue;
      }
      normalizedParts.add(normalizedPart);
    }

    return normalizedParts.join('-');
  }
}
