import 'package:web/web.dart' as web;

class PlatformInfo {
  const PlatformInfo();

  bool get isWeb => true;

  bool get isMobile {
    final String userAgent = web.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('iphone') ||
        userAgent.contains('ipad') ||
        userAgent.contains('ipod') ||
        userAgent.contains('android') ||
        userAgent.contains('mobile');
  }

  bool get isDesktop => !isMobile;

  bool get isLinux => false;

  bool get isMacos => false;
}

const platformInfo = PlatformInfo();
