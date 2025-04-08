# web_callkit

**This project is a Web Flutter plugin that facilitates handling of calls.**

Inspired by the iOS CallKit framework, this plugin provides the boilerplate to manage calls via a
simple API and provides a browser call control mechanism through browser notifications.

### Notes

Due to many voip providers e.g. twilio-voice.js providing their own SDKs and audio handling (
incoming ringing, etc), this plugin is intended to be used as a boilerplate for call management and
not as a full-fledged voip solution.

A bird's eye overview/usage of the plugin:

- Notify callkit of an incoming call
- Update state of call from VOIP/SIP provider
- Add/update call capabilities (hold, mute, etc)

## Features

- Boilerplate for call management
- Integration with browser notifications
- Support background calls
- Custom audio sounds for incoming calls, etc.

### Call State flow

The following describes the standard call flow expected of the `CallState` enum.

![](https://raw.githubusercontent.com/cybex-dev/web_callkit/refs/heads/master/doc/images/callflow.png)

## Limitations

### Browser notifications

Use native browser integration, the following limitations apply to each platform. Usage of Flutter
package [js_notifications](https://pub.dev/packages/js_notifications) is assist in browser
notification integration to native systems.
See [js_notifications > platform limitations](https://github.com/cybex-dev/js_notifications?tab=readme-ov-file#platform-limitations)
for more information

## Installation

### Import the package

```dart
import 'package:web_callkit/web_callkit_web.dart';
```

### Display the system call screen

Inform the plugin that an incoming call is being received. This will hook into the browser
notification system.

```dart
WebCallKitWeb.instance.displayIncomingCall(uuid: '1234',handle: 'John Doe',);
```

### End the call

End the call by calling the `endCall` method. This will remove the call screen and stop the browser
notification. Calls are disconnected for various reasons, via local user requests or remote errors
or disconnects with VoIP calls due to internet disruptions.

The CallKit supports `DisconnectResponse` enum to specify the reason for the call disconnection.

e.g. `WebCallKitWeb.instance.reportCallDisconnected('1234', response: DisconnectResponse.local);`

| Reason   | Description                                                                           |
|----------|---------------------------------------------------------------------------------------|
| local    | Disconnect due to a local end call request.                                           |
| remote   | Disconnect due to a remote end call request or remote party failed to answer in time. |
| canceled | Disconnect due to a call was cancelled.                                               |
| missed   | Disconnect due to a incoming call was not answered in time.                           |
| rejected | Disconnect due to incoming call was rejected.                                         |
| busy     | Disconnect due to remote party being busy.                                            |
| error    | Disconnect due to an error.                                                           |
| unknown  | Disconnect response is unknown.                                                       |

### Features

#### Call Management

CallKit provides a simple API to manage calls. The plugin provides methods to report incoming calls,
end calls, and update call information. Futher, inspiration is taken from Android's
ConnectionService providing a set of capabilities to manage calls:

##### Incoming Calls

Incoming calls are displayed on the screen with the caller's name and number. The call screen can be
customized with the caller's name, number, and profile picture.

```dart
WebCallKitWeb.instance.reportNewCall(uuid: '1234', handle: 'John Doe',);
```

##### End Calls

End calls by calling the `endCall` method. This will remove the call screen and stop the browser
notification.

```dart
WebCallKitWeb.instance.reportCallDisconnected('1234', response:DisconnectResponse.local);
```

The response parameter is an enum of `DisconnectResponse` which specifies the reason for the call
disconnection. Due to the CallKit's nature, the call can be disconnected for various reasons,
such as local user requests, remote errors, or disconnects with VoIP calls due to internet
disruptions.
`DisconnectReseponse`s are limited call states, for example an Call with an `initiated` state
cannot be ended with a decline.

The following described scenarios are valid DisconnectResponses for specific call states:

| `CallState`   | `DisconnectResponse`                                     |
|---------------|----------------------------------------------------------|
| initiated     | local, remote, canceled, rejected, busy, unknown, error, |
| ringing       | remote, missed, rejected, busy, unknown, error,          |
| dialing       | local, rejected, busy, unknown, error,                   |
| active        | local, remote, unknown, error,                           |
| reconnecting  | local, remote, unknown, error,                           |
| disconnecting | local, remote, unknown, error,                           |
| disconnected  | local, remote, unknown, error,                           |

if `strictMode` is enabled, the following valid `DisconnectResponse`s will be considered, else it will be rejected (and potentially thrown) in a future update.

#### Notification Integration

t.b.c.

#### Capabilities

CallKit provides a set of capabilities to manage calls. These capabilities provide the ability for
features to be limited based on developer/user requirements.

The following describes the capabilities available:

| Reason      | Description                                                 |
|-------------|-------------------------------------------------------------|
| hold        | Ability to place a call on hold after the call has started. |
| supportHold | Ability to place a call on hold from the start of the call. |
| mute        | Ability to mute a call.                                     |
| video       | Ability to stream/support video or screenshare streaming.   |
| silence     | Ability to silence an incoming call.                        |

The following provides an example of how to report call capabilities:

```dart
WebCallKitWeb.instance.reportCallCapabilities('1234', capabilities: [CallCapability.hold, CallCapability.mute]);
```

#### Call Actions

CallKit provides a set of actions to manage calls. These actions provide the ability for features to
manage calls from the notification tray.

The following describes the actions available:

| Action            | Description                                                                                                             |
|-------------------|-------------------------------------------------------------------------------------------------------------------------|
| none              | No action                                                                                                               |
| answer            | Answer & accept call intent.                                                                                            |
| decline           | Declining call intent.                                                                                                  |
| hangUp            | Ending a call regardless of state.                                                                                      |
| dismiss           | Dismiss a notification.                                                                                                 |
| callback          | Callback intent.                                                                                                        |
| switchVideo       | Switching to video call intent subject to [CallKitCapability.switchVideo] capability.                                   |
| switchAudio       | Switching to audio call intent, opposite of [switchVideo] and [switchScreenShare].                                      |
| switchScreenShare | Switching to screen-share call intent, adjacent to [switchVideo] subject to [CallKitCapability.screenShare] capability. |
| mute              | Muting a call intent subject to [CallKitCapability.mute] capability.                                                    |
| unmute            | Unmuting a call intent, opposite of [mute].                                                                             |
| hold              | Holding a call intent subject to [CallKitCapability.supportHold] or [CallKitCapability.hold] capability.                |
| unhold            | Unholding a call intent, opposite of [hold].                                                                            |
| silence           | Silencing an incoming call intent                                                                                       |
| disableVideo      | Disabling video (on a call with video/screen share) intent                                                              |
| enableVideo       | Enabling video (on a call with video/screen share) intent                                                               |

