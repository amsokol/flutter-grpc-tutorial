import 'package:grpc/grpc.dart';

import 'api/v1/google/protobuf/empty.pb.dart' as $1;
import 'api/v1/google/protobuf/wrappers.pb.dart' as $0;

import 'api/v1/chat.pbgrpc.dart';

class ChatService {
  static var clientSend =
      ClientChannel("172.16.1.18", // Your IP here, localhost might not work.
          port: 3000,
          options: ChannelOptions(
            //TODO: Change to secure with server certificates
            credentials: ChannelCredentials.insecure(),
            idleTimeout: Duration(seconds: 10),
          ));

  static var clientReceive;

  static ResponseFuture<$1.Empty> send(String text) {
    var request = $0.StringValue.create();
    request.value = text;

    var client = ChatServiceClient(clientSend);
    return client.send(request);
  }

  static ResponseStream<Notification> subscribe() {
    if (clientReceive != null) {
      try {
        clientReceive.shutdown();
      } catch (e) {} finally {
        clientReceive = null;
      }
    }
    clientReceive =
        ClientChannel("172.16.1.18", // Your IP here, localhost might not work.
            port: 3000,
            options: ChannelOptions(
              //TODO: Change to secure with server certificates
              credentials: ChannelCredentials.insecure(),
              idleTimeout: Duration(seconds: 10),
            ));

    var client = ChatServiceClient(clientReceive);
    return client.subscribe($1.Empty.create());
  }
}
