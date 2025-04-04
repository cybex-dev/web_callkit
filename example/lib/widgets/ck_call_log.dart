import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_callkit/web_callkit.dart';
import 'package:web_callkit_example/widgets/ck_card.dart';

typedef CallLogWidgetBuilder = Widget Function(BuildContext context, CKCallEvent event);

class CKCallLog extends StatefulWidget {
  final CallLogWidgetBuilder? builder;

  static CallLogWidgetBuilder get defaultBuilder {
    return (context, event) {
      final icon = switch (event.type) {
        CKCallEventType.add => Icons.add,
        CKCallEventType.update => Icons.refresh,
        CKCallEventType.remove => Icons.remove,
      };
      return Row(
        children: [
          Text(event.timestamp.toString(),
              style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Icon(icon),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              event.call.toString(),
              style: const TextStyle(fontSize: 12),
            ),
          )
        ],
      );
    };
  }

  const CKCallLog({super.key, this.builder});

  @override
  State<CKCallLog> createState() => _CKCallLogState();
}

class _CKCallLogState extends State<CKCallLog> {
  final controller = ScrollController();
  final List<CKCallEvent> log = [];
  late final StreamSubscription<CKCallEvent> subscription;
  final webCallkitPlugin = WebCallkit.instance;

  @override
  void initState() {
    super.initState();
    subscription = webCallkitPlugin.eventStream.listen((event) {
      setState(() {
        log.add(event);
      });
      controller.jumpTo(controller.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final logBuilder = widget.builder ?? CKCallLog.defaultBuilder;

    return CKCard(
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.delete),
          label: const Text("Clear"),
          onPressed: () {
            setState(() {
              log.clear();
            });
          },
        ),
      ],
      child: Expanded(
        child: ListView(
          controller: controller,
          shrinkWrap: true,
          children: log.map((e) => logBuilder(context, e)).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}
