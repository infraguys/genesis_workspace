import 'dart:async';
import 'dart:developer';

import 'package:genesis_workspace/flavor.dart';
import 'package:genesis_workspace/main.dart';

void main() async {
  runZonedGuarded(
    () {
      Flavor.current = Flavor.prod;
      return Main.startApp();
    },
    (error, stackTrace) {
      inspect(error);
      inspect(stackTrace);
    },
  );
}
