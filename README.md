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
  runZoned(
    () async {
      try {
        FlutterError.onError = (details) => TestFairy.logError(details.exception);

        // Do any other SDK setup here
        await TestFairy.begin('TOKEN');

        runApp(TestfairyExampleApp());
      } catch (error) {
        TestFairy.logError(error);
      }
    },
    onError: TestFairy.logError,
    zoneSpecification: new ZoneSpecification(
      print: (self, parent, zone, message) => TestFairy.log(message)
    )
  );
}
```

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
* `bringFlutterToFront`

### Features supported by only iOS

* `enableVideo`
* `disableVideo`
* `takeScreenshot`

### Features supported by only Android

* `setFeedbackOptions`
* `logError`
 
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
3. Add `hideView` for both platforms. 
4. Add network logging for both platforms.
