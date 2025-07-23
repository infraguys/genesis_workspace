import 'package:flutter/material.dart';

final theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  bottomNavigationBarTheme: _bottomNavBarTheme,
);

final _bottomNavBarTheme = BottomNavigationBarThemeData(
  // --- General properties ---
  backgroundColor: Colors.white, // Background color of the bar
  elevation: 8.0, // Elevation (shadow)
  // --- Selected item properties ---
  selectedItemColor: Colors.deepPurple, // Color of the icon and label of the selected item
  selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
  selectedIconTheme: IconThemeData(
    size: 28.0,
    // color: Colors.blueAccent, // Usually inherited from selectedItemColor
  ),

  // --- Unselected item properties ---
  unselectedItemColor: Colors.grey[600], // Color of the icon and label of unselected items
  unselectedLabelStyle: TextStyle(fontSize: 12.0),
  unselectedIconTheme: IconThemeData(
    size: 24.0,
    // color: Colors.grey[600], // Usually inherited from unselectedItemColor
  ),

  // --- Other properties ---
  showSelectedLabels: true, // Whether to show labels for selected items
  showUnselectedLabels: true, // Whether to show labels for unselected items
  type: BottomNavigationBarType.fixed, // Or .shifting
  // landscapeLayout: BottomNavigationBarLandscapeLayout.spread, // For landscape orientation
);
