/// A coordinate on the grid. x is the column (0..width-1),
/// y is the row (0..height-1).
class Cell {
  final int x;
  final int y;

  const Cell({required this.x, required this.y});

  /// Two cells are equal when they have the same coordinates.
  @override
  bool operator ==(Object other) =>
      other is Cell && other.x == x && other.y == y;

  /// Must use the same fields as == so Cells work in a Set or Map.
  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Cell(x: $x, y: $y)';
}