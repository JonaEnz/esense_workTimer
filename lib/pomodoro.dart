import 'dart:async';

enum PomoState { Work, Short, Long, LockShort, LockLong }

class Pomodoro {
  int _pomoLength = 1000 * 1 * 25; //25 minutes
  int _shortLength = 1000 * 1 * 5; //5 minutes
  int _longLength = 1000 * 1 * 15; //15 minutes

  int _shortMinMove = 20;
  int _longMinMove = 75;

  PomoState _state = PomoState.Work;
  bool _isPaused = true;
  int _timeStart = 0;
  int _shortCount = 0;
  int _pauseOffset = 0;

  Function _alarmCallback;
  Timer _timer;

  Pomodoro({Function callback}) {
    _alarmCallback = callback;
  }

  void start() {
    if (!canStart()) {
      return;
    }
    _isPaused = false;
    if (_timeStart == 0) {
      _timeStart = DateTime.now().toLocal().millisecondsSinceEpoch;
    }

    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      _update();
    });
  }

  bool canStart() {
    return ((_state != PomoState.LockShort && _state != PomoState.LockLong)) &&
        _isPaused;
  }

  void pause() {
    if (_isPaused) return;
    if (_timer != null) {
      _timer.cancel();
    }
    _isPaused = true;
    _pauseOffset = DateTime.now().toLocal().millisecondsSinceEpoch - _timeStart;
    _timeStart = 0;
  }

  void reset() {
    pause();
    _timeStart = 0;
    _shortCount = 0;
    _state = PomoState.Work;
  }

  bool unlock(int moveUnits) {
    switch (_state) {
      case PomoState.LockShort:
        if (moveUnits >= _shortMinMove) {
          _state = (_timeStart == 0) ? PomoState.Work : PomoState.Short;
          return true;
        } else
          return false;
        break;
      case PomoState.LockLong:
        if (moveUnits >= _longMinMove) {
          _state = (_timeStart == 0) ? PomoState.Work : PomoState.Long;
          return true;
        } else
          return false;
        break;
      default:
        return false;
    }
  }

  void changeCallback({Function callback}) {
    if (!_isPaused) {
      throw new Error();
    }
    _alarmCallback = callback;
  }

  void _update() {
    if (_isPaused) return;
    var diff = DateTime.now().toLocal().millisecondsSinceEpoch -
        _timeStart +
        _pauseOffset;
    switch (_state) {
      case PomoState.Work:
        if (diff >= _pomoLength) {
          print("work");
          _alarmCallback();
          _shortCount++;
          _isPaused = true;
          _timeStart = 0;
          if (_shortCount >= 3) {
            _shortCount = 0;
            _state = PomoState.Long;
            start();
            _state = PomoState.LockLong;
          } else {
            _state = PomoState.Short;
            start();
            _state = PomoState.LockShort;
          }
        }
        break;
      case PomoState.Short:
      case PomoState.LockShort:
        if (diff >= _shortLength) {
          if (_state == PomoState.Short) {
            _state = PomoState.Work;
          }
          _isPaused = true;
          _timeStart = 0;
          print("short");
          _alarmCallback();
        }
        break;
      case PomoState.Long:
      case PomoState.LockLong:
        if (diff >= _longLength) {
          if (_state == PomoState.Long) {
            _state = PomoState.Work;
          }
          _isPaused = true;
          _timeStart = 0;
          print("long");
          _alarmCallback();
        }
        break;
      default:
        break;
    }
  }

  bool isPaused() {
    return _isPaused;
  }

  int getMoveGoal() {
    switch (_state) {
      case PomoState.LockShort:
        return _shortMinMove;
      case PomoState.LockLong:
        return _longMinMove;
      default:
        return -1;
    }
  }

  PomoState getState() {
    return _state;
  }

  String getTimer() {
    if (_timeStart <= 0) {
      return "0:00:00";
    }
    var diff = DateTime.now().toLocal().millisecondsSinceEpoch -
        _timeStart +
        _pauseOffset;
    var res = 0;
    switch (_state) {
      case PomoState.Work:
        res = _pomoLength - diff;
        break;
      case PomoState.Short:
      case PomoState.LockShort:
        res = _shortLength - diff;
        break;
      case PomoState.Long:
      case PomoState.LockLong:
        res = _longLength - diff;
        break;
      default:
        return "Error...";
    }
    //print(res);
    int h = (res / (1000 * 60 * 24)).floor();
    int m = (res / (1000 * 60)).floor() % 60;
    int s = (res / (1000)).floor() % 60;
    return "$h:${(m > 9) ? "" : "0"}$m:${(s > 9) ? "" : "0"}$s";
  }

  int getWorkUnilLB() {
    return 3 - _shortCount;
  }
}
