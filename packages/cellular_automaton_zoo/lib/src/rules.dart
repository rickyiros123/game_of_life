/// Conway's Game of Life, rule B3/S23.
///
///   * B3:  a dead cell with exactly 3 live neighbors is born.
///   * S23: a live cell with 2 or 3 live neighbors survives.
///   * Every other cell is dead in the next generation.
///
/// No `on` clause: [nextState] only uses its two parameters and never
/// reads the board, so this mixin does not depend on any class.
mixin ConwayRules {
  /// Returns true if the cell should be alive in the next generation.
  bool nextState(bool currentlyAlive, int liveNeighborCount){
    if(!currentlyAlive){
      // Birth (B3): a dead cell comes alive with exactly 3 neighbors.
      return liveNeighborCount == 3;
    }
    // Survival (S23): a live cell stays alive with 2 or 3 neighbors.
    // Fewer (loneliness) or more (overcrowding) and it dies.
    return liveNeighborCount == 2 || liveNeighborCount == 3;
  }
}

mixin CustomRules {
  /// Returns true if the cell should be alive in the next generation.
  bool nextState(bool currentlyAlive, int liveNeighborCount){
    if(!currentlyAlive){
      // Birth (B3): a dead cell comes alive with exactly 3/6 neighbors.
      return liveNeighborCount == 3 || liveNeighborCount == 6;
    }
    // Survival (S23): a live cell stays alive with 2 or 3 neighbors.
    // Fewer (loneliness) or more (overcrowding) and it dies.
    return liveNeighborCount == 2 || liveNeighborCount == 3;
  }
}
