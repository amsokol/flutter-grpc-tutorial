import 'package:flutter/material.dart';

/// Message is class defining message data (id and text)
class Message {
  /// id is unique ID of message
  String id;

  /// text is content of message
  String text;

  /// Class constructor
  Message(this.text, [this.id]) {
    if (id == null) {
      id = UniqueKey().toString();
    }
  }
}

/// ChatMessage is base abstract class for outgoing and incoming message widgets
abstract class ChatMessage extends Widget {
  /// Message content
  Message get message;

  /// Controller of animation for message widget
  AnimationController get animationController;
}
