import 'dart:isolate';
import 'dart:io';
import 'package:grpc/grpc.dart';

import 'package:flutter_client/blocs/message_events.dart';
import 'package:flutter_client/models/message_outgoing.dart';

import 'v1/chat.pbgrpc.dart' as grpc;
import 'v1/google/protobuf/empty.pb.dart';
import 'v1/google/protobuf/wrappers.pb.dart';

/// CHANGE TO IP ADDRESS OF YOUR SERVER IF IT IS NECESSARY
const serverIP = "172.16.1.18";
const serverPort = 3000;

/// ChatService client implementation
class ChatService {
  // _isolateSending is isolate to send chat messages
  Isolate _isolateSending;

  // Port to send message
  SendPort _portSending;

  // Port to get status of message sending
  ReceivePort _portSendStatus;

  // _isolateReceiving is isolate to receive chat messages
  Isolate _isolateReceiving;

  // Port to receive messages
  ReceivePort _portReceiving;

  /// Event is raised when message has been sent to the server successfully
  final void Function(MessageSentEvent event) onMessageSent;

  /// Event is raised when message sending is failed
  final void Function(MessageSendFailedEvent event) onMessageSendFailed;

  /// Event is raised when message has been received from the server
  final void Function(MessageReceivedEvent event) onMessageReceived;

  /// Event is raised when message receiving is failed
  final void Function(MessageReceiveFailedEvent event) onMessageReceiveFailed;

  /// Constructor
  ChatService(
      {this.onMessageSent,
      this.onMessageSendFailed,
      this.onMessageReceived,
      this.onMessageReceiveFailed})
      : _portSendStatus = ReceivePort(),
        _portReceiving = ReceivePort();

  // Start threads to send and receive messages
  void start() {
    _startSending();
    _startReceiving();
  }

  /// Start thread to send messages
  void _startSending() async {
    // start thread to send messages
    _isolateSending =
        await Isolate.spawn(_sendingIsolate, _portSendStatus.sendPort);

    // listen send status
    await for (var event in _portSendStatus) {
      if (event is SendPort) {
        _portSending = event;
      } else if (event is MessageSentEvent) {
        // call for success handler
        if (onMessageSent != null) {
          onMessageSent(event);
        }
      } else if (event is MessageSendFailedEvent) {
        // call for error handler
        if (onMessageSendFailed != null) {
          onMessageSendFailed(event);
        }
      } else {
        assert(false, 'Unknown event type ${event.runtimeType}');
      }
    }
  }

  /// Thread to send messages
  static void _sendingIsolate(SendPort portSendStatus) async {
    // Port to get messages to send
    ReceivePort portSendMessages = ReceivePort();

    // send port to send messages to the caller
    portSendStatus.send(portSendMessages.sendPort);

    ClientChannel client;

    // waiting messages to send
    await for (MessageOutgoing message in portSendMessages) {
      var sent = false;
      do {
        // create new client
        client ??= ClientChannel(
          serverIP, // Your IP here or localhost
          port: serverPort,
          options: ChannelOptions(
            //TODO: Change to secure with server certificates
            credentials: ChannelCredentials.insecure(),
            idleTimeout: Duration(seconds: 1),
          ),
        );

        try {
          // try to send
          var request = StringValue.create();
          request.value = message.text;
          await grpc.ChatServiceClient(client).send(request);
          // sent successfully
          portSendStatus.send(MessageSentEvent(id: message.id));
          sent = true;
        } catch (e) {
          // sent failed
          portSendStatus.send(
              MessageSendFailedEvent(id: message.id, error: e.toString()));
          // reset client
          client.shutdown();
          client = null;
        }

        if (!sent) {
          // try to send again
          sleep(Duration(seconds: 5));
        }
      } while (!sent);
    }
  }

  /// Start listening messages from the server
  void _startReceiving() async {
    // start thread to receive messages
    _isolateReceiving =
        await Isolate.spawn(_receivingIsolate, _portReceiving.sendPort);

    // listen for incoming messages
    await for (var event in _portReceiving) {
      if (event is MessageReceivedEvent) {
        if (onMessageReceived != null) {
          onMessageReceived(event);
        }
      } else if (event is MessageReceiveFailedEvent) {
        if (onMessageReceiveFailed != null) {
          onMessageReceiveFailed(event);
        }
      }
    }
  }

  /// Thread to listen messages from the server
  static void _receivingIsolate(SendPort portReceive) async {
    ClientChannel client;

    do {
      // create new client
      client ??= ClientChannel(
        serverIP, // Your IP here or localhost
        port: serverPort,
        options: ChannelOptions(
          //TODO: Change to secure with server certificates
          credentials: ChannelCredentials.insecure(),
          idleTimeout: Duration(seconds: 1),
        ),
      );

      var stream = grpc.ChatServiceClient(client).subscribe(Empty.create());

      try {
        await for (var message in stream) {
          portReceive.send(MessageReceivedEvent(text: message.text));
        }
      } catch (e) {
        // notify caller
        portReceive.send(MessageReceiveFailedEvent(error: e.toString()));
        // reset client
        client.shutdown();
        client = null;
      }
      // try to connect again
      sleep(Duration(seconds: 5));
    } while (true);
  }

  // Shutdown client
  void shutdown() {
    // stop sending
    _isolateSending?.kill(priority: Isolate.immediate);
    _isolateSending = null;
    _portSendStatus?.close();
    _portSendStatus = null;

    // stop receiving
    _isolateReceiving?.kill(priority: Isolate.immediate);
    _isolateReceiving = null;
    _portReceiving?.close();
    _portReceiving = null;
  }

  /// Send message to the server
  void send(MessageOutgoing message) {
    assert(_portSending != null, "Port to send message can't be null");
    _portSending.send(message);
  }
}
