import 'package:cellular_automaton_zoo/cellular_automaton_zoo.dart';
import 'package:test/test.dart';

// A mixin needs a class to live in, so make a tiny one just for testing.
class AsciiGrid extends Grid with AsciiRenderable {
  AsciiGrid({required super.width, required super.height, required super.seed});
}

class DecoratedGrid extends CellularAutomaton
    with ConwayRules, AsciiRenderable, DecoratedRenderable{
  DecoratedGrid({required super.width, required super.height, required super.seed});
}

void main() {
  test('DecoratedRenderable on a 10x10 board', () {
    final g = DecoratedGrid(width: 10, height: 10, seed: 42);
    final output = g.render();
    print(output);

    final lines = output.split('\n').where((l) => l.isNotEmpty).toList();
    expect(lines.length, equals(12));              // 10 rows + top + bottom
    expect(lines.first, equals('-' * 12));
    expect(lines.last, equals('-' * 12));
    for (final row in lines.sublist(1, 11)) {
      expect(row, matches(RegExp(r'^\|[#.]{10}\|$')));
    }
  });
}