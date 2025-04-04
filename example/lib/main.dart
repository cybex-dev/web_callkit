import 'package:flutter/material.dart';

import 'package:web_callkit/web_callkit.dart';

import 'screens/home_screen.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    final webCallkitPlugin = WebCallkit.instance;
    webCallkitPlugin.setConfiguration(const CKConfiguration());
    webCallkitPlugin.setOnCallActionHandler((uuid, action, source) {
      // ignore: avoid_print
      print("onCallActionHandler: $uuid, $action, $source");
      if (action == CallAction.answer) {
        webCallkitPlugin.updateCallStatus(uuid, callStatus: CallState.active);
      } else if (action == CKCallAction.decline) {
        webCallkitPlugin.reportCallDisconnected(uuid,
            response: DisconnectResponse.declined);
      }
    });
    webCallkitPlugin.setOnCallEventListener((event, source) {
      // ignore: avoid_print
      print("onCallEventListener: $event, $source");
    });
    webCallkitPlugin.setOnCallTypeChangeListener((event, callType, source) {
      // ignore: avoid_print
      webCallkitPlugin.updateCallType(event.uuid, callType: callType);
    });
    webCallkitPlugin.setOnDisconnectListener((uuid, response, source) {
      // ignore: avoid_print
      webCallkitPlugin.reportCallDisconnected(uuid, response: response);
      // webCallkitPlugin.updateCallStatus(uuid, callStatus: CallState.disconnected);
    });
    webCallkitPlugin.setOnDismissedListener((uuid, source) {
      final call = webCallkitPlugin.getCall(uuid);
      if (call != null) {
        webCallkitPlugin.renotify(call.uuid, silent: true);
      }
    });
    // webCallkitPlugin.setOnActionAnswered((uuid, call, source) {
    //   printDebug("onActionAnswered: $uuid, $call, $source");
    //   webCallkitPlugin.updateCallStatus(uuid, callStatus: CallState.active);
    // });
    // webCallkitPlugin.setOnActionHangup((uuid, call, source, response) {
    //   printDebug("onActionHangup: $uuid, $call, $source, $response");
    //   webCallkitPlugin.reportCallDisconnected(uuid, response: response);
    // });
    // webCallkitPlugin.setOnActionDecline((uuid, call, source, response) {
    //   printDebug("onActionDecline: $uuid, $call, $source, $response");
    //   webCallkitPlugin.reportCallDisconnected(uuid, response: response);
    // });
    // webCallkitPlugin.setOnActionCallback((uuid, call, source) {
    //   printDebug("onActionCallback: $uuid, $call, $source");
    //   webCallkitPlugin.reportNewCall(
    //     uuid: uuid,
    //     handle: call.localizedName,
    //     data: call.data,
    //     attributes: call.attributes,
    //     capabilities: call.capabilities,
    //   );
    // });
    // webCallkitPlugin.setOnActionDismiss((uuid, call, source) {
    //   printDebug("onActionDismiss: $uuid, $call, $source");
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: getThemeData(context),
      home: const HomeScreen(),
    );
  }
}
