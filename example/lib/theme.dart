import 'package:flutter/material.dart';

const headerTextStyle = TextStyle(fontSize: 18, color: Colors.deepPurple);
const bodyTextStyle = TextStyle(fontSize: 14);

ThemeData getThemeData(BuildContext context) {
  return ThemeData(
    textTheme: const TextTheme(
      titleMedium: headerTextStyle,
      bodyMedium: bodyTextStyle,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 10),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Colors.black,
      thickness: 1,
    ),
    listTileTheme: const ListTileThemeData(
      titleTextStyle: TextStyle(fontSize: 12),
      subtitleTextStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
    ),
  );
}
