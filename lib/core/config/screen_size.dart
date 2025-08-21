import 'package:flutter/material.dart';

ScreenSize currentSize(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  switch (width) {
    case (> 1440):
      return ScreenSize.desktop;
    case (<= 1440 && > 1024):
      return ScreenSize.laptop;
    case (<= 1024 && > 768):
      return ScreenSize.lTablet;
    case (<= 768 && > 425):
      return ScreenSize.tablet;
    case (<= 425):
      return ScreenSize.mobile;
    default:
      return ScreenSize.mobile;
  }
}

enum ScreenSize {
  /// >1440+
  desktop,

  /// <= 1440 && > 1024
  laptop,

  /// <= 1024 && > 768
  lTablet,

  /// <= 768 && > 425
  tablet,

  /// <= 425
  mobile,
}

// screen_size.dart (continued)
extension ScreenSizeComparison on ScreenSize {
  /// Checks if this screen size is smaller than the [other] screen size.
  /// Example: ScreenSize.s.isSmallerThan(ScreenSize.m) -> true
  bool isSmallerThan(ScreenSize other) {
    // Assuming xl is the "largest" and s is the "smallest"
    // Higher index means smaller screen in your current enum definition
    return index > other.index;
  }

  /// Checks if this screen size is smaller than or equal to the [other] screen size.
  bool isSmallerThanOrEqualTo(ScreenSize other) {
    return index >= other.index;
  }

  /// Checks if this screen size is larger than the [other] screen size.
  /// Example: ScreenSize.xl.isLargerThan(ScreenSize.m) -> true
  bool isLargerThan(ScreenSize other) {
    // Lower index means larger screen in your current enum definition
    return index < other.index;
  }

  /// Checks if this screen size is larger than or equal to the [other] screen size.
  bool isLargerThanOrEqualTo(ScreenSize other) {
    return index <= other.index;
  }

  // You can also add shorthand operators if you prefer,
  // though they won't be true operator overrides.

  /// Alias for isSmallerThan (mimics '<')
  bool operator <(ScreenSize other) => isSmallerThan(other);

  /// Alias for isSmallerThanOrEqualTo (mimics '<=')
  bool operator <=(ScreenSize other) => isSmallerThanOrEqualTo(other);

  /// Alias for isLargerThan (mimics '>')
  bool operator >(ScreenSize other) => isLargerThan(other);

  /// Alias for isLargerThanOrEqualTo (mimics '>=')
  bool operator >=(ScreenSize other) => isLargerThanOrEqualTo(other);
}
