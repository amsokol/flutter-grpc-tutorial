import 'package:flutter/material.dart';

import 'package:flutter_client/api/chat_service.dart';

import 'package:flutter_client/blocs/application_bloc.dart';
import 'package:flutter_client/blocs/bloc_provider.dart';
import 'package:flutter_client/blocs/message_events.dart';

import 'package:flutter_client/pages/home.dart';

import 'theme.dart';

/// main is entry point of Flutter application
void main() {
  return runApp(BlocProvider<ApplicationBloc>(
    bloc: ApplicationBloc(),
    child: App(),
  ));
}

// Stateful application widget
class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppState();
}

// State for application widget
class _AppState extends State<App> {
  // BLoc for application
  ApplicationBloc _appBloc;

  /// Chat client service
  ChatService _service;

  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // As the context of not yet available at initState() level,
    // if not yet initialized, we get application BLoc to start
    // gRPC isolates
    if (_isInit == false) {
      _appBloc = BlocProvider.of<ApplicationBloc>(context);

      // initialize Chat client service
      _service = ChatService(
          onMessageSent: _onMessageSent,
          onMessageSendFailed: _onMessageSendFailed,
          onMessageReceived: _onMessageReceived,
          onMessageReceiveFailed: _onMessageReceiveFailed);
      _service.start();

      _listenMessagesToSend();

      if (mounted) {
        setState(() {
          _isInit = true;
        });
      }
    }
  }

  void _listenMessagesToSend() async {
    await for (var event in _appBloc.outMessageSend) {
      _service.send(event.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Friendlychat',
      theme: isIOS(context) ? kIOSTheme : kDefaultTheme,
      home: HomePage(),
    );
  }

  @override
  void dispose() {
    // close Chat client service
    _service.shutdown();
    _service = null;

    super.dispose();
  }

  /// 'outgoing message sent to the server' event
  void _onMessageSent(MessageSentEvent event) {
    debugPrint('Message "${event.id}" sent to the server');
    _appBloc.inMessageSent.add(event);
  }

  /// 'failed to send message' event
  void _onMessageSendFailed(MessageSendFailedEvent event) {
    debugPrint(
        'Failed to send message "${event.id}" to the server: ${event.error}');
    _appBloc.inMessageSendFailed.add(event);
  }

  /// 'new incoming message received from the server' event
  void _onMessageReceived(MessageReceivedEvent event) {
    debugPrint('Message received from the server: ${event.text}');
    _appBloc.inMessageReceived.add(event);
  }

  /// 'failed to receive messages' event
  void _onMessageReceiveFailed(MessageReceiveFailedEvent event) {
    debugPrint('Failed to receive messages from the server: ${event.error}');
  }
}
