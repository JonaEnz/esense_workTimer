class Movement {
  static const int MOVEMENT_MIN = 2000;
  static const int MOVEMENT_MAX = 7000;
  static const int DIFF_COUNT = 20;
  static const int MIN_COUNT = 12;

  List<int> _diff = [0, 0, 0];
  List<int> _last = [0, 0, 0];
  List<int> _calib = [0, 0, 0];

  List<int> _history = new List.filled(100, 0);
  int _historyPos = 0;

  void update(List<int> accel) {
    if (accel.length < _calib.length) {
      throw new Error();
    }
    for (int i = 0; i < _calib.length; i++) {
      _diff[i] = (accel[i] - _last[i] - _calib[i]).abs();
    }
    _last = accel;

    _history[_historyPos] = _diff.reduce((a, b) => a + b);
    if (_history[_historyPos] > 5000) _history[_historyPos] = 0;
    //print("diff:  ${_diff.reduce((a, b) => a.abs() + b.abs())}");
    _historyPos = (_historyPos + 1) % 100;

    isMoving();
  }

  bool isMoving() {
    int sum = 0;
    for (int i = 0; i < DIFF_COUNT; i++) {
      var a = _history[
          (_historyPos - i >= 0) ? _historyPos - i : _historyPos - i + 100];
      sum += (a >= MOVEMENT_MIN && a <= MOVEMENT_MAX) ? 1 : 0;
    }
    //print(sum);
    return sum > MIN_COUNT;
  }

  int movementPercent() {
    return _history
        .map((e) => (e >= MOVEMENT_MIN / DIFF_COUNT) ? 1 : 0)
        .reduce((a, b) => a + b);
  }
}
