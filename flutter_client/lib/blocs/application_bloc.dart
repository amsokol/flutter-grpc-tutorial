import 'dart:collection';

import 'package:rxdart/rxdart.dart';

import 'package:flutter_client/models/message.dart';
import 'package:flutter_client/models/message_incoming.dart';
import 'package:flutter_client/models/message_outgoing.dart';

import 'bloc_provider.dart';
import 'message_events.dart';

class ApplicationBloc implements BlocBase {
  final _messages = Set<Message>();

  final _messageCreatedController =
      new BehaviorSubject<MessageNewCreatedEvent>();
  Sink<MessageNewCreatedEvent> get inNewMessageCreated =>
      _messageCreatedController.sink;

  final _messageSendController = new BehaviorSubject<MessageNewCreatedEvent>();
  Sink<MessageNewCreatedEvent> get inMessageSend => _messageSendController.sink;
  Stream<MessageNewCreatedEvent> get outMessageSend =>
      _messageSendController.stream;

  final _messageSentController = new BehaviorSubject<MessageSentEvent>();
  Sink<MessageSentEvent> get inMessageSent => _messageSentController.sink;

  final _messageSendFailedController =
      new BehaviorSubject<MessageSendFailedEvent>();
  Sink<MessageSendFailedEvent> get inMessageSendFailed =>
      _messageSendFailedController.sink;

  final _messageReceivedController =
      new BehaviorSubject<MessageReceivedEvent>();
  Sink<MessageReceivedEvent> get inMessageReceived =>
      _messageReceivedController.sink;

  final _messagesController = new BehaviorSubject<List<Message>>(seedValue: []);
  Sink<List<Message>> get _inMessages => _messagesController.sink;
  Stream<List<Message>> get outMessages => _messagesController.stream;

  ApplicationBloc() {
    _messageCreatedController.listen(_onNewMessageCreated);
    _messageSentController.listen(_onMessageSent);
    _messageSendFailedController.listen(_onMessageSendFailed);
    _messageReceivedController.listen(_onMessageReceived);
  }

  void dispose() {
    _messageCreatedController.close();
    _messageSendController.close();
    _messageSentController.close();
    _messageSendFailedController.close();
    _messageReceivedController.close();
    _messagesController.close();
  }

  void _onNewMessageCreated(MessageNewCreatedEvent event) {
    _messages.add(event.message);
    _notify();
    _messageSendController.add(event);
  }

  void _onMessageSent(MessageSentEvent event) {
    _findOutgoingMessage(event.id).status = MessageOutgoingStatus.SENT;
    _notify();
  }

  void _onMessageSendFailed(MessageSendFailedEvent event) {
    _findOutgoingMessage(event.id).status = MessageOutgoingStatus.FAILED;
    _notify();
  }

  void _onMessageReceived(MessageReceivedEvent event) {
    _messages.add(MessageIncoming(text: event.text));
    _notify();
  }

  void _notify() {
    _inMessages.add(UnmodifiableListView(_messages));
  }

  MessageOutgoing _findOutgoingMessage(String id) {
    var message =
        _messages.firstWhere((message) => message.id == id, orElse: () => null);
    assert(message != null, 'Sent message with id="$id" is not found in state');
    assert(message is MessageOutgoing,
        'Invalid message (id="$id") type ${message.runtimeType}; must be MessageOutgoing');
    return message;
  }
}
