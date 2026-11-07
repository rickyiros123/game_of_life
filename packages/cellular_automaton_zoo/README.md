## Running

Install dependencies:

```bash
dart pub get
```

Run Conway's Game of Life with the defaults (40×20 board, seed 42, 100 generations, 8 fps):

```bash
dart run bin/main.dart
```

Choose the board size, speed, and length:

```bash
dart run bin/main.dart --species=conway --width=30 --height=15 --generations=100 --fps=8
```

Run the custom rule (HighLife, B36/S23):

```bash
dart run bin/main.dart --species=custom --width=40 --height=20 --generations=200 --fps=15
```

Try a different starting board (the same seed always gives the same board):

```bash
dart run bin/main.dart --seed=7
```

Run the tests:

```bash
dart test
```

### Options

| Option          | Default  | Description                          |
|-----------------|----------|--------------------------------------|
| `--species`     | `conway` | Rule set: `conway` or `custom`       |
| `--width`       | `40`     | Number of columns                    |
| `--height`      | `20`     | Number of rows                       |
| `--seed`        | `42`     | Random seed for the starting board   |
| `--generations` | `100`    | Number of steps to run               |
| `--fps`         | `8`      | Generations shown per second         |
