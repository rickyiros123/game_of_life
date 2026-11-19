// -reset (finish this group first)
// Restores the seeded starting board. Tick a few times, reset, then compare every cell with a fresh controller made with the same seed. Use a non-default seed (like 7) so the boardSeed bug would have been caught.
// Pauses the game. Play, reset, check that isRunning is false.
// Keeps custom rules. Set non-default rules, reset, check that birth and survive still match.
// toggle
// Flips a cell. Check one cell’s state, toggle it, and check it’s now the opposite.
// Flipping twice restores it, so toggling is its own undo.
// Doesn’t change the generation, since editing isn’t a step.
// Clears the repeat history. This one protects a subtle behavior: tap the same cell twice while running, then tick, and the game should not auto-pause, even though the board briefly returned to an earlier state.
// tick and the auto-pause
// Advances the generation by exactly one.
// Auto-pauses on a still board. Build a known still pattern, such as a 2 × 2 block, on an otherwise empty board, play, then tick: the game should pause, because the board didn’t change.
// Auto-pauses on an oscillator, like a blinker (three cells in a row), after one full cycle of two ticks.
// Doesn’t pause while the board keeps changing.
//
// These need a board you fully control, which is where a small board size and toggle come in. A “clear board” method on the controller would make these much easier, and doubles as a feature.
//
// setRules
// Stores the new rules, readable through birth and survive.
// The game actually uses them. Set up a pattern that behaves differently under two rules, then tick and check the result. For example, a dead cell with exactly 6 live neighbors comes alive under B36 but not under B3.
// Notifies listeners, using the counter trick.
// setSpeed
// Stores the new speed, readable through speed.
// While paused, it doesn’t start the game.
// While running, the game keeps running after the change.

import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_of_life/game_controller.dart';

void main() {
  test('pause stops the game', () {
    // Arrange: a fresh controller, cleaned up when the test ends
    final controller = GameController();
    addTearDown(controller.dispose);

    // Act: start the game, then pause it
    controller.play();
    controller.pause();

    // Assert: the game should no longer be running
    expect(controller.isRunning, isFalse);
  });

  test('play restarts the game after a pause', () {
    final controller = GameController();
    addTearDown(controller.dispose);

    controller.play();
    controller.pause();

    // Start counting notifications only from here on
    var notifications = 0;
    controller.addListener(() => notifications++);

    controller.play();

    expect(controller.isRunning, isTrue);
    expect(notifications, greaterThan(0));
  });

  test('reset sets the generation to 0', () {
    final controller = GameController();
    addTearDown(controller.dispose);

    controller.tick();
    controller.tick();
    controller.tick();
    expect(controller.generation, 3);

    controller.reset();
    expect(controller.generation, 0);

  });

  test('reset restores the starting seed', () {
    final controller1 = GameController(seed: 7);
    final controller2 = GameController(seed: 7);
    addTearDown(controller1.dispose);
    addTearDown(controller2.dispose);

    controller1.tick();
    controller1.tick();
    controller1.tick();
    expect(controller1.generation, 3);

    controller1.reset();

    for(var x = 0; x < controller1.size; x++){
      for(var y = 0; y < controller2.size; y++){
        expect(
            controller1.isAlive(x, y),
            controller2.isAlive(x, y),
            reason: 'cell ($x, $y) differs after reset');
      }
    }
  });
}
