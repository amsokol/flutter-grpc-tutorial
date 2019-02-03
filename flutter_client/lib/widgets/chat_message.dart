import 'package:flutter/material.dart';

import 'package:flutter_client/models/message.dart';

/// ChatMessage is base abstract class for outgoing and incoming message widgets
abstract class ChatMessage extends Widget {
  /// Message content
  Message get message;

  /// Controller of animation for message widget
  AnimationController get animationController;
}
