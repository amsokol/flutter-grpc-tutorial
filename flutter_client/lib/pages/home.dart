import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_client/blocs/application_bloc.dart';
import 'package:flutter_client/blocs/bloc_provider.dart';
import 'package:flutter_client/blocs/message_events.dart';

import 'package:flutter_client/models/message.dart';
import 'package:flutter_client/models/message_incoming.dart';
import 'package:flutter_client/models/message_outgoing.dart';

import 'package:flutter_client/theme.dart';

import 'package:flutter_client/widgets/chat_message.dart';
import 'package:flutter_client/widgets/chat_message_incoming.dart';
import 'package:flutter_client/widgets/chat_message_outgoing.dart';

/// Host screen widget - main window
class HomePage extends StatefulWidget {
  // Constructor
  HomePage() : super(key: new ObjectKey("Main window"));

  @override
  State createState() => HomePageState();
}

/// State for main window
class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // BLoc for application
  ApplicationBloc _appBloc;

  /// Chat messages list to display into ListView
  final List<ChatMessage> _messages = <ChatMessage>[];

  /// Look at the https://codelabs.developers.google.com/codelabs/flutter/#4
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;

  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // As the context of not yet available at initState() level,
    // if not yet initialized, we get the list of all genres
    // and retrieve the currently selected one, as well as the
    // filter parameters
    if (_isInit == false) {
      _appBloc = BlocProvider.of<ApplicationBloc>(context);
      _isInit = true;
    }
  }

  @override
  void dispose() {
    // free UI resources
    for (ChatMessage message in _messages)
      message.animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friendlychat'),
        elevation: isIOS(context) ? 0.0 : 4.0,
      ),
      body: new Container(
          child: new Column(
            children: <Widget>[
              Flexible(
                child: StreamBuilder(
                  stream: _appBloc.outMessages,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Message>> snapshot) {
                    if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else if (snapshot.hasData) {
                      // update messages according to the data
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
                child: _buildTextComposer(context),
              ),
            ],
          ),
          decoration: isIOS(context)
              ? new BoxDecoration(
                  border: new Border(
                    top: new BorderSide(color: Colors.grey[200]),
                  ),
                )
              : null),
    );
  }

  /// Look at the https://codelabs.developers.google.com/codelabs/flutter/#4
  Widget _buildTextComposer(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: isIOS(context)
                  ? CupertinoTextField(
                      key: Key('message-text-field'),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      controller: _textController,
                      onChanged: (String text) {
                        setState(() {
                          _isComposing = text.length > 0;
                        });
                      },
                      onSubmitted: _isComposing ? _handleSubmitted : null,
                    )
                  : TextField(
                      key: Key('message-text-field'),
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
              child: isIOS(context)
                  ? new CupertinoButton(
                      child: new Text("Send"),
                      onPressed: _isComposing
                          ? () => _handleSubmitted(_textController.text)
                          : null,
                    )
                  : new IconButton(
                      key: Key('send-button'),
                      icon: new Icon(Icons.send),
                      onPressed: _isComposing
                          ? () => _handleSubmitted(_textController.text)
                          : null,
                    ),
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

    _appBloc.inNewMessageCreated
        .add(MessageNewCreatedEvent(message: MessageOutgoing(text: text)));
  }

  /// this methods is called to display new (outgoing or incoming) message or
  /// update status of existing outgoing message
  void _updateMessages(List<Message> messages) {
    for (var message in messages) {
      int i = _messages.indexWhere((msg) => msg.message.id == message.id);
      if (i != -1) {
        // existing message
        if (message is MessageOutgoing) {
          // update existing message
          var chatMessage = _messages[i];
          if (chatMessage is ChatMessageOutgoing) {
            if (chatMessage.message.status != message.status) {
              // dispose previous message
              chatMessage.animationController.dispose();
              // update status for outgoing message
              _messages[i] = ChatMessageOutgoing(
                message: MessageOutgoing.copy(message),
                animationController: AnimationController(
                  duration: Duration.zero,
                  vsync: this,
                ),
              );
            }
            _messages[i].animationController.forward();
          } else {
            assert(false, 'Message must be MessageOutcome type');
          }
        }
      } else {
        ChatMessage chatMessage;
        // new message
        var animationController = AnimationController(
          duration: Duration(milliseconds: 700),
          vsync: this,
        );
        if (message is MessageOutgoing) {
          // add new outgoing message
          chatMessage = ChatMessageOutgoing(
            message: MessageOutgoing.copy(message),
            animationController: animationController,
          );
        } else if (message is MessageIncoming) {
          // add new incoming message
          chatMessage = ChatMessageIncoming(
            message: MessageIncoming.copy(message),
            animationController: animationController,
          );
        } else {
          assert(false, 'Unknown message type ${message.runtimeType}');
        }
        _messages.insert(0, chatMessage);

        // look at the https://codelabs.developers.google.com/codelabs/flutter/#6
        chatMessage.animationController.forward();
      }
    }
  }
}
