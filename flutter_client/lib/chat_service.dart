import 'package:grpc/grpc.dart';

import 'api/v1/chat.pbgrpc.dart' as grpc;
import 'api/v1/google/protobuf/empty.pb.dart';
import 'api/v1/google/protobuf/wrappers.pb.dart';
import 'chat_message.dart';
import 'chat_message_outgoing.dart';

/// CHANGE TO IP ADDRESS OF YOUR SERVER IF IT IS NECESSARY
const serverIP = "127.0.0.1";
const serverPort = 3000;

/// ChatService client implementation
class ChatService {
  /// Flag is indicating that client is shutting down
  bool _isShutdown = false;

  /// gRPC client channel to send messages to the server
  ClientChannel _clientSend;

  /// gRPC client channel to receive messages from the server
  ClientChannel _clientReceive;

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
      this.onReceivedError});

  // Shutdown client
  Future<void> shutdown() async {
    _isShutdown = true;
    _shutdownSend();
    _shutdownReceive();
  }

  // Shutdown client (send channel)
  void _shutdownSend() {
    if (_clientSend != null) {
      _clientSend.shutdown();
      _clientSend = null;
    }
  }

  // Shutdown client (receive channel)
  void _shutdownReceive() {
    if (_clientReceive != null) {
      _clientReceive.shutdown();
      _clientReceive = null;
    }
  }

  /// Send message to the server
  void send(MessageOutgoing message) {
    if (_clientSend == null) {
      // create new client
      _clientSend = ClientChannel(
        serverIP, // Your IP here or localhost
        port: serverPort,
        options: ChannelOptions(
          //TODO: Change to secure with server certificates
          credentials: ChannelCredentials.insecure(),
          idleTimeout: Duration(seconds: 10),
        ),
      );
    }

    var request = StringValue.create();
    request.value = message.text;

    grpc.ChatServiceClient(_clientSend).send(request).then((_) {
      // call for success handler
      if (onSentSuccess != null) {
        var sentMessage = MessageOutgoing(
            text: message.text,
            id: message.id,
            status: MessageOutgoingStatus.SENT);
        onSentSuccess(sentMessage);
      }
    }).catchError((e) {
      if (!_isShutdown) {
        // invalidate current client
        _shutdownSend();

        // call for error handler
        if (onSentError != null) {
          onSentError(message, e.toString());
        }

        // try to send again
        Future.delayed(Duration(seconds: 30), () {
          send(message);
        });
      }
    });
  }

  /// Start listening messages from the server
  void startListening() {
    if (_clientReceive == null) {
      // create new client
      _clientReceive = ClientChannel(
        serverIP, // Your IP here or localhost
        port: serverPort,
        options: ChannelOptions(
          //TODO: Change to secure with server certificates
          credentials: ChannelCredentials.insecure(),
          idleTimeout: Duration(seconds: 10),
        ),
      );
    }

    var stream =
        grpc.ChatServiceClient(_clientReceive).subscribe(Empty.create());

    stream.forEach((msg) {
      if (onReceivedSuccess != null) {
        var message = Message(msg.text);
        onReceivedSuccess(message);
      }
    }).then((_) {
      // raise exception to start listening again
      throw Exception("stream from the server has been closed");
    }).catchError((e) {
      if (!_isShutdown) {
        // invalidate current client
        _shutdownReceive();

        // call for error handler
        if (onReceivedError != null) {
          onReceivedError(e.toString());
        }

        // start listening again
        Future.delayed(Duration(seconds: 30), () {
          startListening();
        });
      }
    });
  }
}
