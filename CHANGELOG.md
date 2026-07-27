## Unreleased

* Add missing return type of `CKNotificationDirection.fromJs`.
* Update docs

## 1.0.0

* Removed requirement to copy service worker to web folder. Now it is bundled with the package and registered automatically. See [README.md](README.md#service-worker) for more information.
* **BREAKING**: Added WASM support from [js_notifications](https://pub.dev/packages/js_notifications) update.
* **BREAKING**: `CKNotification.builder`'s `badge` is now `String?`.
* **BREAKING**: `CKNotification.builder`'s `vibrate` is now `List<int>?`.
* **BREAKING**: minimum Flutter constraint `>=3.22.0`.

## 0.0.4+1

* Update documentation

## 0.0.4

* Add `strictMode` to `CKConfiguration`
* Fix(web): Instance duplication on getting singleton in web implementation. 
* update docs

## 0.0.3+1

* BREAKING CHANGE: Use `WebCallKitWeb` instead of `WebCallKit`.
* update docs

## 0.0.3

* BREAKING CHANGE: Update Callkit Models & Enums with `CK` prefix
* Fix: notifications not always showing [js_notifications #6af62f](https://github.com/cybex-dev/js_notifications/commit/6af62f54b8924bc9d41c88d714efb43b9dd86138)
* Update: call state disconnect reponses
* Fix: calls remaining in `CallManager` after call ends
* Fix: duplicate plugin instances
* Refactor & rework managers & plugin
* Add notification icon support
* Update docs

## 0.0.2+1

* Add browser permission check
* Update changelog

## 0.0.2

* Rework Notification Manager
* Updated call notification API
* Added CallkitCapability, CallState and CallActions
* Add call timer
* Added & update documentation
* Update example

## 0.0.1

* Initial Commit
