# Game of Life
https://rickyiros123.github.io/game_of_life/

A Flutter app for Conway's Game of Life and its variants, with a retro green-phosphor terminal look, smooth cell animations, and a live rule editor. The simulation engine is a separate, pure-Dart package with its own test suite, and the app layers a testable game controller and a UI on top of it.

<!-- TODO: add a GIF or screenshot of the app running -->
<!-- TODO: add the live web demo link once it's deployed -->

## Features

- **20 × 20 board** of glowing cells that you can watch evolve, generation by generation.
- **Play, Pause, and Reset.** Each button is enabled only when it does something, and Reset returns to the same seeded starting board every time.
- **Tap to edit.** Tap any cell to bring it to life or kill it, while the game is running or paused.
- **Live rule editor.** Pick which neighbor counts cause a birth and which let a cell survive, then press Save; the next generation follows the new rules. Try B36/S23 (HighLife) for self-replicating patterns.
- **Automatic pause.** The game stops itself when the board starts repeating: when it dies out, freezes, or settles into a cycle.
- **Smooth animations.** Newborn cells grow into place and dying cells shrink away.
- **Status panel** showing the current generation and whether the simulation is running.

## How the rules work

Every cell has up to 8 neighbors. Each generation, a dead cell is **born** if its number of live neighbors is in the birth set, and a live cell **survives** if its number of live neighbors is in the survival set. Every other cell is dead in the next generation.

Rules are written in B/S notation. Conway's original Game of Life is **B3/S23**: a dead cell with exactly 3 live neighbors is born, and a live cell with 2 or 3 survives. That's the default. The edges of the board are walls, so cells off the board never count as neighbors.

## Architecture

The project is split into three layers, each of which only depends on the one below it:

```
game_of_life/
├── packages/
│   └── cellular_automaton_zoo/   Simulation engine (pure Dart, no Flutter)
├── lib/
│   ├── life_board.dart           The app's board class and editable rules
│   ├── game_controller.dart      Game logic: timer, actions, repeat detection
│   └── main.dart                 UI: theme, board grid, controls, rule editor
└── pubspec.yaml
```

**Simulation engine (`cellular_automaton_zoo`).** A standalone Dart package that stores the board, counts neighbors, and advances generations. Its design is built on mixins: an abstract `CellularAutomaton` class defines how a board steps forward, while separate mixins supply the rules (`nextState`) and a text rendering (`render`). The package is used unchanged by the app and is linked as a local path dependency.

**Board (`life_board.dart`).** The app extends the engine without modifying it, by adding an `EditableRules` mixin whose `nextState` reads from changeable birth and survival sets instead of hardcoded numbers. `LifeBoard` combines it with the engine's classes.

**Controller (`game_controller.dart`).** `GameController` extends `ChangeNotifier` and owns all game state: the board, the timer, and the repeat history. It exposes read-only getters (`isRunning`, `generation`, `isAlive`, `birth`, `survive`) and actions (`play`, `pause`, `tick`, `reset`, `toggle`, `setRules`), and calls `notifyListeners()` after every change. Board size, seed, and tick speed are constructor parameters, which keeps the class easy to test.

**UI (`main.dart`).** The screen holds a single controller and redraws through a `ListenableBuilder` whenever the controller notifies. Widgets only read from the controller and call its methods; none of them contain game logic.

## Design notes

**Detecting a stuck board.** Since the rules are deterministic, a board that returns to any earlier state will repeat the same sequence forever. The controller keeps a `Set` of every board state since the last edit, using the engine's `render()` text as a fingerprint. After each step, `Set.add` returns `false` if the state was already there, and the game pauses. This one check catches empty boards, frozen boards, and oscillators of any period. The history is cleared whenever the board changes by any means other than a step (a tap, a Reset, or new rules), since the old history no longer applies.

**Implicit animations.** Each cell's live layer is an `AnimatedScale` with `scale: alive ? 1 : 0`. The code never starts or controls an animation; it only describes the target size, and Flutter animates the change automatically whenever the grid rebuilds. The animation (800 ms) is shorter than the tick (1000 ms), so each transition finishes before the next generation arrives.

**Controlled widgets.** The rule editor's rows (`SquareRow`) don't store any state of their own. Each row displays the set it's given and reports taps through an `onChanged` callback, so the controller stays the single source of truth for the rules.

## Getting started

You'll need the [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart 3.13.4 or newer).

```bash
git clone https://github.com/rickyiros123/game_of_life.git
cd game_of_life
flutter pub get
flutter run
```

### Running the tests

The engine package has its own test suite, which runs from inside the package:

```bash
cd packages/cellular_automaton_zoo
dart pub get
dart test
```

## Roadmap

- Unit tests for `GameController` and widget tests for the UI, run automatically with GitHub Actions
- A live web demo
- Rendering with `CustomPainter` to support much larger boards
- Importing and exporting patterns in the standard RLE format
- A speed control and a step-by-step mode
- Timeline scrubbing to rewind and replay a run

## Background

This project started as a course assignment for CS 378 (Framework-Based Software Development for Hand-Held Devices) at the University of Illinois Chicago in Fall 2026. The engine was written first as a pure-Dart command-line project, then imported unchanged into a Flutter app, and the app was later extended with the rule editor, the controller architecture, and the terminal design.
