import 'package:flutter/material.dart';

import 'chat_message.dart';

const String _server = "Server";

class ChatMessageIncome extends StatelessWidget implements ChatMessage {
  final Message message;
  final AnimationController animationController;

  ChatMessageIncome({this.message, this.animationController})
      : super(key: new ObjectKey(message.id));

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
                    child: Text(message.text),
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
