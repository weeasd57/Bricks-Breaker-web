import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/game_provider.dart';

class SettingsDialog extends StatefulWidget {
  final GameProvider gameProvider;

  const SettingsDialog({super.key, required this.gameProvider});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late double ballSpeed;
  late int columns;
  late int rows;
  late double screenWidth;
  late Color backgroundColor;

  @override
  void initState() {
    super.initState();
    ballSpeed = widget.gameProvider.ballSpeed;
    columns = widget.gameProvider.blocksColumns;
    rows = widget.gameProvider.blocksRows;
    screenWidth = widget.gameProvider.screenWidthPercent;
    backgroundColor = widget.gameProvider.backgroundColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Game Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Ball Speed'),
              subtitle: Slider(
                value: ballSpeed,
                min: 2.0,
                max: 8.0,
                divisions: 6,
                label: ballSpeed.toStringAsFixed(1),
                onChanged: (value) => setState(() => ballSpeed = value),
              ),
            ),
            ListTile(
              title: const Text('Screen Width %'),
              subtitle: Slider(
                value: screenWidth,
                min: 50,
                max: 100,
                divisions: 5,
                label: screenWidth.round().toString(),
                onChanged: (value) => setState(() => screenWidth = value),
              ),
            ),
            ListTile(
              title: const Text('Blocks Columns'),
              subtitle: Slider(
                value: columns.toDouble(),
                min: 4,
                max: 12,
                divisions: 8,
                label: columns.toString(),
                onChanged: (value) => setState(() => columns = value.round()),
              ),
            ),
            ListTile(
              title: const Text('Blocks Rows'),
              subtitle: Slider(
                value: rows.toDouble(),
                min: 3,
                max: 8,
                divisions: 5,
                label: rows.toString(),
                onChanged: (value) => setState(() => rows = value.round()),
              ),
            ),
            ListTile(
              title: const Text('Background Color'),
              trailing: CircleAvatar(
                backgroundColor: backgroundColor,
                child: IconButton(
                  icon: const Icon(Icons.color_lens),
                  onPressed: () => _showColorPicker(),
                ),
              ),
            ),
            ListTile(
              title: const Text('Border Color'),
              trailing: CircleAvatar(
                backgroundColor: widget.gameProvider.borderColor,
                child: IconButton(
                  icon: const Icon(Icons.border_color),
                  onPressed: () => _showColorPicker(isBorder: true),
                ),
              ),
            ),
            ListTile(
              title: const Text('Border Width'),
              subtitle: Slider(
                value: widget.gameProvider.borderWidth,
                min: 1.0,
                max: 5.0,
                divisions: 4,
                label: widget.gameProvider.borderWidth.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    widget.gameProvider.borderWidth = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.gameProvider.updateSettings(
              ballSpeed: ballSpeed,
              columns: columns,
              rows: rows,
              screenWidth: screenWidth,
              backgroundColor: backgroundColor,
            );
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  void _showColorPicker({bool isBorder = false}) {
    Color currentColor =
        isBorder ? widget.gameProvider.borderColor : backgroundColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pick ${isBorder ? 'Border' : 'Background'} Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (color) {
              setState(() {
                if (isBorder) {
                  widget.gameProvider.borderColor = color;
                } else {
                  backgroundColor = color;
                }
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
