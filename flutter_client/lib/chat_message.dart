import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Message is class defining message data (id and text)
class Message {
  /// _uuid is unique ID generator
  static var _uuid = Uuid();

  /// id is unique ID of message
  String id;

  /// text is content of message
  String text;

  /// Class constructor
  Message(this.text, [this.id]) {
    if (id == null) {
      id = _uuid.v4();
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
