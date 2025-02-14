import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DataGridWidget extends StatefulWidget {
  final Set<String> dataKeys;
  final Set<String> metadataKeys;
  final Map<String, String> currentData;
  final Function(Map<String, String> updatedData) onDataToggle;
  final Function(Map<String, String> updatedMetadata) onMetaToggle;

  const DataGridWidget({
    required this.dataKeys,
    required this.metadataKeys,
    required this.currentData,
    required this.onDataToggle,
    required this.onMetaToggle,
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _DataGridWidgetState createState() => _DataGridWidgetState();
}

class _DataGridWidgetState extends State<DataGridWidget> {
  late List<MapEntry<String, String>> rows;
  late Set<String> dataChecked;
  late Set<String> metadataChecked;

  @override
  void initState() {
    super.initState();
    rows = widget.currentData.entries.toList();
    dataChecked = widget.dataKeys;
    metadataChecked = widget.metadataKeys;
  }

  void _addRow() {
    setState(() {
      rows.add(const MapEntry("", ""));
    });
  }

  void _removeRow(int index) {
    setState(() {
      rows.removeAt(index);
      _notifyChanges();
    });
  }

  void _onKeyChanged(int index, String newKey) {
    setState(() {
      rows[index] = MapEntry(newKey, rows[index].value);
      _notifyChanges();
    });
  }

  void _onValueChanged(int index, String newValue) {
    setState(() {
      rows[index] = MapEntry(rows[index].key, newValue);
      _notifyChanges();
    });
  }

  void _notifyChanges() {
    dataChecked =
        dataChecked.where((key) => rows.any((row) => row.key == key)).toSet();
    metadataChecked = metadataChecked
        .where((key) => rows.any((row) => row.key == key))
        .toSet();
    final updatedData = rows.fold<Map<String, String>>(
      {},
      (previousValue, element) => {
        ...previousValue,
        if (dataChecked.contains(element.key)) element.key: element.value,
      },
    );
    final updatedMetadata = rows.fold<Map<String, String>>(
      {},
      (previousValue, element) => {
        ...previousValue,
        if (metadataChecked.contains(element.key)) element.key: element.value,
      },
    );
    widget.onDataToggle(updatedData);
    widget.onMetaToggle(updatedMetadata);
  }

  @override
  Widget build(BuildContext context) {
    const constraints = BoxConstraints(minWidth: 100);
    return DataTable(
      columns: const [
        DataColumn(label: Text('Key')),
        DataColumn(label: Text('Value')),
        DataColumn(label: Text('Data')),
        DataColumn(label: Text('Metadata')),
      ],
      rows: List.generate(rows.length + 1, (index) {
        if (index == rows.length) {
          return DataRow(
            cells: [
              _buildDataCell(
                TextField(
                  decoration: const InputDecoration(
                      hintText: 'New Key', border: InputBorder.none),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _addRow();
                      _onKeyChanged(index, value);
                    }
                  },
                ),
                constraints: constraints,
              ),
              _buildDataCell(
                const SizedBox(),
                constraints: constraints,
              ),
              _buildDataCell(
                const SizedBox(),
                constraints: constraints,
              ),
              _buildDataCell(
                const SizedBox(),
                constraints: constraints,
              ),
            ],
          );
        }
        return DataRow(
          cells: [
            _buildDataCell(
              _TextField(
                value: rows[index].key,
                onChanged: (value) => _onKeyChanged(index, value),
                onSubmitted: (value) {
                  if (value.isEmpty) {
                    _removeRow(index);
                  }
                },
                hintText: 'Key',
                onFocusChanged: (hasFocus) {
                  if (!hasFocus && rows[index].key.isEmpty) {
                    _removeRow(index);
                  }
                },
                onBackspace: (value) {
                  if (value.isEmpty) {
                    _removeRow(index);
                  }
                },
              ),
              constraints: constraints,
            ),
            _buildDataCell(
              _TextField(
                value: rows[index].value,
                onChanged: (value) => _onValueChanged(index, value),
                hintText: 'Value',
              ),
              constraints: constraints,
            ),
            _buildDataCell(
              Checkbox(
                value: dataChecked.contains(rows[index].key),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      dataChecked.add(rows[index].key);
                    } else {
                      dataChecked.remove(rows[index].key);
                    }
                    _notifyChanges();
                  });
                },
              ),
            ),
            _buildDataCell(
              Checkbox(
                value: metadataChecked.contains(rows[index].key),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      metadataChecked.add(rows[index].key);
                    } else {
                      metadataChecked.remove(rows[index].key);
                    }
                    _notifyChanges();
                  });
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  DataCell _buildDataCell(Widget child, {BoxConstraints? constraints}) {
    return DataCell(
      Container(
        constraints: constraints,
        child: child,
      ),
    );
  }
}

class _TextField extends StatefulWidget {
  final String value;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? hintText;
  final ValueChanged? onFocusChanged;
  final ValueChanged<String>? onBackspace;

  const _TextField({
    // ignore: unused_element
    super.key,
    this.onChanged,
    this.onSubmitted,
    required this.value,
    this.hintText,
    this.onFocusChanged,
    this.onBackspace,
  });

  @override
  State<_TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<_TextField> {
  late FocusNode focusNode;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode(
      onKeyEvent: _onKeyEvent,
    )..addListener(_onFocusChanged);
    controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _TextField oldWidget) {
    controller.value = controller.value.copyWith(text: widget.value);
    super.didUpdateWidget(oldWidget);
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      widget.onBackspace?.call(controller.text);
    }
    return KeyEventResult.ignored;
  }

  void _onFocusChanged() {
    widget.onFocusChanged?.call(focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      controller: controller,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: widget.hintText,
      ),
    );
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }
}
