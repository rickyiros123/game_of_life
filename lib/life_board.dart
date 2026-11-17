import 'package:cellular_automaton_zoo/cellular_automaton_zoo.dart';

class LifeBoard extends CellularAutomaton with AsciiRenderable, EditableRules {
  LifeBoard({
    required super.width,
    required super.height,
    required super.seed,
  });
}

mixin EditableRules {
  Set<int> birth = {3};
  Set<int> survive = {2, 3};

  bool nextState(bool currentlyAlive, int liveNeighborCount) =>
      currentlyAlive
          ? survive.contains(liveNeighborCount)
          : birth.contains(liveNeighborCount);
}