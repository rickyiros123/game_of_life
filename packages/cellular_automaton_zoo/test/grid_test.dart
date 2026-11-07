import 'package:cellular_automaton_zoo/cellular_automaton_zoo.dart';
import 'package:test/test.dart';

/// Sets every cell on the grid to [alive].
void setAll(Grid grid, bool alive) {
  for (var x = 0; x < grid.width; x++) {
    for (var y = 0; y < grid.height; y++) {
      grid.setAlive(Cell(x: x, y: y), alive);
    }
  }
}

void main() {
  group('Grid constructor', () {
    test('same seed produces the same board', () {
      final a = Grid(width: 20, height: 10, seed: 7);
      final b = Grid(width: 20, height: 10, seed: 7);
      expect(a.population, equals(b.population));
      for (var x = 0; x < 20; x++) {
        for (var y = 0; y < 10; y++) {
          final cell = Cell(x: x, y: y);
          expect(a.isAlive(cell), equals(b.isAlive(cell)),
              reason: 'mismatch at $cell');
        }
      }
    });

    test('a 1x1 grid always has exactly one live cell', () {
      for (var seed = 0; seed < 50; seed++) {
        final g = Grid(width: 1, height: 1, seed: seed);
        expect(g.population, equals(1), reason: 'seed $seed');
      }
    });

    test('tiny non-square grids are never empty', () {
      for (var seed = 0; seed < 50; seed++) {
        expect(Grid(width: 1, height: 2, seed: seed).population,
            greaterThanOrEqualTo(1),
            reason: '1x2, seed $seed');
        expect(Grid(width: 2, height: 1, seed: seed).population,
            greaterThanOrEqualTo(1),
            reason: '2x1, seed $seed');
      }
    });

    test('population never exceeds the number of cells', () {
      final g = Grid(width: 30, height: 15, seed: 42);
      expect(g.population, inInclusiveRange(1, 30 * 15));
    });

    test('invalid dimensions throw ArgumentError', () {
      expect(() => Grid(width: 0, height: 5, seed: 1),
          throwsA(isA<ArgumentError>()));
      expect(() => Grid(width: 5, height: 0, seed: 1),
          throwsA(isA<ArgumentError>()));
      expect(() => Grid(width: -3, height: 5, seed: 1),
          throwsA(isA<ArgumentError>()));
    });
  });

  group('contains', () {
    // 30 wide, 15 tall: x runs 0..29, y runs 0..14.
    final g = Grid(width: 30, height: 15, seed: 1);

    test('corners are inside', () {
      expect(g.contains(Cell(x: 0, y: 0)), isTrue);
      expect(g.contains(Cell(x: 29, y: 0)), isTrue);
      expect(g.contains(Cell(x: 0, y: 14)), isTrue);
      expect(g.contains(Cell(x: 29, y: 14)), isTrue);
    });

    test('just outside each edge is outside', () {
      expect(g.contains(Cell(x: -1, y: 0)), isFalse);
      expect(g.contains(Cell(x: 0, y: -1)), isFalse);
      expect(g.contains(Cell(x: 30, y: 0)), isFalse);
      expect(g.contains(Cell(x: 0, y: 15)), isFalse);
    });

    test('swapped axes are caught (x=14, y=29 is off the board)', () {
      expect(g.contains(Cell(x: 14, y: 29)), isFalse);
    });
  });

  group('isAlive / setAlive', () {
    test('setAlive true then false round-trips', () {
      final g = Grid(width: 5, height: 5, seed: 1);
      final cell = Cell(x: 2, y: 3);
      g.setAlive(cell, true);
      expect(g.isAlive(cell), isTrue);
      g.setAlive(cell, false);
      expect(g.isAlive(cell), isFalse);
    });

    test('population follows setAlive, with no double counting', () {
      final g = Grid(width: 5, height: 5, seed: 1);
      setAll(g, false);
      expect(g.population, equals(0));

      final cell = Cell(x: 1, y: 1);
      g.setAlive(cell, true);
      g.setAlive(cell, true); // setting twice must not count twice
      expect(g.population, equals(1));

      g.setAlive(cell, false);
      g.setAlive(cell, false); // killing a dead cell is harmless
      expect(g.population, equals(0));
    });

    test('filling the board gives population == width * height', () {
      final g = Grid(width: 6, height: 4, seed: 1);
      setAll(g, true);
      expect(g.population, equals(24));
    });

    test('off-board cells throw RangeError', () {
      final g = Grid(width: 5, height: 5, seed: 1);
      final off = Cell(x: -1, y: 0);
      expect(() => g.isAlive(off), throwsA(isA<RangeError>()));
      expect(() => g.setAlive(off, true), throwsA(isA<RangeError>()));
      expect(() => g.isAlive(Cell(x: 5, y: 0)), throwsA(isA<RangeError>()));
    });
  });

  group('liveNeighborCount', () {
    test('3x3 all alive: center 8, edges 5, corners 3', () {
      final g = Grid(width: 3, height: 3, seed: 1);
      setAll(g, true);
      expect(g.liveNeighborCount(Cell(x: 1, y: 1)), equals(8));
      for (final edge in [
        Cell(x: 1, y: 0),
        Cell(x: 0, y: 1),
        Cell(x: 2, y: 1),
        Cell(x: 1, y: 2),
      ]) {
        expect(g.liveNeighborCount(edge), equals(5), reason: 'edge $edge');
      }
      for (final corner in [
        Cell(x: 0, y: 0),
        Cell(x: 2, y: 0),
        Cell(x: 0, y: 2),
        Cell(x: 2, y: 2),
      ]) {
        expect(g.liveNeighborCount(corner), equals(3),
            reason: 'corner $corner');
      }
    });

    test('3x3 only center alive: others see 1, center sees 0', () {
      final g = Grid(width: 3, height: 3, seed: 1);
      setAll(g, false);
      g.setAlive(Cell(x: 1, y: 1), true);
      for (var x = 0; x < 3; x++) {
        for (var y = 0; y < 3; y++) {
          final cell = Cell(x: x, y: y);
          final expected = (x == 1 && y == 1) ? 0 : 1;
          expect(g.liveNeighborCount(cell), equals(expected),
              reason: 'at $cell');
        }
      }
    });

    test('non-square grid (4 wide, 2 tall) all alive', () {
      final g = Grid(width: 4, height: 2, seed: 1);
      setAll(g, true);
      expect(g.liveNeighborCount(Cell(x: 0, y: 0)), equals(3));
      expect(g.liveNeighborCount(Cell(x: 3, y: 1)), equals(3));
      expect(g.liveNeighborCount(Cell(x: 1, y: 0)), equals(5));
      expect(g.liveNeighborCount(Cell(x: 2, y: 1)), equals(5));
    });

    test('empty board: every count is 0', () {
      final g = Grid(width: 4, height: 4, seed: 1);
      setAll(g, false);
      for (var x = 0; x < 4; x++) {
        for (var y = 0; y < 4; y++) {
          expect(g.liveNeighborCount(Cell(x: x, y: y)), equals(0));
        }
      }
    });

    test('off-board cell throws RangeError', () {
      final g = Grid(width: 3, height: 3, seed: 1);
      expect(() => g.liveNeighborCount(Cell(x: 3, y: 0)),
          throwsA(isA<RangeError>()));
    });
  });
}