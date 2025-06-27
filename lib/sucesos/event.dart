import 'package:equatable/equatable.dart';

abstract class Event extends Equatable {
  const Event();

  @override
  List<Object> get props => [];
}

class InitGame extends Event {
  const InitGame();
}

class Click extends Event {
  final int index;

  const Click(this.index);

  @override
  List<Object> get props => [index];
}

class LongClicked extends Event {
  final int index;

  const LongClicked(this.index);

  @override
  List<Object> get props => [index];
}

class TimeTick extends Event {}