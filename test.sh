#!/usr/bin/env bash

cd example

# Test with test_driver (all platforms)
flutter drive --target=test_driver/app.dart

# Test with integration_test (all platforms)
#flutter drive --target=integration_test/app_integration_test.dart --driver=integration_test/app.dart

# Test with integration_test standalone (android)
# cd android
#./gradlew app:connectedAndroidTest -Ptarget=`pwd`/../integration_test/app_integration_test.dart -Pdriver=`pwd`/../integration_test/app.dart
# cd ..

cd ..
