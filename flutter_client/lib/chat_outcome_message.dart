import 'package:flutter/material.dart';

import 'chat_message.dart';

const String _name = "Me";

enum OutcomeMessageStatus { UNKNOWN, SENT }

class ChatOutcomeMessage extends ChatMessage {
  final OutcomeMessageStatus status;

  ChatOutcomeMessage(
      String uuid, String text, AnimationController animationController,
      [OutcomeMessageStatus status = OutcomeMessageStatus.UNKNOWN])
      : status = status,
        super(uuid: uuid, text: text, animationController: animationController);

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
              child: Icon(status == OutcomeMessageStatus.SENT
                  ? Icons.done
                  : Icons.access_time),
            ),
          ],
        ),
      ),
    );
  }
}
