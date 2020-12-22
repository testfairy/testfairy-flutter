#!/usr/bin/env bash

pushd example
pushd android

# flutter build generates files in android/ for building the app
flutter build apk --enable-experiment=non-nullable --no-sound-null-safety
./gradlew app:assembleAndroidTest
./gradlew app:assembleDebug -Ptarget=integration_test/app_integration_test.dart

popd
popd