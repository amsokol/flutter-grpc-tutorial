import 'package:grpc/grpc.dart';

import 'api/v1/chat.pbgrpc.dart' as grpc;
import 'api/v1/google/protobuf/empty.pb.dart';
import 'api/v1/google/protobuf/wrappers.pb.dart';
import 'chat_message.dart';
import 'chat_message_outcome.dart';

const serverIP = /*"10.80.135.109"*/ "172.16.1.18";
const serverPort = 3000;

class ChatService {
  bool _isShutdown = false;

  ClientChannel _clientSend;
  ClientChannel _clientReceive;

  final void Function(MessageOutcome message) onSentSuccess;
  final void Function(MessageOutcome message, String error) onSentError;

  final void Function(Message message) onReceivedSuccess;
  final void Function(String error) onReceivedError;

  ChatService(
      {this.onSentSuccess,
      this.onSentError,
      this.onReceivedSuccess,
      this.onReceivedError});

  Future<void> shutdown() async {
    _isShutdown = true;
    _shutdownSend();
    _shutdownReceive();
  }

  void _shutdownSend() {
    if (_clientSend != null) {
      _clientSend.shutdown();
      _clientSend = null;
    }
  }

  void _shutdownReceive() {
    if (_clientReceive != null) {
      _clientReceive.shutdown();
      _clientReceive = null;
    }
  }

  void send(MessageOutcome message) {
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
        var sentMessage =
            MessageOutcome(message.text, message.id, MessageOutcomeStatus.SENT);
        onSentSuccess(sentMessage);
      }
    }).catchError((e) {
      if (!_isShutdown) {
        // invalidate current client
        _shutdownSend();

        // call for error handler
        if (onSentError != null) {
          message.status = MessageOutcomeStatus.SENT;
          onSentError(message, e.toString());
        }

        // try to send again
        this.send(message);
      }
    });
  }

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
        this.startListening();
      }
    });
  }
}
