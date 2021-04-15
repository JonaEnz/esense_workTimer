class Movement {

  static const int MOVEMENT_MIN = 1000;

  List<int> diff = [0,0,0];
  List<int> last = [0,0,0];
  List<int> calib = [0,0,0];

  List<bool> history = new List.filled(100, false);
  int historyPos = 0;

  void update(List<int> accel) {
    if (accel.length < 3) {
      throw new Error();
    }
    for (int i = 0; i < 3; i++) {
      diff[i] = accel[i] - last[i];
    }
    last = accel;

    history[historyPos] = isMoving();
    historyPos = (historyPos + 1) % 100;
  }

  bool isMoving() {
    return diff.reduce((a, b) => a+b) > MOVEMENT_MIN;
  }

  int movementPercent() {
    return history.map((e) => e ? 1 : 0).reduce((a, b) => a + b);
  }
}