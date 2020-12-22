#!/usr/bin/env bash

set -x
set -e

pushd example
pushd android

# flutter build generates files in android/ for building the app
flutter build apk
./gradlew app:assembleAndroidTest
./gradlew app:assembleDebug -Ptarget=integration_test/app_integration_test.dart

popd
popd