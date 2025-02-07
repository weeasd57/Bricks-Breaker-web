import 'package:flutter/material.dart';

class GameSettings {
  double ballSpeed;
  int blocksColumns;
  int blocksRows;
  Color backgroundColor;
  double screenWidthPercent;

  GameSettings({
    this.ballSpeed = 4.0,
    this.blocksColumns = 8,
    this.blocksRows = 5,
    this.backgroundColor = Colors.black,
    this.screenWidthPercent = 100,
  });
}
