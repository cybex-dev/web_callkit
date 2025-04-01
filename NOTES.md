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

