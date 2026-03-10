import 'dart:io' as io;

class PlatformInfo {
  const PlatformInfo();

  bool get isWeb => false;

  bool get isMobile => io.Platform.isAndroid || io.Platform.isIOS;

  bool get isDesktop => io.Platform.isWindows || io.Platform.isLinux || io.Platform.isMacOS;

  bool get isLinux => io.Platform.isLinux;

  bool get isMacos => io.Platform.isMacOS;

  bool get isIos => io.Platform.isIOS;

  bool get isAndroid => io.Platform.isAndroid;
}

const platformInfo = PlatformInfo();
