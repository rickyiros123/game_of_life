import 'grid.dart';
import 'cell.dart';

/// A Grid that evolves over discrete time steps.
///
/// This class is abstract: it defines HOW the board advances ([step]),
/// but leaves two pieces for subclasses/mixins to supply:
///   * [nextState] - the rules (e.g. ConwayRules, CustomRules)
///   * [render]    - the drawing (e.g. AsciiRenderable, DecoratedRenderable)
/// Because of this, the same [step] works for every species.
abstract class CellularAutomaton extends Grid {
  /// Number of steps taken so far. Starts at 0 and goes up by 1 per [step].
  int generation = 0;

  /// Forwards [width], [height] and [seed] to the [Grid] constructor,
  /// which validates the size and randomly fills the board.
  CellularAutomaton({
    required super.width,
    required super.height,
    required super.seed
  });

  /// Returns whether a cell should be alive in the next generation,
  /// given whether it is alive now and how many live neighbors it has.
  /// Abstract: implemented by a rules mixin such as ConwayRules.
  bool nextState(bool currentlyAlive, int liveNeighborCount);

  /// Returns a text picture of the board.
  /// Abstract: implemented by a rendering mixin such as AsciiRenderable.
  String render();

  /// Advances the board by one generation.
  ///
  /// Works in two passes so every cell's decision is based on the same,
  /// unchanged board:
  ///   1. Decide: compute every cell's next state without touching the board.
  ///   2. Apply:  update the board to match those decisions.
  void step(){
    // Cells that should be alive next generation. Any cell not in this
    // set will be dead, the same way the board itself is stored.
    Set<Cell> nextStates = {};

    // Pass 1 (decide): visit every position, alive or dead, since dead
    // cells can be born. i is the column (x), j is the row (y).
    for(int i = 0; i < width; i++){
      for(int j = 0; j < height; j++){
        Cell curr = Cell(x: i, y: j);
        // Let the rules mixin decide, based on the current board.
        bool ifCellWillLive = nextState(isAlive(curr), liveNeighborCount(curr));
        if(ifCellWillLive){
          nextStates.add(curr);
        }
      }
    }

    // Pass 2 (apply): set each cell alive if it is in nextStates, dead
    // otherwise. This is what kills cells that should die.
    for(int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        Cell curr = Cell(x: i, y: j);
        setAlive(curr, nextStates.contains(curr));
      }
    }

    // One full step is complete.
    generation++;
  }
}