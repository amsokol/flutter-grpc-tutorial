import 'package:grpc/grpc.dart';

import 'api/v1/google/protobuf/empty.pb.dart';
import 'api/v1/google/protobuf/wrappers.pb.dart';

import 'api/v1/chat.pbgrpc.dart';

const serverIP = "10.80.135.109" /*"172.16.1.18"*/;
const serverPort = 3000;

class ChatService {
  bool _isShutdown = false;

  ClientChannel _clientSend;
  ClientChannel _clientReceive;

  final void Function(String uuid, String text) onSentSuccess;
  final void Function(String uuid, String text, String error) onSentError;

  final void Function(String text) onReceivedSuccess;
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

  Future<void> send(String uuid, String text) async {
    do {
      try {
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
        request.value = text;

        await ChatServiceClient(_clientSend).send(request);

        // call for success handler
        if (onSentSuccess != null) {
          onSentSuccess(uuid, text);
        }
        break;
      } catch (e) {
        if (!_isShutdown) {
          // invalidate current client
          _shutdownSend();

          // call for error handler
          if (onSentError != null) {
            onSentError(uuid, text, e.toString());
          }

          // sleep for sometime
          // new Future.delayed(const Duration(seconds: 10));
        }
      }
      // try to send again
    } while (!_isShutdown);
  }

  Future<void> receive() async {
    do {
      try {
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
            ChatServiceClient(_clientReceive).subscribe(Empty.create());

        await for (var notification in stream) {
          if (onReceivedSuccess != null) {
            onReceivedSuccess(notification.message);
          }
        }

        throw Exception("stream from the server has closed");
      } catch (e) {
        if (!_isShutdown) {
          // invalidate current client
          _shutdownReceive();

          // call for error handler
          if (onReceivedError != null) {
            onReceivedError(e.toString());
          }

          // sleep for sometime
          // new Future.delayed(const Duration(seconds: 10));
        }
      }
      // try to receive again
    } while (!_isShutdown);
  }
}
