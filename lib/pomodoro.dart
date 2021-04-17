import 'dart:async';

import 'package:flutter/material.dart';

enum PomoState{
  Work, Short, Long
}

class Pomodoro {
  int _pomoLength = 1000 * 20 * 1; //25 minutes
  int _shortLength = 1000 * 60 * 5; //5 minutes
  int _longLength = 1000 * 60 * 15; //15 minutes

  PomoState _state = PomoState.Work;
  bool _isPaused = true;
  int _timeStart = 0;
  int _shortCount = 0;

  Function _alarmCallback;
  Timer _timer;

  Pomodoro({Function callback}) {
    _alarmCallback = callback;
  }

  void start() async {
    if (!_isPaused) {
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

  void pause() {
    if (_isPaused) return;
    if (_timer != null) {
      _timer.cancel();
    }
    _isPaused = true;
  }

  void reset() {
    pause();
    _timeStart = 0;
    _shortCount = 0;
    _state = PomoState.Work;
  }

  void changeCallback({Function callback}) {
    if (!_isPaused) {
      throw new Error();
    }
    _alarmCallback = callback;
  }

  void _update() {
    var diff = DateTime.now().toLocal().millisecondsSinceEpoch - _timeStart;
    //print("diff: $diff");
    switch (_state) {
      case PomoState.Work:
        if (diff >= _pomoLength) {
          _alarmCallback();
          _shortCount++;
          _isPaused = true;
          _timeStart = 0;
          if (_shortCount > 3) {
            _shortCount = 0;
            _state = PomoState.Long;
          } else {
            _state = PomoState.Short;
          }
        }
        break;
      case PomoState.Short:
        if (diff >= _shortLength) {
          _state = PomoState.Work;
          _isPaused = true;
          _timeStart = 0;
          _alarmCallback();
        }
        break;
      case PomoState.Long:
        if (diff >= _longLength) {
          _state = PomoState.Work;
          _isPaused = true;
          _timeStart = 0;
          _alarmCallback();
        }
        break;
    }
  }

  bool isPaused() {
    return _isPaused;
  }

  PomoState getState() {
    return _state;
  }

  String getTimer() {
    if (_timeStart <= 0) {
      return "00:00:00";
    }
    var diff = DateTime.now().toLocal().millisecondsSinceEpoch - _timeStart;
    var res = 0;
    switch(_state) {
      case PomoState.Work:
        res = _pomoLength - diff;
        break;
      case PomoState.Short:
        res = _shortLength - diff;
        break;
      case PomoState.Long:
        res = _longLength - diff;
        break;
    }
    print(res);
    int h = (res / (1000 * 60 * 24)).floor();
    int m = (res / (1000 * 60)).floor() % 60;
    int s = (res / (1000)).floor() % 60;
    return "$h:${(m > 9) ? "" : "0"}$m:${(s > 9) ? "" : "0"}$s";
  }
}