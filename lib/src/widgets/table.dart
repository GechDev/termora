import 'dart:math' as math;

import '../core/build_context.dart';
import '../core/key.dart';
import '../core/widget.dart';
import '../layout/edge_insets.dart';
import '../layout/flex_layout.dart';
import '../rendering/unicode_width.dart';
import '../style/border.dart';
import '../style/color.dart';
import '../style/modifier.dart';
import '../style/style.dart';
import 'basic.dart';
import 'container.dart';
import 'flex.dart';
import 'flexible.dart';

/// Alignment options for table cell text.
enum TableCellAlignment {
  left,
  center,
  right,
}

/// Definition for a column in a [Table].
class TableColumn {
  final String title;
  final int? width;
  final TableCellAlignment alignment;

  const TableColumn({
    required this.title,
    this.width,
    this.alignment = TableCellAlignment.left,
  });
}

/// An individual cell in a [Table].
class TableCell {
  final Widget child;
  final TableCellAlignment alignment;

  TableCell({
    required this.child,
    this.alignment = TableCellAlignment.left,
  });

  TableCell.text(
    String text, {
    Style? style,
    this.alignment = TableCellAlignment.left,
  }) : child = Text(text, style: style ?? const Style());
}

/// A row of cells in a [Table].
class TableRow {
  final List<TableCell> cells;
  final Style? style;

  const TableRow({
    required this.cells,
    this.style,
  });

  factory TableRow.fromStrings(List<String> values, {Style? style}) {
    return TableRow(
      cells: values.map((v) => TableCell.text(v, style: style)).toList(),
      style: style,
    );
  }
}

/// A flexible grid table widget with borders, headers, and column auto-sizing.
class Table extends StatelessWidget {
  final List<TableColumn> columns;
  final List<TableRow> rows;
  final Border? border;
  final Style? headerStyle;
  final Style? rowStyle;
  final Style? alternateRowStyle;
  final bool showHeader;
  final bool showHorizontalDividers;

  const Table({
    super.key,
    required this.columns,
    required this.rows,
    this.border,
    this.headerStyle,
    this.rowStyle,
    this.alternateRowStyle,
    this.showHeader = true,
    this.showHorizontalDividers = true,
  });

  factory Table.fromStrings({
    Key? key,
    required List<String> headers,
    required List<List<String>> data,
    Border? border,
    Style? headerStyle,
    Style? rowStyle,
    Style? alternateRowStyle,
    bool showHeader = true,
    bool showHorizontalDividers = true,
    List<TableCellAlignment>? alignments,
  }) {
    final cols = <TableColumn>[];
    for (var i = 0; i < headers.length; i++) {
      cols.add(
        TableColumn(
          title: headers[i],
          alignment: (alignments != null && i < alignments.length)
              ? alignments[i]
              : TableCellAlignment.left,
        ),
      );
    }

    final tableRows = data.map((row) => TableRow.fromStrings(row)).toList();

    return Table(
      key: key,
      columns: cols,
      rows: tableRows,
      border: border,
      headerStyle: headerStyle,
      rowStyle: rowStyle,
      alternateRowStyle: alternateRowStyle,
      showHeader: showHeader,
      showHorizontalDividers: showHorizontalDividers,
    );
  }

  List<int> _calculateColumnWidths() {
    final colCount = columns.length;
    final widths = List<int>.filled(colCount, 0);

    for (var i = 0; i < colCount; i++) {
      if (columns[i].width != null) {
        widths[i] = columns[i].width!;
      } else {
        var maxLen = UnicodeWidth.stringWidth(columns[i].title);
        for (final row in rows) {
          if (i < row.cells.length) {
            final cell = row.cells[i];
            if (cell.child is Text) {
              final len = UnicodeWidth.stringWidth((cell.child as Text).data);
              maxLen = math.max(maxLen, len);
            }
          }
        }
        widths[i] = math.max(maxLen, 3);
      }
    }

    return widths;
  }

  @override
  Widget build(BuildContext context) {
    final widths = _calculateColumnWidths();
    final colCount = columns.length;

    final children = <Widget>[];

    // Header row
    if (showHeader) {
      final headerCells = <Widget>[];
      for (var i = 0; i < colCount; i++) {
        final col = columns[i];
        final colWidth = widths[i];
        final effectiveHeaderStyle = headerStyle ??
            const Style(
              foregroundColor: Color.brightCyan,
              modifiers: {TextModifier.bold},
            );

        headerCells.add(
          SizedBox(
            width: colWidth + 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Text(col.title, style: effectiveHeaderStyle),
            ),
          ),
        );

        if (i < colCount - 1) {
          headerCells.add(
            const Text('│', style: Style(foregroundColor: Color.brightBlack)),
          );
        }
      }

      children.add(Row(children: headerCells));

      // Divider below header
      final dividerSpans = <Widget>[];
      for (var i = 0; i < colCount; i++) {
        dividerSpans.add(
          Text('─' * (widths[i] + 2),
              style: const Style(foregroundColor: Color.brightBlack)),
        );
        if (i < colCount - 1) {
          dividerSpans.add(
            const Text('┼', style: Style(foregroundColor: Color.brightBlack)),
          );
        }
      }
      children.add(Row(children: dividerSpans));
    }

    // Data rows
    for (var r = 0; r < rows.length; r++) {
      final row = rows[r];
      final isAlternate = r % 2 == 1;
      final currentStyle = row.style ??
          (isAlternate ? (alternateRowStyle ?? rowStyle) : rowStyle);

      final rowCells = <Widget>[];
      for (var i = 0; i < colCount; i++) {
        final colWidth = widths[i];
        final TableCell cell =
            i < row.cells.length ? row.cells[i] : TableCell.text('');

        Widget cellContent = cell.child;
        if (cellContent is Text && currentStyle != null) {
          cellContent = Text(cellContent.data, style: currentStyle);
        }

        rowCells.add(
          SizedBox(
            width: colWidth + 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: cellContent,
            ),
          ),
        );

        if (i < colCount - 1) {
          rowCells.add(
            const Text('│', style: Style(foregroundColor: Color.brightBlack)),
          );
        }
      }

      children.add(Row(children: rowCells));

      if (showHorizontalDividers && r < rows.length - 1) {
        final dividerSpans = <Widget>[];
        for (var i = 0; i < colCount; i++) {
          dividerSpans.add(
            Text('─' * (widths[i] + 2),
                style: const Style(foregroundColor: Color.brightBlack)),
          );
          if (i < colCount - 1) {
            dividerSpans.add(
              const Text('┼', style: Style(foregroundColor: Color.brightBlack)),
            );
          }
        }
        children.add(Row(children: dividerSpans));
      }
    }

    return Container(
      border: border ??
          const Border.rounded(
            Style(foregroundColor: Color.brightBlack),
          ),
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
