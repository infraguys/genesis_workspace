class PlatformInfo {
  const PlatformInfo();

  bool get isWeb => false;
  bool get isMobile => false;
  bool get isDesktop => false;
}

const platformInfo = PlatformInfo();
