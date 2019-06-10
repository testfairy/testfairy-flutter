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
* `enableVideo`
* `disableVideo`
* `bringFlutterToFront`

## Supported by only Android

TestFairy iOS SDK does not have corresponding Objective-C interface for these integrations.

* `setFeedbackOptions`

## Not supported by any platform

These are waiting updates to native SDKs. Dart functionality is already implemented.

* `enableVideo`
* `disableVideo`
* `takeScreenshot`
* `hideView`