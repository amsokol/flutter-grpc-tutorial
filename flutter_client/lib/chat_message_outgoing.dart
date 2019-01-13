import 'package:flutter/material.dart';

import 'chat_message.dart';

/// Outgoing message author name
const String _name = "Me";

/// Outgoing message statuses
/// UNKNOWN - message just created and is not sent yet
/// SENT - message is sent to the server successfully
enum MessageOutgoingStatus { UNKNOWN, SENT }

/// MessageOutgoing is class defining message data (id and text) and status
class MessageOutgoing extends Message {
  /// Outgoing message status
  MessageOutgoingStatus status;

  /// Constructor
  MessageOutgoing(
      {String text, String id, this.status = MessageOutgoingStatus.UNKNOWN})
      : super(text, id);
}

/// ChatMessageOutgoingController is 'Controller' class that allows change message properties
class ChatMessageOutgoingController {
  /// Outgoing message content
  MessageOutgoing message;

  /// Controller raises this event when status has been changed
  void Function(
          MessageOutgoingStatus oldStatus, MessageOutgoingStatus newStatus)
      onStatusChanged;

  /// Constructor
  ChatMessageOutgoingController({this.message});

  /// setStatus is method to update status of the outgoing message
  /// It raises onStatusChanged event
  void setStatus(MessageOutgoingStatus newStatus) {
    var oldStatus = message.status;
    if (oldStatus != newStatus) {
      message.status = newStatus;
      if (onStatusChanged != null) {
        onStatusChanged(oldStatus, newStatus);
      }
    }
  }
}

/// ChatMessageOutgoing is widget to display outgoing to server message
class ChatMessageOutgoing extends StatefulWidget implements ChatMessage {
  /// Outgoing message content
  final MessageOutgoing message;

  /// Message state controller
  final ChatMessageOutgoingController controller;

  /// Controller of animation for message widget
  final AnimationController animationController;

  /// Constructor
  ChatMessageOutgoing({this.message, this.animationController})
      : controller = ChatMessageOutgoingController(message: message),
        super(key: new ObjectKey(message.id));

  @override
  State createState() => ChatMessageOutgoingState(
      animationController: animationController, controller: controller);
}

/// State for ChatMessageOutgoing widget
class ChatMessageOutgoingState extends State<ChatMessageOutgoing> {
  /// Message state controller
  final ChatMessageOutgoingController controller;

  /// Controller of animation for message widget
  final AnimationController animationController;

  /// Constructor
  ChatMessageOutgoingState({this.controller, this.animationController}) {
    // Subscribe to event "message status has been changed"
    controller.onStatusChanged = onStatusChanged;
  }

  /// Subscription to event "message status has been changed"
  void onStatusChanged(
      MessageOutgoingStatus oldStatus, MessageOutgoingStatus newStatus) {
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
                  controller.message.status == MessageOutgoingStatus.SENT
                      ? Icons.done
                      : Icons.access_time),
            ),
          ],
        ),
      ),
    );
  }
}
