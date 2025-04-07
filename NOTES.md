# Notes

The plugin is intended to be used as a boilerplate for call management and not as a full-fledged voip solution. The plugin facilitates handling of calls via a simple API and provides a browser call control mechanism through browser notifications. 

_Thus, core features such as audio handling, RTC/SIP connections, websocket communication, etc. are not provided by the plugin and should be handled via 3rd party resources._

Core tenets of the plugin:
1. Transparency: the user should at all times be aware of any call on their device.
2. Accessibility: the user should be able to interact with the call in any state.
3. (Future work) flexibility within the Callkit structure.

Future work may include:
- Integration with RTC/SIP connections
- Websocket communication
- Audio & VIDEO handling
- Integration with native callkit frameworks

### Regarding imports

So, this is a tricky one I hope to resolve soon. For now, one should use the web_callkit_web.dart import instead of the web_callkit.dart import. 

This is because the web_callkit.dart import is a stub for the web_callkit_web.dart import. This is due to multiple instances are created when calling `WebCallKit.instance` in a web OS environment. Even though a `WebCallKitWeb` object is created and registered with the plugin, it seems the Flutter still prefers the MethodChannel file filled with stubs.

If you have a solution for this, please let me know. I would love to hear it or submit a PR addressing the issue. Note, the issue crops up in child dependencies of the plugin, e.g. [twilio_voice](https://pub.dev/packages/twilio_voice) but is not found in the example project.
