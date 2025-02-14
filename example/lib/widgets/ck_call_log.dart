import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_callkit/web_callkit.dart';
import 'package:web_callkit_example/widgets/ck_card.dart';

typedef CallLogWidgetBuilder = Widget Function(
    BuildContext context, CallEvent event);

class CKCallLog extends StatefulWidget {
  final CallLogWidgetBuilder builder;

  static CallLogWidgetBuilder get defaultBuilder {
    return (context, event) {
      final icon = switch (event.type) {
        CallEventType.add => Icons.add,
        CallEventType.update => Icons.refresh,
        CallEventType.remove => Icons.remove,
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

  const CKCallLog({super.key, required this.builder});

  @override
  State<CKCallLog> createState() => _CKCallLogState();
}

class _CKCallLogState extends State<CKCallLog> {
  final controller = ScrollController();
  final List<CallEvent> log = [];
  late final StreamSubscription<CallEvent> subscription;
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
          children: log.map((e) => widget.builder(context, e)).toList(),
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
