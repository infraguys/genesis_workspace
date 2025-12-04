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

  Future<List<PinnedChat>> getPinnedChats(String folderUuid, int organizationId) {
    return (select(pinnedChats)
          ..where(
            (t) => t.folderUuid.equals(folderUuid) & t.organizationId.equals(organizationId),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
  }

  Future<PinnedChat?> getPinnedChatByIds({
    required String folderUuid,
    required int chatId,
    required int organizationId,
  }) {
    return (select(pinnedChats)..where(
          (t) => t.folderUuid.equals(folderUuid) & t.chatId.equals(chatId) & t.organizationId.equals(organizationId),
        ))
        .getSingleOrNull();
  }

  Future<void> pinToEnd({
    required String folderUuid,
    required int chatId,
    required int organizationId,
  }) async {
    await transaction(() async {
      final existing = await getPinnedChatByIds(
        folderUuid: folderUuid,
        chatId: chatId,
        organizationId: organizationId,
      );
      if (existing != null) return;

      final maxExpr = pinnedChats.orderIndex.max();
      final maxRow =
          await (selectOnly(pinnedChats)
                ..addColumns([maxExpr])
                ..where(
                  pinnedChats.folderUuid.equals(folderUuid) & pinnedChats.organizationId.equals(organizationId),
                ))
              .getSingle();

      final int maxIndex = maxRow.read(maxExpr) ?? 0;
      final int newIndex = (maxIndex == 0) ? kOrderStep : maxIndex + kOrderStep;

      await into(pinnedChats).insert(
        PinnedChatsCompanion.insert(
          uuid: '${folderUuid}_$chatId',
          folderUuid: folderUuid,
          chatId: chatId,
          orderIndex: Value(newIndex),
          pinnedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
          organizationId: organizationId,
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> pinChat({
    required String folderUuid,
    required int chatId,
    required int organizationId,
  }) {
    return pinToEnd(
      folderUuid: folderUuid,
      chatId: chatId,
      organizationId: organizationId,
    );
  }

  Future<void> unpinByIds({
    required String folderUuid,
    required int chatId,
    required int organizationId,
  }) {
    return (delete(pinnedChats)..where(
          (t) => t.folderUuid.equals(folderUuid) & t.chatId.equals(chatId) & t.organizationId.equals(organizationId),
        ))
        .go();
  }

  Future<void> moveBetween({
    required String folderUuid,
    required int movedChatId,
    int? previousChatId,
    int? nextChatId,
    required int organizationId,
  }) async {
    await transaction(() async {
      Future<int?> indexOf(int chatId) async {
        final row =
            await (select(pinnedChats)..where(
                  (t) =>
                      t.folderUuid.equals(folderUuid) &
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
        newIndex = kOrderStep;
      }

      if (newIndex == null || newIndex <= 0) {
        await resequenceFolder(folderUuid, organizationId);

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

      await (update(pinnedChats)..where(
            (t) =>
                t.folderUuid.equals(folderUuid) &
                t.chatId.equals(movedChatId) &
                t.organizationId.equals(organizationId),
          ))
          .write(
            PinnedChatsCompanion(
              orderIndex: Value(newIndex!),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
    });
  }

  Future<void> updateOrder({required String pinnedChatUuid, required int newOrderIndex}) async {
    await (update(pinnedChats)..where((t) => t.uuid.equals(pinnedChatUuid))).write(
      PinnedChatsCompanion(
        orderIndex: Value(newOrderIndex),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> resequenceFolder(String folderUuid, int organizationId) async {
    final rows = await getPinnedChats(folderUuid, organizationId);
    int position = 1;
    for (final row in rows) {
      final int newIndex = position * kOrderStep;
      position++;
      await (update(pinnedChats)..where((t) => t.uuid.equals(row.uuid))).write(
        PinnedChatsCompanion(
          orderIndex: Value(newIndex),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
    }
  }
}
