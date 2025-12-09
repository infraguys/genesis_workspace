class PlatformInfo {
  const PlatformInfo();

  bool get isWeb => false;
  bool get isMobile => false;
  bool get isDesktop => false;
  bool get isLinux => false;
  bool get isMacos => false;
}

const platformInfo = PlatformInfo();
