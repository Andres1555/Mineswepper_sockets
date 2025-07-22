abstract class Event {
  const Event();
}

class InitGame extends Event {
  const InitGame();
}

class Click extends Event {
  final int index;
  const Click(this.index);
}

class LongClicked extends Event {
  final int index;
  const LongClicked(this.index);
}

class TimeTick extends Event {}