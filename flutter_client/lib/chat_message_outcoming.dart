import 'package:flutter/material.dart';

import 'chat_message.dart';

const String _name = "Me";

enum MessageOutcomingStatus { UNKNOWN, SENT }

class MessageOutcoming extends Message {
  MessageOutcomingStatus status;

  MessageOutcoming(
      {String text, String id, this.status = MessageOutcomingStatus.UNKNOWN})
      : super(text, id);
}

class ChatMessageOutcomingController {
  MessageOutcoming message;

  void Function(
          MessageOutcomingStatus oldStatus, MessageOutcomingStatus newStatus)
      onStatusChanged;

  ChatMessageOutcomingController({this.message});

  void setStatus(MessageOutcomingStatus newStatus) {
    var oldStatus = message.status;
    if (oldStatus != newStatus) {
      message.status = newStatus;
      if (onStatusChanged != null) {
        onStatusChanged(oldStatus, newStatus);
      }
    }
  }
}

class ChatMessageOutcoming extends StatefulWidget implements ChatMessage {
  final MessageOutcoming message;
  final ChatMessageOutcomingController controller;
  final AnimationController animationController;

  ChatMessageOutcoming({this.message, this.animationController})
      : controller = ChatMessageOutcomingController(message: message),
        super(key: new ObjectKey(message.id));

  @override
  State createState() => ChatMessageOutcomingState(
      animationController: animationController, controller: controller);
}

class ChatMessageOutcomingState extends State<ChatMessageOutcoming> {
  final ChatMessageOutcomingController controller;
  final AnimationController animationController;

  ChatMessageOutcomingState({this.controller, this.animationController}) {
    controller.onStatusChanged = onStatusChanged;
  }

  void onStatusChanged(
      MessageOutcomingStatus oldStatus, MessageOutcomingStatus newStatus) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor:
          CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 16.0),
              child: CircleAvatar(child: Text(_name[0])),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(_name, style: Theme.of(context).textTheme.subhead),
                  Container(
                    margin: EdgeInsets.only(top: 5.0),
                    child: Text(controller.message.text),
                  ),
                ],
              ),
            ),
            Container(
              child: Icon(
                  controller.message.status == MessageOutcomingStatus.SENT
                      ? Icons.done
                      : Icons.access_time),
            ),
          ],
        ),
      ),
    );
  }
}
