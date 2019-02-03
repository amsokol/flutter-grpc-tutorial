import 'package:meta/meta.dart';

import 'message.dart';

/// MessageIncoming is class defining incoming message data (id and text)
class MessageIncoming extends Message {
  /// Constructor
  MessageIncoming({String id, @required String text})
      : super(id: id, text: text);

  MessageIncoming.copy(MessageIncoming original)
      : super(id: original.id, text: original.text);
}
