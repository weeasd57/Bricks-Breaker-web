import 'package:flutter/material.dart';
import 'dart:async';

class Block {
  final double x;
  final double y;
  final Color color;
  bool isVisible;
  Block(this.x, this.y, this.color, {this.isVisible = true});
}

class GameProvider with ChangeNotifier {
  double paddleX = 0.0;
  double ballX = 0.0;
  double ballY = 0.0;
  double ballSpeedX = 4.0;
  double ballSpeedY = 4.0;
  bool gameStarted = false;
  Timer? gameTimer;
  List<Block> blocks = [];
  int score = 0;

  // Screen dimensions for better boundary calculation
  double screenWidth = 0;
  double screenHeight = 0;

  // Base size calculation
  double get baseSize =>
      (screenWidth < screenHeight ? screenWidth : screenHeight) / 100;

  // Relative sizes based on base unit
  double get paddleWidth => baseSize * 10; // Reduced from 15 units
  double get paddleHeight => baseSize * 1; // Reduced from 2 units
  double get ballSize => baseSize * 1.2; // Reduced from 2.5 units
  double get blockWidth => baseSize * 8; // Reduced from 12 units
  double get blockHeight => baseSize * 2; // Reduced from 4 units

  // Add timer variables
  int elapsedSeconds = 0;
  Timer? clockTimer;

  // Background color gradient
  final List<Color> backgroundColors = [
    Colors.black,
    Colors.blue.shade900,
    Colors.black,
  ];

  // Add new property for paddle sensitivity
  final double paddleBounceStrength = 6.0;
  final double minBallSpeed = 4.0;
  final double maxBallSpeed = 8.0;

  // Remove variable speeds and set constants
  final double initialBallY = 150.0; // Fixed starting position

  // Add new settings properties
  double ballSpeed = 4.0;
  int blocksColumns = 8;
  int blocksRows = 5;
  Color backgroundColor = Colors.black;
  double screenWidthPercent = 100;

  bool isPaused = false;
  Color borderColor = Colors.blue;
  double borderWidth = 2.0;

  // Add getter for game area width
  double get gameAreaWidth => screenWidth * (screenWidthPercent / 100);
  double get gameAreaHeight => screenHeight;

  // Add helper methods for boundaries
  double get gameLeftBound => -gameAreaWidth / 2;
  double get gameRightBound => gameAreaWidth / 2;

