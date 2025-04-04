import 'package:web_callkit/src/method_channel/web_callkit_method_channel.dart';

import 'src/platform_interface/web_callkit_platform_interface.dart';

export 'src/src.dart';

class WebCallkit extends MethodChannelWebCallkit {
  static WebCallkitPlatform get instance => WebCallkitPlatform.instance;
}
