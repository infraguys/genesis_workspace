// lib/data/all_chats/dao/pinned_chats_dao.dart
import 'package:drift/drift.dart';
import 'package:genesis_workspace/data/all_chats/tables/folder_table.dart';
import 'package:genesis_workspace/data/all_chats/tables/pinned_chats_table.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:injectable/injectable.dart';

part 'pinned_chats_dao.g.dart';

const int kOrderStep = 1024;

@injectable
@DriftAccessor(tables: [PinnedChats, Folders])
class PinnedChatsDao extends DatabaseAccessor<AppDatabase> with _$PinnedChatsDaoMixin {
  PinnedChatsDao(super.db);

  // ---------- Queries ----------

  Future<List<PinnedChat>> getPinnedChats(int folderId, int organizationId) {
    return (select(pinnedChats)
          ..where(
            (t) => t.folderId.equals(folderId) & t.organizationId.equals(organizationId),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
  }

  Future<PinnedChat?> getPinnedChatByIds({
    required int folderId,
    required int chatId,
    required int organizationId,
  }) {
    return (select(
      pinnedChats,
    )..where(
            (t) =>
                t.folderId.equals(folderId) &
                t.chatId.equals(chatId) &
                t.organizationId.equals(organizationId),
          ))
        .getSingleOrNull();
  }

  // ---------- Pin / Unpin ----------

  /// Пинуем чат в конец списка папки (дефолтное поведение)
  Future<int> pinToEnd({
    required int folderId,
    required int chatId,
    required PinnedChatType type,
    required int organizationId,
  }) async {
    return transaction(() async {
      // уникальность: если уже пиннут — просто вернуть id
      final existing = await getPinnedChatByIds(
        folderId: folderId,
        chatId: chatId,
        organizationId: organizationId,
      );
      if (existing != null) return existing.id;

      final maxExpr = pinnedChats.orderIndex.max();
      final maxRow =
          await (selectOnly(pinnedChats)
                ..addColumns([maxExpr])
                ..where(
                  pinnedChats.folderId.equals(folderId) &
                      pinnedChats.organizationId.equals(organizationId),
                ))
              .getSingle();

      final int maxIndex = maxRow.read(maxExpr) ?? 0;
      final int newIndex = (maxIndex == 0) ? kOrderStep : maxIndex + kOrderStep;

      return into(pinnedChats).insert(
        PinnedChatsCompanion.insert(
          folderId: folderId,
          chatId: chatId,
          orderIndex: Value(newIndex),
          type: type,
          organizationId: organizationId,
        ),
        mode: InsertMode.insert,
      );
    });
  }

  Future<void> pinChat({
    required int folderId,
    required int chatId,
    required PinnedChatType type,
    required int organizationId,
  }) {
    return pinToEnd(
      folderId: folderId,
      chatId: chatId,
      type: type,
      organizationId: organizationId,
    );
  }

  Future<void> unpinById(int pinnedChatId) {
    return (delete(pinnedChats)..where((t) => t.id.equals(pinnedChatId))).go();
  }

  Future<void> unpinByIds({
    required int folderId,
    required int chatId,
    required int organizationId,
  }) {
    return (delete(
      pinnedChats,
    )..where(
            (t) =>
                t.folderId.equals(folderId) &
                t.chatId.equals(chatId) &
                t.organizationId.equals(organizationId),
          ))
        .go();
  }

  // ---------- Reorder ----------

  /// Перемещает чат между соседями. Если одного из соседей нет — ставит в начало/конец.
  Future<void> moveBetween({
    required int folderId,
    required int movedChatId,
    int? previousChatId,
    int? nextChatId,
    required int organizationId,
  }) async {
    await transaction(() async {
      Future<int?> indexOf(int chatId) async {
        final row = await (select(
          pinnedChats,
        )..where(
                (t) =>
                    t.folderId.equals(folderId) &
                    t.chatId.equals(chatId) &
                    t.organizationId.equals(organizationId),
              ))
            .getSingleOrNull();
        return row?.orderIndex;
      }

      final int? prevIndex = previousChatId == null ? null : await indexOf(previousChatId);
      final int? nextIndex = nextChatId == null ? null : await indexOf(nextChatId);

      int? newIndex;

      if (prevIndex != null && nextIndex != null) {
        final int mid = (prevIndex + nextIndex) >> 1;
        if (mid > prevIndex && mid < nextIndex) {
          newIndex = mid;
        }
      } else if (prevIndex != null) {
        newIndex = prevIndex + kOrderStep;
      } else if (nextIndex != null) {
        newIndex = nextIndex - kOrderStep;
      } else {
        // единственный элемент
        newIndex = kOrderStep;
      }

      // Если “зазора” нет — перенумеруем и попробуем ещё раз
      if (newIndex == null || newIndex <= 0) {
        await resequenceFolder(folderId, organizationId);

        final int? prev2 = previousChatId == null ? null : await indexOf(previousChatId);
        final int? next2 = nextChatId == null ? null : await indexOf(nextChatId);

        if (prev2 != null && next2 != null) {
          newIndex = (prev2 + next2) >> 1;
        } else if (prev2 != null) {
          newIndex = prev2 + kOrderStep;
        } else if (next2 != null) {
          newIndex = next2 - kOrderStep;
        } else {
          newIndex = kOrderStep;
        }
      }

      await (update(pinnedChats)
            ..where(
              (t) =>
                  t.folderId.equals(folderId) &
                  t.chatId.equals(movedChatId) &
                  t.organizationId.equals(organizationId),
            ))
          .write(PinnedChatsCompanion(orderIndex: Value(newIndex!)));
    });
  }

  /// Прямая установка индекса (если нужно зафиксировать конкретное значение).
  /// В обычном UI лучше использовать moveBetween.
  Future<void> updateOrder({required int pinnedChatId, required int newOrderIndex}) async {
    await (update(pinnedChats)..where((t) => t.id.equals(pinnedChatId))).write(
      PinnedChatsCompanion(orderIndex: Value(newOrderIndex)),
    );
  }

  /// Редко вызываемая операция: равномерно расставляет индексы с шагом.
  Future<void> resequenceFolder(int folderId, int organizationId) async {
    final rows = await getPinnedChats(folderId, organizationId);
    int position = 1;
    for (final row in rows) {
      final int newIndex = position * kOrderStep;
      position++;
      await (update(pinnedChats)..where((t) => t.id.equals(row.id))).write(
        PinnedChatsCompanion(orderIndex: Value(newIndex)),
      );
    }
  }
}
