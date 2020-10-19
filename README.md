# TestFairy-Flutter integration

This is TestFairy integration for Flutter, bundles with the native SDK. 

## Installation
Read installation docs at [pub.dartlang.org](https://pub.dartlang.org/packages/testfairy#-installing-tab-)

## Quick Start
Include the library and run your main app like this. 

Make sure your project is [AndroidX](https://flutter.dev/docs/development/androidx-migration) compatible. 

Minimum supported iOS target is 9.0.

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
  HttpOverrides.global = TestFairy.httpOverrides();

  runZonedGuarded(
    () async {
      try {
        FlutterError.onError =
            (details) => TestFairy.logError(details.exception);

        // Call `await TestFairy.begin()` or any other setup code here.

        runApp(TestFairyGestureDetector(child: TestfairyExampleApp()));
      } catch (error) {
        TestFairy.logError(error);
      }
    },
    (e, s) {
      TestFairy.logError(e);
    },
    zoneSpecification: new ZoneSpecification(
      print: (self, parent, zone, message) {
        TestFairy.log(message);
      },
    )
  );
}
```

### How to update native SDKs?
Run `pod repo update` and update the plugin in *pubspec.yaml*. Then run `cd ios; pod update TestFairy; cd..`.

### How to opt-out from Dart 2?
Starting from 2.0.0, *testfairy* will only work with projects that use Dart 2 as the development language. If you'd like to keep using legacy Dart, you may choose the following version.

```
dependencies:
  testfairy: ^1.0.25
```

### How to compile with latest unreleased Flutter?

Flutter's master channel introduces new Dart syntax and has breaking changes in its SDK classes. These changes will show up similar to the following error when you compile your project.

```
../pub.dartlang.org/testfairy-1.x.y/lib/src/network_logging.dart:253:7: 
            Error: The non-abstract class '_TestFairyClientHttpRequest' is missing implementations for these members:

     - HttpClientRequest.abort

    Try to either
     - provide an implementation,
     - inherit an implementation from a superclass or mixin,
     - mark the class as abstract, or
     - provide a 'noSuchMethod' implementation.

    class _TestFairyClientHttpRequest implements HttpClientRequest {
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^
    org-dartlang-sdk:///third_party/dart/sdk/lib/_http/http.dart:2045:8: Context: 'HttpClientRequest.abort' is defined here.
      void abort([Object? exception, StackTrace? stackTrace]);
           ^^^^^
```

In order to use TestFairy with the latest unstable Flutter, you must clone this repo and use it as an offline dependency instead of the published version in pub.

1. Clone this [repo](https://github.com/testfairy/testfairy-flutter).

2. Use the following code to include the clone as an offline dependency (assuming both projects reside in the same directory as siblings).

```yaml
dependencies:
  testfairy:
    path: ../testfairy-flutter # or "./testfairy-flutter" if you cloned it inside your main project as a child directory 
```

3. Launch a terminal and run the following commands.

```bash
cd path/to/testfairy-flutter
sed  "s/Modern Flutter \*\*/\//" lib/src/network_logging.dart > lib/src/network_logging.temp
sed  "s/\*\* Modern Flutter/\//" lib/src/network_logging.temp > lib/src/network_logging.dart
rm -rf lib/src/network_logging.temp
```

4. Checkout **testfairy-flutter** to your VCS without including its **.git** directory.

5. When there is a new update in this repo, delete **testfairy-flutter** and retry the steps.

### Troubleshoot
1. **I see `Specs satisfying the TestFairy dependency were found, but they required a higher minimum deployment target.` when I build and iOS app.**

You have to update the native SDK alongside with CocoaPods repository.

Run `pod repo update` and update the plugin in *pubspec.yaml*. Then run `cd ios; pod update TestFairy; cd..`.

2. **I have my own `HttpOverrides.global` setup. How can I make it work with TestFairy?**

Copy [this](https://github.com/testfairy/testfairy-flutter/blob/master/lib/src/network_logging.dart) file to your project. Add the necessary functionality and assign to `HttpOverrides.global` an instance from your new implementation.

3. **I see `Errno::ENOENT - No such file or directory @ rb_sysopen - ./ios/Pods/Local Podspecs/testfairy.podspec.json` when I build an iOS app.**

This happens due to a pod misconfiguration bug on the Flutter side. We have [a blog post](https://blog.testfairy.com/errnoenoent-fix-for-flutter-ios/) explaining the fix.

Clean your project, remove *ios/Podfile* and Xcode workspace file entirely. (make sure you have backups just in case)
```
flutter clean
rm -rf ios/Podfile ios/Podfile.lock pubspec.lock ios/Pods ios/Runner.xcworkspace
```

Revert to **cocoapods 1.7.5** temporarily.
```
gem uninstall cocoapods
gem install cocoapods -v 1.7.5
```

Add the following line to the beginning of your iOS project's generated Podfile.
```
# Beginning of file
use_frameworks!

# The rest of the file contents
# ...
```

Install pods.
```
pod repo update
cd ios
pod install
cd ..
```

Retry your build.

Once your build is successful, you can update cocoapods back to its latest version. If the error reoccurs, you will have to revert back to 1.7.5 and retry the steps.

4. **I see `Automatically assigning platform `ios` with version `8.0`` when I build.**

TestFairy supports iOS 9.0 and above. Please change the build target accordingly in your Xcode project.

5. **I see `Looks like TestFairy has an upgrade to do... 1.X.Y+hotfixZ is the latest stable branch` or errors related to Jetifier in the logs when I call an SDK method.**

Migrate your Android project to AndroidX by following [this](https://flutter.dev/docs/development/androidx-migration) guide.

6. **I see `Undefined symbols for architecture` error during compilation.**

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

7. **CocoaPods could not find compatible versions for pod "TestFairy".**

This is an old bug in the plugin pubspec file. First, run `flutter clean` in your root directory. 

Please move *ios/Podfile.lock* into a temporary place before running `pod repo update; pod install` in your *ios* directory. 

If some of the libraries you use need to be at specific versions, copy the necessary lines from your backed up *Podfile.lock* into the newly created one. Please keep the lines related to TestFairy (note the title case in the name) untouched.

Finally, run `pod repo update; pod install; pod update TestFairy` again to re-download libraries from the replaced lines.

If everything went smoothly, this issue should never happen again.

8. **There are syntax errors in TestFairyFlutterPlugin.java or TestFairyFlutterPlugin.m file.**

In your project root, run `flutter clean; cd ios; pod repo update; pod install; pod update TestFairy; cd ..` and test again.

## Docs
[Go to docs...](https://pub.dartlang.org/documentation/testfairy/latest/)

## Credits

* This library incorporates code pieces derived from [@leishuai](https://github.com/leishuai)'s [flutter_widget_detector](https://github.com/leishuai/flutter_widget_detector) library.
