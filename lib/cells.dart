import 'package:flutter/material.dart';
import 'package:sockets/model/model.dart';

import '../../assets.dart';

class CellView extends StatelessWidget {
  final Cell cell;
  final VoidCallback onClick;
  final VoidCallback onLongPress;

  const CellView({
    super.key,
    required this.cell,
    required this.onClick,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      onLongPress: onLongPress,
      child: Image.asset(_imageForCell(cell)),
    );
  }

  String _imageForCell(Cell cell) {
    if (cell is CellClose) {
      return cell.isFlagged ? Assets.cellFlagged : Assets.cellClosed;
    } else {
      return Assets.openedCells[cell.content.index];
    }
  }
}