  void setupGame() {
    print("Setting up game...");
    gameTimer?.cancel();
    clockTimer?.cancel();

    // Set initial ball position closer to paddle
    ballX = 0;
    ballY = initialBallY; // Start at fixed position
    paddleX = 0;
    score = 0;
    gameStarted = false;

    // Set fixed initial speeds
    ballSpeedX = 0; // Start with no horizontal speed
    ballSpeedY = -ballSpeed; // Start with fixed speed upward

    // Blocks setup
    blocks.clear();
    int columns = blocksColumns; // Use settings for blocks setup
    int rows = blocksRows; // Use settings for blocks setup

    // Adjust block positioning to be visible
    double blockSpacing = baseSize * 1.5; // Reduced spacing
    double totalBlockWidth = blocksColumns * (blockWidth + blockSpacing);
    double startX = -totalBlockWidth / 2 + blockWidth / 2;

    // Ensure blocks fit within game area
    if (totalBlockWidth > gameAreaWidth) {
      blockSpacing =
          (gameAreaWidth - (blocksColumns * blockWidth)) / (blocksColumns - 1);
      startX = -gameAreaWidth / 2 + blockWidth / 2;
    }

    // Adjust block positioning to account for border
    double startY = -gameAreaHeight / 3 + borderWidth;
    double maxWidth = gameAreaWidth - (borderWidth * 2);

    // Calculate block layout
    blockSpacing = baseSize * 1.5;
    totalBlockWidth = blocksColumns * (blockWidth + blockSpacing);
    startX = -totalBlockWidth / 2 + blockWidth / 2;

    // Ensure blocks fit within bordered area
    if (totalBlockWidth > maxWidth) {
      blockSpacing =
          (maxWidth - (blocksColumns * blockWidth)) / (blocksColumns - 1);
      startX = -maxWidth / 2 + blockWidth / 2;
    }

    // Create blocks with adjusted positioning
    for (var i = 0; i < blocksColumns; i++) {
      for (var j = 0; j < blocksRows; j++) {
        blocks.add(Block(
          startX + i * (blockWidth + blockSpacing),
          startY + j * (blockHeight + baseSize),
          Colors.primaries[(i + j) % Colors.primaries.length],
        ));
      }
    }

    // Initialize timer
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (gameStarted) {
        updateGame();
      }
    });
    notifyListeners();
  }

  void startGame() {
    if (!gameStarted) {
      gameStarted = true;

      // Reset ball position to just above paddle
      ballX = 0;
      ballY = initialBallY; // Keep consistent with setupGame

      // Reset with fixed speeds
      ballSpeedX = ballSpeed;
      ballSpeedY = -ballSpeed;

      // Start the clock
      elapsedSeconds = 0;
      clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (gameStarted) {
          elapsedSeconds++;
          notifyListeners();
        }
      });

      notifyListeners();
    }
  }

  void updatePaddlePosition(Offset position, double screenWidth) {
    // Convert screen position to game coordinates
    double gameX =
        (position.dx - screenWidth / 2) * (gameAreaWidth / screenWidth);
    paddleX = gameX;

    // Limit paddle to game area
    double maxPaddleX = gameAreaWidth / 2 - paddleWidth / 2;
    if (paddleX < -maxPaddleX) paddleX = -maxPaddleX;
    if (paddleX > maxPaddleX) paddleX = maxPaddleX;

    notifyListeners();
  }

  void updateGame() {
    if (!gameStarted || gameTimer == null || isPaused) return;

    // Calculate next position
    double nextX = ballX + ballSpeedX;
    double nextY = ballY + ballSpeedY;

    // Update boundaries with border consideration
    double maxX = (gameAreaWidth / 2) - ballSize - borderWidth;
    double minX = -maxX;
    double maxY = (gameAreaHeight / 2) - ballSize - borderWidth;
    double minY = -maxY;

    // Wall and border collisions with proper bounce
    if (nextX > maxX || nextX < minX) {
      ballSpeedX *= -1;
      nextX = ballX + ballSpeedX;
    }

    // Top border collision
    if (nextY < minY) {
      ballSpeedY *= -1;
      nextY = minY;
    }

    // Bottom game over condition
    if (nextY > maxY) {
      gameStarted = false;
      setupGame();
      return;
    }

    // Update ball position
    ballX = nextX;
    ballY = nextY;

    // Improved paddle collision detection
    final paddleTop = screenHeight * 0.35; // Adjusted paddle position
    final paddleBottom = paddleTop + paddleHeight;
    final paddleLeft = paddleX - paddleWidth / 2;
    final paddleRight = paddleX + paddleWidth / 2;

    // Check for paddle collision with improved accuracy
    if (ballY >= paddleTop - ballSize && ballY <= paddleBottom) {
      if (ballX >= paddleLeft - ballSize / 2 &&
          ballX <= paddleRight + ballSize / 2) {
        // Calculate hit position relative to paddle center (-1 to 1)
        double hitPosition = (ballX - paddleX) / (paddleWidth / 2);

        // Fixed speed bounce
        ballSpeedY = -ballSpeed;
        ballSpeedX = hitPosition * ballSpeed;

        // Place ball above paddle
        ballY = paddleTop - ballSize;

        // Add screen shake effect or sound here if desired
      }
    }

    // Wall collisions with adjusted boundaries
    if (nextX > maxX || nextX < minX) {
      ballSpeedX *= -1;
      nextX = ballX + ballSpeedX;
    }

    // Update ball position
    ballX = nextX;
    ballY = nextY;

    // Game over - more forgiving boundary
    if (ballY > maxY + ballSize) {
      gameStarted = false;
      setupGame();
    }

    // Block collisions
    for (var block in blocks) {
      if (block.isVisible) {
        final blockLeft = block.x - blockWidth / 2;
        final blockRight = block.x + blockWidth / 2;
        final blockTop = block.y - blockHeight / 2;
        final blockBottom = block.y + blockHeight / 2;

        if (checkCollision(
            ballX, ballY, blockLeft, blockRight, blockTop, blockBottom)) {
          block.isVisible = false;
          score += 10;

          // Determine bounce direction
          final overlapX = (block.x - ballX).abs();
          final overlapY = (block.y - ballY).abs();

          if (overlapX > overlapY) {
            ballSpeedX *= -1;
          } else {
            ballSpeedY *= -1;
          }

          break;
        }
      }
    }

    notifyListeners();
  }

  bool checkCollision(double x, double y, double left, double right, double top,
      double bottom) {
    return x >= left && x <= right && y >= top && y <= bottom;
  }

  void updateScreenSize(Size size) {
    screenWidth = size.width;
    screenHeight = size.height;
  }

  @override
  void dispose() {
    // Safely dispose timers
    gameTimer?.cancel();
    clockTimer?.cancel();
    super.dispose();
  }

  // Helper method to format time
  String get formattedTime {
    int minutes = elapsedSeconds ~/ 60;
    int seconds = elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void updateSettings({
    required double ballSpeed,
    required int columns,
    required int rows,
    required double screenWidth,
    required Color backgroundColor,
  }) {
    this.ballSpeed = ballSpeed;
    this.blocksColumns = columns;
    this.blocksRows = rows;
    this.screenWidthPercent = screenWidth;
    this.backgroundColor = backgroundColor;
    backgroundColors[0] = backgroundColor; // Update background color
    backgroundColors[2] = backgroundColor; // Update gradient end color

    // Ensure ball and paddle are within new boundaries
    double maxX = gameAreaWidth * 0.4;
    if (ballX.abs() > maxX) {
      ballX = ballX.sign * maxX;
    }
    if (paddleX.abs() > maxX) {
      paddleX = paddleX.sign * maxX;
    }

    notifyListeners();
    setupGame();
  }

  // Update screen width calculation
  double get effectiveScreenWidth => screenWidth * (screenWidthPercent / 100);

  void pauseGame() {
    isPaused = true;
    notifyListeners();
  }

  void resumeGame() {
    isPaused = false;
    notifyListeners();
  }

  void restartGame() {
    gameStarted = false;
    score = 0;
    elapsedSeconds = 0;
    setupGame();
    notifyListeners();
  }
}
