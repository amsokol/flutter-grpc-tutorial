import 'dart:isolate';
import 'dart:io';
import 'package:grpc/grpc.dart';

import 'api/v1/chat.pbgrpc.dart' as grpc;
import 'api/v1/google/protobuf/empty.pb.dart';
import 'api/v1/google/protobuf/wrappers.pb.dart';
import 'chat_message.dart';
import 'chat_message_outgoing.dart';

/// CHANGE TO IP ADDRESS OF YOUR SERVER IF IT IS NECESSARY
const serverIP = "10.0.2.2";
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
  final void Function(MessageOutgoing message) onSentSuccess;

  /// Event is raised when message sending is failed
  final void Function(MessageOutgoing message, String error) onSentError;

  /// Event is raised when message has been received from the server
  final void Function(Message message) onReceivedSuccess;

  /// Event is raised when message receiving is failed
  final void Function(String error) onReceivedError;

  /// Constructor
  ChatService(
      {this.onSentSuccess,
      this.onSentError,
      this.onReceivedSuccess,
      this.onReceivedError})
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
    await for (var msg in _portSendStatus) {
      if (msg is SendPort) {
        _portSending = msg;
      } else {
        var message = msg[0] as MessageOutgoing;
        var statusDetails = msg[1] as String;
        switch (message.status) {
          case MessageOutgoingStatus.SENT:
            // call for success handler
            if (onSentSuccess != null) {
              onSentSuccess(message);
            }
            break;
          case MessageOutgoingStatus.FAILED:
            // call for error handler
            if (onSentError != null) {
              onSentError(message, statusDetails);
            }
            break;
          default:
            // call for error handler
            if (onSentError != null) {
              onSentError(message, "unexpected message status");
            }
            break;
        }
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
        if (client == null) {
          // create new client
          client = ClientChannel(
            serverIP, // Your IP here or localhost
            port: serverPort,
            options: ChannelOptions(
              //TODO: Change to secure with server certificates
              credentials: ChannelCredentials.insecure(),
              idleTimeout: Duration(seconds: 1),
            ),
          );
        }

        MessageOutgoingStatus statusCode;
        String statusDetails;

        try {
          // try to send
          var request = StringValue.create();
          request.value = message.text;
          await grpc.ChatServiceClient(client).send(request);
          // sent successfully
          statusCode = MessageOutgoingStatus.SENT;
          sent = true;
        } catch (e) {
          // sent failed
          statusCode = MessageOutgoingStatus.FAILED;
          statusDetails = e.toString();
          // reset client
          client.shutdown();
          client = null;
        } finally {
          var msg = MessageOutgoing(
              text: message.text, id: message.id, status: statusCode);
          portSendStatus.send([
            msg,
            statusDetails,
          ]);
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
    await for (var msg in _portReceiving) {
      var message = msg[0] as Message;
      var error = msg[1] as String;
      if (error != null) {
        // call for error handler
        if (onReceivedError != null) {
          onReceivedError(error);
        }
      } else {
        if (onReceivedSuccess != null) {
          onReceivedSuccess(message);
        }
      }
    }
  }

  /// Thread to listen messages from the server
  static void _receivingIsolate(SendPort portReceive) async {
    ClientChannel client;

    do {
      if (client == null) {
        // create new client
        client = ClientChannel(
          serverIP, // Your IP here or localhost
          port: serverPort,
          options: ChannelOptions(
            //TODO: Change to secure with server certificates
            credentials: ChannelCredentials.insecure(),
            idleTimeout: Duration(seconds: 1),
          ),
        );
      }

      var stream = grpc.ChatServiceClient(client).subscribe(Empty.create());

      try {
        await for (var msg in stream) {
          var message = Message(msg.text);
          portReceive.send([message, null]);
        }
      } catch (e) {
        // reset client
        client.shutdown();
        client = null;
        // notify caller
        portReceive.send([null, e.toString()]);
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
    _portSending.send(message);
  }
}
