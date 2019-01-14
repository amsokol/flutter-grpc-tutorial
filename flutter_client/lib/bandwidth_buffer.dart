import 'dart:async';

class BandwidthBuffer<T> {
  final Duration duration;
  final void Function(List<T>) onReceive;

  List<T> _list = <T>[];
  Timer _timer;

  BandwidthBuffer({this.duration, this.onReceive});

  void start() {
    _timer = Timer.periodic(duration, _onTimeToSend);
  }

  void stop() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }

  void send(T t) {
    _list.add(t);
  }

  void _onTimeToSend(Timer t) {
    if (_list.length > 0 && onReceive != null) {
      var list = _list;
      _list = <T>[];
      onReceive(list);
    }
  }
}
