import 'package:flutter/material.dart';

import 'chat_message.dart';

const String _server = "Server";

class ChatIncomeMessage extends ChatMessage {
  ChatIncomeMessage(
      String uuid, String text, AnimationController animationController)
      : super(uuid: uuid, text: text, animationController: animationController);

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(_server, style: Theme.of(context).textTheme.subhead),
                  Container(
                    margin: EdgeInsets.only(top: 5.0),
                    child: Text(text),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 16.0),
              child: CircleAvatar(
                  backgroundColor: Colors.pink.shade600,
                  child: Text(_server[0])),
            ),
          ],
        ),
      ),
    );
  }
}
