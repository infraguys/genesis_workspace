import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/features/feed/bloc/feed_cubit.dart';
import 'package:genesis_workspace/features/feed/view/feed_view.dart';

class Feed extends StatelessWidget {
  const Feed({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => FeedCubit(), child: FeedView());
  }
}
