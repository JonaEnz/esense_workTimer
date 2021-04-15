import 'dart:async';

import 'package:flutter/material.dart';

enum State{
  Work, Short, Long
}

class Pomodoro {
  int pomoLength = 1000 * 60 * 25; //25 minutes
  int shortLength = 1000 * 60 * 5; //5 minutes
  int longLength = 1000 * 60 * 15; //15 minutes

  State state = State.Work;
  bool isPaused = true;
  int timeStart = 0;
  int shortCount = 0;

  Function alarmCallback;
  Timer timer;

  Pomodoro(Function callback) {
    alarmCallback = callback;
  }

  void start() async {
    if (!isPaused) {
      return;
    }
    isPaused = false;
    timeStart = DateTime.now().toLocal().millisecondsSinceEpoch;

    timer = Timer(Duration(seconds: 1), () async => {
      update()
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
    state = State.Work;
  }

  void changeCallback(Function callback) {
    if (!isPaused) {
      throw new Error();
    }
    alarmCallback = callback;
  }

  void update() {
    var diff = DateTime.now().toLocal().millisecondsSinceEpoch - timeStart;
    switch (state) {
      case State.Work:
        if (diff >= pomoLength) {
          alarmCallback();
          shortCount++;
          isPaused = true;
          timeStart = 0;
          if (shortCount > 3) {
            shortCount = 0;
            state = State.Long;
          } else {
            state = State.Short;
          }
        }
        break;
      case State.Short:
        if (diff >= shortLength) {
          state = State.Work;
          isPaused = true;
          timeStart = 0;
          alarmCallback();
        }
        break;
      case State.Long:
        if (diff >= longLength) {
          state = State.Work;
          isPaused = true;
          timeStart = 0;
          alarmCallback();
        }
        break;
    }
  }
}