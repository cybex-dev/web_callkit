// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web_callkit/src/managers/managers.dart';

import 'src/method_channel/web_callkit_method_channel.dart';
import 'src/platform_interface/web_callkit_platform_interface.dart';

export './src/core/enums/enums.dart';

/// A web implementation of the WebCallkitPlatform of the WebCallkit plugin.
class WebCallkitWeb extends MethodChannelWebCallkit {
  WebCallkitWeb({super.configuration}) : super(notificationManager: NotificationManagerImplWeb());

  static void registerWith(Registrar registrar) {
    WebCallkitPlatform.instance = WebCallkitWeb();
  }
}
