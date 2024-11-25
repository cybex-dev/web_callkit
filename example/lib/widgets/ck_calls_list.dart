import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_callkit/web_callkit.dart';
import 'package:web_callkit/web_callkit_web.dart';
import 'package:web_callkit_example/theme.dart';
import 'package:web_callkit_example/widgets/ck_card.dart';

import 'ck_call_widget.dart';

class CKCallsList extends StatefulWidget {
  const CKCallsList({super.key});

  @override
  State<CKCallsList> createState() => _CKCallsListState();
}

class _CKCallsListState extends State<CKCallsList> {
  List<CKCall> _calls = [];
  late StreamSubscription<Iterable<CKCall>> _streamSubscription;
  final webCallkitPlugin = WebCallkit.instance;

  @override
  void initState() {
    super.initState();
    _streamSubscription = webCallkitPlugin.callStream.listen((event) {
      setState(() {
        _calls.clear();
        _calls = event.toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CKCard(
      title: const Text("Active Calls", style: headerTextStyle),
      child: ListView.builder(
        itemBuilder: (context, index) => CKCallWidget(call: _calls[index]),
        itemCount: _calls.length,
        shrinkWrap: true,
      ),
    );
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}
