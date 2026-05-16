import 'dart:async';

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
  }
}

class Throttle {
  final Duration interval;
  Timer? _timer;
  bool _hasPending = false;
  VoidCallback? _pendingAction;

  Throttle({this.interval = const Duration(milliseconds: 300)});

  void run(VoidCallback action) {
    if (_timer == null || !_timer!.isActive) {
      action();
      _timer = Timer(interval, () {
        if (_hasPending) {
          _pendingAction?.call();
          _hasPending = false;
          _pendingAction = null;
        }
      });
    } else {
      _hasPending = true;
      _pendingAction = action;
    }
  }

  void cancel() {
    _timer?.cancel();
    _hasPending = false;
    _pendingAction = null;
  }
}
