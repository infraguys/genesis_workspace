import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/features/drafts/bloc/drafts_cubit.dart';

class DraftsView extends StatefulWidget {
  const DraftsView({super.key});

  @override
  State<DraftsView> createState() => _DraftsViewState();
}

class _DraftsViewState extends State<DraftsView> {
  late final Future _future;

  @override
  void initState() {
    _future = context.read<DraftsCubit>().getDrafts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Drafts"),
    );
  }
}
