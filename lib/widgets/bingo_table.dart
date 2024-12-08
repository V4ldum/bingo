import 'package:bingo/models/bingo.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BingoTable extends StatelessWidget {
  const BingoTable({
    required this.bingo,
    required this.itemBuilder,
    this.cellPadding = const EdgeInsets.all(8),
    this.onCellTapped,
    super.key,
  });

  final Bingo bingo;
  final Widget Function(int) itemBuilder;
  final EdgeInsets cellPadding;
  final void Function(int)? onCellTapped;

  @override
  Widget build(BuildContext context) {
    const tableSize = 750.0;

    return Table(
      border: TableBorder.all(
        color: ShadTheme.of(context).colorScheme.border,
      ),
      columnWidths: Map.fromEntries(
        List.generate(bingo.size, (index) => MapEntry(index, FixedColumnWidth(tableSize / bingo.size))),
      ),
      children: List.generate(
        bingo.size,
        (rowIndex) => TableRow(
          children: List.generate(
            bingo.size,
            (columnIndex) {
              final currentIndex = (rowIndex * bingo.size) + columnIndex;

              return SizedBox.square(
                dimension: tableSize / bingo.size,
                child: GestureDetector(
                  onTap: () => onCellTapped?.call(currentIndex),
                  child: ColoredBox(
                    color: ShadTheme.of(context).colorScheme.primary,
                    child: Padding(
                      padding: cellPadding,
                      child: Center(
                        child: itemBuilder(currentIndex),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
