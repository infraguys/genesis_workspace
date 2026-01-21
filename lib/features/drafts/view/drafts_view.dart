import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/extensions.dart';
import 'package:genesis_workspace/core/widgets/workspace_app_bar.dart';
import 'package:genesis_workspace/features/drafts/bloc/drafts_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class DraftsView extends StatelessWidget {
  const DraftsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WorkspaceAppBar(
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffB86BEF),
              ),
              child: Assets.icons.pencilFilled.svg(
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
            SizedBox(width: 12),
            Text(
              context.t.drafts.title,
            ),
          ],
        ),
      ),
      body: BlocBuilder<DraftsCubit, DraftsState>(
        builder: (context, state) {
          if (state.drafts.isEmpty) {
            return Center(
              child: Text(context.t.drafts.noDrafts),
            );
          }
          return ListView.builder(
            itemCount: state.drafts.length,
            itemBuilder: (BuildContext context, int index) {
              final draft = state.drafts[index];
              return ListTile(
                title: Text(draft.content),
                trailing: IconButton(
                  onPressed: () async {
                    if (draft.id != null) {
                      await context.read<DraftsCubit>().deleteDraft(draft.id!);
                    }
                  },
                  icon: Icon(
                    Icons.delete_outline,
                    color: AppColors.noticeBase,
                  ),
                ).pending(state.pendingDraftId == draft.id),
              );
            },
          );
        },
      ),
    );
  }
}
