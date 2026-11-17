import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cellular_automaton_zoo/cellular_automaton_zoo.dart';
import 'package:game_of_life/life_board.dart';

const boardSeed = 1;

class GameController extends ChangeNotifier {
  GameController({
    this.size = 20,
    this.seed = 1,
    this.tickSpeed = const Duration(milliseconds: 1000),
  }) : _board = LifeBoard(width: size, height: size, seed: seed);

  // Settings, fixed for the controller's lifetime.
  final int size;
  final int seed;
  final Duration tickSpeed;

  // Private game state. Only the controller changes these.
  LifeBoard _board;
  Timer? _timer;
  final Set<String> _history = {};

  // Read-only views for the UI.
  bool get isRunning => _timer != null;
  int get generation => _board.generation;
  bool isAlive(int x, int y) => _board.isAlive(Cell(x: x, y: y));
  Set<int> get birth => _board.birth;
  Set<int> get survive => _board.survive;

  void play() {
    if (_timer != null) return;
    _history.add(_board.render());
    _timer = Timer.periodic(tickSpeed, (_) => tick());
    notifyListeners();
  }

  void tick() {
    _board.step();
    notifyListeners();
    final isNew = _history.add(_board.render());
    if (!isNew) pause();
  }

  void pause() {
      _timer?.cancel();
      _timer = null;
      notifyListeners();
  }

  void reset() {
    pause();
    var currBirth = _board.birth;
    var currSurvive = _board.survive;
    _history.clear();
    _board = LifeBoard(width: size, height: size, seed: boardSeed);
    _board.birth = currBirth;
    _board.survive = currSurvive;
    _history.add(_board.render());
    notifyListeners();
  }

  void toggle(int x, int y) {
    final cell = Cell(x: x, y: y);
    _board.setAlive(cell, !_board.isAlive(cell));
    _history.clear();
    _history.add(_board.render());
    notifyListeners();
  }

  void setRules(Set<int> newBirth, Set<int> newSurvive){
    _board.survive = newSurvive;
    _board.birth = newBirth;
    _history.clear();
    _history.add(_board.render());
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

