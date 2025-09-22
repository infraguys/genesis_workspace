import 'dart:io' as io;

class PlatformInfo {
  const PlatformInfo();

  bool get isWeb => false;

  bool get isMobile => io.Platform.isAndroid || io.Platform.isIOS;

  bool get isDesktop => io.Platform.isWindows || io.Platform.isLinux || io.Platform.isMacOS;
}

const platformInfo = PlatformInfo();
