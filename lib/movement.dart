class Movement {
  static const int MOVEMENT_MIN = 10000;

  List<int> _diff = [0, 0, 0];
  List<int> _last = [0, 0, 0];
  List<int> _calib = [0, 0, 0];

  List<bool> _history = new List.filled(100, false);
  int _historyPos = 0;

  void update(List<int> accel) {
    if (accel.length < _calib.length) {
      throw new Error();
    }
    for (int i = 0; i < _calib.length; i++) {
      _diff[i] = accel[i] - _last[i] - _calib[i];
    }
    _last = accel;

    _history[_historyPos] = isMoving();
    //print("diff:  ${_diff.reduce((a, b) => a.abs() + b.abs())}");
    _historyPos = (_historyPos + 1) % 100;
  }

  bool isMoving() {
    return _diff.reduce((a, b) => a.abs() + b.abs()) > MOVEMENT_MIN;
  }

  int movementPercent() {
    return _history.map((e) => e ? 1 : 0).reduce((a, b) => a + b);
  }
}
