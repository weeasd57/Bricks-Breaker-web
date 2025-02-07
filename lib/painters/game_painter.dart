import 'package:flutter/material.dart';
import '../providers/game_provider.dart';

class GamePainter extends CustomPainter {
  final GameProvider gameProvider;
  final Size screenSize;

  GamePainter(this.gameProvider, this.screenSize);

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate game area
    final gameWidth = gameProvider.gameAreaWidth;
    final gameHeight = size.height;
    final gameX = (size.width - gameWidth) / 2;

    // Draw full screen background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black,
    );

    // Clip to game area
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(gameX, 0, gameWidth, gameHeight));

    // Draw game background
    canvas.drawRect(
      Rect.fromLTWH(gameX, 0, gameWidth, gameHeight),
      Paint()..color = gameProvider.backgroundColor,
    );

    // Update center point for game objects
    final centerX = gameX + gameWidth / 2;
    final centerY = gameHeight / 2;

    // Draw blocks with smaller shadow
    for (var block in gameProvider.blocks) {
      if (block.isVisible) {
        // Smaller shadow offset
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(
              centerX + block.x,
              centerY + block.y + 1, // Reduced shadow offset
            ),
            width: gameProvider.blockWidth,
            height: gameProvider.blockHeight,
          ),
          Paint()..color = Colors.black.withOpacity(0.3), // Lighter shadow
        );

        // Draw block with rounded corners
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(centerX + block.x, centerY + block.y),
              width: gameProvider.blockWidth,
              height: gameProvider.blockHeight,
            ),
            Radius.circular(gameProvider.baseSize * 0.5), // Smaller radius
          ),
          Paint()..color = block.color,
        );
      }
    }

    // Ball with smaller glow
    final ballPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 1); // Reduced glow

    canvas.drawCircle(
      Offset(
        centerX + gameProvider.ballX,
        centerY + gameProvider.ballY,
      ),
      gameProvider.ballSize / 2, // Divide by 2 for actual ball size
      ballPaint,
    );

    // Paddle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(
            centerX + gameProvider.paddleX,
            size.height - gameProvider.baseSize * 10, // 10 units from bottom
          ),
          width: gameProvider.paddleWidth,
          height: gameProvider.paddleHeight,
        ),
        Radius.circular(gameProvider.baseSize),
      ),
      Paint()..color = Colors.blue,
    );

    canvas.restore();

    // Draw border on top
    canvas.drawRect(
      Rect.fromLTWH(gameX, 0, gameWidth, gameHeight),
      Paint()
        ..color = gameProvider.borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = gameProvider.borderWidth,
    );
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) => true;
}
