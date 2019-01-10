import 'package:flutter/material.dart';

import 'chat_message.dart';

const String _name = "Me";

enum OutcomeMessageStatus { UNKNOWN, SENT }

class ChatOutcomeMessageController {
  OutcomeMessageStatus status = OutcomeMessageStatus.UNKNOWN;

  void Function(OutcomeMessageStatus oldStatus, OutcomeMessageStatus newStatus)
      onStatusChanged;

  void setStatus(OutcomeMessageStatus newStatus) {
    var oldStatus = status;
    status = newStatus;
    if (onStatusChanged != null) {
      onStatusChanged(oldStatus, newStatus);
    }
  }
}

class ChatOutcomeMessage extends StatefulWidget implements ChatMessage {
  final String uuid;
  final String text;
  final AnimationController animationController;
  final ChatOutcomeMessageController controller;

  ChatOutcomeMessage(
      {this.uuid, this.text, this.controller, this.animationController})
      : super(key: new ObjectKey(uuid));

  @override
  State createState() => ChatOutcomeMessageState(
      text: text,
      animationController: animationController,
      controller: controller);
}

class ChatOutcomeMessageState extends State<ChatOutcomeMessage> {
  final String text;
  final AnimationController animationController;
  final ChatOutcomeMessageController controller;

  ChatOutcomeMessageState(
      {this.text, this.animationController, this.controller}) {
    controller.onStatusChanged = onStatusChanged;
  }

  void onStatusChanged(
      OutcomeMessageStatus oldStatus, OutcomeMessageStatus newStatus) {
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
                    child: Text(text),
                  ),
                ],
              ),
            ),
            Container(
              child: Icon(controller.status == OutcomeMessageStatus.SENT
                  ? Icons.done
                  : Icons.access_time),
            ),
          ],
        ),
      ),
    );
  }
}
