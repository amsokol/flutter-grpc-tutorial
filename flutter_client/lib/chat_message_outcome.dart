import 'package:flutter/material.dart';

import 'chat_message.dart';

const String _name = "Me";

enum MessageOutcomeStatus { UNKNOWN, SENT }

class MessageOutcome extends Message {
  MessageOutcomeStatus status;

  MessageOutcome({String text, String id, this.status}) : super(text, id) {
    if (status == null) {
      this.status = MessageOutcomeStatus.UNKNOWN;
    }
  }
}

class ChatMessageOutcomeController {
  MessageOutcome message;

  void Function(MessageOutcomeStatus oldStatus, MessageOutcomeStatus newStatus)
      onStatusChanged;

  ChatMessageOutcomeController({this.message});

  void setStatus(MessageOutcomeStatus newStatus) {
    var oldStatus = message.status;
    if (oldStatus != newStatus) {
      message.status = newStatus;
      if (onStatusChanged != null) {
        onStatusChanged(oldStatus, newStatus);
      }
    }
  }
}

class ChatMessageOutcome extends StatefulWidget implements ChatMessage {
  final MessageOutcome message;
  final ChatMessageOutcomeController controller;
  final AnimationController animationController;

  ChatMessageOutcome({this.message, this.animationController})
      : controller = ChatMessageOutcomeController(message: message),
        super(key: new ObjectKey(message.id));

  @override
  State createState() => ChatMessageOutcomeState(
      animationController: animationController, controller: controller);
}

class ChatMessageOutcomeState extends State<ChatMessageOutcome> {
  final ChatMessageOutcomeController controller;
  final AnimationController animationController;

  ChatMessageOutcomeState({this.controller, this.animationController}) {
    controller.onStatusChanged = onStatusChanged;
  }

  void onStatusChanged(
      MessageOutcomeStatus oldStatus, MessageOutcomeStatus newStatus) {
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
              child: Icon(controller.message.status == MessageOutcomeStatus.SENT
                  ? Icons.done
                  : Icons.access_time),
            ),
          ],
        ),
      ),
    );
  }
}
