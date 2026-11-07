import 'cell.dart';
import 'grid.dart';
import 'cellular_automaton.dart';

/// Draws the board as plain text: '#' for a live cell, '.' for a dead one.
///
/// Declared `on Grid` because render() needs Grid's members:
/// [Grid.width], [Grid.height] and [Grid.isAlive].
mixin AsciiRenderable on Grid{
  /// Returns the board as one line of text per row, top to bottom.
  /// Every row, including the last, ends with a newline.
  String render(){
    String result = "";
    // Outer loop: one pass per row (y), since each line of text is a row.
    for(int i = 0; i < height; i++){
      // Inner loop: one character per column (x), left to right.
      for(int j = 0; j < width; j++){
        Cell curr = Cell(x: j, y: i);
        if(isAlive(curr)){
          result = '$result#';
        } else {
          result = '$result.';
        }
      }
      // End of the row.
      result = '$result\n';
    }
    return result;
  }
}

/// Wraps the board drawn by an earlier render() in a border:
/// '-' along the top and bottom, '|' down each side.
///
/// Declared `on CellularAutomaton` because that is where render() is
/// declared, which is what allows the call to super.render(). In a `with`
/// list it must come AFTER a mixin that implements render(), such as
/// [AsciiRenderable].
mixin DecoratedRenderable on CellularAutomaton{
  /// Returns the underlying drawing surrounded by a border.
  @override
  String render(){
    // Get the plain drawing (e.g. from AsciiRenderable) and split it into
    // rows. The trailing newline leaves an empty last item.
    List<String> oldBoard = super.render().split("\n");
    String result = "";
    // Border line: the row width plus one character for each side wall.
    String topBottom = '-' * (width+2);
    for(var l in oldBoard){
      // Skip the empty item left by the trailing newline, so no blank
      // row appears inside the border.
      if(l.isEmpty) continue;
      // Put a wall on each side of the row and end the line.
      l = "|$l|\n";
      result = result+l;
    }

    // Add the top and bottom borders, ending with a newline like the
    // plain drawing does.
    result = "$topBottom\n$result$topBottom\n";
    return result;
  }
}