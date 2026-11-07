// Tests for CustomRules (HighLife, B36/S23).
// Delete this file (or leave it out) while CustomRules is removed for the
// video recording, or the whole test run will fail to compile.
import 'package:cellular_automaton_zoo/cellular_automaton_zoo.dart';
import 'package:test/test.dart';

class HighLifeRules with CustomRules {}
class ConwayOnly with ConwayRules {}

class HighLife extends CellularAutomaton
    with CustomRules, AsciiRenderable, DecoratedRenderable {
  HighLife({required super.width, required super.height, required super.seed});
}

class Life extends CellularAutomaton
    with ConwayRules, AsciiRenderable, DecoratedRenderable {
  Life({required super.width, required super.height, required super.seed});
}

/// Clears [g] and makes exactly [cells] alive.
void place(Grid g, Iterable<Cell> cells) {
  for (var x = 0; x < g.width; x++) {
    for (var y = 0; y < g.height; y++) {
      g.setAlive(Cell(x: x, y: y), false);
    }
  }
  for (final c in cells) {
    g.setAlive(c, true);
  }
}

void main() {
  final rules = HighLifeRules();

  group('CustomRules (HighLife, B36/S23)', () {
    test('live cell: survives only with 2 or 3 neighbors', () {
      for (var n = 0; n <= 8; n++) {
        expect(rules.nextState(true, n), equals(n == 2 || n == 3),
            reason: 'alive with $n neighbors');
      }
    });

    test('dead cell: born only with 3 or 6 neighbors', () {
      for (var n = 0; n <= 8; n++) {
        expect(rules.nextState(false, n), equals(n == 3 || n == 6),
            reason: 'dead with $n neighbors');
      }
    });

    test('differs from Conway only for a dead cell with 6 neighbors', () {
      final conway = ConwayOnly();
      for (final alive in [true, false]) {
        for (var n = 0; n <= 8; n++) {
          final differs =
              rules.nextState(alive, n) != conway.nextState(alive, n);
          expect(differs, equals(!alive && n == 6),
              reason: 'alive=$alive, n=$n');
        }
      }
    });
  });

  group('HighLife on a board', () {
    // Center (1,1) is dead with 6 live neighbors: everything except the
    // center and the two middle-edge cells on the left and right.
    final six = {
      Cell(x: 0, y: 0), Cell(x: 1, y: 0), Cell(x: 2, y: 0),
      Cell(x: 0, y: 2), Cell(x: 1, y: 2), Cell(x: 2, y: 2),
    };

    test('a dead cell with 6 neighbors is born in HighLife', () {
      final g = HighLife(width: 3, height: 3, seed: 1);
      place(g, six);
      expect(g.liveNeighborCount(Cell(x: 1, y: 1)), equals(6));
      g.step();
      expect(g.isAlive(Cell(x: 1, y: 1)), isTrue);
    });

    test('the same cell stays dead in Conway', () {
      final g = Life(width: 3, height: 3, seed: 1);
      place(g, six);
      g.step();
      expect(g.isAlive(Cell(x: 1, y: 1)), isFalse);
    });

    test('a blinker behaves the same as in Conway', () {
      final g = HighLife(width: 5, height: 5, seed: 1);
      place(g, {Cell(x: 1, y: 2), Cell(x: 2, y: 2), Cell(x: 3, y: 2)});
      g.step();
      expect(g.isAlive(Cell(x: 2, y: 1)), isTrue);
      expect(g.isAlive(Cell(x: 2, y: 3)), isTrue);
      expect(g.isAlive(Cell(x: 1, y: 2)), isFalse);
      expect(g.population, equals(3));
    });
  });
}
