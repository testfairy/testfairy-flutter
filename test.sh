#!/usr/bin/env bash

cd example
flutter drive --target=test_driver/app.dart
#flutter drive --target=integration_test/app_integration_test.dart --driver=integration_test/app.dart
cd ..
