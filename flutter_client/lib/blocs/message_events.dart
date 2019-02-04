import 'package:meta/meta.dart';

import 'package:flutter_client/models/message_outgoing.dart';

/// New message created event
class MessageNewCreatedEvent {
  final MessageOutgoing message;

  MessageNewCreatedEvent({@required this.message});
}

/// Message sent to the server event
class MessageSentEvent {
  final String id;

  MessageSentEvent({@required this.id});
}

/// Message failed to send to the server event
class MessageSendFailedEvent {
  final String id;
  final String error;

  MessageSendFailedEvent({@required this.id, @required this.error});
}

/// Message received from the server event
class MessageReceivedEvent {
  final String text;

  MessageReceivedEvent({@required this.text});
}

/// Message failed to receive from the server event
class MessageReceiveFailedEvent {
  final String error;

  MessageReceiveFailedEvent({@required this.error});
}
