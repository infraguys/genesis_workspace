import 'package:flutter_bloc/flutter_bloc.dart';

part 'logs_state.dart';

class LogsCubit extends Cubit<LogsState> {
  LogsCubit() : super(LogsInitial());
}
