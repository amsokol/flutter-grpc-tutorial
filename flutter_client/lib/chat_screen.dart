import 'dart:async';

import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

import 'package:grpc/grpc.dart' as $0;
import 'api/v1/chat.pbgrpc.dart' as $1;

import 'chat_message.dart';
import 'chat_outcome_message.dart';
import 'chat_income_message.dart';
import 'chat_service.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen() : super(key: new ObjectKey("Main window"));

  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  static var _uuid = Uuid();

  bool _active;
  $0.ResponseStream<$1.Notification> _serverStream;

  final List<ChatMessage> _messages = <ChatMessage>[];
  final StreamController _streamController = StreamController<ChatMessage>();

  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _active = true;
    _subscribeForMessages();
  }

  Future<void> _subscribeForMessages() async {
    do {
      try {
        // open stream
        _serverStream = ChatService.subscribe();
        debugPrint("succesfully opened stream to the server");

        await for (var notification in _serverStream) {
          debugPrint("message from server: ${notification.message}");
          ChatMessage message = ChatIncomeMessage(
            _uuid.v4(),
            notification.message,
            AnimationController(
              duration: Duration(milliseconds: 700),
              vsync: this,
            ),
          );
          _streamController.add(message);
          debugPrint("_subscribeForMessages: ${message.text}");
        }

        debugPrint("stream is closed");
      } catch (e) {
        debugPrint("failed to get notifications from server: $e");
      }
    } while (_active);
  }

  @override
  void dispose() {
    _active = false;
    if (_serverStream != null) {
      _serverStream.cancel();
      _serverStream = null;
    }
    for (ChatMessage message in _messages)
      message.animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Friendlychat")),
      body: Column(
        children: <Widget>[
          Flexible(
            child: StreamBuilder<ChatMessage>(
              stream: _streamController.stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    break;
                  case ConnectionState.active:
                  case ConnectionState.done:
                    debugPrint("builder: ${snapshot.data.text}");
                    _updateMessages(snapshot.data);
                }
                return ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    reverse: true,
                    itemBuilder: (_, int index) => _messages[index],
                    itemCount: _messages.length);
              },
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                textInputAction: TextInputAction.send,
                controller: _textController,
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                onSubmitted: _isComposing ? _handleSubmitted : null,
                decoration:
                    InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _isComposing
                      ? () => _handleSubmitted(_textController.text)
                      : null),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });

    var uuid = _uuid.v4();
    ChatMessage message = ChatOutcomeMessage(
      uuid,
      text,
      AnimationController(
        duration: Duration(milliseconds: 700),
        vsync: this,
      ),
    );

    _streamController.add(message);

    // async send message to the server
    _sendMessage(text).then((_) {
      ChatMessage message = ChatOutcomeMessage(
        uuid,
        text,
        AnimationController(
          duration: Duration.zero,
          vsync: this,
        ),
        OutcomeMessageStatus.SENT,
      );
      _streamController.add(message);
      debugPrint("_sendMessage: ${message.text}");
    });
  }

  Future<void> _sendMessage(String text) async {
    var sent = false;
    do {
      try {
        await ChatService.send(text);
        sent = true;
        debugPrint("succesfully sent message \"$text\" to the server");
      } catch (e) {
        debugPrint("failed to send message \"$text\" to the server: $e");
      }
    } while (!sent);
  }

  void _updateMessages(ChatMessage message) {
    var i = _messages.indexWhere((msg) => msg.uuid == message.uuid);
    if (i != -1) {
      if (message is ChatOutcomeMessage) {
        if ((_messages[i] as ChatOutcomeMessage).status != message.status) {
          _messages[i].animationController.dispose();
          _messages[i] = message;
          message.animationController.forward();
        }
      }
    } else {
      // add new message to the chat
      _messages.insert(0, message);
      message.animationController.forward();
    }
  }
}
