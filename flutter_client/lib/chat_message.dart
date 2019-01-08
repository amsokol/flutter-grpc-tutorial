import 'package:flutter/material.dart';

abstract class ChatMessage extends StatelessWidget {
  final String uuid;
  final String text;

  final AnimationController animationController;

  ChatMessage({this.uuid, this.text, this.animationController})
      : super(key: new ObjectKey(uuid));
}
