// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

/// Реальная реализация для Web.
void platformUpdateBrowserUrlPath(String path, {bool addToHistory = true}) {
  final normalized = path.startsWith('/') ? path : '/$path';
  if (addToHistory) {
    html.window.history.pushState(null, '', normalized);
  } else {
    html.window.history.replaceState(null, '', normalized);
  }
}
