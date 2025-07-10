import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppTable<T> extends StatelessWidget {
  const AppTable({super.key, required this.items, required this.columns, this.maxWidth = 1280});

  final List<T> items;
  final List<AppTableColumn<T>> columns;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          child: Material(
            color: Colors.white,
            child: Table(
              columnWidths: Map.fromEntries(
                  columns.where((c) => c.width != null).map((c) => MapEntry(columns.indexOf(c), c.width!))
              ),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.blue.withAlpha(50)),
                  children: [
                    for (final c in columns)
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            c.title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
                for (final i in items)
                  TableRow(
                    children: [for (final c in columns) TableCell(child: c.builder(i))],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

abstract class AppTableColumn<T> {
  AppTableColumn({required this.title, this.width});

  final String title;
  final TableColumnWidth? width;

  Widget builder(T item);
}

class AppTableColumnString<T> extends AppTableColumn<T> {
  AppTableColumnString({
    required super.title,
    required this.dataSelector,
    super.width,
  });

  final String Function(T) dataSelector;

  @override
  Widget builder(T item) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(dataSelector(item)),
    );
  }
}

class AppTableColumnMoney<T> extends AppTableColumn<T> {
  AppTableColumnMoney({
    required super.title,
    required this.dataSelector,
    super.width,
  });

  final int Function(T) dataSelector;

  @override
  Widget builder(T item) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(NumberFormat.simpleCurrency(locale: 'pt-BR')
          .format(dataSelector(item) / 100)),
    );
  }
}

class AppTableColumnWidget<T> extends AppTableColumn<T> {
  AppTableColumnWidget({
    required super.title,
    required this.dataSelector,
    super.width,
  });

  final Widget Function(T) dataSelector;

  @override
  Widget builder(T item) {
    return dataSelector(item);
  }
}

class AppTableColumnImage<T> extends AppTableColumn<T> {
  AppTableColumnImage({
    required super.title,
    required this.dataSelector,
    super.width,
  });

  final String Function(T) dataSelector;

  @override
  Widget builder(T item) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Image.network(dataSelector(item), fit: BoxFit.cover, width: 100),
    );
  }
}

class AppTableColumnDateTime<T> extends AppTableColumn<T> {
  AppTableColumnDateTime({
    required super.title,
    required this.dataSelector,
    super.width,
  });

  final DateTime Function(T) dataSelector;

  @override
  Widget builder(T item) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(DateFormat('dd/MM/yyyy HH:mm').format(dataSelector(item))),
    );
  }
}