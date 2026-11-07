import 'package:cellular_automaton_zoo/cellular_automaton_zoo.dart';
import 'package:test/test.dart';

/// A concrete automaton for testing, composed like Conway in bin/main.dart.
class Life extends CellularAutomaton
    with ConwayRules, AsciiRenderable, DecoratedRenderable {
  Life({required super.width, required super.height, required super.seed});
}

/// Builds a board containing exactly [cells] alive.
Life board(int width, int height, Iterable<Cell> cells) {
  final g = Life(width: width, height: height, seed: 1);
  for (var x = 0; x < width; x++) {
    for (var y = 0; y < height; y++) {
      g.setAlive(Cell(x: x, y: y), false);
    }
  }
  for (final c in cells) {
    g.setAlive(c, true);
  }
  return g;
}

/// Reads back every live cell on the board.
Set<Cell> aliveCells(Grid g) => {
      for (var x = 0; x < g.width; x++)
        for (var y = 0; y < g.height; y++)
          if (g.isAlive(Cell(x: x, y: y))) Cell(x: x, y: y),
    };

void main() {
  group('generation counter', () {
    test('starts at 0', () {
      expect(Life(width: 5, height: 5, seed: 1).generation, equals(0));
    });

    test('goes up by exactly 1 per step', () {
      final g = Life(width: 5, height: 5, seed: 1);
      for (var i = 1; i <= 5; i++) {
        g.step();
        expect(g.generation, equals(i));
      }
    });
  });

  group('classic patterns', () {
    test('blinker flips horizontal -> vertical -> horizontal', () {
      final horizontal = {
        Cell(x: 1, y: 2), Cell(x: 2, y: 2), Cell(x: 3, y: 2),
      };
      final vertical = {
        Cell(x: 2, y: 1), Cell(x: 2, y: 2), Cell(x: 2, y: 3),
      };
      final g = board(5, 5, horizontal);

      g.step();
      expect(aliveCells(g), equals(vertical));
      g.step();
      expect(aliveCells(g), equals(horizontal));
    });

    test('block (2x2) never changes', () {
      final block = {
        Cell(x: 1, y: 1), Cell(x: 2, y: 1),
        Cell(x: 1, y: 2), Cell(x: 2, y: 2),
      };
      final g = board(4, 4, block);
      for (var i = 0; i < 5; i++) {
        g.step();
        expect(aliveCells(g), equals(block), reason: 'after step ${i + 1}');
      }
    });

    test('beehive never changes', () {
      final beehive = {
        Cell(x: 2, y: 1), Cell(x: 3, y: 1),
        Cell(x: 1, y: 2), Cell(x: 4, y: 2),
        Cell(x: 2, y: 3), Cell(x: 3, y: 3),
      };
      final g = board(6, 5, beehive);
      g.step();
      expect(aliveCells(g), equals(beehive));
    });

    test('glider moves one cell down-right every 4 steps', () {
      final glider = {
        Cell(x: 1, y: 0),
        Cell(x: 2, y: 1),
        Cell(x: 0, y: 2), Cell(x: 1, y: 2), Cell(x: 2, y: 2),
      };
      final g = board(8, 8, glider);
      for (var i = 0; i < 4; i++) {
        g.step();
      }
      final moved = {for (final c in glider) Cell(x: c.x + 1, y: c.y + 1)};
      expect(aliveCells(g), equals(moved));
    });

    test('a lone cell dies', () {
      final g = board(3, 3, {Cell(x: 1, y: 1)});
      g.step();
      expect(g.population, equals(0));
    });

    test('an empty board stays empty', () {
      final g = board(4, 4, <Cell>{});
      g.step();
      expect(g.population, equals(0));
    });
  });

  group('edges are walls (no wrap-around)', () {
    test('blinker against the top wall cannot flip upward', () {
      // Horizontal blinker in the top row. With wrap-around it would flip
      // to a vertical line through the bottom row; with walls, only the
      // center survives and one cell is born below it.
      final g = board(5, 5, {
        Cell(x: 1, y: 0), Cell(x: 2, y: 0), Cell(x: 3, y: 0),
      });
      g.step();
      expect(aliveCells(g), equals({Cell(x: 2, y: 0), Cell(x: 2, y: 1)}));
    });

    test('block in a corner is stable', () {
      final corner = {
        Cell(x: 0, y: 0), Cell(x: 1, y: 0),
        Cell(x: 0, y: 1), Cell(x: 1, y: 1),
      };
      final g = board(4, 4, corner);
      g.step();
      expect(aliveCells(g), equals(corner));
    });
  });

  group('step() uses the old board for every decision', () {
    test('matches nextState applied to a snapshot of the board', () {
      for (final seed in [1, 2, 3, 42, 99]) {
        final g = Life(width: 12, height: 8, seed: seed);

        // Work out the expected next board BEFORE stepping.
        final expected = <Cell>{};
        for (var x = 0; x < g.width; x++) {
          for (var y = 0; y < g.height; y++) {
            final c = Cell(x: x, y: y);
            if (g.nextState(g.isAlive(c), g.liveNeighborCount(c))) {
              expected.add(c);
            }
          }
        }

        g.step();
        expect(aliveCells(g), equals(expected), reason: 'seed $seed');
      }
    });

    test('same seed gives the same sequence of boards', () {
      final a = Life(width: 15, height: 10, seed: 7);
      final b = Life(width: 15, height: 10, seed: 7);
      for (var i = 0; i < 10; i++) {
        a.step();
        b.step();
        expect(a.render(), equals(b.render()), reason: 'step ${i + 1}');
      }
    });
  });

  group('render after step', () {
    test('bordered output reflects the new board', () {
      final g = board(3, 3, {
        Cell(x: 0, y: 1), Cell(x: 1, y: 1), Cell(x: 2, y: 1),
      });
      g.step();
      expect(g.render(), equals('-----\n|.#.|\n|.#.|\n|.#.|\n-----\n'));
    });
  });
}
