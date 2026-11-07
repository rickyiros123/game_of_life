import 'dart:math';
import 'cell.dart';

/// A rectangular board of alive/dead cells, [width] columns by [height] rows.
///
/// State is stored as a Set of the LIVE cells only: a cell is alive if it
/// is in the set and dead otherwise. The edges are walls (no wrap-around),
/// so cells outside the board never count as neighbors.
class Grid {
  /// Number of columns. Valid x values are 0 to width - 1.
  final int width;

  /// Number of rows. Valid y values are 0 to height - 1.
  final int height;

  /// The live cells. Private to this file, so other files use the public
  /// methods below. Works because Cell overrides == and hashCode.
  final Set<Cell> _alive = {};

  /// Offsets to the 8 surrounding cells, as [row change, column change].
  List<List<int>> directions = [
    [-1, 0], [-1, 1], [0, 1], [1, 1],
    [1, 0], [1, -1], [0, -1], [-1, -1]
  ];

  /// Creates a board and fills it randomly using [seed].
  ///
  /// The same seed always produces the same starting board.
  /// Throws an [ArgumentError] if [width] or [height] is 0 or negative.
  /// Guarantees at least one live cell.
  Grid({required this.width, required this.height, required int seed}) {
    if(width <= 0 || height <= 0) throw ArgumentError('width or height are less than or equal to 0');

    // One Random for the whole board, so each cell gets a different value.
    var random = Random(seed);

    // Visit every position; each cell has a 50% chance to start alive.
    // i is the column (x), j is the row (y).
    for(int i = 0; i < width; i++){
      for(int j = 0; j < height; j++){
        int randomNumber = random.nextInt(2);
        if(randomNumber == 1){
          Cell curr = Cell(x: i, y: j);
          _alive.add(curr);
        }
      }
    }

    // An all-dead board never changes, so if the random fill produced
    // no live cells (possible on tiny boards), bring one random cell to life.
    if(_alive.isEmpty){
      int row = random.nextInt(height);
      int col = random.nextInt(width);
      Cell curr = Cell(x: col, y: row);
      _alive.add(curr);
    }
  }

  /// Number of live cells on the board.
  int get population => _alive.length;

  /// Returns true if [cell] lies inside the board.
  bool contains(Cell cell) {
    final row = cell.y;
    final col = cell.x;
    return !(row < 0 || row >= height || col < 0 || col >= width);
  }

  /// Returns true if [cell] is alive.
  /// Throws a [RangeError] if [cell] is off the board.
  bool isAlive(Cell cell) {
    if(!contains(cell)) throw RangeError('Cell is off grid.');
    if(_alive.contains(cell)) return true;
    return false;
  }

  /// Makes [cell] alive (adds it to the set) or dead (removes it).
  /// Adding a live cell or removing a dead one has no effect.
  /// Throws a [RangeError] if [cell] is off the board.
  void setAlive(Cell cell, bool alive) {
    if(!contains(cell)) throw RangeError('Cell is off grid.');

    if(alive){
      _alive.add(cell);
    } else {
      _alive.remove(cell);
    }
  }

  /// Counts the live cells among the up-to-8 neighbors of [cell].
  /// Corners have 3 neighbors and edge cells have 5, since off-board
  /// positions are skipped. Throws a [RangeError] if [cell] is off the board.
  int liveNeighborCount(Cell cell) {
    if(!contains(cell)) throw RangeError('Cell is off grid.');

    int count = 0;
    final row = cell.y;
    final col = cell.x;

    for(var d in directions) {
      int neighborRow = row + d[0];
      int neighborCol = col + d[1];
      Cell neighborCell = Cell(x: neighborCol, y: neighborRow);
      // Count it only if it is on the board AND alive.
      if (contains(neighborCell) && _alive.contains(neighborCell)) {
        count++;
      }
    }
    return count;
  }
}