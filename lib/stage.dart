import 'package:genesis_workspace/flavor.dart';
import 'package:genesis_workspace/main.dart';

void main() async {
  Flavor.current = Flavor.stage;
  return Main.startApp();
}
