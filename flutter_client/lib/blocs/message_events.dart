import 'package:meta/meta.dart';

import 'package:flutter_client/models/message_outgoing.dart';

class MessageNewCreatedEvent {
  final MessageOutgoing message;

  MessageNewCreatedEvent({@required this.message});
}

class MessageSentEvent {
  final String id;

  MessageSentEvent({@required this.id});
}

class MessageSendFailedEvent {
  final String id;
  final String error;

  MessageSendFailedEvent({@required this.id, @required this.error});
}

class MessageReceivedEvent {
  final String text;

  MessageReceivedEvent({@required this.text});
}

class MessageReceiveFailedEvent {
  final String error;

  MessageReceiveFailedEvent({@required this.error});
}
