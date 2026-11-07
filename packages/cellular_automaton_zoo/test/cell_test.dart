import 'package:cellular_automaton_zoo/cellular_automaton_zoo.dart';
import 'package:test/test.dart';

void main() {
  group('Cell', () {
    test('cells with the same coordinates are equal', () {
      expect(Cell(x: 2, y: 3), equals(Cell(x: 2, y: 3)));
    });

    test('cells with different coordinates are not equal', () {
      expect(Cell(x: 2, y: 3), isNot(equals(Cell(x: 3, y: 2))));
      expect(Cell(x: 2, y: 3), isNot(equals(Cell(x: 2, y: 4))));
    });

    test('equal cells have equal hash codes', () {
      expect(Cell(x: 5, y: 7).hashCode, equals(Cell(x: 5, y: 7).hashCode));
    });

    test('a Set treats equal cells as one', () {
      final cells = {Cell(x: 1, y: 1), Cell(x: 1, y: 1), Cell(x: 2, y: 1)};
      expect(cells.length, equals(2));
      expect(cells.contains(Cell(x: 1, y: 1)), isTrue);
    });

    test('a Cell is not equal to a non-Cell', () {
      // ignore: unrelated_type_equality_checks
      expect(Cell(x: 0, y: 0) == 0, isFalse);
    });

    test('off-board coordinates can be created (Grid does the checking)', () {
      expect(() => Cell(x: -1, y: -1), returnsNormally);
    });
  });
}
