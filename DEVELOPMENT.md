# Development
1. Install [Flutter](https://flutter.io/docs).
2. Connect an Android device.
3. Run `flutter packages get` in both root and *example* directory.
4. Run `./test.sh` in the main directory and wait for tests to complete. It will detect if an Android or iOS device/emulator/simulator is plugged.
5. (Optional) Run `./run.sh` and tap buttons to see what happens.
6. (Optional) Run `./profile.sh` in the main directory and tap around to benchmark.
7. Edit *example/lib/main.dart* and *example/test_driver/app_test.dart* to add a test case.
8. Edit *lib/testfairy.dart* to add more SDK integration.
9. Run `./docs.sh` to generate documentation for offline usage.

# Publish
1. Bump up versions in these files: *ios/testfairy.podspec*, *android/build.gradle*, *pubspec.yaml*, *example/pubspec.yaml*, *CHANGELOG.md*.
2. Publish to pub.
