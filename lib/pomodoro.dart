import 'dart:async';

import 'package:flutter/material.dart';

enum PomoState{
  Work, Short, Long
}

class Pomodoro {
  int pomoLength = 1000 * 20 * 1; //25 minutes
  int shortLength = 1000 * 60 * 5; //5 minutes
  int longLength = 1000 * 60 * 15; //15 minutes

  PomoState state = PomoState.Work;
  bool isPaused = true;
  int timeStart = 0;
  int shortCount = 0;

  Function alarmCallback;
  Timer timer;

  Pomodoro({Function callback}) {
    alarmCallback = callback;
  }

  void start() async {
    if (!isPaused) {
      return;
    }
    isPaused = false;
    timeStart = DateTime.now().toLocal().millisecondsSinceEpoch;

    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      update();
    });
  }

  void pause() {
    if (isPaused) return;
    if (timer != null) {
      timer.cancel();
    }
    isPaused = true;
  }

  void reset() {
    pause();
    timeStart = 0;
    shortCount = 0;
    state = PomoState.Work;
  }

  void changeCallback({Function callback}) {
    if (!isPaused) {
      throw new Error();
    }
    alarmCallback = callback;
  }

  void update() {
    var diff = DateTime.now().toLocal().millisecondsSinceEpoch - timeStart;
    print("diff: $diff");
    switch (state) {
      case PomoState.Work:
        if (diff >= pomoLength) {
          alarmCallback();
          shortCount++;
          isPaused = true;
          timeStart = 0;
          if (shortCount > 3) {
            shortCount = 0;
            state = PomoState.Long;
          } else {
            state = PomoState.Short;
          }
        }
        break;
      case PomoState.Short:
        if (diff >= shortLength) {
          state = PomoState.Work;
          isPaused = true;
          timeStart = 0;
          alarmCallback();
        }
        break;
      case PomoState.Long:
        if (diff >= longLength) {
          state = PomoState.Work;
          isPaused = true;
          timeStart = 0;
          alarmCallback();
        }
        break;
    }
  }

  String getTimer() {
    if (timeStart <= 0) {
      return "00:00:00";
    }
    var diff = DateTime.now().toLocal().millisecondsSinceEpoch - timeStart;
    var res = 0;
    switch(state) {
      case PomoState.Work:
        res = pomoLength - diff;
        break;
      case PomoState.Short:
        res = shortLength - diff;
        break;
      case PomoState.Long:
        res = longLength - diff;
        break;
    }
    print(res);
    int h = (res / (1000 * 60 * 24)).floor();
    int m = (res / (1000 * 60)).floor() % 60;
    int s = (res / (1000)).floor() % 60;
    return "$h:$m:$s";
  }
}