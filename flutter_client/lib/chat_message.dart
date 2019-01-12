import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Message {
  static var _uuid = Uuid();

  String id;
  String text;

  Message(this.text, [this.id]) {
    if (id == null) {
      id = _uuid.v4();
    }
  }
}

abstract class ChatMessage extends Widget {
  Message get message;
  AnimationController get animationController;
}
