# TestFairy-Flutter integration

This is TestFairy integration for Flutter, bundles with the native SDK. 

## Installation
Read installation docs at [pub.dartlang.org](https://pub.dartlang.org/packages/testfairy#-installing-tab-)

## Quick Start
Include the library and run your main app like this. Make sure your project is [AndroidX](https://flutter.dev/docs/development/androidx-migration) compatible.

```yaml
# inside pubspec.yaml

dependencies:
  testfairy: any
```

```dart
// inside your main.dart
import 'dart:async';
import 'dart:io';
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

If you need to update the native iOS SDK used by your current integration, run `pod repo update; pod install` in your *ios* directory.

### Troubleshoot
1. **I see `Looks like TestFairy has an upgrade to do... 1.X.Y+hotfixZ is the latest stable branch` or errors related to Jetifier in the logs when I call an SDK method.**

Migrate your Android project to AndroidX by following [this](https://flutter.dev/docs/development/androidx-migration) guide.

2. **I see `Undefined symbols for architecture` error during compilation.**

You must use frameworks and specify a platform version of at least `9.0` in your generated iOS project's Podfile. Please make the following changes in *ios/Podfile* and rebuild.

```
target 'Runner' do
  platform :ios, '9.0'   ####################################### <--- add this and specify at least 9.0

  use_frameworks!        ####################################### <--- add this, and try building if there is 
                         #######################################      no Swift code or plugin in the project.
                         #######################################      If there is Swift code, please also add 
                         #######################################      the marked line below

  ...
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['SWIFT_VERSION'] = '3.2'  ########## <--- add this, change the version to what's being
                                                      ##########      used in the project, remove if there is none
    end
  end
end
```

3. **CocoaPods could not find compatible versions for pod "TestFairy".**

This is an old bug in the plugin pubspec file. First, run `flutter clean` in your root directory. 

Please move *ios/Podfile.lock* into a temporary place before running `pod repo update; pod install` in your *ios* directory. 

If some of the libraries you use need to be at specific versions, copy the necessary lines from your backed up *Podfile.lock* into the newly created one. Please keep the lines related to TestFairy (note the title case in the name) untouched.

Finally, run `pod repo update; pod install; pod update TestFairy` again to re-download libraries from the replaced lines.

If everything went smoothly, this issue should never happen again.

4. **There are syntax errors in TestFairyFlutterPlugin.java or TestFairyFlutterPlugin.m file.**

In your project root, run `flutter clean; cd ios; pod repo update; pod install; pod update TestFairy; cd ..` and test again.

5. **My widget's are not hidden in screenshots.**

This is currently not supported in iOS and will be fixed in the next release.


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
* `enableVideo`
* `disableVideo`
* `takeScreenshot`
* `disableAutoUpdate`
* `hideWidget`

### Features supported by only Android

* `setFeedbackOptions`