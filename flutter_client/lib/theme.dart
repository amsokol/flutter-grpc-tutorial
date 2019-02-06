import 'package:flutter/material.dart';

final ThemeData kIOSTheme = new ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = ThemeData.light();
final Color shimmerBaseColor = Colors.black; /*Colors.white;*/
final Color shimmerHighlightColor = Colors.grey[200]; /*Colors.grey[700];*/

bool isIOS(BuildContext context) {
  return Theme.of(context).platform == TargetPlatform.iOS;
}
