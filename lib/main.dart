
import 'package:flutter/material.dart';
import 'package:game_of_life/game_controller.dart';


const Color terminalBackground = Colors.black;
const Color terminalSurface = Color(0xFF101B12);
const Color terminalGreen = Color(0xFF65D982);
const Color terminalBright = Color(0xFF9BFFAC);
const Color terminalMuted = Color(0xFF478C57);
const Color terminalBorder = Color(0xFF285B36);
const Color terminalCell = Color(0xFF17251A);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MU/TH/UR 6000',
      theme: ThemeData(
        // Use Flutter's dark theme so default widgets also fit the terminal.
        brightness: Brightness.dark,
        // Sets the background behind the Scaffold on every screen.
        scaffoldBackgroundColor: terminalBackground,

        // Defines the app-wide colors used by Material widgets.
        colorScheme: const ColorScheme.dark(
          primary: terminalGreen,
          secondary: terminalBright,
          surface: terminalSurface,
          onPrimary: terminalBackground,
          onSurface: terminalBright,
        ),

        fontFamily: "MyFont",

        // Styles every AppBar: black background, green title, no raised shadow.
        appBarTheme: const AppBarTheme(
          backgroundColor: terminalBackground,
          foregroundColor: terminalBright,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: terminalBright,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 10,
            fontFamily: "MyFont",
          ),
        ),

        // One shared button style keeps PLAY, PAUSE, and RESET visually consistent.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: terminalGreen,
            foregroundColor: terminalBackground,
            disabledBackgroundColor: terminalBorder,
            disabledForegroundColor: terminalMuted,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
            textStyle: const TextStyle(
              fontFamily: "MyFont",
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              fontSize: 11,
            ),
            // Small corner radius keeps the buttons looking like physical control keys.
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        dividerColor: terminalBorder,
      ),
      home: const MyHomePage(title: 'MU/TH/UR 6000'),
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
  final controller = GameController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  Widget _buildCell(int index) {
    final x = index % 20;
    final y = index ~/ 20;
    final alive = controller.isAlive(x, y);

    final duration = Duration(milliseconds: 250);

    return GestureDetector(
      onTap: () => controller.toggle(x, y),
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: terminalCell,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: terminalBorder.withValues(alpha: 0.35),
            width: 0.5,
          ),
        ),
        child: AnimatedScale(
          scale: alive ? 1 : 0,
          duration: duration,
          curve: Curves.easeIn,
          child: Container(
            decoration: BoxDecoration(
              color: terminalBright,
              borderRadius: BorderRadius.circular(2),
              // A soft green shadow creates the CRT-like glow around living cells.
              boxShadow: [
                BoxShadow(
                  color: terminalGreen.withValues(alpha: 0.65),
                  blurRadius: 7,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: terminalBorder),
        ),
      ),
      child: Row(
        children: [
          // Monitor icon acts like a small hardware/system symbol.
          const Icon(
            Icons.monitor,
            color: terminalGreen,
            size: 20,
          ),
          const SizedBox(width: 10),

          // Expanded lets the two-line company/system title use the remaining row width.
          // Column stacks the company name above the MU/TH/UR model name.
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ROSE CORP.",
                  style: TextStyle(
                    color: terminalMuted,
                    fontSize: 9,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "MU/TH/UR 6000",
                  style: TextStyle(
                    color: terminalBright,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            "SYS ONLINE",
            style: TextStyle(
              color: terminalGreen,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerationMonitor() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: terminalBackground,
        border: Border.all(
          color: terminalBorder,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.memory,
                color: terminalGreen,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                "BIOLOGICAL COMPUTING UNIT",
                style: TextStyle(
                  color: terminalGreen,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Spacer(),
              Text(
                "ONLINE",
                style: TextStyle(
                  color: terminalBright,
                  fontSize: 10,
                ),
              ),
            ],
          ),

          const Divider(color: terminalBorder),

          const Text(
            "BIOLOGICAL SIMULATION // SEQUENCE",
            style: TextStyle(
              color: terminalMuted,
              fontSize: 9,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 5),
          Text(
            "GEN ${controller.generation.toString().padLeft(4, '0')}",
            style: const TextStyle(
              color: terminalBright,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: terminalGreen,
                  blurRadius: 8,
                ),
              ],
            ),
          ),

          const Divider(color: terminalBorder),

          Row(
            children: [
              const Text(
                "COMPUTATION STATUS",
                style: TextStyle(
                  color: terminalMuted,
                  fontSize: 9,
                ),
              ),
              const Spacer(),
              Text(
                controller.isRunning ? "RUNNING" : "STANDBY",
                style: const TextStyle(
                  color: terminalBright,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: controller.isRunning ? null : controller.play,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow, size: 16),
                  SizedBox(width: 4),
                  Text('PLAY'),
                ],
              )
          ),
          ElevatedButton(
            onPressed: controller.isRunning ? controller.pause : null,
            child: const Text("Ⅱ PAUSE"),
          ),
          ElevatedButton(
            onPressed: controller.reset,
            child: const Text("↻ RESET"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value != 'settings') return;
                bool wasRunning = controller.isRunning;
                controller.pause();
                final result = await showDialog<(Set<int>, Set<int>, Duration)>(
                  context: context,
                  builder: (context) => SettingsDialog(
                    initialBirth: controller.birth,
                    initialSurvive: controller.survive,
                    initialSpeed: controller.speed,
                  ),
                );
                if (!mounted) return;
                if(result != null){ 
                  controller.setRules(result.$1, result.$2);
                  controller.setSpeed(result.$3);
                }
                if(wasRunning) controller.play();
              },
              itemBuilder: (context) => const[
                PopupMenuItem(value: 'settings', child: Text('Settings')),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Terminal header
              _buildHeader(),
              Flexible(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: terminalSurface,
                        border: Border.all(
                          color: terminalBorder,
                          width: 1.5,
                        ),
                      ),
                      child: GridView.count(
                        crossAxisCount: 20,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        // Calls _buildCell(index) for each index from 0 through 399.
                        children: List.generate(400, _buildCell),
                      ),
                    ),
                  ),
                ),
              ),

              _buildControls(),

              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: _buildGenerationMonitor(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({
    super.key,
    required this.initialBirth,
    required this.initialSurvive,
    required this.initialSpeed
  });

  final Set<int> initialBirth;
  final Set<int> initialSurvive;
  final Duration initialSpeed;

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog>{
  late Set<int> _birth;
  late Set<int> _survive;
  late Duration _speed;

  @override
  void initState() {
    super.initState();
    _birth = Set.of(widget.initialBirth);
    _survive = Set.of(widget.initialSurvive);
    _speed = widget.initialSpeed;
  }

  @override
  Widget build(BuildContext context){
    return AlertDialog(
      scrollable: true,
      backgroundColor: terminalBorder,
      title: const Text('Set Rules'),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SquareRow(
              selected: _birth,
              onChanged: (updated) => setState(() => _birth = updated),
            ),
            Text("Birth"),
            SizedBox(height: 1),
            SquareRow(
              selected: _survive,
              onChanged: (updated) => setState(() => _survive = updated),
            ),
            Text("Survive"),
            Slider(
              value: _speed.inMilliseconds.toDouble(),
              min: 250,
              max: 1000,
              onChanged: (newValue) => setState(
                      () => _speed = Duration(milliseconds: newValue.round())
              ),
            ),
            Text('${_speed.inMilliseconds} ms per generation'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, (_birth, _survive, _speed)),
          child: const Text('Save')
        ),
      ],
    );
  }
}

class SquareRow extends StatelessWidget {
  const SquareRow({
    super.key,
    this.activeColor = terminalBright,
    this.inactiveColor = terminalSurface,
    this.selected = const {},
    required this.onChanged
  });

  final Color activeColor;
  final Color inactiveColor;
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  @override
  Widget build(BuildContext context){
    return Row(
      children: List.generate(9, (i){
        final on = selected.contains(i);
        return Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: GestureDetector(
                onTap: () {
                  final updated = on
                      ? ({...selected}..remove(i))
                      : {...selected, i};
                  onChanged(updated);
                },
                child: Container(
                  margin: const EdgeInsets.all(1),
                  color: on ? activeColor : inactiveColor,
                  child: Center(
                      child: Text(
                        '$i',
                        style: TextStyle(
                          color: on ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                  ),
                )
            ),
          ),
        );
      }),
    );
  }
}


