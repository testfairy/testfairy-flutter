# testfairy
TestFairy integration for Flutter, bundles with the native SDK. 

## Installation
[See details...](https://pub.dartlang.org/packages/testfairy#-installing-tab-)

## Quick Start
Include the library and run your main app like this.

```yaml
# inside pubspec.yaml

dependencies:
  testfairy: any
```

```dart
// inside your main.dart

import 'package:testfairy/testfairy.dart';

void main() {
    HttpOverrides.runWithHttpOverrides(
         () async {
           try {
             // Enables widget error logging
             FlutterError.onError =
                 (details) => TestFairy.logError(details.exception);
   
             // Initializes a session
             await TestFairy.begin(TOKEN);
   
             // Runs your app
             runApp(TestfairyExampleApp());
           } catch (error) {
   
             // Logs synchronous errors
             TestFairy.logError(error);
   
           }
         },
   
         // Logs network events
         TestFairy.httpOverrides(),
   
         // Logs asynchronous errors
         onError: TestFairy.logError,
   
         // Logs console messages
         zoneSpecification: new ZoneSpecification(
           print: (self, parent, zone, message) {
             TestFairy.log(message);
           },
         )
     );
}
```

### How to update native SDKs?
This is done automatically for Android. 

If you want to update the native iOS SDK used by this integration, run `pod install` in your *ios* directory. This will fix all the syntax errors in *TestFairyFlutterPlugin.m* file if there is any due to an update.

## Docs
[Go to docs...](https://pub.dartlang.org/documentation/testfairy/latest/)

### Features supported by both Android and iOS

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

### Features supported by only Android

* `setFeedbackOptions`

### Features not supported by any platform yet

* `enableVideo`
* `disableVideo`
* `takeScreenshot`
 
## Development
1. Install [Flutter](https://flutter.io/docs).
2. Connect an Android device.
3. Run `flutter packages get` in both root and *example* folder.
4. Run `./test.sh` in the main folder and wait for tests to complete.
5. (Optional) Run `./run.sh` and tap buttons to see what happens.
6. (Optional) Run `./profile.sh` in the main folder and tap around to benchmark.
7. Edit *example/lib/main.dart* and *example/test_driver/app_test.dart* to add a test case.
8. Edit *lib/testfairy_flutter.dart* to add more SDK integration.
9. Run `./docs.sh` to generate documentation for offline usage.

## TODO
1. Add video and screenshot support on Android.
2. Add feedback options support for iOS.
