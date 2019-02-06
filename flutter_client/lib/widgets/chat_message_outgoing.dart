import 'package:flutter/material.dart';

import 'package:shimmer/shimmer.dart';

import 'package:flutter_client/models/message_outgoing.dart';
import 'package:flutter_client/theme.dart';

import 'chat_message.dart';

/// Outgoing message author name
const String _name = "Me";

/// ChatMessageOutgoing is widget to display outgoing to server message
class ChatMessageOutgoing extends StatelessWidget implements ChatMessage {
  /// Incoming message content
  final MessageOutgoing message;

  /// Controller of animation for message widget
  final AnimationController animationController;

  /// Constructor
  ChatMessageOutgoing({this.message, this.animationController})
      : super(key: Key(message.id));

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
              child: _getMessageContent(context),
            ),
            Container(
              child: Icon(message.status == MessageOutgoingStatus.SENT
                  ? Icons.done
                  : Icons.access_time),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getMessageContent(BuildContext context) {
    var content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(_name, style: Theme.of(context).textTheme.subhead),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(message.text),
        ),
      ],
    );
    if (message.status != MessageOutgoingStatus.SENT) {
      return Shimmer.fromColors(
        baseColor: shimmerBaseColor,
        highlightColor: shimmerHighlightColor,
        child: content,
      );
    }
    return content;
  }
}
