import 'dart:async';

import 'package:flutter/material.dart';

import 'bandwidth_buffer.dart';
import 'chat_message.dart';
import 'chat_message_incoming.dart';
import 'chat_message_outgoing.dart';
import 'chat_service.dart';

/// Host screen widget - main window
class ChatScreen extends StatefulWidget {
  ChatScreen() : super(key: new ObjectKey("Main window"));

  @override
  State createState() => ChatScreenState();
}

/// State for ChatScreen widget
class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  /// Chat client service
  ChatService _service;

  /// Look at the https://github.com/flutter/flutter/issues/26375
  BandwidthBuffer _bandwidthBuffer;

  /// Stream controller to add messages to the ListView
  final StreamController _streamController = StreamController<List<Message>>();

  /// Chat messages list to display into ListView
  final List<ChatMessage> _messages = <ChatMessage>[];

  /// Look at the https://codelabs.developers.google.com/codelabs/flutter/#4
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();

    // initialize bandwidth buffer for chat messages display
    _bandwidthBuffer = BandwidthBuffer<Message>(
      duration: Duration(milliseconds: 500),
      onReceive: onReceivedFromBuffer,
    );
    _bandwidthBuffer.start();

    // initialize Chat client service
    _service = ChatService(
        onSentSuccess: onSentSuccess,
        onSentError: onSentError,
        onReceivedSuccess: onReceivedSuccess,
        onReceivedError: onReceivedError);
    _service.startListening();
  }

  @override
  void dispose() {
    // close Chat client service
    _service.shutdown();

    // close bandwidth buffer
    _bandwidthBuffer.stop();

    // free UI resources
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
            child: StreamBuilder<List<Message>>(
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
                    _addMessages(snapshot.data);
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

  /// Look at the https://codelabs.developers.google.com/codelabs/flutter/#4
  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                maxLines: null,
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

  /// 'new outgoing message created' event
  void _handleSubmitted(String text) {
    _textController.clear();
    _isComposing = false;

    // create new message from input text
    var message = MessageOutgoing(text: text);

    // send message to the display stream through the bandwidth buffer
    _bandwidthBuffer.send(message);

    // async send message to the server
    _service.send(message);
  }

  /// 'outgoing message sent to the server' event
  void onSentSuccess(MessageOutgoing message) {
    debugPrint("message \"${message.text}\" sent to the server");
    // send updated message to the display stream through the bandwidth buffer
    _bandwidthBuffer.send(message);
  }

  /// 'failed to send message' event
  void onSentError(Message message, String error) {
    debugPrint(
        "FAILED to send message \"${message.text}\" to the server: $error");
  }

  /// 'new incoming message received from the server' event
  void onReceivedSuccess(Message message) {
    debugPrint("received message from the server: ${message.text}");
    // send updated message to the display stream through the bandwidth buffer
    _bandwidthBuffer.send(message);
  }

  /// 'failed to receive messages' event
  void onReceivedError(String error) {
    debugPrint("FAILED to receive messages from the server: $error");
  }

  /// this event means 'the message (or messages) can be displayed'
  /// Look at the https://github.com/flutter/flutter/issues/26375
  void onReceivedFromBuffer(List<Message> messages) {
    // send message(s) to the ListView stream
    _streamController.add(messages);
  }

  /// this methods is called to display new (outgoing or incoming) message or
  /// update status of existing outgoing message
  void _addMessages(List<Message> messages) {
    messages.forEach((message) {
      // check if message with the same ID is already existed
      var i = _messages.indexWhere((msg) => msg.message.id == message.id);
      if (i != -1) {
        // found
        var chatMessage = _messages[i];
        if (chatMessage is ChatMessageOutgoing) {
          assert(message is MessageOutgoing,
              "message must be MessageOutcome type");
          // update status for outgoing message (from UNKNOWN to SENT)
          chatMessage.controller.setStatus((message as MessageOutgoing).status);
        }
      } else {
        // new message
        ChatMessage chatMessage;
        var animationController = AnimationController(
          duration: Duration(milliseconds: 700),
          vsync: this,
        );
        switch (message.runtimeType) {
          case MessageOutgoing:
            // add new outgoing message
            chatMessage = ChatMessageOutgoing(
              message: message,
              animationController: animationController,
            );
            break;
          default:
            // add new incoming message
            chatMessage = ChatMessageIncoming(
              message: message,
              animationController: animationController,
            );
            break;
        }
        _messages.insert(0, chatMessage);

        // look at the https://codelabs.developers.google.com/codelabs/flutter/#6
        chatMessage.animationController.forward();
      }
    });
  }
}
