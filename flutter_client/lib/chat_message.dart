import 'package:flutter/material.dart';

abstract class ChatMessage extends Widget {
  String get uuid;
  AnimationController get animationController;
}
