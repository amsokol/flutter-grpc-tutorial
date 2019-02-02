import 'package:flutter/material.dart';

import 'chat_screen.dart';
import 'theme.dart';

/// FriendlychatApp is Flutter application
class FriendlychatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Friendlychat",
      theme: isIOS(context) ? kIOSTheme : kDefaultTheme,
      home: ChatScreen(),
    );
  }
}
