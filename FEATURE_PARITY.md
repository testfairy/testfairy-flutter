# Feature Parity for Flutter Integration

## Supported by both Android and iOS

* `begin`
* `beginWithOptions`
* `setServerEndpoint`
* `getVersion`
* `sendUserFeedback`
* `addCheckpoint`
* `addEvent`
* `setCorrelationId`
* `identifyWithTraits`
* `identify`
* `setUserId`
* `setAttribute`
* `getSessionUrl`
* `showFeedbackForm`
* `stop`
* `resume`
* `pause`
* `log`
* `setScreenName`
* `didLastSessionCrash`
* `enableCrashHandler`
* `disableCrashHandler`
* `enableMetric`
* `disableMetric`
* `enableFeedbackForm`
* `disableFeedbackForm`
* `setMaxSessionLength`
* `bringFlutterToFront`

## Supported by only iOS

Android requires these to be reimplemented on the Dart side. iOS works normally.

* `enableVideo`
* `disableVideo`
* `takeScreenshot`

## Supported by only Android

TestFairy iOS SDK does not have corresponding Objective-C interface for these integrations.

* `setFeedbackOptions`
* `logError` - forwarded to `log` as a workaround in iOS

## Not supported by any platform
* `addNetworkEvent` - This requires research to eliminate all the edge cases.
* `hideView` - This needs to implemented on the Dart side entirely to be able to crawl the widget tree.
* Session and distribution status listeners are omitted by decision.