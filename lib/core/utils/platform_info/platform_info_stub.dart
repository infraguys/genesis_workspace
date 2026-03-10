class PlatformInfo {
  const PlatformInfo();

  bool get isWeb => false;
  bool get isMobile => false;
  bool get isDesktop => false;
  bool get isLinux => false;
  bool get isMacos => false;
  bool get isIos => false;
  bool get isAndroid => false;
}

const platformInfo = PlatformInfo();
