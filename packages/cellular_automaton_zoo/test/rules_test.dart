import 'package:cellular_automaton_zoo/cellular_automaton_zoo.dart';
import 'package:test/test.dart';

// A mixin can't be created on its own, so give it a tiny class.
class Conway with ConwayRules {}

void main() {
  final rules = Conway();

  group('ConwayRules (B3/S23)', () {
    test('live cell: survives only with 2 or 3 neighbors', () {
      for (var n = 0; n <= 8; n++) {
        expect(rules.nextState(true, n), equals(n == 2 || n == 3),
            reason: 'alive with $n neighbors');
      }
    });

    test('dead cell: born only with exactly 3 neighbors', () {
      for (var n = 0; n <= 8; n++) {
        expect(rules.nextState(false, n), equals(n == 3),
            reason: 'dead with $n neighbors');
      }
    });

    test('named cases from the assignment', () {
      expect(rules.nextState(true, 1), isFalse, reason: 'loneliness');
      expect(rules.nextState(true, 2), isTrue, reason: 'survival');
      expect(rules.nextState(true, 3), isTrue, reason: 'survival');
      expect(rules.nextState(true, 4), isFalse, reason: 'overcrowding');
      expect(rules.nextState(false, 3), isTrue, reason: 'reproduction');
    });
  });
}
