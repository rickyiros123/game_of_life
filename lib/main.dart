import 'package:flutter/material.dart';
import 'package:cellular_automaton_zoo/cellular_automaton_zoo.dart';
import 'dart:async';

class ConwayBoard extends CellularAutomaton with ConwayRules, AsciiRenderable {
  ConwayBoard({required super.width, required super.height, required super.seed});
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game of Life',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.cyanAccent,
            brightness: Brightness.dark,
          ),
        ),
      home: const MyHomePage(title: 'Game of life'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var board = ConwayBoard(width: 20, height: 20, seed: 100);
  Timer? _timer;
  final Set<String> _snapShot = {};

  void _play() {
    if (_timer != null) return; // already playing
    _snapShot.add(board.render());
    setState(() {
      _timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
        setState(() => board.step());
        final isNew = _snapShot.add(board.render());
        if(!isNew) _pause();
      });
    });
  }

  void _pause() {
    setState(() {
      _timer?.cancel();
      _timer = null;
    });
  }

  void _reset() {
    _pause();
    setState(() {
      _snapShot.clear();
      board = ConwayBoard(width: 20, height: 20, seed: 100);
      _snapShot.add(board.render());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle(int x, int y) {
    final cell = Cell(x: x, y: y);
    setState(() {
      board.setAlive(cell, !board.isAlive(cell));
      _snapShot.clear();
      _snapShot.add(board.render());
    });
  }

  Widget _buildCell(int index) {
    final colors = Theme.of(context).colorScheme;
    final x = index % 20;
    final y = index ~/ 20;
    final alive = board.isAlive(Cell(x: x, y: y));
    const duration = Duration(milliseconds: 300);

    return GestureDetector(
      onTap: () => _toggle(x, y),
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: colors.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(3),
        ),
        child: AnimatedScale(
          scale: alive ? 1 : 0,
          duration: duration,
          curve: Curves.easeIn,
          child: Container(
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.6),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Flexible(
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView.count(
                crossAxisCount: 20,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(400, _buildCell),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: (_timer != null) ? null : _play, child: const Text('Play')),
                ElevatedButton(onPressed: (_timer != null) ? _pause : null, child: const Text('Pause')),
                ElevatedButton(onPressed: _reset, child: const Text('Reset')),
              ],
            ),
          ),
          Text("Generation ${board.generation}"),
        ],
      ),
    );
  }
}
