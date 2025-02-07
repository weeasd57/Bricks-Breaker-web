import 'package:admin_ai_web/widgets/settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'painters/game_painter.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: const MyGame(),
    ),
  );
}

class MyGame extends StatelessWidget {
  const MyGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brick Breaker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    // Delay setup until after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final gameProvider = Provider.of<GameProvider>(context, listen: false);
        gameProvider.updateScreenSize(MediaQuery.of(context).size);
        gameProvider.setupGame();
        print("Game initialized in initState");
      }
    });
  }

  @override
  void dispose() {
    if (mounted) {
      Provider.of<GameProvider>(context, listen: false).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = Size(
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height,
    );

    return Scaffold(
      appBar: AppBar(
        title: Consumer<GameProvider>(
          builder: (context, gameProvider, _) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Score: ${gameProvider.score}'),
              Text(
                gameProvider.formattedTime,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final gameProvider =
                  Provider.of<GameProvider>(context, listen: false);
              gameProvider.restartGame();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              final gameProvider =
                  Provider.of<GameProvider>(context, listen: false);
              gameProvider.pauseGame();
              showDialog(
                context: context,
                builder: (context) => SettingsDialog(
                  gameProvider: gameProvider,
                ),
              ).then((_) => gameProvider.resumeGame());
            },
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, _) {
          return GestureDetector(
            onTapDown: (details) {
              print("Tap detected"); // Debug print
              gameProvider.startGame();
            },
            onPanUpdate: (details) {
              gameProvider.updatePaddlePosition(
                details.localPosition,
                screenSize.width,
              );
            },
            child: Stack(
              children: [
                RepaintBoundary(
                  child: CustomPaint(
                    painter: GamePainter(gameProvider, screenSize),
                    size: screenSize,
                  ),
                ),
                if (!gameProvider.gameStarted)
                  const Center(
                    child: Text(
                      'Tap to Start',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
