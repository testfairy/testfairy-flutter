#!/usr/bin/env bash

set -x
set -e

pushd example
pushd android

# flutter build generates files in android/ for building the app
flutter build apk
./gradlew app:assembleAndroidTest -Ptarget=`pwd`/../integration_test/app_integration_test.dart -Pdriver=`pwd`/../integration_test/app.dart
./gradlew app:assembleDebug -Ptarget=`pwd`/../integration_test/app_integration_test.dart -Pdriver=`pwd`/../integration_test/app.dart

popd
popd